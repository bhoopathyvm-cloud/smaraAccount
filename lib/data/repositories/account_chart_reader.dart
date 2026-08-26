import 'package:drift/drift.dart';

import '../../domain/exceptions.dart';
import '../../domain/models/account.dart';
import '../../domain/models/account_group.dart';
import '../database/app_database.dart';

/// Cycle-free chart-of-accounts reads: financial accounts, categories, and
/// groups mapped to domain models.
///
/// [AccountRepository] depends on [LedgerRepository] for posting writes, so
/// posting cannot import AccountRepository (architecture-deepening D1a).
/// Both posting and remaining ledger reads use this seam instead of private
/// duplicate `_watchFinancialAccounts` adapters.
class AccountChartReader {
  AccountChartReader(this._db);

  final AppDatabase _db;

  Stream<List<Account>> watchFinancialAccounts({bool includeArchived = false}) {
    final query = _db.select(_db.accounts)
      ..where(
        (a) =>
            a.type.equalsValue(AccountType.asset) |
            a.type.equalsValue(AccountType.liability),
      )
      ..orderBy([
        (a) => OrderingTerm.asc(a.sortOrder),
        (a) => OrderingTerm.asc(a.name),
      ]);
    if (!includeArchived) {
      query.where((a) => a.archivedAt.isNull());
    }
    return query.watch().map((rows) => rows.map(toDomainAccount).toList());
  }

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
    return query.watch().map((rows) => rows.map(toDomainAccount).toList());
  }

  Stream<List<AccountGroup>> watchAccountGroups({
    bool includeArchived = false,
  }) {
    final query = _db.select(_db.accountGroups)
      ..orderBy([(g) => OrderingTerm.asc(g.sortOrder)]);
    if (!includeArchived) {
      query.where((g) => g.archivedAt.isNull());
    }
    return query.watch().map((rows) => rows.map(toDomainGroup).toList());
  }

  /// Active asset/liability account, or [AccountGroupException].
  Future<AccountRow> requireActiveFinancialAccount(String id) async {
    final row = await (_db.select(
      _db.accounts,
    )..where((a) => a.id.equals(id))).getSingleOrNull();
    if (row == null ||
        (row.type != AccountType.asset && row.type != AccountType.liability)) {
      throw AccountGroupException(
        'Account $id is not a financial account.',
        code: AppErrorCode.accountNotFinancial,
      );
    }
    if (row.archivedAt != null) {
      throw AccountGroupException(
        'Account $id is archived.',
        code: AppErrorCode.accountArchived,
      );
    }
    return row;
  }

  /// ISO 4217 currency of [accountRow]'s group.
  Future<String> groupCurrencyFor(AccountRow accountRow) async {
    final groupId = accountRow.groupId;
    if (groupId == null) {
      throw AccountGroupException(
        'Account ${accountRow.id} has no group assigned.',
        code: AppErrorCode.accountHasNoGroup,
      );
    }
    final group = await (_db.select(
      _db.accountGroups,
    )..where((g) => g.id.equals(groupId))).getSingleOrNull();
    final currency = group?.currency;
    if (currency == null) {
      throw AccountGroupException(
        'Account group $groupId has no currency set yet.',
        code: AppErrorCode.groupHasNoCurrency,
      );
    }
    return currency;
  }

  /// Active category of [type], or [onInvalid].
  Future<AccountRow> requireActiveCategoryOfType(
    String id,
    AccountType type, {
    required Exception Function(String id) onInvalid,
  }) async {
    final row = await (_db.select(
      _db.accounts,
    )..where((a) => a.id.equals(id))).getSingleOrNull();
    if (row == null || row.type != type || row.archivedAt != null) {
      throw onInvalid(id);
    }
    return row;
  }

  /// Active expense category, or [PendingTransferException] (posting and
  /// investment share this exception even on buy — chart-catalog follow-through).
  Future<AccountRow> requireActiveExpenseCategory(String id) {
    return requireActiveCategoryOfType(
      id,
      AccountType.expense,
      onInvalid: (id) => PendingTransferException(
        '$id is not an active Expense category.',
        code: AppErrorCode.notActiveExpenseCategory,
      ),
    );
  }

  Account toDomainAccount(AccountRow row) {
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

  AccountGroup toDomainGroup(AccountGroupRow row) {
    return AccountGroup(
      id: row.id,
      name: row.name,
      kind: row.kind,
      sortOrder: row.sortOrder,
      isSystem: row.isSystem,
      currency: row.currency,
      archived: row.archivedAt != null,
    );
  }
}
