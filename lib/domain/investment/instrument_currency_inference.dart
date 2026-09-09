import 'exchange_registry.dart';
import 'isin.dart';

/// The instrument's likely trading currency, inferred locally at entry time
/// (instrument-identifier-assist tasks.md 2.2). Precedence: the ISIN
/// country, then a recognised ticker market suffix, then the default
/// exchange's currency. Never null — a bare ticker with no other signal
/// falls back to [defaultExchange]'s currency.
String inferTradingCurrency({
  String? isin,
  String? ticker,
  required Exchange defaultExchange,
}) {
  final fromIsin = currencyForIsin(isin);
  if (fromIsin != null) return fromIsin;

  final suffix = _tickerSuffix(ticker);
  if (suffix != null) {
    final exchange = exchangeForYahooSuffix(suffix);
    if (exchange != null) return exchange.currency;
  }

  return defaultExchange.currency;
}

/// The market suffix of [ticker] (e.g. `.SW`), or null for a bare ticker
/// or empty input. Only a trailing `.XX`-style suffix counts.
String? _tickerSuffix(String? ticker) {
  final t = ticker?.trim() ?? '';
  if (t.isEmpty) return null;
  final dot = t.lastIndexOf('.');
  if (dot <= 0 || dot >= t.length - 1) return null;
  return t.substring(dot);
}

/// The Yahoo/Stooq market suffix a listing in [currency] would carry (e.g.
/// `.SW` for CHF), for the mismatch warning's corrective hint. Null when no
/// registry exchange trades in [currency], or when it is a US (empty-suffix)
/// listing that a bare ticker already targets.
String? suffixHintForCurrency(String currency) {
  for (final exchange in kExchangeRegistry) {
    if (exchange.currency == currency && exchange.yahooSuffix.isNotEmpty) {
      return exchange.yahooSuffix;
    }
  }
  return null;
}
