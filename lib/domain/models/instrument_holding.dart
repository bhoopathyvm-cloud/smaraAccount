import 'instrument.dart';

/// Computed current holding of one instrument in one investment account.
/// Derived by replaying lot/sell history in transaction-date order.
class InstrumentHolding {
  const InstrumentHolding({
    required this.instrument,
    required this.quantityScaled,
    required this.averageCostMinor,
    required this.totalCostMinor,
    required this.sellableQuantityScaled,
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

  double get quantity => quantityScaled / 10000;
  double get sellableQuantity => sellableQuantityScaled / 10000;
}
