import 'instrument_kind.dart';

export 'instrument_kind.dart';

/// Domain-facing view of an instrument (stock, ETF, etc.).
class Instrument {
  const Instrument({
    required this.id,
    required this.name,
    required this.kind,
    this.ticker,
    this.isin,
    this.resolvedSymbol,
    this.exchange,
    required this.archived,
  });

  final String id;
  final String name;
  final InstrumentKind kind;
  final String? ticker;
  final String? isin;

  /// Canonical market-data symbol confirmed for this instrument (e.g.
  /// `UBSG.SW`), preferred over [ticker] when fetching quotes. Null until
  /// resolved (instrument-identifier-assist).
  final String? resolvedSymbol;

  /// Registry code of the exchange the resolved listing trades on (e.g.
  /// `SIX`). Null until resolved.
  final String? exchange;

  final bool archived;

  /// The symbol market-price fetching should send: the resolved canonical
  /// symbol when present, otherwise the raw ticker.
  String? get quoteSymbol {
    final resolved = resolvedSymbol?.trim();
    if (resolved != null && resolved.isNotEmpty) return resolved;
    final t = ticker?.trim();
    if (t != null && t.isNotEmpty) return t;
    return null;
  }
}
