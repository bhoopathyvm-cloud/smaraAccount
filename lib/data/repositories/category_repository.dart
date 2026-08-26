import 'package:drift/drift.dart';

import '../../domain/exceptions.dart';
import '../../domain/models/account.dart';
import '../../domain/models/summary.dart';
import '../database/app_database.dart';
import 'repository_date_utils.dart';

/// Income/expense categories - creation, renaming, archive/unarchive
/// lifecycle, monthly limits, and per-category totals. Split out of
/// `LedgerRepository` (architecture-deepening design.md D1); a leaf with
/// no dependency on any other repository.
class CategoryRepository {
  CategoryRepository({required AppDatabase database}) : _db = database;

  final AppDatabase _db;

  /// Categories for pickers ([includeArchived] false, the default) or
  /// historical views ([includeArchived] true). Allowlist: income/expense
  /// only — never liability/equity/asset.
  Stream<List<Account>> watchCategories({bool includeArchived = false}) {
    final query = _db.select(_db.accounts)
      ..where(
        (a) =>
            a.type.equalsValue(AccountType.income) |
            a.type.equalsValue(AccountType.expense),
      )
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
      groupId: row.groupId,
      sortOrder: row.sortOrder,
      holdsInvestments: row.holdsInvestments,
      investmentOwnerAccountId: row.investmentOwnerAccountId,
      monthlyLimitMinor: row.monthlyLimitMinor,
      isCreditCard: row.isCreditCard,
    );
  }

  /// [type] must be [AccountType.income] or [AccountType.expense].
  Future<void> addCategory({
    required String name,
    required AccountType type,
  }) async {
    if (type != AccountType.income && type != AccountType.expense) {
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

  /// Restores an archived income or expense category to active status
  /// (unarchive-accounts-categories spec: "Unarchive Income or Expense
  /// Category").
  Future<void> unarchiveCategory(String id) async {
    await (_db.update(_db.accounts)..where((a) => a.id.equals(id))).write(
      const AccountsCompanion(archivedAt: Value(null)),
    );
  }

  /// Sets or clears (`null`) an Expense category's optional monthly
  /// spending limit (spec: "Category Management" - "An Income category
  /// SHALL NOT have a monthly limit"). Informational only - never
  /// enforced against posting (monthly-category-limits design.md
  /// Decision 3).
  Future<void> setCategoryMonthlyLimit({
    required String id,
    required int? monthlyLimitMinor,
  }) async {
    if (monthlyLimitMinor != null) {
      if (monthlyLimitMinor <= 0) {
        throw InvalidTransactionAmountException(
          'Monthly limit must be positive and non-zero, got $monthlyLimitMinor.',
          code: AppErrorCode.monthlyLimitMustBePositive,
        );
      }
      final row = await (_db.select(
        _db.accounts,
      )..where((a) => a.id.equals(id))).getSingleOrNull();
      if (row == null || row.type != AccountType.expense) {
        throw ArgumentError.value(
          id,
          'id',
          'must be an Expense category to set a monthly limit',
        );
      }
    }
    await (_db.update(_db.accounts)..where((a) => a.id.equals(id))).write(
      AccountsCompanion(monthlyLimitMinor: Value(monthlyLimitMinor)),
    );
  }

  /// Per-category totals within a date range (home-hub-capture: "this
  /// calendar month's spent totals grouped by expense category and
  /// received totals by income category") - same exclusions as
  /// LedgerRepository.watchSummary (quarantined entries, migration-
  /// superseded entries, non-income/expense account types), but grouped
  /// by category instead of collapsed into two totals. A category with
  /// no postings in range is simply absent, not returned as zero.
  Stream<List<CategoryTotal>> watchCategoryTotals({
    required DateTime start,
    required DateTime end,
  }) {
    final startDate = dateOnly(start);
    final endDate = dateOnly(end);

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
          leftOuterJoin(
            _db.entryVerificationCache,
            _db.entryVerificationCache.entryId.equalsExp(_db.postings.entryId),
          ),
        ])..where(
          _db.journalEntries.transactionDate.isBiggerOrEqualValue(startDate) &
              _db.journalEntries.transactionDate.isSmallerOrEqualValue(endDate),
        );

    return query.watch().asyncMap((rows) async {
      final supersededEntryIds = <String>{
        for (final row in rows)
          ?row.readTable(_db.journalEntries).migratedFromEntryId,
      };

      final totalsById = <String, ({String name, bool isIncome, int total})>{};
      for (final row in rows) {
        final entry = row.readTable(_db.journalEntries);
        if (supersededEntryIds.contains(entry.id)) continue;

        final verification = row.readTableOrNull(_db.entryVerificationCache);
        if (verification != null && !verification.isVerified) continue;

        final account = row.readTable(_db.accounts);
        final posting = row.readTable(_db.postings);
        int magnitude;
        bool isIncome;
        switch (account.type) {
          case AccountType.income:
            magnitude = -posting.amountMinor;
            isIncome = true;
          case AccountType.expense:
            magnitude = posting.amountMinor;
            isIncome = false;
          case AccountType.asset:
          case AccountType.liability:
          case AccountType.equity:
          case AccountType.clearing:
          case AccountType.inventory:
            continue;
        }

        final existing = totalsById[account.id];
        totalsById[account.id] = (
          name: account.name,
          isIncome: isIncome,
          total: (existing?.total ?? 0) + magnitude,
        );
      }

      return [
        for (final entry in totalsById.entries)
          CategoryTotal(
            categoryId: entry.key,
            categoryName: entry.value.name,
            isIncome: entry.value.isIncome,
            totalMinor: entry.value.total,
          ),
      ];
    });
  }
}
