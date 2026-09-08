import 'package:drift/drift.dart';

import '../../domain/exceptions.dart';
import '../../domain/models/account.dart';
import '../../domain/models/summary.dart';
import '../../domain/summary/ledger_summary_engine.dart';
import '../database/app_database.dart';
import 'account_chart_reader.dart';
import 'repository_date_utils.dart';

/// Income/expense categories - creation, renaming, archive/unarchive
/// lifecycle, monthly limits, and per-category totals. Split out of
/// `LedgerRepository` (architecture-deepening design.md D1); a leaf with
/// no dependency on any other repository.
class CategoryRepository {
  CategoryRepository({required AppDatabase database, AccountChartReader? chart})
    : _db = database,
      _chart = chart ?? AccountChartReader(database);

  final AppDatabase _db;
  final AccountChartReader _chart;

  /// Categories for pickers ([includeArchived] false, the default) or
  /// historical views ([includeArchived] true). Allowlist: income/expense
  /// only — never liability/equity/asset.
  Stream<List<Account>> watchCategories({bool includeArchived = false}) {
    return _chart.watchCategories(includeArchived: includeArchived);
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
      final lines = <SummaryPostingLine>[];
      for (final row in rows) {
        final entry = row.readTable(_db.journalEntries);
        final account = row.readTable(_db.accounts);
        final posting = row.readTable(_db.postings);
        final verification = row.readTableOrNull(_db.entryVerificationCache);
        lines.add(
          SummaryPostingLine(
            entryId: entry.id,
            migratedFromEntryId: entry.migratedFromEntryId,
            isQuarantined: verification != null && !verification.isVerified,
            accountId: account.id,
            accountName: account.name,
            accountType: account.type,
            amountMinor: posting.amountMinor,
          ),
        );
      }
      return buildCategoryTotals(lines);
    });
  }
}
