import 'package:drift/drift.dart';

import '../../domain/exceptions.dart';
import '../../domain/models/account.dart';
import '../../domain/models/journal_entry.dart';
import '../../domain/models/posting.dart';
import '../../domain/models/summary.dart';
import '../../domain/models/transaction_direction.dart';
import '../database/app_database.dart';

/// The only layer that talks to Drift. Exposes domain models, never
/// Drift's generated row classes (smara-tech-guidelines.md). Every write
/// path (recordTransaction, reverseEntry) writes an entry and its postings
/// in a single Drift transaction. No updateEntry/deleteEntry method exists
/// anywhere on this class - immutability is enforced by omission
/// (Golden Rule #7).
class LedgerRepository {
  LedgerRepository({required AppDatabase database}) : _db = database;

  final AppDatabase _db;

  /// Reactive stream of the register: every posted entry with its
  /// postings, ordered chronologically by transaction date.
  Stream<List<JournalEntry>> watchEntries() {
    final query =
        _db.select(_db.journalEntries).join([
          leftOuterJoin(
            _db.postings,
            _db.postings.entryId.equalsExp(_db.journalEntries.id),
          ),
        ])..orderBy([
          OrderingTerm.asc(_db.journalEntries.transactionDate),
          OrderingTerm.asc(_db.journalEntries.createdAt),
          OrderingTerm.asc(_db.postings.lineNumber),
        ]);

    return query.watch().map(_groupIntoEntries);
  }

  List<JournalEntry> _groupIntoEntries(List<TypedResult> rows) {
    final entryRows = <String, JournalEntryRow>{};
    final postingsByEntry = <String, List<PostingRow>>{};

    for (final row in rows) {
      final entry = row.readTable(_db.journalEntries);
      entryRows[entry.id] = entry;
      final posting = row.readTableOrNull(_db.postings);
      if (posting != null) {
        postingsByEntry.putIfAbsent(entry.id, () => []).add(posting);
      }
    }

    return entryRows.values
        .map(
          (entry) =>
              _toDomainEntry(entry, postingsByEntry[entry.id] ?? const []),
        )
        .toList();
  }

  JournalEntry _toDomainEntry(
    JournalEntryRow entry,
    List<PostingRow> postings,
  ) {
    return JournalEntry(
      id: entry.id,
      transactionDate: DateTime.parse(entry.transactionDate),
      recordedAt: entry.recordedAt,
      description: entry.description,
      reversesEntryId: entry.reversesEntryId,
      postings: postings.map(_toDomainPosting).toList(),
    );
  }

  Posting _toDomainPosting(PostingRow row) {
    return Posting(
      id: row.id,
      entryId: row.entryId,
      accountId: row.accountId,
      amountMinor: row.amountMinor,
      lineNumber: row.lineNumber,
    );
  }

  /// Categories for pickers ([includeArchived] false, the default) or
  /// historical views ([includeArchived] true - never filters on
  /// archived_at). Never includes the single financial (asset) account.
  Stream<List<Account>> watchCategories({bool includeArchived = false}) {
    final query = _db.select(_db.accounts)
      ..where((a) => a.type.equalsValue(AccountType.asset).not())
      ..orderBy([(a) => OrderingTerm.asc(a.name)]);
    if (!includeArchived) {
      query.where((a) => a.archivedAt.isNull());
    }
    return query.watch().map((rows) => rows.map(_toDomainAccount).toList());
  }

  Account _toDomainAccount(AccountRow row) {
    return Account(
      id: row.id,
      name: row.name,
      type: row.type,
      archived: row.archivedAt != null,
    );
  }

  Future<AccountRow> _financialAccount() {
    return (_db.select(
      _db.accounts,
    )..where((a) => a.type.equalsValue(AccountType.asset))).getSingle();
  }

  /// Validates `amountMinor > 0`, derives the two postings, stamps
  /// recorded_at automatically via DateTime.now() (never user-supplied),
  /// and writes the entry + postings in one Drift transaction.
  Future<void> recordTransaction({
    required int amountMinor,
    required TransactionDirection direction,
    required String categoryId,
    required DateTime transactionDate,
    String? description,
  }) async {
    if (amountMinor <= 0) {
      throw InvalidTransactionAmountException(
        'Transaction amount must be positive and non-zero, got $amountMinor.',
      );
    }

    final financialAccount = await _financialAccount();
    final (assetAmount, categoryAmount) = switch (direction) {
      TransactionDirection.moneyIn => (amountMinor, -amountMinor),
      TransactionDirection.moneyOut => (-amountMinor, amountMinor),
    };

    await _db.transaction(() async {
      final entry = await _db
          .into(_db.journalEntries)
          .insertReturning(
            JournalEntriesCompanion.insert(
              transactionDate: _dateOnly(transactionDate),
              recordedAt: DateTime.now(),
              description: Value(description),
            ),
          );

      await _db
          .into(_db.postings)
          .insert(
            PostingsCompanion.insert(
              entryId: entry.id,
              accountId: financialAccount.id,
              amountMinor: assetAmount,
              lineNumber: 1,
            ),
          );
      await _db
          .into(_db.postings)
          .insert(
            PostingsCompanion.insert(
              entryId: entry.id,
              accountId: categoryId,
              amountMinor: categoryAmount,
              lineNumber: 2,
            ),
          );
    });
  }

  /// Inserts a new entry with swapped posting amounts, referencing
  /// [entryId] via reverses_entry_id, as an independent action with no
  /// required follow-up. The original entry is never modified.
  ///
  /// The reversal's transaction date is today (when the correction is
  /// actually performed), never backdated to the original entry's date -
  /// an auditable ledger should reflect when a correction really
  /// happened, not disguise it as having occurred earlier. A summary
  /// range spanning only the original entry's period will not show the
  /// correction netting out; a range covering today will.
  Future<void> reverseEntry(String entryId) async {
    final original = await (_db.select(
      _db.journalEntries,
    )..where((e) => e.id.equals(entryId))).getSingle();
    final originalPostings = await (_db.select(
      _db.postings,
    )..where((p) => p.entryId.equals(entryId))).get();

    await _db.transaction(() async {
      final reversal = await _db
          .into(_db.journalEntries)
          .insertReturning(
            JournalEntriesCompanion.insert(
              transactionDate: _dateOnly(DateTime.now()),
              recordedAt: DateTime.now(),
              reversesEntryId: Value(original.id),
            ),
          );

      for (final posting in originalPostings) {
        await _db
            .into(_db.postings)
            .insert(
              PostingsCompanion.insert(
                entryId: reversal.id,
                accountId: posting.accountId,
                amountMinor: -posting.amountMinor,
                lineNumber: posting.lineNumber,
              ),
            );
      }
    });
  }

  /// [type] must be [AccountType.income] or [AccountType.expense] - the
  /// single financial account is seeded once at onCreate and never
  /// created through this method.
  Future<void> addCategory({
    required String name,
    required AccountType type,
  }) async {
    if (type == AccountType.asset) {
      throw ArgumentError.value(type, 'type', 'must be income or expense');
    }
    await _db
        .into(_db.accounts)
        .insert(AccountsCompanion.insert(name: name, type: type));
  }

  Future<void> renameCategory({
    required String id,
    required String newName,
  }) async {
    await (_db.update(_db.accounts)..where((a) => a.id.equals(id))).write(
      AccountsCompanion(name: Value(newName)),
    );
  }

  Future<void> archiveCategory(String id) async {
    await (_db.update(_db.accounts)..where((a) => a.id.equals(id))).write(
      AccountsCompanion(archivedAt: Value(DateTime.now())),
    );
  }

  /// Total income and total expense posted within [start]..[end]
  /// (inclusive), based on transaction date. Both totals are positive
  /// magnitudes; a reversed entry's postings net out automatically since
  /// they carry opposite signs to the original.
  Stream<Summary> watchSummary({
    required DateTime start,
    required DateTime end,
  }) {
    final startDate = _dateOnly(start);
    final endDate = _dateOnly(end);

    final query =
        _db.select(_db.postings).join([
          innerJoin(
            _db.journalEntries,
            _db.journalEntries.id.equalsExp(_db.postings.entryId),
          ),
          innerJoin(
            _db.accounts,
            _db.accounts.id.equalsExp(_db.postings.accountId),
          ),
        ])..where(
          _db.journalEntries.transactionDate.isBiggerOrEqualValue(startDate) &
              _db.journalEntries.transactionDate.isSmallerOrEqualValue(endDate),
        );

    return query.watch().map((rows) {
      var totalIncomeMinor = 0;
      var totalExpenseMinor = 0;
      for (final row in rows) {
        final account = row.readTable(_db.accounts);
        final posting = row.readTable(_db.postings);
        switch (account.type) {
          case AccountType.income:
            totalIncomeMinor -= posting.amountMinor;
          case AccountType.expense:
            totalExpenseMinor += posting.amountMinor;
          case AccountType.asset:
            break;
        }
      }
      return Summary(
        totalIncomeMinor: totalIncomeMinor,
        totalExpenseMinor: totalExpenseMinor,
      );
    });
  }
}

String _dateOnly(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
