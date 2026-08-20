/// Cached last price for one instrument. Never posted to the journal.
class InstrumentQuote {
  const InstrumentQuote({
    required this.instrumentId,
    required this.priceMinor,
    required this.currency,
    required this.fetchedAt,
  });

  final String instrumentId;
  final int priceMinor;
  final String currency;
  final DateTime fetchedAt;
}

/// How a holding's market contribution was chosen.
enum QuoteUse {
  live,
  cached,
  stale,
  missing,
  disabled,
  currencyMismatch,
}

/// One instrument's book vs market figures for holdings / Home.
class HoldingValuation {
  const HoldingValuation({
    required this.quantityScaled,
    required this.totalCostMinor,
    required this.marketValueMinor,
    required this.unrealizedGainLossMinor,
    required this.quoteUse,
  });

  final int quantityScaled;
  final int totalCostMinor;
  final int marketValueMinor;
  final int unrealizedGainLossMinor;
  final QuoteUse quoteUse;
}
