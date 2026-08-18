import '../../data/database/tables/instruments_table.dart' show InstrumentKind;

export '../../data/database/tables/instruments_table.dart' show InstrumentKind;

/// Domain-facing view of an instrument (stock, ETF, etc.).
class Instrument {
  const Instrument({
    required this.id,
    required this.name,
    required this.kind,
    this.ticker,
    this.isin,
    required this.archived,
  });

  final String id;
  final String name;
  final InstrumentKind kind;
  final String? ticker;
  final String? isin;
  final bool archived;
}
