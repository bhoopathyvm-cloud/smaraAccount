import 'dart:async';

import 'package:drift/drift.dart';

import '../../domain/exceptions.dart';
import '../../domain/models/account.dart';
import '../../domain/models/instrument.dart';
import '../../domain/models/instrument_holding.dart';
import '../../domain/models/instrument_quote.dart';
import '../../domain/models/transaction_direction.dart';
import '../database/app_database.dart';
import '../database/tables/investment_lots_table.dart';
import 'account_chart_reader.dart';
import 'investment_holdings_logic.dart';
import 'ledger_repository.dart';
import 'repository_date_utils.dart';

/// Instruments, quotes, holdings, and buy/sell/dividend posting. Split
/// out of `LedgerRepository` (architecture-deepening design.md D1).
/// Posts through [LedgerRepository.appendSignedEntry] / [LedgerRepository.recordTransaction];
/// does not take Identity (design.md D2).
class InvestmentRepository {
  InvestmentRepository({
    required AppDatabase database,
    required LedgerRepository ledgerRepository,
    AccountChartReader? chart,
  }) : _db = database,
       _ledgerRepository = ledgerRepository,
       _chart = chart ?? AccountChartReader(database);

  final AppDatabase _db;
  final LedgerRepository _ledgerRepository;
  final AccountChartReader _chart;

  Stream<List<Instrument>> watchInstruments({bool includeArchived = false}) {
    final query = _db.select(_db.instruments)
      ..orderBy([(i) => OrderingTerm.asc(i.name)]);
    if (!includeArchived) {
      query.where((i) => i.archivedAt.isNull());
    }
    return query.watch().map((rows) => rows.map(_toDomainInstrument).toList());
  }

  Instrument _toDomainInstrument(InstrumentRow row) {
    return Instrument(
      id: row.id,
      name: row.name,
      kind: row.kind,
      ticker: row.ticker,
      isin: row.isin,
      archived: row.archivedAt != null,
    );
  }

  Future<Instrument> createInstrument({
    required String name,
    required InstrumentKind kind,
    String? ticker,
    String? isin,
  }) async {
    final created = await _db
        .into(_db.instruments)
        .insertReturning(
          InstrumentsCompanion.insert(
            name: name,
            kind: kind,
            ticker: Value(ticker),
            isin: Value(isin),
          ),
        );
    return _toDomainInstrument(created);
  }

  Future<void> renameInstrument({
    required String id,
    required String newName,
  }) async {
    await (_db.update(_db.instruments)..where((i) => i.id.equals(id))).write(
      InstrumentsCompanion(name: Value(newName)),
    );
  }

  Future<void> archiveInstrument(String id) async {
    await (_db.update(_db.instruments)..where((i) => i.id.equals(id))).write(
      InstrumentsCompanion(archivedAt: Value(DateTime.now())),
    );
  }

  Stream<List<InstrumentHolding>> watchHoldingsForAccount(String accountId) {
    return _tickOn([
      watchInstruments(includeArchived: true),
      _db.select(_db.instrumentQuotes).watch(),
      _ledgerRepository.watchEntriesForAccount(accountId),
    ]).asyncMap((_) => computeHoldingsForAccount(accountId));
  }

  /// Instruments that have ever had a lot in [accountId], including
  /// ones currently at zero quantity (ex-dividend / fully sold).
  Stream<List<Instrument>> watchInstrumentsHeldInAccount(String accountId) {
    return watchHoldingsForAccount(accountId).asyncMap((_) async {
      return computeInstrumentsHeldInAccount(accountId);
    });
  }

  Future<List<Instrument>> computeInstrumentsHeldInAccount(
    String accountId,
  ) async {
    final lots = await (_db.select(
      _db.investmentLots,
    )..where((l) => l.accountId.equals(accountId))).get();
    final instrumentIds = lots.map((l) => l.instrumentId).toSet();
    if (instrumentIds.isEmpty) return [];
    final instruments = await (_db.select(
      _db.instruments,
    )..where((i) => i.id.isIn(instrumentIds))).get();
    instruments.sort((a, b) => a.name.compareTo(b.name));
    return instruments.map(_toDomainInstrument).toList();
  }

  Stream<List<InstrumentQuote>> watchInstrumentQuotes() {
    return _db
        .select(_db.instrumentQuotes)
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => InstrumentQuote(
                  instrumentId: row.instrumentId,
                  priceMinor: row.priceMinor,
                  currency: row.currency,
                  fetchedAt: row.fetchedAt,
                ),
              )
              .toList(),
        );
  }

  Future<void> cacheInstrumentQuote({
    required String instrumentId,
    required int priceMinor,
    required String currency,
  }) async {
    final existing = await (_db.select(
      _db.instrumentQuotes,
    )..where((q) => q.instrumentId.equals(instrumentId))).get();
    if (existing.isEmpty) {
      await _db
          .into(_db.instrumentQuotes)
          .insert(
            InstrumentQuotesCompanion.insert(
              instrumentId: instrumentId,
              priceMinor: priceMinor,
              currency: currency,
              fetchedAt: DateTime.now(),
            ),
          );
      return;
    }
    await (_db.update(
      _db.instrumentQuotes,
    )..where((q) => q.instrumentId.equals(instrumentId))).write(
      InstrumentQuotesCompanion(
        priceMinor: Value(priceMinor),
        currency: Value(currency),
        fetchedAt: Value(DateTime.now()),
      ),
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

  Future<String> recordBuy({
    required String accountId,
    required String instrumentId,
    required int quantityScaled,
    required int unitPriceMinor,
    required DateTime transactionDate,
    required BuyFundingSource fundingSource,
    String? incomeCategoryId,
    DateTime? lockedUntil,
    String? description,
    int? brokerageMinor,
    String? brokerageExpenseCategoryId,
  }) async {
    if (quantityScaled <= 0 || unitPriceMinor <= 0) {
      throw const InvestmentException(
        'Buy quantity and unit price must be positive.',
        code: AppErrorCode.buyQuantityAndPriceMustBePositive,
      );
    }
    await _requireInvestmentCashAccount(accountId);
    final instrument = await (_db.select(
      _db.instruments,
    )..where((i) => i.id.equals(instrumentId))).getSingleOrNull();
    if (instrument == null) {
      throw InvestmentException(
        'Instrument $instrumentId not found.',
        code: AppErrorCode.instrumentNotFound,
      );
    }
    if (instrument.archivedAt != null) {
      throw const InvestmentException(
        'Cannot buy an archived instrument.',
        code: AppErrorCode.instrumentArchived,
      );
    }

    final totalCostMinor = multiplyScaledQuantityPrice(
      quantityScaled,
      unitPriceMinor,
    );
    final feeMinor = brokerageMinor;
    final hasBrokerage = feeMinor != null && feeMinor > 0;
    if (fundingSource == BuyFundingSource.nonCash && hasBrokerage) {
      throw const InvestmentException(
        'Non-cash acquisitions cannot include brokerage.',
        code: AppErrorCode.nonCashCannotIncludeBrokerage,
      );
    }
    if (hasBrokerage && brokerageExpenseCategoryId == null) {
      throw const InvestmentException(
        'An active expense category is required when brokerage is positive.',
        code: AppErrorCode.brokerageRequiresExpenseCategory,
      );
    }
    if (hasBrokerage) {
      await _requireActiveExpenseCategory(brokerageExpenseCategoryId!);
    }
    if (fundingSource == BuyFundingSource.nonCash) {
      if (incomeCategoryId == null) {
        throw const InvestmentException(
          'An active income category is required for a non-cash acquisition.',
          code: AppErrorCode.incomeRequiredForNonCash,
        );
      }
      await _requireActiveIncomeCategory(incomeCategoryId);
    } else {
      final cashBalance = await _ledgerRepository.displayBalanceMinor(
        accountId,
      );
      if (totalCostMinor > cashBalance) {
        throw InsufficientCashException(
          'Insufficient cash for buy: need $totalCostMinor minor units, '
          'have $cashBalance.',
        );
      }
    }

    final inventoryAccountId = await _inventoryAccountIdFor(accountId);
    final lotSource = fundingSource == BuyFundingSource.cash
        ? LotSource.cashPurchase
        : LotSource.nonCashAcquisition;

    final entryId = await _db.transaction(() async {
      final postings = <({String accountId, int amountMinor, int lineNumber})>[
        (
          accountId: inventoryAccountId,
          amountMinor: totalCostMinor,
          lineNumber: 1,
        ),
        if (fundingSource == BuyFundingSource.cash)
          (accountId: accountId, amountMinor: -totalCostMinor, lineNumber: 2)
        else
          (
            accountId: incomeCategoryId!,
            amountMinor: -totalCostMinor,
            lineNumber: 2,
          ),
      ];
      final id = await _ledgerRepository.appendSignedEntry(
        transactionDate: dateOnly(transactionDate),
        description: description,
        reversesEntryId: null,
        postings: postings,
      );
      await _db
          .into(_db.investmentLots)
          .insert(
            InvestmentLotsCompanion.insert(
              accountId: accountId,
              instrumentId: instrumentId,
              quantityScaled: quantityScaled,
              unitCostMinor: unitPriceMinor,
              source: lotSource,
              acquiredAt: parseTransactionDate(dateOnly(transactionDate)),
              lockedUntil: Value(lockedUntil),
              journalEntryId: id,
            ),
          );
      return id;
    });

    if (hasBrokerage) {
      try {
        await _ledgerRepository.recordTransaction(
          amountMinor: feeMinor,
          direction: TransactionDirection.moneyOut,
          categoryId: brokerageExpenseCategoryId!,
          financialAccountId: accountId,
          transactionDate: transactionDate,
          description: description == null
              ? 'Brokerage'
              : '$description (brokerage)',
        );
      } on InvalidTransactionAmountException catch (e) {
        throw InvestmentException(
          'Buy posted, but brokerage fee failed: ${e.message}',
          code: AppErrorCode.brokerageFailedAfterBuy,
          params: {'innerCode': e.code.name, ...e.params},
        );
      } on AccountGroupException catch (e) {
        throw InvestmentException(
          'Buy posted, but brokerage fee failed: ${e.message}',
          code: AppErrorCode.brokerageFailedAfterBuy,
          params: {'innerCode': e.code.name, ...e.params},
        );
      }
    }

    return entryId;
  }

  Future<String> recordSell({
    required String accountId,
    required String instrumentId,
    required int quantityScaled,
    required int unitPriceMinor,
    required DateTime transactionDate,
    String? gainIncomeCategoryId,
    String? lossExpenseCategoryId,
    String? description,
    int? brokerageMinor,
    String? brokerageExpenseCategoryId,
  }) async {
    if (quantityScaled <= 0 || unitPriceMinor <= 0) {
      throw const InvestmentException(
        'Sell quantity and unit price must be positive.',
        code: AppErrorCode.sellQuantityAndPriceMustBePositive,
      );
    }
    await _requireInvestmentCashAccount(accountId, allowArchived: true);

    final proceedsMinor = multiplyScaledQuantityPrice(
      quantityScaled,
      unitPriceMinor,
    );
    final feeMinor = brokerageMinor;
    final hasBrokerage = feeMinor != null && feeMinor > 0;
    if (hasBrokerage && proceedsMinor < feeMinor) {
      throw const InvestmentException(
        'Sell proceeds must be at least the brokerage amount.',
        code: AppErrorCode.sellProceedsMustCoverBrokerage,
      );
    }
    if (hasBrokerage && brokerageExpenseCategoryId == null) {
      throw const InvestmentException(
        'An active expense category is required when brokerage is positive.',
        code: AppErrorCode.brokerageRequiresExpenseCategory,
      );
    }
    if (hasBrokerage) {
      await _requireActiveExpenseCategory(brokerageExpenseCategoryId!);
    }

    final events = await loadInvestmentReplayEvents(
      _db,
      accountId: accountId,
      instrumentId: instrumentId,
    );
    final sellDate = parseTransactionDate(dateOnly(transactionDate));
    final metricsBeforeSell = replayInvestmentHistory(events, asOf: sellDate);
    if (quantityScaled > metricsBeforeSell.sellableQuantityScaled) {
      final locked = metricsBeforeSell.lockedQuantityScaled;
      if (locked > 0) {
        final until = metricsBeforeSell.earliestLockedUntil;
        final untilLabel = until == null ? 'a later date' : dateOnly(until);
        throw LockedQuantityException(
          'Cannot sell: some units are locked until $untilLabel.',
          params: {'date': untilLabel},
        );
      }
      throw InsufficientQuantityException(
        'Cannot sell $quantityScaled scaled units: only '
        '${metricsBeforeSell.sellableQuantityScaled} held.',
      );
    }

    final avgCostMinor = metricsBeforeSell.averageCostMinor;
    final costRemovedMinor = multiplyScaledQuantityPrice(
      quantityScaled,
      avgCostMinor,
    );
    final gainLossMinor = proceedsMinor - costRemovedMinor;

    if (gainLossMinor > 0) {
      if (gainIncomeCategoryId == null) {
        throw const InvestmentException(
          'An active income category is required for a realized gain.',
          code: AppErrorCode.incomeRequiredForGain,
        );
      }
      await _requireActiveIncomeCategory(gainIncomeCategoryId);
    } else if (gainLossMinor < 0) {
      if (lossExpenseCategoryId == null) {
        throw const InvestmentException(
          'An active expense category is required for a realized loss.',
          code: AppErrorCode.expenseRequiredForLoss,
        );
      }
      await _requireActiveExpenseCategory(lossExpenseCategoryId);
    }

    final inventoryAccountId = await _inventoryAccountIdFor(accountId);
    final postings = <({String accountId, int amountMinor, int lineNumber})>[
      (accountId: accountId, amountMinor: proceedsMinor, lineNumber: 1),
      (
        accountId: inventoryAccountId,
        amountMinor: -costRemovedMinor,
        lineNumber: 2,
      ),
    ];
    if (gainLossMinor > 0) {
      postings.add((
        accountId: gainIncomeCategoryId!,
        amountMinor: -gainLossMinor,
        lineNumber: 3,
      ));
    } else if (gainLossMinor < 0) {
      postings.add((
        accountId: lossExpenseCategoryId!,
        amountMinor: -gainLossMinor,
        lineNumber: 3,
      ));
    }

    final entryId = await _db.transaction(() async {
      final id = await _ledgerRepository.appendSignedEntry(
        transactionDate: dateOnly(transactionDate),
        description: description,
        reversesEntryId: null,
        postings: postings,
      );
      await _db
          .into(_db.investmentSells)
          .insert(
            InvestmentSellsCompanion.insert(
              accountId: accountId,
              instrumentId: instrumentId,
              quantityScaled: quantityScaled,
              journalEntryId: id,
            ),
          );
      return id;
    });

    if (hasBrokerage) {
      try {
        await _ledgerRepository.recordTransaction(
          amountMinor: feeMinor,
          direction: TransactionDirection.moneyOut,
          categoryId: brokerageExpenseCategoryId!,
          financialAccountId: accountId,
          transactionDate: transactionDate,
          description: description == null
              ? 'Brokerage'
              : '$description (brokerage)',
        );
      } on InvalidTransactionAmountException catch (e) {
        throw InvestmentException(
          'Sell posted, but brokerage fee failed: ${e.message}',
          code: AppErrorCode.brokerageFailedAfterSell,
          params: {'innerCode': e.code.name, ...e.params},
        );
      } on AccountGroupException catch (e) {
        throw InvestmentException(
          'Sell posted, but brokerage fee failed: ${e.message}',
          code: AppErrorCode.brokerageFailedAfterSell,
          params: {'innerCode': e.code.name, ...e.params},
        );
      }
    }

    return entryId;
  }

  Future<String> recordDividend({
    required String accountId,
    required String instrumentId,
    required int amountMinor,
    required DateTime transactionDate,
    required String incomeCategoryId,
    String? description,
  }) async {
    if (amountMinor <= 0) {
      throw const InvestmentException(
        'Dividend amount must be positive.',
        code: AppErrorCode.dividendMustBePositive,
      );
    }
    await _requireInvestmentCashAccount(accountId, allowArchived: true);
    await _requireActiveIncomeCategory(incomeCategoryId);
    final instrument = await (_db.select(
      _db.instruments,
    )..where((i) => i.id.equals(instrumentId))).getSingleOrNull();
    if (instrument == null) {
      throw InvestmentException(
        'Instrument $instrumentId not found.',
        code: AppErrorCode.instrumentNotFound,
      );
    }

    return _ledgerRepository.appendSignedEntry(
      transactionDate: dateOnly(transactionDate),
      description: description,
      reversesEntryId: null,
      postings: [
        (accountId: accountId, amountMinor: amountMinor, lineNumber: 1),
        (accountId: incomeCategoryId, amountMinor: -amountMinor, lineNumber: 2),
      ],
    );
  }

  Future<void> _requireActiveIncomeCategory(String id) =>
      _chart.requireActiveCategoryOfType(
        id,
        AccountType.income,
        onInvalid: (id) => InvestmentException(
          '$id is not an active Income category.',
          code: AppErrorCode.notActiveIncomeCategory,
        ),
      );

  Future<AccountRow> _requireInvestmentCashAccount(
    String id, {
    bool allowArchived = false,
  }) async {
    final row = await (_db.select(
      _db.accounts,
    )..where((a) => a.id.equals(id))).getSingleOrNull();
    if (row == null || row.type != AccountType.asset || !row.holdsInvestments) {
      throw InvestmentException(
        'Account $id is not an investment account.',
        code: AppErrorCode.notInvestmentAccount,
      );
    }
    if (row.archivedAt != null && !allowArchived) {
      throw AccountGroupException(
        'Account $id is archived.',
        code: AppErrorCode.accountArchived,
      );
    }
    return row;
  }

  Future<void> _requireActiveExpenseCategory(String id) =>
      _chart.requireActiveExpenseCategory(id);

  Future<String> _inventoryAccountIdFor(String cashAccountId) async {
    final row =
        await (_db.select(_db.accounts)
              ..where((a) => a.investmentOwnerAccountId.equals(cashAccountId)))
            .getSingleOrNull();
    if (row == null) {
      throw InvestmentException(
        'No inventory companion for investment account $cashAccountId.',
        code: AppErrorCode.noInventoryCompanion,
      );
    }
    return row.id;
  }

  Future<List<InstrumentHolding>> computeHoldingsForAccount(
    String accountId, {
    bool includeZeroQuantity = false,
  }) async {
    var groupCurrency = 'USD';
    final cashRow = await (_db.select(
      _db.accounts,
    )..where((a) => a.id.equals(accountId))).getSingleOrNull();
    if (cashRow != null) {
      try {
        groupCurrency = await _groupCurrencyFor(cashRow);
      } on AccountGroupException {
        // Fall back to USD for display-only valuation.
      }
    }
    return computeInstrumentHoldingsForAccount(
      _db,
      accountId: accountId,
      groupCurrency: groupCurrency,
      includeZeroQuantity: includeZeroQuantity,
    );
  }

  Future<String> _groupCurrencyFor(AccountRow accountRow) =>
      _chart.groupCurrencyFor(accountRow);
}
