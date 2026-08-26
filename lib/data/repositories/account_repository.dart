import 'package:drift/drift.dart';

import '../../domain/exceptions.dart';
import '../../domain/models/account.dart';
import '../../domain/models/account_currency_catalog.dart';
import '../../domain/models/account_group.dart';
import '../database/app_database.dart';
import '../database/tables/account_groups_table.dart';
import '../database/tables/accounts_table.dart';
import 'account_chart_reader.dart';
import 'ledger_repository.dart';
import 'repository_date_utils.dart';

/// Financial accounts and account groups - creation, renaming,
/// archive/unarchive lifecycle, group currency, and the currency-backfill
/// migration path (multi-currency-support, custom-account-groups,
/// unarchive-accounts-categories). Split out of `LedgerRepository`
/// (architecture-deepening) - see that class's own doc comment for the
/// shared conventions (Drift-only access, domain models never row
/// classes, one transaction per write).
///
/// Depends on [LedgerRepository] for its two writes that post a journal
/// entry (an archived account's closeout transfer, and a new account's
/// opening balance) - never the other way around, since `LedgerRepository`
/// would then depend back on this class too, which Dart can't construct
/// (architecture-deepening design.md D1a/D2).
class AccountRepository {
  AccountRepository({
    required AppDatabase database,
    required LedgerRepository ledgerRepository,
    AccountChartReader? chart,
  }) : _db = database,
       _ledgerRepository = ledgerRepository,
       _chart = chart ?? AccountChartReader(database);

  final AppDatabase _db;
  final LedgerRepository _ledgerRepository;
  final AccountChartReader _chart;

  /// Whether any `account_groups` row still has no currency - the signal
  /// for a database migrated from schemaVersion 3 that needs the one-time
  /// currency-backfill prompt before the app is otherwise usable
  /// (multi-currency-support design.md Migration Plan step 3). Always
  /// false for a fresh schemaVersion-4 install, since
  /// `IdentityRepository.confirmFirstIdentity` seeds every group with a
  /// currency already.
  Future<bool> needsCurrencyBackfill() async {
    final row =
        await (_db.select(_db.accountGroups)
              ..where((g) => g.currency.isNull())
              ..limit(1))
            .getSingleOrNull();
    return row != null;
  }

  /// Applies [currency] to every account group that doesn't have one yet.
  /// A one-time action for a database migrated from schemaVersion 3 - see
  /// [needsCurrencyBackfill].
  Future<void> backfillGroupCurrencies(String currency) async {
    await (_db.update(_db.accountGroups)..where((g) => g.currency.isNull()))
        .write(AccountGroupsCompanion(currency: Value(currency)));
  }

  /// Active financial accounts only (`asset` / `liability` allowlist).
  Stream<List<Account>> watchFinancialAccounts({
    bool includeArchived = false,
  }) => _chart.watchFinancialAccounts(includeArchived: includeArchived);

  /// Account-group pickers ([includeArchived] false, the default) or
  /// callers resolving an existing account's own group, which may since
  /// have been archived ([includeArchived] true) - mirrors
  /// [watchFinancialAccounts]'s convention.
  Stream<List<AccountGroup>> watchAccountGroups({
    bool includeArchived = false,
  }) => _chart.watchAccountGroups(includeArchived: includeArchived);

  /// Reactive account-id → group-currency catalog. Derived once here so
  /// record/register/transfer/settle/recurring view models do not each
  /// join [watchFinancialAccounts] and [watchAccountGroups]
  /// (account-group-currency-lookup).
  Stream<AccountCurrencyCatalog> watchAccountCurrencies({
    bool includeArchived = false,
  }) {
    final query =
        _db.select(_db.accounts).join([
          innerJoin(
            _db.accountGroups,
            _db.accountGroups.id.equalsExp(_db.accounts.groupId),
          ),
        ])..where(
          _db.accounts.type.equalsValue(AccountType.asset) |
              _db.accounts.type.equalsValue(AccountType.liability),
        );
    if (!includeArchived) {
      query.where(_db.accounts.archivedAt.isNull());
    }
    return query.watch().map((rows) {
      final byAccountId = <String, String>{};
      for (final row in rows) {
        final account = row.readTable(_db.accounts);
        final currency = row.readTable(_db.accountGroups).currency;
        if (currency != null) {
          byAccountId[account.id] = currency;
        }
      }
      return AccountCurrencyCatalog(byAccountId);
    });
  }

  /// Snapshot of [watchAccountCurrencies] for one account, including
  /// archived accounts. Null when the account is missing, has no group,
  /// or the group has no currency yet.
  Future<String?> groupCurrencyFor(String financialAccountId) async {
    final catalog = await watchAccountCurrencies(includeArchived: true).first;
    return catalog.currencyFor(financialAccountId);
  }

  Account _toDomainAccount(AccountRow row) => _chart.toDomainAccount(row);

  AccountGroup _toDomainGroup(AccountGroupRow row) => _chart.toDomainGroup(row);

  Future<AccountRow> _requireActiveFinancialAccount(String id) =>
      _chart.requireActiveFinancialAccount(id);

  /// Sibling of [_requireActiveFinancialAccount] for the one write that
  /// *must* start from an archived account: closeout of its remaining
  /// display balance (spec: "Closeout of an Archived Account with a
  /// Remaining Balance"). A boolean on the active helper would let any
  /// caller silently loosen both sides of a transfer.
  Future<AccountRow> _requireCloseoutEligibleFinancialAccount(String id) async {
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
    if (row.archivedAt == null) {
      throw AccountGroupException(
        'Account $id is not archived.',
        code: AppErrorCode.accountNotArchived,
      );
    }
    final balance = await _ledgerRepository.displayBalanceMinor(id);
    if (balance <= 0) {
      throw AccountGroupException(
        'Account $id has no positive display balance to close out.',
        code: AppErrorCode.accountNoPositiveBalanceToCloseOut,
      );
    }
    return row;
  }

  Future<String> _groupCurrencyFor(AccountRow accountRow) =>
      _chart.groupCurrencyFor(accountRow);

  /// Creates a financial account. [openingBalanceMinor] if supplied must be
  /// positive; for liabilities it means amount owed.
  Future<Account> createFinancialAccount({
    required String name,
    required AccountType type,
    required String groupId,
    int? openingBalanceMinor,
    bool holdsInvestments = false,
    bool isCreditCard = false,
  }) async {
    if (type != AccountType.asset && type != AccountType.liability) {
      throw ArgumentError.value(type, 'type', 'must be asset or liability');
    }
    if (holdsInvestments && type != AccountType.asset) {
      throw AccountGroupException(
        'Only asset accounts can be marked as investment accounts.',
        code: AppErrorCode.investmentAccountsMustBeAssets,
      );
    }
    if (isCreditCard && type != AccountType.liability) {
      throw AccountGroupException(
        'Only liability accounts can be marked as credit cards.',
        code: AppErrorCode.creditCardsMustBeLiabilities,
      );
    }
    if (openingBalanceMinor != null && openingBalanceMinor <= 0) {
      throw InvalidOpeningBalanceException(
        'Opening balance must be positive and non-zero when supplied, '
        'got $openingBalanceMinor.',
      );
    }
    final group = await (_db.select(
      _db.accountGroups,
    )..where((g) => g.id.equals(groupId))).getSingleOrNull();
    if (group == null) {
      throw AccountGroupException(
        'Account group $groupId not found.',
        code: AppErrorCode.groupNotFound,
      );
    }
    final expectedKind = type == AccountType.asset
        ? AccountGroupKind.assetGroup
        : AccountGroupKind.liabilityGroup;
    if (group.kind != expectedKind) {
      throw AccountGroupException(
        'Account type $type does not match group kind ${group.kind}.',
        code: AppErrorCode.accountTypeDoesNotMatchGroup,
      );
    }
    // Defensive: the app-level currency-backfill gate (needsCurrencyBackfill)
    // should always run before any account-creation UI is reachable, so
    // this should never actually trigger - but a null currency here would
    // otherwise propagate silently into every downstream currency label.
    if (group.currency == null) {
      throw AccountGroupException(
        'Account group $groupId has no currency set yet.',
        code: AppErrorCode.groupHasNoCurrency,
      );
    }

    late AccountRow created;
    await _db.transaction(() async {
      created = await _db
          .into(_db.accounts)
          .insertReturning(
            AccountsCompanion.insert(
              name: name,
              type: type,
              holdsInvestments: Value(holdsInvestments),
              isCreditCard: Value(isCreditCard),
              groupId: Value(groupId),
            ),
          );
      if (holdsInvestments) {
        await _db
            .into(_db.accounts)
            .insert(
              AccountsCompanion.insert(
                name: '$name Inventory',
                type: AccountType.inventory,
                holdsInvestments: const Value(false),
                investmentOwnerAccountId: Value(created.id),
                groupId: Value(groupId),
              ),
            );
      }
    });

    if (openingBalanceMinor != null) {
      await _postOpeningBalance(
        account: created,
        openingBalanceMinor: openingBalanceMinor,
      );
    }
    return _toDomainAccount(created);
  }

  Future<void> _postOpeningBalance({
    required AccountRow account,
    required int openingBalanceMinor,
  }) async {
    // Option A: asset +O / equity −O; liability −O / equity +O.
    final (financialAmount, equityAmount) = account.type == AccountType.asset
        ? (openingBalanceMinor, -openingBalanceMinor)
        : (-openingBalanceMinor, openingBalanceMinor);

    await _ledgerRepository.appendSignedEntry(
      transactionDate: dateOnly(DateTime.now()),
      description: 'Opening balance',
      reversesEntryId: null,
      postings: [
        (accountId: account.id, amountMinor: financialAmount, lineNumber: 1),
        (
          accountId: openingBalanceEquityAccountId,
          amountMinor: equityAmount,
          lineNumber: 2,
        ),
      ],
    );
  }

  Future<void> renameFinancialAccount({
    required String id,
    required String newName,
  }) async {
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
    await (_db.update(_db.accounts)..where((a) => a.id.equals(id))).write(
      AccountsCompanion(name: Value(newName)),
    );
  }

  Future<void> reassignFinancialAccountGroup({
    required String id,
    required String groupId,
  }) async {
    final account = await (_db.select(
      _db.accounts,
    )..where((a) => a.id.equals(id))).getSingleOrNull();
    if (account == null ||
        (account.type != AccountType.asset &&
            account.type != AccountType.liability)) {
      throw AccountGroupException(
        'Account $id is not a financial account.',
        code: AppErrorCode.accountNotFinancial,
      );
    }
    final group = await (_db.select(
      _db.accountGroups,
    )..where((g) => g.id.equals(groupId))).getSingleOrNull();
    if (group == null) {
      throw AccountGroupException(
        'Account group $groupId not found.',
        code: AppErrorCode.groupNotFound,
      );
    }
    final expectedKind = account.type == AccountType.asset
        ? AccountGroupKind.assetGroup
        : AccountGroupKind.liabilityGroup;
    if (group.kind != expectedKind) {
      throw AccountGroupException(
        'Account type ${account.type} does not match group kind ${group.kind}.',
        code: AppErrorCode.accountTypeDoesNotMatchGroup,
      );
    }
    // multi-currency-support: reassigning across currencies would silently
    // reinterpret the account's entire historical balance in a new
    // currency - rejected regardless of whether the account has any
    // postings yet (design.md Decision 1).
    if (account.groupId != null) {
      final currentGroup = await (_db.select(
        _db.accountGroups,
      )..where((g) => g.id.equals(account.groupId!))).getSingleOrNull();
      if (currentGroup != null && currentGroup.currency != group.currency) {
        throw AccountGroupException(
          'Cannot reassign to a group with a different currency '
          '(${currentGroup.currency} -> ${group.currency}).',
          code: AppErrorCode.cannotReassignDifferentCurrency,
        );
      }
    }
    await (_db.update(_db.accounts)..where((a) => a.id.equals(id))).write(
      AccountsCompanion(groupId: Value(groupId)),
    );
  }

  /// Changes an account group's currency. Rejected while the group has at
  /// least one active financial account, since that would retroactively
  /// reinterpret its members' historical balances (multi-currency-support
  /// design.md Open Questions).
  Future<void> changeAccountGroupCurrency({
    required String groupId,
    required String currency,
  }) async {
    final group = await (_db.select(
      _db.accountGroups,
    )..where((g) => g.id.equals(groupId))).getSingleOrNull();
    if (group == null) {
      throw AccountGroupException(
        'Account group $groupId not found.',
        code: AppErrorCode.groupNotFound,
      );
    }
    final activeMembers =
        await (_db.select(_db.accounts)..where(
              (a) =>
                  a.groupId.equals(groupId) &
                  (a.type.equalsValue(AccountType.asset) |
                      a.type.equalsValue(AccountType.liability)) &
                  a.archivedAt.isNull(),
            ))
            .get();
    if (activeMembers.isNotEmpty) {
      throw AccountGroupException(
        'Cannot change currency while the group has active financial accounts.',
        code: AppErrorCode.cannotChangeGroupCurrencyWithAccounts,
      );
    }
    await (_db.update(_db.accountGroups)..where((g) => g.id.equals(groupId)))
        .write(AccountGroupsCompanion(currency: Value(currency)));
  }

  Future<void> archiveFinancialAccount(String id) async {
    await _requireActiveFinancialAccount(id);
    final activeCount =
        await (_db.select(_db.accounts)..where(
              (a) =>
                  (a.type.equalsValue(AccountType.asset) |
                      a.type.equalsValue(AccountType.liability)) &
                  a.archivedAt.isNull(),
            ))
            .get();
    if (activeCount.length <= 1) {
      throw LastActiveAccountException(
        'Cannot archive the last active financial account.',
      );
    }
    await (_db.update(_db.accounts)..where((a) => a.id.equals(id))).write(
      AccountsCompanion(archivedAt: Value(DateTime.now())),
    );
  }

  /// Restores an archived financial account to active status
  /// (unarchive-accounts-categories spec: "Unarchive Financial Account").
  /// If the account's own group is itself archived - only reachable by
  /// archiving the account, then archiving its now-empty group - the
  /// group is unarchived in the same transaction too, so the restored
  /// account is never left referencing an archived group (design.md
  /// Decision 2).
  Future<void> unarchiveFinancialAccount(String id) async {
    final account = await (_db.select(
      _db.accounts,
    )..where((a) => a.id.equals(id))).getSingleOrNull();
    if (account == null ||
        (account.type != AccountType.asset &&
            account.type != AccountType.liability)) {
      throw AccountGroupException(
        'Account $id is not a financial account.',
        code: AppErrorCode.accountNotFinancial,
      );
    }
    await _db.transaction(() async {
      await (_db.update(_db.accounts)..where((a) => a.id.equals(id))).write(
        const AccountsCompanion(archivedAt: Value(null)),
      );
      final groupId = account.groupId;
      if (groupId == null) return;
      final group = await (_db.select(
        _db.accountGroups,
      )..where((g) => g.id.equals(groupId))).getSingleOrNull();
      if (group != null && group.archivedAt != null) {
        await (_db.update(_db.accountGroups)
              ..where((g) => g.id.equals(groupId)))
            .write(const AccountGroupsCompanion(archivedAt: Value(null)));
      }
    });
  }

  Future<void> renameAccountGroup({
    required String id,
    required String newName,
  }) async {
    final group = await (_db.select(
      _db.accountGroups,
    )..where((g) => g.id.equals(id))).getSingleOrNull();
    if (group == null) {
      throw AccountGroupException(
        'Account group $id not found.',
        code: AppErrorCode.groupNotFound,
      );
    }
    await (_db.update(_db.accountGroups)..where((g) => g.id.equals(id))).write(
      AccountGroupsCompanion(name: Value(newName)),
    );
  }

  /// Creates a user-created account group (custom-account-groups
  /// design.md Decision 5). [currency] must be non-blank - the first
  /// repository-level currency check in this codebase, since every other
  /// currency value today only ever reaches the Repository after a UI
  /// screen's own regex already validated it. `sortOrder` is always `(max
  /// existing sortOrder) + 1`, so a new group sorts after every existing
  /// one.
  Future<AccountGroup> createAccountGroup({
    required String name,
    required AccountGroupKind kind,
    required String currency,
  }) async {
    if (currency.trim().isEmpty) {
      throw AccountGroupException(
        'Currency is required to create a group.',
        code: AppErrorCode.currencyRequiredToCreateGroup,
      );
    }
    final existing = await _db.select(_db.accountGroups).get();
    final nextSortOrder =
        existing.fold<int>(
          -1,
          (max, g) => g.sortOrder > max ? g.sortOrder : max,
        ) +
        1;
    final created = await _db
        .into(_db.accountGroups)
        .insertReturning(
          AccountGroupsCompanion.insert(
            name: name,
            kind: kind,
            sortOrder: nextSortOrder,
            isSystem: false,
            currency: Value(currency),
          ),
        );
    return _toDomainGroup(created);
  }

  /// Archives a user-created account group once it has zero active member
  /// financial accounts (custom-account-groups design.md Decision 3). A
  /// system group ([AccountGroupRow.isSystem]) is rejected outright,
  /// before even checking membership - "System Account Groups Are
  /// Permanent and Renameable" requires they SHALL NOT be archived.
  /// Archiving is not idempotent, mirroring [archiveFinancialAccount]'s
  /// existing "must currently be active" precondition.
  Future<void> archiveAccountGroup(String id) async {
    final group = await (_db.select(
      _db.accountGroups,
    )..where((g) => g.id.equals(id))).getSingleOrNull();
    if (group == null) {
      throw AccountGroupException(
        'Account group $id not found.',
        code: AppErrorCode.groupNotFound,
      );
    }
    if (group.isSystem) {
      throw AccountGroupException(
        'System account groups cannot be archived.',
        code: AppErrorCode.systemGroupCannotBeArchived,
      );
    }
    if (group.archivedAt != null) {
      throw AccountGroupException(
        'Account group $id is already archived.',
        code: AppErrorCode.groupAlreadyArchived,
      );
    }
    final activeMembers =
        await (_db.select(_db.accounts)..where(
              (a) =>
                  a.groupId.equals(id) &
                  (a.type.equalsValue(AccountType.asset) |
                      a.type.equalsValue(AccountType.liability)) &
                  a.archivedAt.isNull(),
            ))
            .get();
    if (activeMembers.isNotEmpty) {
      throw AccountGroupException(
        'Cannot archive a group with active financial accounts.',
        code: AppErrorCode.cannotArchiveGroupWithAccounts,
      );
    }
    await (_db.update(_db.accountGroups)..where((g) => g.id.equals(id))).write(
      AccountGroupsCompanion(archivedAt: Value(DateTime.now())),
    );
  }

  /// Restores an archived user-created account group to active status
  /// (unarchive-accounts-categories spec: "Unarchive Account Group").
  /// Does not itself unarchive any of the group's previously archived
  /// member accounts - that's [unarchiveFinancialAccount]'s own action,
  /// done independently per account (design.md Decision 3). Rejects a
  /// system group, though that's unreachable in practice since system
  /// groups are never archived in the first place.
  Future<void> unarchiveAccountGroup(String id) async {
    final group = await (_db.select(
      _db.accountGroups,
    )..where((g) => g.id.equals(id))).getSingleOrNull();
    if (group == null) {
      throw AccountGroupException(
        'Account group $id not found.',
        code: AppErrorCode.groupNotFound,
      );
    }
    if (group.isSystem) {
      throw AccountGroupException(
        'System account groups are never archived.',
        code: AppErrorCode.systemGroupNeverArchived,
      );
    }
    await (_db.update(_db.accountGroups)..where((g) => g.id.equals(id))).write(
      const AccountGroupsCompanion(archivedAt: Value(null)),
    );
  }

  /// No account group - system or user-created, archived or not - can be
  /// permanently deleted (custom-account-groups design.md Non-Goals):
  /// archiving via [archiveAccountGroup] is the only lifecycle action.
  Future<void> deleteAccountGroup(String id) async {
    final group = await (_db.select(
      _db.accountGroups,
    )..where((g) => g.id.equals(id))).getSingleOrNull();
    if (group == null) {
      throw AccountGroupException(
        'Account group $id not found.',
        code: AppErrorCode.groupNotFound,
      );
    }
    throw AccountGroupException(
      'Account groups cannot be deleted.',
      code: AppErrorCode.accountGroupsCannotBeDeleted,
    );
  }

  /// Closes out an archived financial account's remaining display balance
  /// into another active account (spec: "Closeout of an Archived Account
  /// with a Remaining Balance"). Delegates the actual posting to
  /// [LedgerRepository.postTransferEntry] - this method's own job is
  /// resolving and validating both accounts.
  Future<void> recordArchivedAccountCloseoutTransfer({
    required String fromAccountId,
    required String toAccountId,
    required DateTime transactionDate,
    String? description,
    int? destinationAmountMinor,
  }) async {
    if (fromAccountId == toAccountId) {
      throw InvalidTransferException(
        'Source and destination accounts must be distinct.',
        code: AppErrorCode.transferAccountsMustDiffer,
      );
    }
    final fromAccount = await _requireCloseoutEligibleFinancialAccount(
      fromAccountId,
    );
    final toAccount = await _requireActiveFinancialAccount(toAccountId);
    final amountMinor = await _ledgerRepository.displayBalanceMinor(
      fromAccountId,
    );
    final fromCurrency = await _groupCurrencyFor(fromAccount);
    final toCurrency = await _groupCurrencyFor(toAccount);
    if (fromCurrency != toCurrency &&
        (destinationAmountMinor == null || destinationAmountMinor <= 0)) {
      throw InvalidTransferException(
        'A cross-currency closeout requires a known destination amount; '
        'a pending transfer is not allowed on an archived account.',
        code: AppErrorCode.closeoutRequiresDestinationAmount,
      );
    }
    await _ledgerRepository.postTransferEntry(
      fromAccount: fromAccount,
      toAccount: toAccount,
      amountMinor: amountMinor,
      transactionDate: transactionDate,
      description: description,
      destinationAmountMinor: destinationAmountMinor,
    );
  }

  /// Seeds the five system groups, Opening Balance Equity, Transfers in
  /// transit, the first cash account, and starter income/expense
  /// categories. Called from [IdentityRepository.confirmFirstIdentity]
  /// after the signing identity exists (architecture-deepening design.md
  /// D1a) — starter books must not exist before that identity.
  Future<void> seedOnboardingBooks({required String currency}) async {
    final seeds = <(String id, String name, AccountGroupKind kind, int order)>[
      (
        groupCashEquivalentsId,
        'Cash & cash equivalents',
        AccountGroupKind.assetGroup,
        0,
      ),
      (
        groupPensionRetirementId,
        'Pension & retirement',
        AccountGroupKind.assetGroup,
        1,
      ),
      (
        groupCreditShortTermId,
        'Credit & short-term debt',
        AccountGroupKind.liabilityGroup,
        2,
      ),
      (
        groupLoansMortgagesId,
        'Loans & mortgages',
        AccountGroupKind.liabilityGroup,
        3,
      ),
      (groupInvestmentsId, 'Investments', AccountGroupKind.assetGroup, 4),
    ];
    for (final (id, name, kind, order) in seeds) {
      await _db
          .into(_db.accountGroups)
          .insertOnConflictUpdate(
            AccountGroupsCompanion.insert(
              id: Value(id),
              name: name,
              kind: kind,
              sortOrder: order,
              isSystem: true,
              currency: Value(currency),
            ),
          );
    }
    await _db
        .into(_db.accounts)
        .insertOnConflictUpdate(
          AccountsCompanion.insert(
            id: const Value(openingBalanceEquityAccountId),
            name: openingBalanceEquityAccountName,
            type: AccountType.equity,
          ),
        );
    await _db
        .into(_db.accounts)
        .insertOnConflictUpdate(
          AccountsCompanion.insert(
            id: const Value(transfersInTransitAccountId),
            name: transfersInTransitAccountName,
            type: AccountType.clearing,
          ),
        );
    await _db
        .into(_db.accounts)
        .insert(
          AccountsCompanion.insert(
            name: financialAccountName,
            type: AccountType.asset,
            groupId: const Value(groupCashEquivalentsId),
          ),
        );
    for (final name in starterIncomeCategories) {
      await _db
          .into(_db.accounts)
          .insert(
            AccountsCompanion.insert(name: name, type: AccountType.income),
          );
    }
    for (final name in starterExpenseCategories) {
      await _db
          .into(_db.accounts)
          .insert(
            AccountsCompanion.insert(name: name, type: AccountType.expense),
          );
    }
  }
}
