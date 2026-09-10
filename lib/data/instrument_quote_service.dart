import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../domain/investment/exchange_registry.dart';
import '../domain/models/quote_provider.dart';
import '../domain/money/currency_minor_units.dart';

/// A last-trade price in minor units plus the quote's ISO currency.
class FetchedQuote {
  const FetchedQuote({required this.priceMinor, required this.currency});

  final int priceMinor;
  final String currency;
}

/// One listing returned by the Save-time identifier search
/// (instrument-identifier-assist Decision 4): a canonical market symbol
/// with the venue and currency the user picks between when confirming.
class InstrumentCandidate {
  const InstrumentCandidate({
    required this.name,
    required this.symbol,
    required this.exchangeDisplay,
    required this.currency,
    this.exchangeCode,
  });

  /// Display name of the security (issuer/fund name).
  final String name;

  /// Canonical market-data symbol, e.g. `UBSG.SW`.
  final String symbol;

  /// Human-facing venue label (registry name when known, else the
  /// provider's exchange display string).
  final String exchangeDisplay;

  /// ISO 4217 currency of this listing, derived from the symbol's market
  /// suffix (registry) — Yahoo search does not itself return a currency.
  final String currency;

  /// Registry [Exchange.code] when the symbol's suffix matches a known
  /// exchange, used to pre-select the default-exchange listing. Null for an
  /// unrecognised venue (still selectable).
  final String? exchangeCode;
}

/// Best-effort, offline-safe lookup of an indicative instrument price.
/// The request sends only a ticker and/or ISIN — never quantity, cost,
/// account ids, or descriptions. Never throws: any failure resolves to
/// `null`.
class InstrumentQuoteService {
  InstrumentQuoteService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  static const _timeout = Duration(seconds: 5);

  /// Stooq market suffix (the part after the last `.` in a symbol) → the
  /// ISO-4217 currency that market quotes in. Stooq's light CSV carries no
  /// currency column, but its symbols encode the market as `ticker.<mic>`,
  /// so the suffix is a deterministic, offline currency source. A bare
  /// symbol (no `.`) is a US listing (Stooq's convention). A suffix that is
  /// not in this map is treated as "no quote" rather than guessed at — see
  /// [stooqCurrencyForSymbol].
  static const stooqSuffixCurrency = <String, String>{
    'us': 'USD',
    'ch': 'CHF',
    'de': 'EUR',
    'fr': 'EUR',
    'nl': 'EUR',
    'be': 'EUR',
    'es': 'EUR',
    'it': 'EUR',
    'pt': 'EUR',
    'uk': 'GBP',
    'jp': 'JPY',
    'hk': 'HKD',
    'ca': 'CAD',
    'au': 'AUD',
    'ns': 'INR',
  };

  /// The currency a Stooq [symbol] quotes in, or `null` when the market
  /// cannot be determined from a recognised suffix. A symbol with no `.`
  /// suffix is a US listing (`USD`); a symbol whose suffix is not in
  /// [stooqSuffixCurrency] returns `null` so the caller treats it as a
  /// missing quote instead of silently assuming a currency.
  static String? stooqCurrencyForSymbol(String symbol) {
    final lower = symbol.trim().toLowerCase();
    final dot = lower.lastIndexOf('.');
    if (dot < 0) return 'USD';
    final suffix = lower.substring(dot + 1);
    return stooqSuffixCurrency[suffix];
  }

  Future<FetchedQuote?> fetchQuote({
    required QuoteProvider provider,
    String? symbol,
    String? ticker,
    String? isin,
  }) async {
    final resolved = _symbol(symbol: symbol, ticker: ticker, isin: isin);
    if (resolved == null) return null;
    try {
      return switch (provider) {
        QuoteProvider.stooq => await _fetchStooq(resolved),
        QuoteProvider.yahooFinance => await _fetchYahoo(resolved),
      };
    } catch (_) {
      return null;
    }
  }

  /// Tries the resolved exchange's national data source once, after the
  /// primary provider returned nothing (instrument-identifier-assist
  /// Decision 5). The accessible national source for the currently
  /// supported endpoints (NSE India, Börse Frankfurt) is the Yahoo chart
  /// API keyed on the resolved market symbol — the same offline-safe,
  /// never-throwing contract as [fetchQuote].
  Future<FetchedQuote?> fetchNationalQuote({
    required NationalQuoteEndpoint endpoint,
    required String symbol,
  }) async {
    if (symbol.trim().isEmpty) return null;
    try {
      return await _fetchYahoo(symbol.trim());
    } catch (_) {
      return null;
    }
  }

  /// Searches the market-data provider for listings matching [query] (an
  /// ISIN or ticker) and returns the candidates for the user to confirm.
  /// Sends only [query] — never quantity, cost, or account information.
  /// Never throws: any failure resolves to an empty list.
  Future<List<InstrumentCandidate>> searchIdentifier(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];
    try {
      final uri = Uri.https('query1.finance.yahoo.com', '/v1/finance/search', {
        'q': q,
        'quotesCount': '10',
        'newsCount': '0',
      });
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode != 200) return const [];
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return const [];
      final quotes = decoded['quotes'];
      if (quotes is! List) return const [];
      final candidates = <InstrumentCandidate>[];
      for (final quote in quotes) {
        final candidate = _candidateFrom(quote);
        if (candidate != null) candidates.add(candidate);
      }
      return candidates;
    } catch (_) {
      return const [];
    }
  }

  InstrumentCandidate? _candidateFrom(Object? quote) {
    if (quote is! Map<String, dynamic>) return null;
    final quoteType = quote['quoteType'];
    if (quoteType is String &&
        !const {'EQUITY', 'ETF', 'MUTUALFUND', 'INDEX'}.contains(quoteType)) {
      return null;
    }
    final symbol = quote['symbol'];
    if (symbol is! String || symbol.isEmpty) return null;
    final name =
        (quote['longname'] ?? quote['shortname'] ?? quote['symbol']) as String;
    final exchangeForSymbol = _exchangeForSymbol(symbol);
    final exchDisp = quote['exchDisp'];
    final display =
        exchangeForSymbol?.name ??
        (exchDisp is String && exchDisp.isNotEmpty ? exchDisp : symbol);
    return InstrumentCandidate(
      name: name,
      symbol: symbol,
      exchangeDisplay: display,
      currency: exchangeForSymbol?.currency ?? 'USD',
      exchangeCode: exchangeForSymbol?.code,
    );
  }

  /// The registry exchange a Yahoo symbol's suffix maps to (e.g.
  /// `UBSG.SW` → SIX), or null for a bare (US) symbol / unknown suffix.
  Exchange? _exchangeForSymbol(String symbol) {
    final dot = symbol.lastIndexOf('.');
    if (dot <= 0 || dot >= symbol.length - 1) return null;
    return exchangeForYahooSuffix(symbol.substring(dot));
  }

  String? _symbol({String? symbol, String? ticker, String? isin}) {
    final s = symbol?.trim();
    if (s != null && s.isNotEmpty) return s;
    final t = ticker?.trim();
    if (t != null && t.isNotEmpty) return t;
    final i = isin?.trim();
    if (i != null && i.isNotEmpty) return i;
    return null;
  }

  Future<FetchedQuote?> _fetchStooq(String symbol) async {
    final uri = Uri.https('stooq.com', '/q/l/', {
      's': symbol.toLowerCase(),
      'f': 'sd2t2ohlcv',
      'h': '',
      'e': 'csv',
    });
    final response = await _client.get(uri).timeout(_timeout);
    if (response.statusCode != 200) return null;
    final lines = const LineSplitter().convert(response.body.trim());
    if (lines.length < 2) return null;
    final parts = lines[1].split(',');
    // Symbol,Date,Time,Open,High,Low,Close,Volume — Close is index 6.
    if (parts.length < 7) return null;
    final close = double.tryParse(parts[6]);
    if (close == null || close <= 0) return null;
    // Stooq reports no currency; infer it from the symbol's market suffix.
    // An unrecognised suffix is "no quote", never a guessed currency, so a
    // wrong-market ticker never silently mis-values a holding.
    final currency = stooqCurrencyForSymbol(symbol);
    if (currency == null) return null;
    final digits = minorUnitDigitsForCurrency(currency);
    return FetchedQuote(
      priceMinor: (close * pow(10, digits)).round(),
      currency: currency,
    );
  }

  Future<FetchedQuote?> _fetchYahoo(String symbol) async {
    final uri = Uri.https(
      'query1.finance.yahoo.com',
      '/v8/finance/chart/$symbol',
    );
    final response = await _client.get(uri).timeout(_timeout);
    if (response.statusCode != 200) return null;
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return null;
    final chart = decoded['chart'];
    if (chart is! Map<String, dynamic>) return null;
    final result = chart['result'];
    if (result is! List || result.isEmpty) return null;
    final first = result.first;
    if (first is! Map<String, dynamic>) return null;
    final meta = first['meta'];
    if (meta is! Map<String, dynamic>) return null;
    final price = meta['regularMarketPrice'];
    final currency = meta['currency'];
    if (price is! num || price <= 0) return null;
    if (currency is! String || currency.isEmpty) return null;
    final upperCurrency = currency.toUpperCase();
    final digits = minorUnitDigitsForCurrency(upperCurrency);
    return FetchedQuote(
      priceMinor: (price.toDouble() * pow(10, digits)).round(),
      currency: upperCurrency,
    );
  }
}
