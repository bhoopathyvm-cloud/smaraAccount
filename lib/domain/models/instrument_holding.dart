import 'instrument.dart';
import 'instrument_quote.dart';

/// Computed current holding of one instrument in one investment account.
/// Derived by replaying lot/sell history in transaction-date order.
class InstrumentHolding {
  const InstrumentHolding({
    required this.instrument,
    required this.quantityScaled,
    required this.averageCostMinor,
    required this.totalCostMinor,
    required this.sellableQuantityScaled,
    this.marketValueMinor,
    this.unrealizedGainLossMinor,
    this.quoteUse = QuoteUse.missing,
  });

  final Instrument instrument;

  /// Current quantity x 10000.
  final int quantityScaled;

  /// Average cost per unit in minor units (weighted by quantity).
  final int averageCostMinor;

  /// Total book cost in minor units.
  final int totalCostMinor;

  /// Quantity available for sale (excluding locked lots as of now).
  final int sellableQuantityScaled;

  /// qty × last usable price, or [totalCostMinor] when no usable quote.
  final int? marketValueMinor;

  /// [marketValueMinor] − [totalCostMinor].
  final int? unrealizedGainLossMinor;

  final QuoteUse quoteUse;

  double get quantity => quantityScaled / 10000;
  double get sellableQuantity => sellableQuantityScaled / 10000;

  int get displayMarketValueMinor => marketValueMinor ?? totalCostMinor;
  int get displayUnrealizedMinor =>
      unrealizedGainLossMinor ?? 0;
}
