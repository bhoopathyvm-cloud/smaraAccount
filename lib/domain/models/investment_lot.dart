import '../../data/database/tables/investment_lots_table.dart' show LotSource;

export '../../data/database/tables/investment_lots_table.dart' show LotSource;

/// A single acquisition lot for an instrument in one investment account.
class InvestmentLot {
  const InvestmentLot({
    required this.id,
    required this.accountId,
    required this.instrumentId,
    required this.quantityScaled,
    required this.unitCostMinor,
    required this.source,
    required this.acquiredAt,
    this.lockedUntil,
    required this.journalEntryId,
  });

  final String id;
  final String accountId;
  final String instrumentId;

  /// Quantity x 10000, supporting fractional shares.
  final int quantityScaled;

  /// Unit cost in minor currency units (e.g. cents).
  final int unitCostMinor;

  final LotSource source;
  final DateTime acquiredAt;
  final DateTime? lockedUntil;
  final String journalEntryId;

  /// Total cost of this lot in minor units.
  int get totalCostMinor => (quantityScaled * unitCostMinor) ~/ 10000;
}
