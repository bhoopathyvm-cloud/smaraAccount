import '../../domain/models/instrument.dart';
import '../../domain/models/instrument_holding.dart';
import '../../domain/models/instrument_quote.dart';
import '../database/app_database.dart' show InstrumentRow;

/// Cash-funded vs non-cash acquisition for [LedgerRepository.recordBuy].
enum BuyFundingSource { cash, nonCash }

/// Internal lot bucket used while replaying acquisition history.
class InvestmentLotBucket {
  InvestmentLotBucket({required this.quantityScaled, this.lockedUntil});

  int quantityScaled;
  final DateTime? lockedUntil;
}

/// One buy or sell event in transaction-date order for replay.
class InvestmentReplayEvent {
  InvestmentReplayEvent({
    required this.kind,
    required this.transactionDate,
    required this.recordedAt,
    required this.quantityScaled,
    required this.unitCostMinor,
    this.lockedUntil,
    required this.journalEntryId,
  });

  final InvestmentReplayEventKind kind;
  final DateTime transactionDate;
  final DateTime recordedAt;
  final int quantityScaled;
  final int unitCostMinor;
  final DateTime? lockedUntil;
  final String journalEntryId;
}

enum InvestmentReplayEventKind { buy, sell }

int multiplyScaledQuantityPrice(int quantityScaled, int priceMinor) {
  return (quantityScaled * priceMinor) ~/ 10000;
}

DateTime parseTransactionDate(String dateOnly) => DateTime.parse(dateOnly);

int lockedQuantityScaledAt(List<InvestmentLotBucket> buckets, DateTime asOf) {
  var locked = 0;
  for (final bucket in buckets) {
    if (bucket.lockedUntil != null && asOf.isBefore(bucket.lockedUntil!)) {
      locked += bucket.quantityScaled;
    }
  }
  return locked;
}

void consumeUnlockedQuantity(
  List<InvestmentLotBucket> buckets,
  int quantityScaled,
  DateTime asOf,
) {
  var remaining = quantityScaled;
  for (final bucket in buckets) {
    if (remaining <= 0) break;
    if (bucket.quantityScaled <= 0) continue;
    if (bucket.lockedUntil != null && asOf.isBefore(bucket.lockedUntil!)) {
      continue;
    }
    final take = remaining < bucket.quantityScaled
        ? remaining
        : bucket.quantityScaled;
    bucket.quantityScaled -= take;
    remaining -= take;
  }
}

/// Replays [events] and returns holding metrics after the last event.
/// [asOf] controls lock-until sellable calculations for the final state.
InvestmentHoldingMetrics replayInvestmentHistory(
  List<InvestmentReplayEvent> events, {
  DateTime? asOf,
}) {
  final buckets = <InvestmentLotBucket>[];
  var quantityScaled = 0;
  var totalCostMinor = 0;

  for (final event in events) {
    switch (event.kind) {
      case InvestmentReplayEventKind.buy:
        quantityScaled += event.quantityScaled;
        totalCostMinor += multiplyScaledQuantityPrice(
          event.quantityScaled,
          event.unitCostMinor,
        );
        buckets.add(
          InvestmentLotBucket(
            quantityScaled: event.quantityScaled,
            lockedUntil: event.lockedUntil,
          ),
        );
      case InvestmentReplayEventKind.sell:
        final sellable =
            quantityScaled -
            lockedQuantityScaledAt(buckets, event.transactionDate);
        if (event.quantityScaled > sellable) {
          throw StateError('Replay would imply negative quantity.');
        }
        final avgCostMinor = quantityScaled > 0
            ? (totalCostMinor * 10000) ~/ quantityScaled
            : 0;
        final costRemoved = multiplyScaledQuantityPrice(
          event.quantityScaled,
          avgCostMinor,
        );
        quantityScaled -= event.quantityScaled;
        totalCostMinor -= costRemoved;
        consumeUnlockedQuantity(
          buckets,
          event.quantityScaled,
          event.transactionDate,
        );
    }
  }

  final evaluationDate = asOf ?? DateTime.now();
  final locked = lockedQuantityScaledAt(buckets, evaluationDate);
  final sellable = quantityScaled - locked;
  final averageCostMinor = quantityScaled > 0
      ? (totalCostMinor * 10000) ~/ quantityScaled
      : 0;

  DateTime? earliestLockedUntil;
  for (final bucket in buckets) {
    if (bucket.quantityScaled <= 0) continue;
    final until = bucket.lockedUntil;
    if (until == null || !evaluationDate.isBefore(until)) continue;
    if (earliestLockedUntil == null || until.isBefore(earliestLockedUntil)) {
      earliestLockedUntil = until;
    }
  }

  return InvestmentHoldingMetrics(
    quantityScaled: quantityScaled,
    totalCostMinor: totalCostMinor,
    averageCostMinor: averageCostMinor,
    sellableQuantityScaled: sellable < 0 ? 0 : sellable,
    lockedQuantityScaled: locked,
    earliestLockedUntil: earliestLockedUntil,
  );
}

/// Returns false if removing [excludedBuyEntryId]'s buy would make quantity
/// negative at any sell during replay.
bool canReverseBuy({
  required List<InvestmentReplayEvent> events,
  required String excludedBuyEntryId,
}) {
  final filtered = events
      .where((e) => e.journalEntryId != excludedBuyEntryId)
      .toList();
  try {
    replayInvestmentHistory(filtered);
    return true;
  } catch (_) {
    return false;
  }
}

/// Holding metrics from replay — not the domain [InstrumentHolding] widget.
class InvestmentHoldingMetrics {
  const InvestmentHoldingMetrics({
    required this.quantityScaled,
    required this.totalCostMinor,
    required this.averageCostMinor,
    required this.sellableQuantityScaled,
    required this.lockedQuantityScaled,
    this.earliestLockedUntil,
  });

  final int quantityScaled;
  final int totalCostMinor;
  final int averageCostMinor;
  final int sellableQuantityScaled;
  final int lockedQuantityScaled;
  final DateTime? earliestLockedUntil;
}

const quoteStaleAfter = Duration(hours: 24);

/// Whether [quote] may be multiplied into a mark — currency must match
/// the holding's group. Disabled quotes still use a matching cache.
bool quoteIsUsable(InstrumentQuote? quote, String groupCurrency) {
  return quote != null && quote.currency == groupCurrency;
}

QuoteUse quoteUseFor({
  required InstrumentQuote? quote,
  required String groupCurrency,
  required bool quotesEnabled,
  DateTime? now,
}) {
  if (quote != null && quote.currency != groupCurrency) {
    return QuoteUse.currencyMismatch;
  }
  if (!quoteIsUsable(quote, groupCurrency)) {
    return quotesEnabled ? QuoteUse.missing : QuoteUse.disabled;
  }
  if (!quotesEnabled) return QuoteUse.disabled;
  final age = (now ?? DateTime.now()).difference(quote!.fetchedAt);
  if (age > quoteStaleAfter) return QuoteUse.stale;
  return QuoteUse.live;
}

/// Market contribution for an instrument: qty × last price when the quote
/// is usable in [groupCurrency], otherwise book cost.
HoldingValuation valueHolding({
  required int quantityScaled,
  required int totalCostMinor,
  required InstrumentQuote? quote,
  required String groupCurrency,
  required bool quotesEnabled,
  DateTime? now,
}) {
  final use = quoteUseFor(
    quote: quote,
    groupCurrency: groupCurrency,
    quotesEnabled: quotesEnabled,
    now: now,
  );
  final canUsePrice = quoteIsUsable(quote, groupCurrency);
  final marketValueMinor = canUsePrice
      ? multiplyScaledQuantityPrice(quantityScaled, quote!.priceMinor)
      : totalCostMinor;
  return HoldingValuation(
    quantityScaled: quantityScaled,
    totalCostMinor: totalCostMinor,
    marketValueMinor: marketValueMinor,
    unrealizedGainLossMinor: marketValueMinor - totalCostMinor,
    quoteUse: use,
  );
}

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

String formatQuantityScaled(int quantityScaled) {
  final value = quantityScaled / 10000;
  if (value == value.roundToDouble()) return value.round().toString();
  var text = value.toStringAsFixed(4);
  while (text.contains('.') && (text.endsWith('0') || text.endsWith('.'))) {
    text = text.substring(0, text.length - 1);
  }
  return text;
}

int? parseQuantityScaled(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return null;
  final value = double.tryParse(trimmed.replaceAll(',', '.'));
  if (value == null || value <= 0) return null;
  return (value * 10000).round();
}
