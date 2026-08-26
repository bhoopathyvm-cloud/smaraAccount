import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/crypto/entry_canonical_hash.dart';
import '../../domain/crypto/signing_key_service.dart';
import '../../domain/exceptions.dart';
import '../../domain/models/integrity_event.dart';
import '../../domain/models/pending_transfer.dart';
import '../../domain/models/transaction_direction.dart';
import '../database/app_database.dart';
import '../database/tables/accounts_table.dart';
import 'account_chart_reader.dart';
import 'investment_holdings_logic.dart';
import 'ledger_chain_store.dart';
import 'repository_date_utils.dart';

/// Deep posting/signing module: record, reverse, fix, pending-transfer
/// writes, and [appendSignedEntry]. Chart reads go through
/// [AccountChartReader] so this class never depends on AccountRepository
/// (architecture-deepening D1a). Chain tip and identity lookup go through
/// [LedgerChainStore] so posting does not copy IdentityRepository helpers.
///
/// [LedgerRepository] constructs this and delegates its public write
/// methods so existing tests keep building the facade.
class LedgerPosting {
  LedgerPosting({
    required AppDatabase database,
    required AccountChartReader chart,
    required LedgerChainStore chain,
    required Future<int> Function(String financialAccountId)
    displayBalanceMinor,
    SigningKeyService? signingKeyService,
  }) : _db = database,
       _chart = chart,
       _chain = chain,
       _displayBalanceMinor = displayBalanceMinor,
       _signingKeyService = signingKeyService ?? SigningKeyService();

  final AppDatabase _db;
  final AccountChartReader _chart;
  final LedgerChainStore _chain;
  final Future<int> Function(String financialAccountId) _displayBalanceMinor;
  final SigningKeyService _signingKeyService;

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

    final account = await _chart.requireActiveFinancialAccount(
      financialAccountId,
    );
    final accountCurrency = await _chart.groupCurrencyFor(account);
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

    await _chart.requireActiveFinancialAccount(financialAccountId);

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
    final fromAccount = await _chart.requireActiveFinancialAccount(
      fromAccountId,
    );
    final toAccount = await _chart.requireActiveFinancialAccount(toAccountId);
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
    final fromCurrency = await _chart.groupCurrencyFor(fromAccount);
    final toCurrency = await _chart.groupCurrencyFor(toAccount);
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
        final cashBalance = await _displayBalanceMinor(fromAccount.id);
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
        final cashBalance = await _displayBalanceMinor(fromAccount.id);
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
    final identity = await _chain.currentSigningIdentity();
    if (identity == null) {
      throw StateError(
        'No signing identity is set up on this device - '
        'confirmFirstIdentity/restoreIdentity must run before recording a transaction.',
      );
    }

    return _db.transaction(() async {
      final chainState = await _chain.loadState();
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

      await _chain.upsertVerificationCache(
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

      await _chain.updateState(
        trustedTipEntryId: id,
        trustedTipHash: entryHash,
        nextDeviceChainSequence: sequence + 1,
      );

      return id;
    });
  }
}
