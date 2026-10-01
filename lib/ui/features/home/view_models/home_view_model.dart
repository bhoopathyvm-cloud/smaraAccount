import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/instrument_quote_refresh.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/investment_repository.dart';
import '../../../../data/repositories/ledger_repository.dart';
import '../../../../data/repositories/membership_repository.dart';
import '../../../../data/repositories/recurring_template_repository.dart';
import '../../../../data/repositories/settings_repository.dart';
import '../../../../domain/backup/backup_reminder_policy.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/models/home_overview.dart';
import '../../../../domain/models/instrument.dart';
import '../../../../domain/models/journal_entry.dart';
import '../../../../domain/models/membership_notice.dart';
import '../../../../domain/models/recurring_template.dart';
import '../../../../domain/models/summary.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required LedgerRepository ledgerRepository,
    required CategoryRepository categoryRepository,
    required RecurringTemplateRepository recurringTemplateRepository,
    required InvestmentRepository investmentRepository,
    SettingsRepository? settingsRepository,
    MembershipRepository? membershipRepository,
    InstrumentQuoteRefresh? quoteRefresh,
    bool refreshInstrumentQuotes = true,
    DateTime Function()? clock,
    this.booksGeneration = 0,
  }) : _ledgerRepository = ledgerRepository,
       _categoryRepository = categoryRepository,
       _recurringTemplateRepository = recurringTemplateRepository,
       _investmentRepository = investmentRepository,
       _settingsRepository = settingsRepository,
       _membershipRepository = membershipRepository,
       _clock = clock ?? DateTime.now,
       _quoteRefresh =
           quoteRefresh ??
           (!refreshInstrumentQuotes || settingsRepository == null
               ? null
               : InstrumentQuoteRefresh(
                   settingsRepository: settingsRepository,
                   investmentRepository: investmentRepository,
                 )) {
    _subscription = _ledgerRepository.watchHomeOverview().listen((overview) {
      _overview = overview;
      _isLoading = false;
      notifyListeners();
    });
    final now = DateTime.now();
    final firstOfMonth = DateTime(now.year, now.month, 1);
    final lastOfMonth = DateTime(now.year, now.month + 1, 0);
    _categoryTotalsSubscription = _categoryRepository
        .watchCategoryTotals(start: firstOfMonth, end: lastOfMonth)
        .listen((totals) {
          _categoryTotals = totals;
          notifyListeners();
        });
    _dueTemplatesSubscription = _recurringTemplateRepository
        .watchDueRecurringTemplates()
        .listen((due) {
          _dueTemplates = due;
          notifyListeners();
        });
    // monthly-category-limits: additive surfacing on this section, if it
    // exists (design.md Decision 2) - just enough of watchCategories to
    // look up a limited Expense category's limit by id.
    _categoriesSubscription = _categoryRepository.watchCategories().listen((
      categories,
    ) {
      _limitByCategoryId = {
        for (final category in categories)
          if (category.monthlyLimitMinor != null)
            category.id: category.monthlyLimitMinor!,
      };
      notifyListeners();
    });
    if (_quoteRefresh != null) {
      _instrumentsSubscription = _investmentRepository
          .watchInstruments()
          .listen((instruments) {
            _instruments = instruments;
            unawaited(_refreshQuotes());
          });
      _quoteTimer = Timer.periodic(const Duration(minutes: 5), (_) {
        unawaited(_refreshQuotes());
      });
    }
    if (_settingsRepository != null) {
      _entriesSubscription = _ledgerRepository.watchEntries().listen((entries) {
        _entryCount = entries.length;
        _firstEntryAt = _earliestEntryDate(entries);
        unawaited(_refreshReminder());
      });
    }
    if (_membershipRepository != null) {
      unawaited(_refreshMembershipNotices());
    }
  }

  final LedgerRepository _ledgerRepository;
  final CategoryRepository _categoryRepository;
  final RecurringTemplateRepository _recurringTemplateRepository;
  final InvestmentRepository _investmentRepository;
  final SettingsRepository? _settingsRepository;
  final MembershipRepository? _membershipRepository;
  final DateTime Function() _clock;
  final InstrumentQuoteRefresh? _quoteRefresh;

  /// Books-set generation this ViewModel was built for; DI recreates when
  /// [ActiveBooksSession.generation] advances after a switch.
  final int booksGeneration;
  late final StreamSubscription<HomeOverview> _subscription;
  late final StreamSubscription<List<CategoryTotal>>
  _categoryTotalsSubscription;
  late final StreamSubscription<List<DueRecurringTemplate>>
  _dueTemplatesSubscription;
  late final StreamSubscription<List<Account>> _categoriesSubscription;
  StreamSubscription<List<Instrument>>? _instrumentsSubscription;
  StreamSubscription<List<JournalEntry>>? _entriesSubscription;
  Timer? _quoteTimer;
  List<Instrument> _instruments = const [];

  int _entryCount = 0;
  DateTime? _firstEntryAt;
  bool _showBackupReminder = false;
  bool get showBackupReminder => _showBackupReminder;

  List<MembershipNotice> _membershipNotices = const [];
  List<MembershipNotice> get membershipNotices => _membershipNotices;

  Future<void> _refreshMembershipNotices() async {
    final membership = _membershipRepository;
    if (membership == null) {
      _membershipNotices = const [];
      notifyListeners();
      return;
    }
    _membershipNotices = await membership.listNotices(unreadOnly: true);
    notifyListeners();
  }

  /// Reloads unread membership notices (e.g. after a sync or Settings visit).
  Future<void> refreshMembershipNotices() => _refreshMembershipNotices();

  Future<void> acknowledgeMembershipNotice(String noticeId) async {
    final membership = _membershipRepository;
    if (membership == null) return;
    await membership.acknowledgeNotice(noticeId);
    await _refreshMembershipNotices();
  }

  DateTime? _earliestEntryDate(List<JournalEntry> entries) {
    if (entries.isEmpty) return null;
    return entries
        .map((e) => e.transactionDate)
        .reduce((a, b) => a.isBefore(b) ? a : b);
  }

  Future<void> _refreshReminder() async {
    final settings = _settingsRepository;
    if (settings == null) {
      _showBackupReminder = false;
      notifyListeners();
      return;
    }
    final enabled = await settings.isBackupReminderEnabled();
    final lastCopy = await settings.lastCopySavedAt();
    final entryCountAtLastCopy = await settings.entryCountAtLastCopy();
    final snoozeUntil = await settings.snoozeUntil();
    final entryCountAtSnooze = await settings.entryCountAtSnooze();
    final reminderDays = await settings.backupReminderDays();
    final reminderEntries = await settings.backupReminderEntries();
    final snoozeEntries = await settings.backupReminderSnoozeEntries();

    _showBackupReminder = BackupReminderPolicy.shouldShow(
      enabled: enabled,
      now: _clock(),
      currentEntryCount: _entryCount,
      lastCopySavedAt: lastCopy,
      entryCountAtLastCopy: entryCountAtLastCopy,
      firstEntryAt: _firstEntryAt,
      snoozeUntil: snoozeUntil,
      entryCountAtSnooze: entryCountAtSnooze,
      reminderDays: reminderDays,
      reminderEntries: reminderEntries,
      snoozeEntries: snoozeEntries,
    );
    notifyListeners();
  }

  /// Re-evaluates reminder visibility (e.g. after returning from Settings).
  Future<void> refreshBackupReminder() => _refreshReminder();

  Future<void> snoozeBackupReminder() async {
    final settings = _settingsRepository;
    if (settings == null) return;
    final snoozeDays = await settings.backupReminderSnoozeDays();
    final until = _clock().add(Duration(days: snoozeDays));
    await settings.snoozeBackupReminder(until: until, entryCount: _entryCount);
    await _refreshReminder();
  }

  Future<void> _refreshQuotes() async {
    final refresh = _quoteRefresh;
    if (refresh == null) return;
    await refresh.refresh(_instruments);
  }

  Map<String, int> _limitByCategoryId = const {};

  /// This calendar month's limit for [categoryId], or null if it has
  /// none set (monthly-category-limits).
  int? monthlyLimitFor(String categoryId) => _limitByCategoryId[categoryId];

  List<DueRecurringTemplate> _dueTemplates = const [];

  /// Due recurring templates (recurring-templates), for a Home "DUE
  /// TODAY" section - recording one is a separate explicit action
  /// ([recordDueTemplate]), never automatic.
  List<DueRecurringTemplate> get dueTemplates => _dueTemplates;

  Future<void> recordDueTemplate(String templateId) {
    return _recurringTemplateRepository.recordDueTemplate(templateId);
  }

  HomeOverview? _overview;
  HomeOverview? get overview => _overview;

  List<CategoryTotal> _categoryTotals = const [];

  /// This calendar month's expense-category totals (home-hub-capture),
  /// highest-spending first.
  List<CategoryTotal> get thisMonthExpenseTotals {
    final totals = _categoryTotals.where((t) => !t.isIncome).toList()
      ..sort((a, b) => b.totalMinor.compareTo(a.totalMinor));
    return totals;
  }

  /// This calendar month's income-category totals (home-hub-capture),
  /// highest-received first.
  List<CategoryTotal> get thisMonthIncomeTotals {
    final totals = _categoryTotals.where((t) => t.isIncome).toList()
      ..sort((a, b) => b.totalMinor.compareTo(a.totalMinor));
    return totals;
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  @override
  void dispose() {
    _subscription.cancel();
    _categoryTotalsSubscription.cancel();
    _dueTemplatesSubscription.cancel();
    _categoriesSubscription.cancel();
    _instrumentsSubscription?.cancel();
    _entriesSubscription?.cancel();
    _quoteTimer?.cancel();
    super.dispose();
  }
}
