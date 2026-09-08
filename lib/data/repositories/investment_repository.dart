import 'dart:async';

import 'package:drift/drift.dart';

import '../../domain/exceptions.dart';
import '../../domain/models/instrument.dart';
import '../../domain/models/instrument_holding.dart';
import '../../domain/models/instrument_quote.dart';
import '../database/app_database.dart';
import 'account_chart_reader.dart';
import 'investment_holdings_logic.dart';
import 'investment_trade_posting.dart';
import 'ledger_repository.dart';

/// Instruments, quotes, holdings, and a thin facade over
/// [InvestmentTradePosting] for buy/sell/dividend. Split out of
/// `LedgerRepository` (architecture-deepening design.md D1). Does not
/// take Identity (design.md D2).
class InvestmentRepository {
  InvestmentRepository({
    required AppDatabase database,
    required LedgerRepository ledgerRepository,
    AccountChartReader? chart,
  }) : _db = database,
       _ledgerRepository = ledgerRepository,
       _chart = chart ?? AccountChartReader(database),
       _trade = InvestmentTradePosting(
         database: database,
         ledgerRepository: ledgerRepository,
         chart: chart ?? AccountChartReader(database),
       );

  final AppDatabase _db;
  final LedgerRepository _ledgerRepository;
  final AccountChartReader _chart;
  final InvestmentTradePosting _trade;

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
  }) => _trade.recordBuy(
    accountId: accountId,
    instrumentId: instrumentId,
    quantityScaled: quantityScaled,
    unitPriceMinor: unitPriceMinor,
    transactionDate: transactionDate,
    fundingSource: fundingSource,
    incomeCategoryId: incomeCategoryId,
    lockedUntil: lockedUntil,
    description: description,
    brokerageMinor: brokerageMinor,
    brokerageExpenseCategoryId: brokerageExpenseCategoryId,
  );

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
  }) => _trade.recordSell(
    accountId: accountId,
    instrumentId: instrumentId,
    quantityScaled: quantityScaled,
    unitPriceMinor: unitPriceMinor,
    transactionDate: transactionDate,
    gainIncomeCategoryId: gainIncomeCategoryId,
    lossExpenseCategoryId: lossExpenseCategoryId,
    description: description,
    brokerageMinor: brokerageMinor,
    brokerageExpenseCategoryId: brokerageExpenseCategoryId,
  );

  Future<String> recordDividend({
    required String accountId,
    required String instrumentId,
    required int amountMinor,
    required DateTime transactionDate,
    required String incomeCategoryId,
    String? description,
  }) => _trade.recordDividend(
    accountId: accountId,
    instrumentId: instrumentId,
    amountMinor: amountMinor,
    transactionDate: transactionDate,
    incomeCategoryId: incomeCategoryId,
    description: description,
  );

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
