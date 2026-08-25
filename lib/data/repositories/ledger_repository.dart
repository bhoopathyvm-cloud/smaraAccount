import 'dart:async';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/crypto/entry_canonical_hash.dart';
import '../../domain/crypto/signing_key_service.dart';
import '../../domain/exceptions.dart';
import '../../domain/models/account.dart';
import '../../domain/models/account_group.dart';
import '../../domain/models/home_overview.dart';
import '../../domain/models/integrity_event.dart';
import '../../domain/models/journal_entry.dart';
import '../../domain/money/currency_minor_units.dart';
import '../../domain/models/pending_transfer.dart';
import '../../domain/models/posting.dart';
import '../../domain/models/signing_identity.dart';
import '../../domain/models/summary.dart';
import '../../domain/models/transaction_direction.dart';
import '../database/app_database.dart';
import '../database/tables/accounts_table.dart';
import '../database/tables/ledger_chain_state_table.dart';
import 'investment_holdings_logic.dart';
import 'repository_date_utils.dart';

/// The only layer that talks to Drift. Exposes domain models, never
/// Drift's generated row classes (smara-tech-guidelines.md). Every write
/// path (recordTransaction, reverseEntry) writes an entry and its postings
/// in a single Drift transaction. No updateEntry/deleteEntry method exists
/// anywhere on this class - immutability is enforced by omission
/// (Golden Rule #7).
///
/// Since ledger-integrity-signing, every posted entry is also hashed,
/// chained onto the device's trusted tip, and signed with the current
/// [SigningIdentity]'s private key (via [SigningKeyService], which never
/// exposes the key material itself to this class - only signatures).
class LedgerRepository {
  LedgerRepository({
    required AppDatabase database,
    SigningKeyService? signingKeyService,
  }) : _db = database,
       _signingKeyService = signingKeyService ?? SigningKeyService();

  final AppDatabase _db;
  final SigningKeyService _signingKeyService;

  /// Private copy of IdentityRepository.currentIdentity for
  /// [appendSignedEntry]. Ledger cannot depend on IdentityRepository
  /// (Identity → Account → Ledger would cycle — design.md D1a).
  Future<SigningIdentity?> _currentSigningIdentity() async {
    final row =
        await (_db.select(_db.signingIdentities)
              ..where((t) => t.supersededAt.isNull())
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : _toDomainIdentity(row);
  }

  SigningIdentity _toDomainIdentity(IdentityRow row) {
    return SigningIdentity(
      identityId: row.identityId,
      publicKey: row.publicKey,
      createdAt: row.createdAt,
      supersedesIdentityId: row.supersedesIdentityId,
      supersededAt: row.supersededAt,
      acknowledgedAt: row.acknowledgedAt,
    );
  }

  /// Whether at least one journal entry has ever been recorded - used by
  /// the app router to know whether a first-time user still needs the
  /// guided first-entry screen before the recovery-phrase acknowledgment
  /// flow (deferred-onboarding-first-entry).
  Future<bool> hasAnyJournalEntries() async {
    final row = await (_db.select(
      _db.journalEntries,
    )..limit(1)).getSingleOrNull();
    return row != null;
  }

  /// Closes the underlying database connection. Only meaningful
  /// immediately before replacing the database file out from under it
  /// (see [LedgerBackupRepository.restoreLedgerBackup]) - this repository
  /// instance is unusable afterward.
  Future<void> close() => _db.close();

  // ---------------------------------------------------------------------
  // Register / summary reads.
  // ---------------------------------------------------------------------

  /// Reactive stream of the register: every posted entry with its
  /// postings, ordered chronologically by transaction date. Includes each
  /// entry's current verification status from `entry_verification_cache`
  /// (spec: "Quarantine of Entries After a Break").
  Stream<List<JournalEntry>> watchEntries() {
    final query =
        _db.select(_db.journalEntries).join([
          leftOuterJoin(
            _db.postings,
            _db.postings.entryId.equalsExp(_db.journalEntries.id),
          ),
          leftOuterJoin(
            _db.entryVerificationCache,
            _db.entryVerificationCache.entryId.equalsExp(_db.journalEntries.id),
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
    final verificationByEntry = <String, EntryVerificationRow>{};

    for (final row in rows) {
      final entry = row.readTable(_db.journalEntries);
      entryRows[entry.id] = entry;
      final posting = row.readTableOrNull(_db.postings);
      if (posting != null) {
        postingsByEntry.putIfAbsent(entry.id, () => []).add(posting);
      }
      final verification = row.readTableOrNull(_db.entryVerificationCache);
      if (verification != null) {
        verificationByEntry[entry.id] = verification;
      }
    }

    final supersededEntryIds = <String>{
      for (final entry in entryRows.values) ?entry.migratedFromEntryId,
    };

    return entryRows.values
        .map(
          (entry) => _toDomainEntry(
            entry,
            postingsByEntry[entry.id] ?? const [],
            verificationByEntry[entry.id],
            supersededEntryIds.contains(entry.id),
          ),
        )
        .toList();
  }

  JournalEntry _toDomainEntry(
    JournalEntryRow entry,
    List<PostingRow> postings,
    EntryVerificationRow? verification,
    bool isSupersededByMigration,
  ) {
    return JournalEntry(
      id: entry.id,
      transactionDate: DateTime.parse(entry.transactionDate),
      recordedAt: entry.recordedAt,
      description: entry.description,
      reversesEntryId: entry.reversesEntryId,
      postings: postings.map(_toDomainPosting).toList(),
      deviceChainSequence: entry.deviceChainSequence,
      entryHash: entry.entryHash,
      signedByIdentityId: entry.signedByIdentityId,
      signature: entry.signature,
      migratedFromEntryId: entry.migratedFromEntryId,
      // No cache row yet (e.g. immediately after insert, before the next
      // verification pass populates it) defaults to verified - matches
      // the immediate cache write recordTransaction/reverseEntry already
      // perform for the entry they just created.
      isVerified: verification?.isVerified ?? true,
      breakReason: verification?.breakReason,
      isSupersededByMigration: isSupersededByMigration,
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

  /// Used by [recordTransaction], [recordTransfer], and
  /// [AccountRepository.archiveFinancialAccount] - throws [AccountGroupException] (not
  /// [InvalidTransferException], which is reserved for transfer-specific
  /// validation like same-account/non-positive-amount) so every caller's
  /// existing catch clause for "not a valid financial account" applies
  /// uniformly.
  Future<AccountRow> _requireActiveFinancialAccount(String id) async {
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

  /// The ISO 4217 currency of [accountRow]'s group - never null in
  /// practice for a reachable financial account (the currency-backfill
  /// gate runs before any account-creation UI, and group assignment is
  /// mandatory), but defensively rejected rather than silently treating a
  /// backfill-pending group as some default currency.
  Future<String> _groupCurrencyFor(AccountRow accountRow) async {
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

  /// Internal duplicate of [AccountRepository.watchFinancialAccounts],
  /// kept private here so [watchHomeOverview]/[exportLedgerCsv] don't
  /// need a dependency on AccountRepository (which itself depends on
  /// this class - see design.md D2).
  Stream<List<Account>> _watchFinancialAccounts({
    bool includeArchived = false,
  }) {
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
    return query.watch().map((rows) => rows.map(_toDomainAccount).toList());
  }

  /// Internal duplicate of [CategoryRepository.watchCategories], kept
  /// private here so [exportLedgerCsv] doesn't need a dependency on
  /// CategoryRepository - design.md D2 keeps this class dependency-free
  /// until group 4 adds AccountRepository, so no new repository
  /// dependency is introduced a group early just for this one read.
  Stream<List<Account>> _watchCategories({bool includeArchived = false}) {
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

  /// Internal duplicate of [AccountRepository.watchAccountGroups] - see
  /// [_watchFinancialAccounts].
  Stream<List<AccountGroup>> _watchAccountGroups({
    bool includeArchived = false,
  }) {
    final query = _db.select(_db.accountGroups)
      ..orderBy([(g) => OrderingTerm.asc(g.sortOrder)]);
    if (!includeArchived) {
      query.where((g) => g.archivedAt.isNull());
    }
    return query.watch().map((rows) => rows.map(_toDomainGroup).toList());
  }

  AccountGroup _toDomainGroup(AccountGroupRow row) {
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

  /// Validates `amountMinor > 0`, derives the two postings, stamps
  /// recorded_at automatically via DateTime.now() (never user-supplied),
  /// hashes/chains/signs the entry (ledger-integrity-signing), and writes
  /// everything in one Drift transaction.
  ///
  /// Option A sign table: money in → financial `+amount`; money out →
  /// financial `−amount` (same for asset and liability).
  ///
  /// If [nativeCurrency] differs from the financial account's group
  /// currency, this is a foreign-currency transaction
  /// (multi-currency-support design.md Decisions 6-7): the category leg
  /// always posts [amountMinor] immediately in [nativeCurrency] (it's
  /// already certain). If [accountCurrencyAmountMinor] is supplied (the
  /// rate/fee was known upfront), a single complete entry posts both legs
  /// now. If it's null, the account leg posts provisionally against the
  /// Transfers-in-transit account instead, pending a later
  /// [settlePendingTransfer] call once the real charged amount is known.
  /// When [nativeCurrency] is null or matches the account's own currency,
  /// this is an ordinary same-currency transaction and
  /// [accountCurrencyAmountMinor] must not be supplied.
  Future<String> recordTransaction({
    required int amountMinor,
    required TransactionDirection direction,
    required String categoryId,
    required String financialAccountId,
    required DateTime transactionDate,
    String? description,
    String? nativeCurrency,
    int? accountCurrencyAmountMinor,
  }) async {
    if (amountMinor <= 0) {
      throw InvalidTransactionAmountException(
        'Transaction amount must be positive and non-zero, got $amountMinor.',
        code: AppErrorCode.amountMustBePositive,
      );
    }

    final account = await _requireActiveFinancialAccount(financialAccountId);
    final accountCurrency = await _groupCurrencyFor(account);
    final isForeignCurrency =
        nativeCurrency != null && nativeCurrency != accountCurrency;

    if (!isForeignCurrency && accountCurrencyAmountMinor != null) {
      throw InvalidTransactionAmountException(
        'accountCurrencyAmountMinor must not be supplied for a '
        'same-currency transaction.',
        code: AppErrorCode.accountCurrencyAmountNotForSameCurrency,
      );
    }

    final (categorySign, clearingOrFinancialSign) = switch (direction) {
      TransactionDirection.moneyIn => (-1, 1),
      TransactionDirection.moneyOut => (1, -1),
    };

    if (!isForeignCurrency) {
      return appendSignedEntry(
        transactionDate: dateOnly(transactionDate),
        description: description,
        reversesEntryId: null,
        postings: [
          (
            accountId: financialAccountId,
            amountMinor: clearingOrFinancialSign * amountMinor,
            lineNumber: 1,
          ),
          (
            accountId: categoryId,
            amountMinor: categorySign * amountMinor,
            lineNumber: 2,
          ),
        ],
      );
    }

    if (accountCurrencyAmountMinor != null) {
      if (accountCurrencyAmountMinor <= 0) {
        throw InvalidTransactionAmountException(
          'Account-currency amount must be positive and non-zero, '
          'got $accountCurrencyAmountMinor.',
          code: AppErrorCode.accountCurrencyAmountMustBePositive,
        );
      }
      return appendSignedEntry(
        transactionDate: dateOnly(transactionDate),
        description: description,
        reversesEntryId: null,
        postings: [
          (
            accountId: financialAccountId,
            amountMinor: clearingOrFinancialSign * accountCurrencyAmountMinor,
            lineNumber: 1,
          ),
          (
            accountId: categoryId,
            amountMinor: categorySign * amountMinor,
            lineNumber: 2,
          ),
        ],
      );
    }

    return _postProvisionalEntry(
      kind: PendingTransferKind.foreignTransaction,
      sourceAccountId: financialAccountId,
      currency: nativeCurrency,
      categoryId: categoryId,
      clearingAmountMinor: clearingOrFinancialSign * amountMinor,
      otherLeg: (
        accountId: categoryId,
        amountMinor: categorySign * amountMinor,
      ),
      transactionDate: transactionDate,
      description: description,
    );
  }

  /// Records a transaction split across two or more categories (spec:
  /// "Record a Transaction" - split-transactions design.md Decision 2).
  /// Posts one financial-account leg for the full total and one posting
  /// per [splitLines] entry - the N=1 case of this is exactly
  /// [recordTransaction]'s same-currency path, just expressed generically.
  /// Every line's amount and category are validated before anything
  /// posts: a rejected split posts nothing, not a partial entry.
  ///
  /// No foreign-currency support for v1 (design.md's mechanics only cover
  /// same-currency posting) - a split transaction always posts in the
  /// financial account's own currency.
  Future<String> recordSplitTransaction({
    required int totalAmountMinor,
    required List<({String categoryId, int amountMinor})> splitLines,
    required TransactionDirection direction,
    required String financialAccountId,
    required DateTime transactionDate,
    String? description,
  }) async {
    if (totalAmountMinor <= 0) {
      throw InvalidTransactionAmountException(
        'Transaction amount must be positive and non-zero, got $totalAmountMinor.',
        code: AppErrorCode.amountMustBePositive,
      );
    }
    if (splitLines.length < 2) {
      throw InvalidTransactionAmountException(
        'A split needs at least two category lines, got ${splitLines.length}.',
        code: AppErrorCode.splitNeedsTwoLines,
      );
    }
    for (var i = 0; i < splitLines.length; i++) {
      final amount = splitLines[i].amountMinor;
      if (amount <= 0) {
        throw InvalidTransactionAmountException(
          'Split line ${i + 1} (${splitLines[i].categoryId}) must be '
          'positive and non-zero, got $amount.',
          code: AppErrorCode.splitLineMustBePositive,
        );
      }
    }
    final linesTotal = splitLines.fold<int>(
      0,
      (sum, line) => sum + line.amountMinor,
    );
    if (linesTotal != totalAmountMinor) {
      throw InvalidTransactionAmountException(
        'Split lines sum to $linesTotal, which does not match the '
        'transaction total of $totalAmountMinor.',
        code: AppErrorCode.splitLinesMustSumToTotal,
      );
    }

    await _requireActiveFinancialAccount(financialAccountId);

    final expectedType = direction == TransactionDirection.moneyIn
        ? AccountType.income
        : AccountType.expense;
    for (var i = 0; i < splitLines.length; i++) {
      await _requireActiveCategoryOfType(
        splitLines[i].categoryId,
        expectedType,
        lineNumber: i + 1,
      );
    }

    final (categorySign, financialSign) = switch (direction) {
      TransactionDirection.moneyIn => (-1, 1),
      TransactionDirection.moneyOut => (1, -1),
    };

    final postings = <({String accountId, int amountMinor, int lineNumber})>[
      (
        accountId: financialAccountId,
        amountMinor: financialSign * totalAmountMinor,
        lineNumber: 1,
      ),
      for (var i = 0; i < splitLines.length; i++)
        (
          accountId: splitLines[i].categoryId,
          amountMinor: categorySign * splitLines[i].amountMinor,
          lineNumber: i + 2,
        ),
    ];

    return appendSignedEntry(
      transactionDate: dateOnly(transactionDate),
      description: description,
      reversesEntryId: null,
      postings: postings,
    );
  }

  Future<void> _requireActiveCategoryOfType(
    String id,
    AccountType expectedType, {
    required int lineNumber,
  }) async {
    final row = await (_db.select(
      _db.accounts,
    )..where((a) => a.id.equals(id))).getSingleOrNull();
    if (row == null || row.type != expectedType || row.archivedAt != null) {
      final typeLabel = expectedType == AccountType.income
          ? 'Income'
          : 'Expense';
      throw InvalidTransactionAmountException(
        'Split line $lineNumber ($id) is not an active $typeLabel category.',
      );
    }
  }

  /// Same-currency transfer (unchanged single-entry behavior) when both
  /// accounts' groups share a currency. Otherwise a cross-currency
  /// transfer (multi-currency-support design.md Decisions 4/6): if
  /// [destinationAmountMinor] is supplied (the rate was known upfront), a
  /// single complete entry posts both currencies now; if it's null, the
  /// source leg posts provisionally against the Transfers-in-transit
  /// account, pending a later [settlePendingTransfer] call.
  Future<void> recordTransfer({
    required String fromAccountId,
    required String toAccountId,
    required int amountMinor,
    required DateTime transactionDate,
    String? description,
    int? destinationAmountMinor,
  }) async {
    if (amountMinor <= 0) {
      throw InvalidTransferException(
        'Transfer amount must be positive and non-zero, got $amountMinor.',
        code: AppErrorCode.transferAmountMustBePositive,
      );
    }
    if (fromAccountId == toAccountId) {
      throw InvalidTransferException(
        'Source and destination accounts must be distinct.',
        code: AppErrorCode.transferAccountsMustDiffer,
      );
    }
    final fromAccount = await _requireActiveFinancialAccount(fromAccountId);
    final toAccount = await _requireActiveFinancialAccount(toAccountId);
    await postTransferEntry(
      fromAccount: fromAccount,
      toAccount: toAccount,
      amountMinor: amountMinor,
      transactionDate: transactionDate,
      description: description,
      destinationAmountMinor: destinationAmountMinor,
    );
  }

  /// Shared posting for [recordTransfer] and
  /// [AccountRepository.recordArchivedAccountCloseoutTransfer]. Callers
  /// have already resolved and validated both accounts.
  Future<void> postTransferEntry({
    required AccountRow fromAccount,
    required AccountRow toAccount,
    required int amountMinor,
    required DateTime transactionDate,
    String? description,
    int? destinationAmountMinor,
  }) async {
    final fromCurrency = await _groupCurrencyFor(fromAccount);
    final toCurrency = await _groupCurrencyFor(toAccount);
    final isCrossCurrency = fromCurrency != toCurrency;

    if (!isCrossCurrency) {
      if (destinationAmountMinor != null) {
        throw InvalidTransferException(
          'destinationAmountMinor must not be supplied for a '
          'same-currency transfer.',
          code: AppErrorCode.destinationAmountNotForSameCurrency,
        );
      }
      if (fromAccount.holdsInvestments) {
        final cashBalance = await displayBalanceMinor(fromAccount.id);
        if (amountMinor > cashBalance) {
          throw InvalidTransferException(
            'Cannot transfer more than the investment account cash balance '
            '($cashBalance minor units).',
            code: AppErrorCode.investmentCashExceeded,
          );
        }
      }
      await appendSignedEntry(
        transactionDate: dateOnly(transactionDate),
        description: description,
        reversesEntryId: null,
        postings: [
          (accountId: fromAccount.id, amountMinor: -amountMinor, lineNumber: 1),
          (accountId: toAccount.id, amountMinor: amountMinor, lineNumber: 2),
        ],
      );
      return;
    }

    if (destinationAmountMinor != null) {
      if (destinationAmountMinor <= 0) {
        throw InvalidTransferException(
          'Destination amount must be positive and non-zero, '
          'got $destinationAmountMinor.',
          code: AppErrorCode.destinationAmountMustBePositive,
        );
      }
      if (fromAccount.holdsInvestments) {
        final cashBalance = await displayBalanceMinor(fromAccount.id);
        if (amountMinor > cashBalance) {
          throw InvalidTransferException(
            'Cannot transfer more than the investment account cash balance '
            '($cashBalance minor units).',
            code: AppErrorCode.investmentCashExceeded,
          );
        }
      }
      await appendSignedEntry(
        transactionDate: dateOnly(transactionDate),
        description: description,
        reversesEntryId: null,
        postings: [
          (accountId: fromAccount.id, amountMinor: -amountMinor, lineNumber: 1),
          (
            accountId: toAccount.id,
            amountMinor: destinationAmountMinor,
            lineNumber: 2,
          ),
        ],
      );
      return;
    }

    await _postProvisionalEntry(
      kind: PendingTransferKind.transfer,
      sourceAccountId: fromAccount.id,
      currency: fromCurrency,
      destinationAccountId: toAccount.id,
      clearingAmountMinor: amountMinor,
      otherLeg: (accountId: fromAccount.id, amountMinor: -amountMinor),
      transactionDate: transactionDate,
      description: description,
    );
  }

  /// Posts the provisional entry (the known leg + the Transfers-in-transit
  /// leg) and the matching `pending_transfers` row atomically - Drift
  /// nests the inner [appendSignedEntry] transaction inside this one, so
  /// either both writes land or neither does (multi-currency-support
  /// design.md Decision 4).
  Future<String> _postProvisionalEntry({
    required PendingTransferKind kind,
    required String sourceAccountId,
    required String currency,
    String? categoryId,
    String? destinationAccountId,
    required int clearingAmountMinor,
    required ({String accountId, int amountMinor}) otherLeg,
    required DateTime transactionDate,
    String? description,
  }) async {
    return _db.transaction(() async {
      final entryId = await appendSignedEntry(
        transactionDate: dateOnly(transactionDate),
        description: description,
        reversesEntryId: null,
        postings: [
          (
            accountId: transfersInTransitAccountId,
            amountMinor: clearingAmountMinor,
            lineNumber: 1,
          ),
          (
            accountId: otherLeg.accountId,
            amountMinor: otherLeg.amountMinor,
            lineNumber: 2,
          ),
        ],
      );
      await _db
          .into(_db.pendingTransfers)
          .insert(
            PendingTransfersCompanion.insert(
              kind: kind,
              sourceAccountId: sourceAccountId,
              currency: currency,
              categoryId: Value(categoryId),
              destinationAccountId: Value(destinationAccountId),
              provisionalEntryId: entryId,
              status: PendingTransferStatus.pending,
              initiatedAt: DateTime.now(),
            ),
          );
      return entryId;
    });
  }

  /// Inserts a new entry with swapped posting amounts, referencing
  /// [entryId] via reverses_entry_id, as an independent action with no
  /// required follow-up. The original entry is never modified.
  ///
  /// The reversal's transaction date is today (when the correction is
  /// actually performed), never backdated to the original entry's date -
  /// an auditable ledger should reflect when a correction really
  /// happened, not disguise it as having occurred earlier.
  ///
  /// Rejected if [entryId] is still the open provisional leg of an
  /// unsettled pending transfer (multi-currency-support design.md
  /// Decision 4) - settle it instead, which achieves the same economic
  /// outcome without leaving `pending_transfers` pointing at a reversed
  /// entry while still reporting status pending.
  Future<void> reverseEntry(String entryId) {
    // The already-reversed guard below must not be a separate check-then-act
    // against the insert in `appendSignedEntry` - two overlapping callers
    // could both pass the guard before either has inserted, posting two
    // reversals for one original. Wrapping the whole method in one
    // transaction closes that window; Drift's transactions nest cleanly
    // (this already composes with `fixPostedTransaction`'s outer
    // transaction, which calls this method internally).
    return _db.transaction(() async {
      final stillPending =
          await (_db.select(_db.pendingTransfers)..where(
                (p) =>
                    p.provisionalEntryId.equals(entryId) &
                    p.status.equalsValue(PendingTransferStatus.pending),
              ))
              .getSingleOrNull();
      if (stillPending != null) {
        throw PendingTransferException(
          'Cannot reverse a provisional entry while its pending transfer is '
          'still unsettled. Settle it instead.',
          code: AppErrorCode.cannotReverseUnsettledProvisional,
        );
      }

      await _guardInvestmentBuyReversal(entryId);

      final alreadyReversed = await (_db.select(
        _db.journalEntries,
      )..where((e) => e.reversesEntryId.equals(entryId))).get();
      if (alreadyReversed.isNotEmpty) {
        throw AlreadyReversedException(
          'This entry has already been corrected. The original line stays '
          'as it is.',
        );
      }

      final original = await (_db.select(
        _db.journalEntries,
      )..where((e) => e.id.equals(entryId))).getSingle();
      final originalPostings = await (_db.select(
        _db.postings,
      )..where((p) => p.entryId.equals(entryId))).get();

      await appendSignedEntry(
        transactionDate: dateOnly(DateTime.now()),
        reversesEntryId: original.id,
        postings: [
          for (final p in originalPostings)
            (
              accountId: p.accountId,
              amountMinor: -p.amountMinor,
              lineNumber: p.lineNumber,
            ),
        ],
      );
    });
  }

  /// One user action, two new signed entries: a reversal of [entryId]
  /// plus a replacement with the corrected fields. Runs in a single
  /// Drift transaction so a failed replacement cannot leave a reversed
  /// original without its substitute (and a retry cannot reverse twice).
  Future<String> fixPostedTransaction({
    required String entryId,
    required int amountMinor,
    required TransactionDirection direction,
    required String categoryId,
    required String financialAccountId,
    required DateTime transactionDate,
    String? description,
  }) {
    return _db.transaction(() async {
      await reverseEntry(entryId);
      return recordTransaction(
        amountMinor: amountMinor,
        direction: direction,
        categoryId: categoryId,
        financialAccountId: financialAccountId,
        transactionDate: transactionDate,
        description: description,
      );
    });
  }

  // ---------------------------------------------------------------------
  // Pending transfers / foreign-currency settlement (multi-currency-support).
  // ---------------------------------------------------------------------

  /// One row per unsettled pending transfer or foreign-currency
  /// transaction, ordered by initiation time - the Home overview's
  /// "Pending transfers" section (design.md Decision 4).
  Stream<List<PendingTransfer>> watchPendingTransfers() {
    final query = _db.select(_db.pendingTransfers)
      ..where((p) => p.status.equalsValue(PendingTransferStatus.pending))
      ..orderBy([(p) => OrderingTerm.asc(p.initiatedAt)]);
    return query.watch().map(
      (rows) => rows.map(_toDomainPendingTransfer).toList(),
    );
  }

  PendingTransfer _toDomainPendingTransfer(PendingTransferRow row) {
    return PendingTransfer(
      id: row.id,
      kind: row.kind,
      sourceAccountId: row.sourceAccountId,
      currency: row.currency,
      categoryId: row.categoryId,
      destinationAccountId: row.destinationAccountId,
      provisionalEntryId: row.provisionalEntryId,
      status: row.status,
      settlementEntryId: row.settlementEntryId,
      feeEntryId: row.feeEntryId,
      initiatedAt: row.initiatedAt,
      settledAt: row.settledAt,
    );
  }

  Future<void> _requireActiveExpenseCategory(String id) async {
    final row = await (_db.select(
      _db.accounts,
    )..where((a) => a.id.equals(id))).getSingleOrNull();
    if (row == null || row.type != AccountType.expense) {
      throw PendingTransferException(
        '$id is not an active Expense category.',
        code: AppErrorCode.notActiveExpenseCategory,
      );
    }
    if (row.archivedAt != null) {
      throw PendingTransferException(
        '$id is not an active Expense category.',
        code: AppErrorCode.notActiveExpenseCategory,
      );
    }
  }

  /// Settles a pending transfer or foreign-currency transaction
  /// (multi-currency-support design.md Decision 5).
  ///
  /// For `kind = transfer`, [settledToAccountId] must be the pending
  /// transfer's own source or destination account. Settling to the
  /// **source** (the transfer bounced/returned) compares [settledAmountMinor]
  /// to the provisional amount - both in the source currency - and posts
  /// any shortfall as a fee/loss entry against [feeCategoryId]. Settling
  /// to the **destination** (normal delivery) posts [settledAmountMinor]
  /// alone in the destination currency, with no shortfall comparison
  /// (there is nothing in that currency to compare it against) and
  /// [feeCategoryId] must not be supplied.
  ///
  /// For `kind = foreignTransaction`, [settledToAccountId] is ignored -
  /// settlement always resolves to the pending transfer's own
  /// `sourceAccountId` (the financial account the transaction was against)
  /// - and always follows the no-shortfall path, the same as settling a
  /// transfer to its destination: the provisional entry's clearing leg was
  /// posted in the transaction's native currency, while settlement is in
  /// the account's own currency, so there is no shared-currency figure to
  /// compare a shortfall against (spec: "Settle a Pending Transfer or
  /// Transaction"). A fee category and a zero settled amount are rejected.
  Future<void> settlePendingTransfer({
    required String pendingTransferId,
    required String settledToAccountId,
    required int settledAmountMinor,
    String? feeCategoryId,
  }) async {
    if (settledAmountMinor < 0) {
      throw PendingTransferException(
        'Settled amount must not be negative, got $settledAmountMinor.',
        code: AppErrorCode.settledAmountMustNotBeNegative,
      );
    }

    final pending = await (_db.select(
      _db.pendingTransfers,
    )..where((p) => p.id.equals(pendingTransferId))).getSingleOrNull();
    if (pending == null) {
      throw PendingTransferException(
        'Pending transfer $pendingTransferId not found.',
        code: AppErrorCode.pendingTransferNotFound,
      );
    }
    if (pending.status == PendingTransferStatus.settled) {
      throw PendingTransferException(
        'Pending transfer $pendingTransferId is already settled.',
        code: AppErrorCode.pendingTransferAlreadySettled,
      );
    }

    final resolvedTarget =
        pending.kind == PendingTransferKind.foreignTransaction
        ? pending.sourceAccountId
        : settledToAccountId;
    if (pending.kind == PendingTransferKind.transfer &&
        resolvedTarget != pending.sourceAccountId &&
        resolvedTarget != pending.destinationAccountId) {
      throw PendingTransferException(
        'settledToAccountId must be the pending transfer\'s own source or '
        'destination account.',
        code: AppErrorCode.settledToMustBeSourceOrDestination,
      );
    }

    // Shortfall comparison only applies to a transfer settling back to its
    // own source - never a transfer settling to its destination, and never
    // a foreignTransaction (see method doc for why).
    final isShortfallComparable =
        pending.kind == PendingTransferKind.transfer &&
        resolvedTarget == pending.sourceAccountId;

    if (!isShortfallComparable && feeCategoryId != null) {
      throw PendingTransferException(
        'feeCategoryId is only applicable when settling a transfer back to '
        'its own source account.',
        code: AppErrorCode.feeCategoryOnlyWhenReturningToSource,
      );
    }
    // The destination-delivery / foreignTransaction path has no fee
    // mechanism to close a shortfall with - a settlement of exactly zero
    // would post no entry at all (guarded below) and permanently leave the
    // Transfers-in-transit position for this item unclosed even though
    // status flips to settled. A genuine total loss is a shortfall-path
    // concept (settle back to the source for 0, which the fee entry
    // covers in full) - reject zero here instead of silently no-opping.
    if (!isShortfallComparable && settledAmountMinor == 0) {
      throw PendingTransferException(
        'Settled amount must be positive when settling to the destination '
        'or a foreign-currency transaction - use the source-account path '
        'for a total loss.',
        code: AppErrorCode.settledAmountMustBePositiveForDelivery,
      );
    }

    final provisionalPostings = await (_db.select(
      _db.postings,
    )..where((p) => p.entryId.equals(pending.provisionalEntryId))).get();
    final clearingPosting = provisionalPostings.firstWhere(
      (p) => p.accountId == transfersInTransitAccountId,
    );
    final clearingPhase1Sign = clearingPosting.amountMinor < 0 ? -1 : 1;
    final provisionalAmountAbs = clearingPosting.amountMinor.abs();

    if (isShortfallComparable && settledAmountMinor > provisionalAmountAbs) {
      throw PendingTransferException(
        'Settled amount ($settledAmountMinor) cannot exceed the provisional '
        'amount ($provisionalAmountAbs) when settling back to the source '
        'account.',
        code: AppErrorCode.settledAmountExceedsProvisional,
      );
    }

    final shortfall = isShortfallComparable
        ? provisionalAmountAbs - settledAmountMinor
        : 0;
    if (shortfall > 0 && feeCategoryId == null) {
      throw PendingTransferException(
        'feeCategoryId is required when the settled amount is less than '
        'the provisional amount.',
      );
    }
    if (feeCategoryId != null) {
      await _requireActiveExpenseCategory(feeCategoryId);
    }

    await _db.transaction(() async {
      String? settlementEntryId;
      if (settledAmountMinor > 0) {
        settlementEntryId = await appendSignedEntry(
          transactionDate: dateOnly(DateTime.now()),
          description: 'Settlement',
          reversesEntryId: null,
          postings: [
            (
              accountId: resolvedTarget,
              amountMinor: clearingPhase1Sign * settledAmountMinor,
              lineNumber: 1,
            ),
            (
              accountId: transfersInTransitAccountId,
              amountMinor: -clearingPhase1Sign * settledAmountMinor,
              lineNumber: 2,
            ),
          ],
        );
      }

      String? feeEntryId;
      if (shortfall > 0) {
        feeEntryId = await appendSignedEntry(
          transactionDate: dateOnly(DateTime.now()),
          description: 'Transfer fee / shortfall',
          reversesEntryId: null,
          postings: [
            (
              accountId: feeCategoryId!,
              amountMinor: clearingPhase1Sign * shortfall,
              lineNumber: 1,
            ),
            (
              accountId: transfersInTransitAccountId,
              amountMinor: -clearingPhase1Sign * shortfall,
              lineNumber: 2,
            ),
          ],
        );
      }

      await (_db.update(
        _db.pendingTransfers,
      )..where((p) => p.id.equals(pendingTransferId))).write(
        PendingTransfersCompanion(
          status: const Value(PendingTransferStatus.settled),
          settlementEntryId: Value(settlementEntryId),
          feeEntryId: Value(feeEntryId),
          settledAt: Value(DateTime.now()),
        ),
      );
    });
  }

  Future<({int portfolioMinor, int bookMinor})> _portfolioForInvestmentAccount({
    required String accountId,
    required int cashMinor,
    required String groupCurrency,
  }) async {
    final holdings = await computeInstrumentHoldingsForAccount(
      _db,
      accountId: accountId,
      groupCurrency: groupCurrency,
    );
    var marketInventory = 0;
    var bookInventory = 0;
    for (final holding in holdings) {
      marketInventory += holding.displayMarketValueMinor;
      bookInventory += holding.totalCostMinor;
    }
    return (
      portfolioMinor: cashMinor + marketInventory,
      bookMinor: cashMinor + bookInventory,
    );
  }

  Stream<void> _tickOn(Iterable<Stream<dynamic>> streams) {
    late StreamController<void> controller;
    final subs = <StreamSubscription<dynamic>>[];
    controller = StreamController<void>(
      onListen: () {
        for (final stream in streams) {
          subs.add(
            stream.listen((_) {
              if (!controller.isClosed) controller.add(null);
            }),
          );
        }
      },
      onCancel: () async {
        for (final sub in subs) {
          await sub.cancel();
        }
      },
    );
    return controller.stream;
  }

  Future<void> _guardInvestmentBuyReversal(String entryId) async {
    final lot = await (_db.select(
      _db.investmentLots,
    )..where((l) => l.journalEntryId.equals(entryId))).getSingleOrNull();
    if (lot == null) return;

    final events = await loadInvestmentReplayEvents(
      _db,
      accountId: lot.accountId,
      instrumentId: lot.instrumentId,
    );
    if (!canReverseBuy(events: events, excludedBuyEntryId: entryId)) {
      final blockingSells = events
          .where(
            (e) =>
                e.kind == InvestmentReplayEventKind.sell &&
                e.journalEntryId != entryId,
          )
          .map((e) => e.journalEntryId)
          .toList();
      throw InvestmentReversalBlockedException(
        'Cannot reverse this buy: later sell(s) depend on its units. '
        'Reverse dependent sell(s) first: ${blockingSells.join(", ")}.',
        params: {'sells': blockingSells.join(', ')},
      );
    }
  }

  /// Shared by [recordTransaction] and [reverseEntry]: computes the
  /// canonical hash, signs it, chains onto the current trusted tip, and
  /// writes the entry + postings + an immediate "verified" cache row in
  /// one transaction. If the trusted tip currently lags behind the
  /// physically last-inserted entry (a chain break was detected and not
  /// yet re-anchored by new activity), this is the re-anchor moment and a
  /// `CHAIN_REANCHORED` integrity event is recorded (spec: "Re-anchoring
  /// After a Break"). Returns the new entry's id.
  Future<String> appendSignedEntry({
    required String transactionDate,
    String? description,
    String? reversesEntryId,
    required List<({String accountId, int amountMinor, int lineNumber})>
    postings,
  }) async {
    final identity = await _currentSigningIdentity();
    if (identity == null) {
      throw StateError(
        'No signing identity is set up on this device - '
        'confirmFirstIdentity/restoreIdentity must run before recording a transaction.',
      );
    }

    return _db.transaction(() async {
      final chainState = await _chainState();
      final priorLastEntry =
          await (_db.select(_db.journalEntries)
                ..orderBy([(e) => OrderingTerm.desc(e.deviceChainSequence)])
                ..limit(1))
              .getSingleOrNull();
      final isReanchor =
          priorLastEntry != null &&
          priorLastEntry.id != chainState.trustedTipEntryId;

      final previousHash =
          chainState.trustedTipHash ??
          Uint8List.fromList(genesisPreviousEntryHash);
      final sequence = chainState.nextDeviceChainSequence;
      final id = const Uuid().v4();
      final recordedAt = truncateToStoredPrecision(DateTime.now());

      final canonicalPostings = postings
          .map(
            (p) => CanonicalPosting(
              lineNumber: p.lineNumber,
              accountId: p.accountId,
              amountMinor: p.amountMinor,
            ),
          )
          .toList();

      final bytes = canonicalEntryBytes(
        previousEntryHash: previousHash,
        id: id,
        deviceChainSequence: sequence,
        transactionDate: transactionDate,
        recordedAt: recordedAt,
        description: description,
        reversesEntryId: reversesEntryId,
        signedByIdentityId: identity.identityId,
        postings: canonicalPostings,
      );
      final entryHash = await hashCanonicalEntry(bytes);
      final signature = await _signingKeyService.sign(entryHash);

      await _db
          .into(_db.journalEntries)
          .insert(
            JournalEntriesCompanion.insert(
              id: Value(id),
              transactionDate: transactionDate,
              recordedAt: recordedAt,
              description: Value(description),
              reversesEntryId: Value(reversesEntryId),
              deviceChainSequence: sequence,
              previousEntryHash: previousHash,
              entryHash: entryHash,
              signedByIdentityId: identity.identityId,
              signature: signature,
            ),
          );

      for (final p in postings) {
        await _db
            .into(_db.postings)
            .insert(
              PostingsCompanion.insert(
                entryId: id,
                accountId: p.accountId,
                amountMinor: p.amountMinor,
                lineNumber: p.lineNumber,
              ),
            );
      }

      await _upsertVerificationCache(
        entryId: id,
        isVerified: true,
        breakReason: null,
      );

      if (isReanchor) {
        await _db
            .into(_db.integrityEvents)
            .insert(
              IntegrityEventsCompanion.insert(
                eventType: IntegrityEventType.chainReanchored,
                relatedEntryId: Value(id),
                detail: Value(
                  'Re-anchored onto ${chainState.trustedTipEntryId ?? "genesis"} '
                  'after a chain break; entry $id is the first post-break entry.',
                ),
              ),
            );
      }

      await _updateChainState(
        trustedTipEntryId: id,
        trustedTipHash: entryHash,
        nextDeviceChainSequence: sequence + 1,
      );

      return id;
    });
  }

  Future<ChainStateRow> _chainState() async {
    final existing =
        await (_db.select(_db.ledgerChainState)
              ..where((t) => t.id.equals(ledgerChainStateSingletonId)))
            .getSingleOrNull();
    if (existing != null) return existing;
    return _db
        .into(_db.ledgerChainState)
        .insertReturning(
          LedgerChainStateCompanion.insert(
            id: ledgerChainStateSingletonId,
            nextDeviceChainSequence: 0,
          ),
        );
  }

  Future<void> _updateChainState({
    required String? trustedTipEntryId,
    required Uint8List? trustedTipHash,
    required int nextDeviceChainSequence,
  }) {
    return _db
        .into(_db.ledgerChainState)
        .insertOnConflictUpdate(
          LedgerChainStateCompanion(
            id: const Value(ledgerChainStateSingletonId),
            trustedTipEntryId: Value(trustedTipEntryId),
            trustedTipHash: Value(trustedTipHash),
            nextDeviceChainSequence: Value(nextDeviceChainSequence),
          ),
        );
  }

  Future<void> _upsertVerificationCache({
    required String entryId,
    required bool isVerified,
    required VerificationBreakReason? breakReason,
  }) {
    return _db
        .into(_db.entryVerificationCache)
        .insertOnConflictUpdate(
          EntryVerificationCacheCompanion.insert(
            entryId: entryId,
            isVerified: isVerified,
            breakReason: Value(breakReason),
            checkedAt: DateTime.now(),
          ),
        );
  }

  Stream<List<JournalEntry>> watchEntriesForAccount(String financialAccountId) {
    return watchEntries().map(
      (entries) => entries
          .where(
            (e) => e.postings.any((p) => p.accountId == financialAccountId),
          )
          .toList(),
    );
  }

  /// Display-balance contribution of one posting on a financial account.
  /// Asset: raw amount. Liability owed: negated amount (Option A).
  static int displayBalanceDeltaFor({
    required AccountType accountType,
    required int postingAmountMinor,
  }) {
    return switch (accountType) {
      AccountType.asset => postingAmountMinor,
      AccountType.liability => -postingAmountMinor,
      AccountType.equity ||
      AccountType.clearing ||
      AccountType.inventory ||
      AccountType.income ||
      AccountType.expense => 0,
    };
  }

  /// Current display balance for a financial account (quarantine/supersession
  /// exclusions applied).
  Future<int> displayBalanceMinor(String financialAccountId) async {
    final account = await (_db.select(
      _db.accounts,
    )..where((a) => a.id.equals(financialAccountId))).getSingle();
    final entries = await watchEntriesForAccount(financialAccountId).first;
    var balance = 0;
    for (final entry in entries) {
      if (!entry.isVerified || entry.isSupersededByMigration) continue;
      for (final posting in entry.postings) {
        if (posting.accountId != financialAccountId) continue;
        balance += displayBalanceDeltaFor(
          accountType: account.type,
          postingAmountMinor: posting.amountMinor,
        );
      }
    }
    return balance;
  }

  /// A CSV of [financialAccountId]'s transactions between [start] and
  /// [end] (inclusive, by transaction date), oldest first (spec:
  /// "Ledger Data Export"). Never includes signing-key material - only
  /// the same date/description/category/amount data already shown in
  /// that account's Register.
  ///
  /// One row per category leg: an ordinary transaction has exactly one,
  /// so this reduces to one row per entry; a split-transactions entry
  /// gets one row per category line, each with that line's own amount
  /// (not the entry's total) so the exported rows sum correctly per
  /// entry. A transfer's row uses the counterparty account's name; an
  /// opening-balance entry is labeled as such. A "Verified" column notes
  /// whether the entry's signature still chains correctly - a quarantined
  /// entry is still exported, never silently dropped, matching the
  /// Register's own "still shown, never hidden" treatment.
  Future<String> exportLedgerCsv({
    required String financialAccountId,
    required DateTime start,
    required DateTime end,
  }) async {
    final account = await (_db.select(
      _db.accounts,
    )..where((a) => a.id.equals(financialAccountId))).getSingleOrNull();
    if (account == null ||
        (account.type != AccountType.asset &&
            account.type != AccountType.liability)) {
      throw AccountGroupException(
        'Account $financialAccountId is not a financial account.',
        code: AppErrorCode.accountNotFinancial,
      );
    }
    final startDate = dateOnly(start);
    final endDate = dateOnly(end);

    final entries = await watchEntriesForAccount(financialAccountId).first;
    final inRange = entries.where((e) {
      final entryDate = dateOnly(e.transactionDate);
      return entryDate.compareTo(startDate) >= 0 &&
          entryDate.compareTo(endDate) <= 0;
    }).toList()..sort((a, b) => a.transactionDate.compareTo(b.transactionDate));

    final categories = await _watchCategories(includeArchived: true).first;
    final categoriesById = {for (final c in categories) c.id: c};
    final allAccounts = await _watchFinancialAccounts(
      includeArchived: true,
    ).first;
    final accountsById = {for (final a in allAccounts) a.id: a};

    final buffer = StringBuffer()
      ..writeln('Date,Description,Category,Direction,Amount,Currency,Verified');
    final currency = await _groupCurrencyFor(account);

    for (final entry in inRange) {
      final ownPosting = entry.postings.firstWhere(
        (p) => p.accountId == financialAccountId,
      );
      final delta = displayBalanceDeltaFor(
        accountType: account.type,
        postingAmountMinor: ownPosting.amountMinor,
      );
      final direction = delta >= 0 ? 'Received' : 'Spent';
      final otherPostings = entry.postings
          .where((p) => p.accountId != financialAccountId)
          .toList();
      final legs = otherPostings.isEmpty ? [ownPosting] : otherPostings;
      for (final leg in legs) {
        final label = leg.accountId == financialAccountId
            ? (delta >= 0 ? 'Received' : 'Spent')
            : _exportCounterpartLabel(
                leg.accountId,
                categoriesById,
                accountsById,
              );
        buffer.writeln(
          [
            dateOnly(entry.transactionDate),
            _csvField(entry.description ?? ''),
            _csvField(label),
            direction,
            _csvAmount(leg.amountMinor.abs(), currency),
            currency,
            entry.isVerified ? 'Yes' : 'No',
          ].join(','),
        );
      }
    }
    return buffer.toString();
  }

  String _exportCounterpartLabel(
    String accountId,
    Map<String, Account> categoriesById,
    Map<String, Account> accountsById,
  ) {
    if (accountId == openingBalanceEquityAccountId) return 'Opening balance';
    final category = categoriesById[accountId];
    if (category != null) return category.name;
    final other = accountsById[accountId];
    if (other != null) return 'Transfer: ${other.name}';
    return 'Transfer';
  }

  /// A plain, locale-independent decimal string (period decimal, no
  /// grouping) for [amountMinor] in [currency] - never [formatAmountMinor]'s
  /// locale-grouped display form, which for a currency like EUR uses a
  /// comma as its *decimal* separator and would silently break this CSV's
  /// own comma delimiting. Still uses each currency's real minor-unit
  /// digit count (0 for JPY, 2 for most others), so the value itself is
  /// accurate - only the presentation is deliberately plain.
  String _csvAmount(int amountMinor, String currency) {
    final digits = minorUnitDigitsForCurrency(currency);
    final major = amountMinor / _pow10(digits);
    return major.toStringAsFixed(digits);
  }

  static int _pow10(int exponent) {
    var result = 1;
    for (var i = 0; i < exponent; i++) {
      result *= 10;
    }
    return result;
  }

  String _csvField(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  Stream<HomeOverview> watchHomeOverview() {
    return _tickOn([
      watchEntries(),
      _watchFinancialAccounts(includeArchived: true),
      _db.select(_db.instrumentQuotes).watch(),
    ]).asyncMap((_) => _buildHomeOverview());
  }

  Future<HomeOverview> _buildHomeOverview() async {
    final groups = await _watchAccountGroups(includeArchived: true).first;
    final accounts = await _watchFinancialAccounts(includeArchived: true).first;
    final entries = await watchEntries().first;
    final pendingRows = await (_db.select(
      _db.pendingTransfers,
    )..where((p) => p.status.equalsValue(PendingTransferStatus.pending))).get();

    final rawSumByAccount = <String, int>{};
    for (final entry in entries) {
      if (!entry.isVerified || entry.isSupersededByMigration) continue;
      for (final posting in entry.postings) {
        rawSumByAccount[posting.accountId] =
            (rawSumByAccount[posting.accountId] ?? 0) + posting.amountMinor;
      }
    }

    int displayFor(Account account) {
      final raw = rawSumByAccount[account.id] ?? 0;
      return displayBalanceDeltaFor(
        accountType: account.type,
        postingAmountMinor: raw,
      );
    }

    final assetsByCurrency = <String, int>{};
    final liabilitiesByCurrency = <String, int>{};
    final sections = <AccountGroupSection>[];

    for (final group in groups) {
      final members = accounts.where((a) => a.groupId == group.id).toList()
        ..sort((a, b) {
          final byOrder = a.sortOrder.compareTo(b.sortOrder);
          return byOrder != 0 ? byOrder : a.name.compareTo(b.name);
        });
      if (members.isEmpty) continue;

      final currency = group.currency;
      final balances = <AccountBalance>[];
      var groupTotal = 0;
      for (final account in members) {
        final cashOrOwed = displayFor(account);
        var display = cashOrOwed;
        int? bookValueMinor;
        var isMarketEstimate = false;
        if (account.isInvestmentAccount && currency != null) {
          final valued = await _portfolioForInvestmentAccount(
            accountId: account.id,
            cashMinor: cashOrOwed,
            groupCurrency: currency,
          );
          display = valued.portfolioMinor;
          bookValueMinor = valued.bookMinor;
          isMarketEstimate = true;
        }
        balances.add(
          AccountBalance(
            account: account,
            displayBalanceMinor: display,
            bookValueMinor: bookValueMinor,
            isMarketEstimate: isMarketEstimate,
          ),
        );
        groupTotal += display;
        if (currency != null) {
          if (account.type == AccountType.asset) {
            assetsByCurrency[currency] =
                (assetsByCurrency[currency] ?? 0) + display;
          } else if (account.type == AccountType.liability) {
            liabilitiesByCurrency[currency] =
                (liabilitiesByCurrency[currency] ?? 0) + display;
          }
        }
      }
      sections.add(
        AccountGroupSection(
          group: group,
          accounts: balances,
          totalDisplayBalanceMinor: groupTotal,
        ),
      );
    }

    // Pending transfers: shown as their own line items, and their
    // provisional amount counts toward their source currency's net
    // position while unsettled - unless the provisional entry itself is
    // quarantined or migration-superseded, in which case it's excluded
    // from the totals but still listed for review (multi-currency-support
    // design.md Decision 2 / spec "A quarantined or superseded provisional
    // entry does not distort net worth").
    final entryById = {for (final e in entries) e.id: e};
    final allAccountRows = await _db.select(_db.accounts).get();
    final nameById = {for (final a in allAccountRows) a.id: a.name};
    final pendingSummaries = <PendingTransferSummary>[];

    for (final row in pendingRows) {
      final provisionalEntry = entryById[row.provisionalEntryId];
      if (provisionalEntry == null) continue;
      final clearingPosting = provisionalEntry.postings.firstWhere(
        (p) => p.accountId == transfersInTransitAccountId,
        orElse: () => provisionalEntry.postings.first,
      );
      final amountAbs = clearingPosting.amountMinor.abs();
      // The currency the clearing leg was actually posted in - the source
      // account's own currency for a transfer, but the transaction's
      // *native* currency for a foreignTransaction, which can differ from
      // the financial account's own group currency (never re-derive this
      // from the source account's group - that mislabels a
      // foreignTransaction's amount with the wrong currency).
      final currency = row.currency;
      final destinationLabel =
          nameById[row.destinationAccountId] ?? nameById[row.categoryId];

      pendingSummaries.add(
        PendingTransferSummary(
          pendingTransfer: _toDomainPendingTransfer(row),
          sourceAccountName:
              nameById[row.sourceAccountId] ?? row.sourceAccountId,
          destinationLabel: destinationLabel,
          currency: currency,
          amountMinor: amountAbs,
        ),
      );

      final isExcluded =
          !provisionalEntry.isVerified ||
          provisionalEntry.isSupersededByMigration;
      if (!isExcluded) {
        assetsByCurrency[currency] =
            (assetsByCurrency[currency] ?? 0) + amountAbs;
      }
    }

    final currencies = {
      ...assetsByCurrency.keys,
      ...liabilitiesByCurrency.keys,
    }.toList()..sort();
    final netPositions = currencies
        .map(
          (currency) => CurrencyNetPosition(
            currency: currency,
            totalAssetsMinor: assetsByCurrency[currency] ?? 0,
            totalLiabilitiesMinor: liabilitiesByCurrency[currency] ?? 0,
          ),
        )
        .toList();

    return HomeOverview(
      sections: sections,
      netPositionsByCurrency: netPositions,
      pendingTransfers: pendingSummaries,
    );
  }

  /// Total income and total expense posted within [start]..[end]
  /// (inclusive), based on transaction date. Both totals are positive
  /// magnitudes; a reversed entry's postings net out automatically since
  /// they carry opposite signs to the original. Postings belonging to a
  /// quarantined (unverified) entry are excluded (spec: "Quarantine of
  /// Entries After a Break"). Transfers and opening balances are excluded
  /// because only income/expense account types accumulate. Optional
  /// [financialAccountId] filters to entries that affect that account.
  Stream<LedgerSummary> watchSummary({
    required DateTime start,
    required DateTime end,
    String? financialAccountId,
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

      Set<String>? entryIdsTouchingAccount;
      if (financialAccountId != null) {
        entryIdsTouchingAccount = {
          for (final row in rows)
            if (row.readTable(_db.postings).accountId == financialAccountId)
              row.readTable(_db.journalEntries).id,
        };
      }

      var totalIncomeMinor = 0;
      var totalExpenseMinor = 0;
      for (final row in rows) {
        final entry = row.readTable(_db.journalEntries);
        if (supersededEntryIds.contains(entry.id)) continue;
        if (entryIdsTouchingAccount != null &&
            !entryIdsTouchingAccount.contains(entry.id)) {
          continue;
        }

        final verification = row.readTableOrNull(_db.entryVerificationCache);
        if (verification != null && !verification.isVerified) continue;

        final account = row.readTable(_db.accounts);
        final posting = row.readTable(_db.postings);
        switch (account.type) {
          case AccountType.income:
            totalIncomeMinor -= posting.amountMinor;
          case AccountType.expense:
            totalExpenseMinor += posting.amountMinor;
          case AccountType.asset:
          case AccountType.liability:
          case AccountType.equity:
          case AccountType.clearing:
          case AccountType.inventory:
            break;
        }
      }
      return LedgerSummary(
        totalIncomeMinor: totalIncomeMinor,
        totalExpenseMinor: totalExpenseMinor,
      );
    });
  }

  /// The append-only audit log of chain breaks, re-anchors, and key
  /// migrations, newest first.
  Stream<List<IntegrityEvent>> watchIntegrityEvents() {
    final query = _db.select(_db.integrityEvents)
      ..orderBy([(t) => OrderingTerm.desc(t.occurredAt)]);
    return query.watch().map(
      (rows) => rows
          .map(
            (row) => IntegrityEvent(
              eventId: row.eventId,
              eventType: row.eventType,
              occurredAt: row.occurredAt,
              relatedEntryId: row.relatedEntryId,
              relatedIdentityId: row.relatedIdentityId,
              detail: row.detail,
            ),
          )
          .toList(),
    );
  }
}
