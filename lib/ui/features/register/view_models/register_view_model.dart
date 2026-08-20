import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/database/tables/accounts_table.dart';
import '../../../../data/repositories/ledger_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../l10n/l10n.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/models/account_group.dart';
import '../../../../domain/models/journal_entry.dart';
import '../../../../domain/models/transaction_direction.dart';
import '../../../core/money_formatter.dart';
import 'register_row.dart';

/// Account-scoped register: counterpart labels for category / transfer /
/// opening balance; running display balance for the viewed account.
class RegisterViewModel extends ChangeNotifier {
  RegisterViewModel({
    required LedgerRepository ledgerRepository,
    String? initialAccountId,
  }) : _ledgerRepository = ledgerRepository {
    _accountsSubscription = _ledgerRepository
        .watchFinancialAccounts(includeArchived: true)
        .listen(_onAccounts);
    _groupsSubscription = _ledgerRepository
        .watchAccountGroups(includeArchived: true)
        .listen((groups) {
          _groups = groups;
          notifyListeners();
        });
    if (initialAccountId != null) {
      _selectedAccountId = initialAccountId;
      _resubscribeEntries();
    }
  }

  final LedgerRepository _ledgerRepository;
  late final StreamSubscription<List<Account>> _accountsSubscription;
  late final StreamSubscription<List<AccountGroup>> _groupsSubscription;
  StreamSubscription<List<JournalEntry>>? _entriesSubscription;

  List<Account> _accounts = const [];
  Map<String, Account> _accountsById = const {};
  Map<String, Account> _categoriesById = const {};
  List<AccountGroup> _groups = const [];

  String? _selectedAccountId;
  String? get selectedAccountId => _selectedAccountId;

  List<RegisterRow> _rows = const [];

  /// register-search: a client-side narrowing of [_rows] (design.md
  /// Decision 1 - no new repository query for v1). [_rows] itself always
  /// stays the full, unfiltered set so clearing search/filters restores
  /// everything with no resubscription needed.
  List<RegisterRow> get rows {
    if (!hasActiveSearchOrFilters) return _rows;
    final query = _searchText.trim().toLowerCase();
    return _rows.where((row) {
      if (_filterDirection != null && row.direction != _filterDirection) {
        return false;
      }
      if (_filterStartDate != null &&
          row.transactionDate.isBefore(_filterStartDate!)) {
        return false;
      }
      if (_filterEndDate != null) {
        final endExclusive = DateTime(
          _filterEndDate!.year,
          _filterEndDate!.month,
          _filterEndDate!.day + 1,
        );
        if (!row.transactionDate.isBefore(endExclusive)) return false;
      }
      if (query.isEmpty) return true;
      final description = (row.description ?? '').toLowerCase();
      final category = row.categoryName.toLowerCase();
      final amountText = formatAmountMinor(
        row.amountMinor,
        row.currency,
      ).toLowerCase();
      return description.contains(query) ||
          category.contains(query) ||
          amountText.contains(query);
    }).toList();
  }

  String _searchText = '';
  String get searchText => _searchText;

  DateTime? _filterStartDate;
  DateTime? get filterStartDate => _filterStartDate;
  DateTime? _filterEndDate;
  DateTime? get filterEndDate => _filterEndDate;

  TransactionDirection? _filterDirection;
  TransactionDirection? get filterDirection => _filterDirection;

  bool get hasActiveSearchOrFilters =>
      _searchText.trim().isNotEmpty ||
      _filterStartDate != null ||
      _filterEndDate != null ||
      _filterDirection != null;

  void setSearchText(String value) {
    _searchText = value;
    notifyListeners();
  }

  void setDateRangeFilter({DateTime? start, DateTime? end}) {
    _filterStartDate = start;
    _filterEndDate = end;
    notifyListeners();
  }

  void setDirectionFilter(TransactionDirection? direction) {
    _filterDirection = direction;
    notifyListeners();
  }

  void clearSearchAndFilters() {
    _searchText = '';
    _filterStartDate = null;
    _filterEndDate = null;
    _filterDirection = null;
    notifyListeners();
  }

  List<Account> get accounts => _accounts;

  bool get isLoading => _accounts.isEmpty;

  bool get isSelectedAccountArchived =>
      _accountsById[_selectedAccountId]?.archived ?? false;

  /// credit-card-household-flow: offers a "Pay card" shortcut when true
  /// and the account is still active (an archived card uses the
  /// existing closeout flow instead, not "Pay card").
  bool get isSelectedAccountCreditCard =>
      _accountsById[_selectedAccountId]?.isCreditCard ?? false;

  /// Current display balance of the selected account, from the newest
  /// register row's running balance (oldest-to-newest accumulation).
  int get selectedAccountBalanceMinor =>
      _rows.isEmpty ? 0 : _rows.first.runningBalanceMinor;

  bool get canCloseoutSelectedAccount =>
      isSelectedAccountArchived && selectedAccountBalanceMinor > 0;

  /// Active financial accounts other than the one currently selected.
  List<Account> get closeoutDestinationCandidates => _accounts
      .where((a) => !a.archived && a.id != _selectedAccountId)
      .toList();

  String? currencyFor(String? accountId) {
    final account = _accountsById[accountId];
    if (account?.groupId == null) return null;
    return _groups
        .where((g) => g.id == account!.groupId)
        .cast<AccountGroup?>()
        .firstWhere((g) => g != null, orElse: () => null)
        ?.currency;
  }

  bool isCloseoutCrossCurrency(String? toAccountId) {
    final from = currencyFor(_selectedAccountId);
    final to = currencyFor(toAccountId);
    return from != null && to != null && from != to;
  }

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  void selectAccount(String accountId) {
    if (_selectedAccountId == accountId) return;
    _selectedAccountId = accountId;
    _searchText = '';
    _filterStartDate = null;
    _filterEndDate = null;
    _filterDirection = null;
    _resubscribeEntries();
    notifyListeners();
  }

  void _onAccounts(List<Account> accounts) {
    _accounts = accounts;
    _accountsById = {for (final a in accounts) a.id: a};
    if (_selectedAccountId == null && accounts.isNotEmpty) {
      final active = accounts.where((a) => !a.archived).toList();
      _selectedAccountId = (active.isNotEmpty ? active : accounts).first.id;
      _resubscribeEntries();
    }
    _ledgerRepository.watchCategories(includeArchived: true).first.then((cats) {
      _categoriesById = {for (final c in cats) c.id: c};
      _recompute(_lastEntries);
    });
    notifyListeners();
  }

  List<JournalEntry> _lastEntries = const [];

  void _resubscribeEntries() {
    _entriesSubscription?.cancel();
    final id = _selectedAccountId;
    if (id == null) return;
    _entriesSubscription = _ledgerRepository.watchEntriesForAccount(id).listen((
      entries,
    ) {
      _lastEntries = entries;
      _recompute(entries);
    });
  }

  void _recompute(List<JournalEntry> entries) {
    final accountId = _selectedAccountId;
    if (accountId == null) {
      _rows = const [];
      notifyListeners();
      return;
    }
    final account = _accountsById[accountId];
    if (account == null) {
      _rows = const [];
      notifyListeners();
      return;
    }

    // Null only for a group mid-migration awaiting currency backfill - the
    // router already forces that prompt before Register is reachable, so
    // this fallback is a harmless default for a window never actually seen.
    final rowCurrency = currencyFor(accountId) ?? 'USD';
    var runningBalance = 0;
    final rows = <RegisterRow>[];
    for (final entry in entries) {
      final ownPosting = entry.postings.firstWhere(
        (p) => p.accountId == accountId,
      );
      // split-transactions: an entry can have more than one non-financial-
      // account posting (one per category leg) - collect all of them, not
      // just the first, so a split's row label reflects every category.
      final others = entry.postings
          .where((p) => p.accountId != accountId)
          .toList();
      final counterpartIds = others.isEmpty
          ? [ownPosting.accountId]
          : others.map((p) => p.accountId).toList();

      final counterpartName = _counterpartLabel(counterpartIds);
      final delta = LedgerRepository.displayBalanceDeltaFor(
        accountType: account.type,
        postingAmountMinor: ownPosting.amountMinor,
      );

      if (entry.isVerified && !entry.isSupersededByMigration) {
        runningBalance += delta;
      }

      rows.add(
        RegisterRow(
          entryId: entry.id,
          categoryName: counterpartName,
          counterpartAccountIds: counterpartIds,
          currency: rowCurrency,
          // Sign relative to the viewed account's *display* balance, not
          // the raw posting - for a liability, those are inverted (Option
          // A: a purchase posts -amount raw but increases what's owed),
          // and the row must agree with the running balance shown right
          // next to it.
          direction: delta >= 0
              ? TransactionDirection.moneyIn
              : TransactionDirection.moneyOut,
          amountMinor: delta.abs(),
          transactionDate: entry.transactionDate,
          description: entry.description,
          runningBalanceMinor: runningBalance,
          isReversal: entry.reversesEntryId != null,
          isVerified: entry.isVerified,
          breakReason: entry.breakReason,
          isSupersededByMigration: entry.isSupersededByMigration,
        ),
      );
    }
    // Balance accumulates oldest-to-newest above (the only order that math
    // works in); the register itself displays newest first so a new entry
    // and the current balance are visible without scrolling.
    _rows = rows.reversed.toList();
    notifyListeners();
  }

  /// [accountIds] is normally one id; more than one only for a
  /// split-transactions entry, summarized as "first name +N more" rather
  /// than silently showing only the first category (design.md Decision 3).
  String _counterpartLabel(List<String> accountIds) {
    final names = accountIds.map(_singleCounterpartLabel).toList();
    if (names.length <= 1) {
      return names.isEmpty ? englishAppLocalizations.actionTransfer : names.first;
    }
    return englishAppLocalizations.splitCounterpartMore(
      names.first,
      '${names.length - 1}',
    );
  }

  String _singleCounterpartLabel(String accountId) {
    if (accountId == openingBalanceEquityAccountId) {
      return englishAppLocalizations.openingBalance;
    }
    final category = _categoriesById[accountId];
    if (category != null) return category.name;
    final other = _accountsById[accountId];
    if (other != null) {
      return englishAppLocalizations.transferToName(other.name);
    }
    return englishAppLocalizations.actionTransfer;
  }

  Future<void> reverseEntry(String entryId) =>
      _ledgerRepository.reverseEntry(entryId);

  /// Whether [row] can go through the Fix flow (fix-this-correction-wizard):
  /// only an ordinary, currently-verified, single-category transaction -
  /// its one counterpart must be a category, not a transfer counterparty,
  /// the opening-balance equity account, or (split-transactions) more
  /// than one category leg, since the Fix form has exactly one category
  /// field to prefill. It must also not already be a reversal,
  /// quarantined, superseded, or already corrected by a later reversal
  /// (those are explained some other way, not re-fixed).
  bool isRowFixable(RegisterRow row) {
    final alreadyCorrected = _lastEntries.any(
      (entry) => entry.reversesEntryId == row.entryId,
    );
    return row.counterpartAccountIds.length == 1 &&
        _categoriesById.containsKey(row.counterpartAccountIds.single) &&
        !row.isReversal &&
        !alreadyCorrected &&
        row.isVerified &&
        !row.isSupersededByMigration;
  }

  /// Posts the selected archived account's full current display balance
  /// to [toAccountId] (spec: "Closeout Transfer Is Offered From the
  /// Archived Account Register"). Domain exceptions are stored on
  /// [errorMessage] without changing [selectedAccountId].
  Future<bool> closeoutSelectedAccount({
    required String toAccountId,
    required DateTime transactionDate,
    String? description,
    int? destinationAmountMinor,
  }) async {
    final fromAccountId = _selectedAccountId;
    if (fromAccountId == null) return false;
    _errorMessage = null;
    notifyListeners();
    try {
      await _ledgerRepository.recordArchivedAccountCloseoutTransfer(
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        transactionDate: transactionDate,
        description: description,
        destinationAmountMinor: destinationAmountMinor,
      );
      notifyListeners();
      return true;
    } on AccountGroupException catch (error) {
      _errorMessage = localizeVmError(error);
      notifyListeners();
      return false;
    } on InvalidTransferException catch (error) {
      _errorMessage = localizeVmError(error);
      notifyListeners();
      return false;
    }
  }

  /// The selected account's transactions between [start] and [end] as a
  /// CSV string (ledger-data-export spec: "Ledger Data Export"), or null
  /// with [errorMessage] set on failure. Saving the returned string to a
  /// file is the caller's responsibility - this ViewModel doesn't touch
  /// the filesystem.
  Future<String?> exportCsv({
    required DateTime start,
    required DateTime end,
  }) async {
    final accountId = _selectedAccountId;
    if (accountId == null) return null;
    _errorMessage = null;
    try {
      final csv = await _ledgerRepository.exportLedgerCsv(
        financialAccountId: accountId,
        start: start,
        end: end,
      );
      notifyListeners();
      return csv;
    } on AccountGroupException catch (error) {
      _errorMessage = localizeVmError(error);
      notifyListeners();
      return null;
    }
  }

  @override
  void dispose() {
    _accountsSubscription.cancel();
    _groupsSubscription.cancel();
    _entriesSubscription?.cancel();
    super.dispose();
  }
}
