import 'package:drift/drift.dart';

import '../../domain/investment/investment_holdings.dart';
import '../../domain/models/instrument.dart';
import '../../domain/models/instrument_holding.dart';
import '../../domain/models/instrument_quote.dart';
import '../database/app_database.dart';

export '../../domain/investment/investment_holdings.dart';

InstrumentHolding toInstrumentHolding({
  required InstrumentRow instrumentRow,
  required InvestmentHoldingMetrics metrics,
  HoldingValuation? valuation,
}) {
  final instrument = Instrument(
    id: instrumentRow.id,
    name: instrumentRow.name,
    kind: instrumentRow.kind,
    ticker: instrumentRow.ticker,
    isin: instrumentRow.isin,
    archived: instrumentRow.archivedAt != null,
  );
  return InstrumentHolding(
    instrument: instrument,
    quantityScaled: metrics.quantityScaled,
    averageCostMinor: metrics.averageCostMinor,
    totalCostMinor: metrics.totalCostMinor,
    sellableQuantityScaled: metrics.sellableQuantityScaled,
    marketValueMinor: valuation?.marketValueMinor,
    unrealizedGainLossMinor: valuation?.unrealizedGainLossMinor,
    quoteUse: valuation?.quoteUse ?? QuoteUse.missing,
  );
}

/// Shared by [InvestmentRepository] and core [LedgerRepository.reverseEntry]
/// / home portfolio valuation so those two classes never take each other
/// as constructor dependencies (architecture-deepening design.md D1a).
Future<Set<String>> reversedOriginalEntryIds(AppDatabase db) async {
  final rows = await (db.select(
    db.journalEntries,
  )..where((e) => e.reversesEntryId.isNotNull())).get();
  return rows.map((e) => e.reversesEntryId!).toSet();
}

Future<List<InvestmentReplayEvent>> loadInvestmentReplayEvents(
  AppDatabase db, {
  required String accountId,
  required String instrumentId,
}) async {
  final reversed = await reversedOriginalEntryIds(db);
  final lots =
      await (db.select(db.investmentLots)..where(
            (l) =>
                l.accountId.equals(accountId) &
                l.instrumentId.equals(instrumentId),
          ))
          .get();
  final sells =
      await (db.select(db.investmentSells)..where(
            (s) =>
                s.accountId.equals(accountId) &
                s.instrumentId.equals(instrumentId),
          ))
          .get();

  final entryIds = {
    ...lots.map((l) => l.journalEntryId),
    ...sells.map((s) => s.journalEntryId),
  };
  if (entryIds.isEmpty) return [];

  final entries = await (db.select(
    db.journalEntries,
  )..where((e) => e.id.isIn(entryIds))).get();
  final entryById = {for (final e in entries) e.id: e};

  final events = <InvestmentReplayEvent>[];
  for (final lot in lots) {
    if (reversed.contains(lot.journalEntryId)) continue;
    final entry = entryById[lot.journalEntryId];
    if (entry == null) continue;
    events.add(
      InvestmentReplayEvent(
        kind: InvestmentReplayEventKind.buy,
        transactionDate: parseTransactionDate(entry.transactionDate),
        recordedAt: entry.recordedAt,
        quantityScaled: lot.quantityScaled,
        unitCostMinor: lot.unitCostMinor,
        lockedUntil: lot.lockedUntil,
        journalEntryId: lot.journalEntryId,
      ),
    );
  }
  for (final sell in sells) {
    if (reversed.contains(sell.journalEntryId)) continue;
    final entry = entryById[sell.journalEntryId];
    if (entry == null) continue;
    events.add(
      InvestmentReplayEvent(
        kind: InvestmentReplayEventKind.sell,
        transactionDate: parseTransactionDate(entry.transactionDate),
        recordedAt: entry.recordedAt,
        quantityScaled: sell.quantityScaled,
        unitCostMinor: 0,
        journalEntryId: sell.journalEntryId,
      ),
    );
  }
  events.sort((a, b) {
    final byDate = a.transactionDate.compareTo(b.transactionDate);
    if (byDate != 0) return byDate;
    return a.recordedAt.compareTo(b.recordedAt);
  });
  return events;
}

Future<Map<String, InstrumentQuote>> quotesByInstrumentId(
  AppDatabase db,
) async {
  final rows = await db.select(db.instrumentQuotes).get();
  return {
    for (final row in rows)
      row.instrumentId: InstrumentQuote(
        instrumentId: row.instrumentId,
        priceMinor: row.priceMinor,
        currency: row.currency,
        fetchedAt: row.fetchedAt,
      ),
  };
}

Future<List<InstrumentHolding>> computeInstrumentHoldingsForAccount(
  AppDatabase db, {
  required String accountId,
  required String groupCurrency,
  bool includeZeroQuantity = false,
}) async {
  final lots = await (db.select(
    db.investmentLots,
  )..where((l) => l.accountId.equals(accountId))).get();
  final instrumentIds = lots.map((l) => l.instrumentId).toSet();
  if (instrumentIds.isEmpty) return [];

  final instruments = await (db.select(
    db.instruments,
  )..where((i) => i.id.isIn(instrumentIds))).get();
  final instrumentById = {for (final i in instruments) i.id: i};
  final quotes = await quotesByInstrumentId(db);

  final holdings = <InstrumentHolding>[];
  for (final instrumentId in instrumentIds) {
    final instrumentRow = instrumentById[instrumentId];
    if (instrumentRow == null) continue;
    final events = await loadInvestmentReplayEvents(
      db,
      accountId: accountId,
      instrumentId: instrumentId,
    );
    final metrics = replayInvestmentHistory(events);
    if (metrics.quantityScaled <= 0 && !includeZeroQuantity) continue;
    final valuation = valueHolding(
      quantityScaled: metrics.quantityScaled,
      totalCostMinor: metrics.totalCostMinor,
      quote: quotes[instrumentId],
      groupCurrency: groupCurrency,
      quotesEnabled: true,
    );
    holdings.add(
      toInstrumentHolding(
        instrumentRow: instrumentRow,
        metrics: metrics,
        valuation: valuation,
      ),
    );
  }
  holdings.sort((a, b) => a.instrument.name.compareTo(b.instrument.name));
  return holdings;
}
