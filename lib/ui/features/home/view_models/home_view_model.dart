import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/instrument_quote_refresh.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/ledger_repository.dart';
import '../../../../data/repositories/settings_repository.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/models/home_overview.dart';
import '../../../../domain/models/instrument.dart';
import '../../../../domain/models/recurring_template.dart';
import '../../../../domain/models/summary.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({
    required LedgerRepository ledgerRepository,
    required CategoryRepository categoryRepository,
    SettingsRepository? settingsRepository,
    InstrumentQuoteRefresh? quoteRefresh,
  }) : _ledgerRepository = ledgerRepository,
       _categoryRepository = categoryRepository,
       _quoteRefresh =
           quoteRefresh ??
           (settingsRepository == null
               ? null
               : InstrumentQuoteRefresh(
                   settingsRepository: settingsRepository,
                   ledgerRepository: ledgerRepository,
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
    _dueTemplatesSubscription = _ledgerRepository
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
      _instrumentsSubscription = _ledgerRepository.watchInstruments().listen((
        instruments,
      ) {
        _instruments = instruments;
        unawaited(_refreshQuotes());
      });
      _quoteTimer = Timer.periodic(const Duration(minutes: 5), (_) {
        unawaited(_refreshQuotes());
      });
    }
  }

  final LedgerRepository _ledgerRepository;
  final CategoryRepository _categoryRepository;
  final InstrumentQuoteRefresh? _quoteRefresh;
  late final StreamSubscription<HomeOverview> _subscription;
  late final StreamSubscription<List<CategoryTotal>>
  _categoryTotalsSubscription;
  late final StreamSubscription<List<DueRecurringTemplate>>
  _dueTemplatesSubscription;
  late final StreamSubscription<List<Account>> _categoriesSubscription;
  StreamSubscription<List<Instrument>>? _instrumentsSubscription;
  Timer? _quoteTimer;
  List<Instrument> _instruments = const [];

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
    return _ledgerRepository.recordDueTemplate(templateId);
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
    _quoteTimer?.cancel();
    super.dispose();
  }
}
