import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/database/tables/accounts_table.dart';
import '../../../../data/repositories/ledger_repository.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/models/journal_entry.dart';
import '../../../../domain/models/transaction_direction.dart';
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
    if (initialAccountId != null) {
      _selectedAccountId = initialAccountId;
      _resubscribeEntries();
    }
  }

  final LedgerRepository _ledgerRepository;
  late final StreamSubscription<List<Account>> _accountsSubscription;
  StreamSubscription<List<JournalEntry>>? _entriesSubscription;

  List<Account> _accounts = const [];
  Map<String, Account> _accountsById = const {};
  Map<String, Account> _categoriesById = const {};

  String? _selectedAccountId;
  String? get selectedAccountId => _selectedAccountId;

  List<RegisterRow> _rows = const [];
  List<RegisterRow> get rows => _rows;

  List<Account> get accounts => _accounts;

  bool get isLoading => _accounts.isEmpty;

  void selectAccount(String accountId) {
    if (_selectedAccountId == accountId) return;
    _selectedAccountId = accountId;
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

    var runningBalance = 0;
    final rows = <RegisterRow>[];
    for (final entry in entries) {
      final ownPosting = entry.postings.firstWhere(
        (p) => p.accountId == accountId,
      );
      final other = entry.postings.firstWhere(
        (p) => p.accountId != accountId,
        orElse: () => ownPosting,
      );

      final counterpartName = _counterpartLabel(other.accountId);
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
        ),
      );
    }
    _rows = rows;
    notifyListeners();
  }

  String _counterpartLabel(String accountId) {
    if (accountId == openingBalanceEquityAccountId) {
      return 'Opening balance';
    }
    final category = _categoriesById[accountId];
    if (category != null) return category.name;
    final other = _accountsById[accountId];
    if (other != null) return 'Transfer: ${other.name}';
    return 'Transfer';
  }

  Future<void> reverseEntry(String entryId) =>
      _ledgerRepository.reverseEntry(entryId);

  @override
  void dispose() {
    _accountsSubscription.cancel();
    _entriesSubscription?.cancel();
    super.dispose();
  }
}
