import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/ledger_repository.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/models/journal_entry.dart';
import '../../../../domain/models/transaction_direction.dart';
import 'register_row.dart';

/// All UI state and orchestration lives here. Extends ChangeNotifier.
/// Never touches Drift directly - only calls Repository methods. Rebuilds
/// automatically as the Repository's reactive streams emit; no manual
/// refresh is ever needed (smara-architecture.md's Data Flow).
class RegisterViewModel extends ChangeNotifier {
  RegisterViewModel({required LedgerRepository ledgerRepository})
    : _ledgerRepository = ledgerRepository {
    _entriesSubscription = _ledgerRepository.watchEntries().listen(_onEntries);
    _categoriesSubscription = _ledgerRepository
        .watchCategories(includeArchived: true)
        .listen(_onCategories);
  }

  final LedgerRepository _ledgerRepository;
  late final StreamSubscription<List<JournalEntry>> _entriesSubscription;
  late final StreamSubscription<List<Account>> _categoriesSubscription;

  List<JournalEntry> _entries = const [];
  Map<String, Account> _categoriesById = const {};

  List<RegisterRow> _rows = const [];
  List<RegisterRow> get rows => _rows;

  bool get isLoading => _categoriesById.isEmpty && _entries.isEmpty;

  void _onEntries(List<JournalEntry> entries) {
    _entries = entries;
    _recompute();
  }

  void _onCategories(List<Account> categories) {
    _categoriesById = {for (final c in categories) c.id: c};
    _recompute();
  }

  void _recompute() {
    var runningBalance = 0;
    final rows = <RegisterRow>[];
    for (final entry in _entries) {
      if (entry.postings.length != 2) continue;
      final categoryPosting = entry.postings.firstWhere(
        (p) => _categoriesById.containsKey(p.accountId),
        orElse: () => entry.postings.first,
      );
      final assetPosting = entry.postings.firstWhere(
        (p) => p.accountId != categoryPosting.accountId,
        orElse: () => entry.postings.last,
      );

      if (entry.isVerified && !entry.isSupersededByMigration) {
        runningBalance += assetPosting.amountMinor;
      }
      rows.add(
        RegisterRow(
          entryId: entry.id,
          categoryName: _categoriesById[categoryPosting.accountId]?.name ?? '',
          direction: assetPosting.amountMinor >= 0
              ? TransactionDirection.moneyIn
              : TransactionDirection.moneyOut,
          amountMinor: assetPosting.amountMinor.abs(),
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

  Future<void> reverseEntry(String entryId) =>
      _ledgerRepository.reverseEntry(entryId);

  @override
  void dispose() {
    _entriesSubscription.cancel();
    _categoriesSubscription.cancel();
    super.dispose();
  }
}
