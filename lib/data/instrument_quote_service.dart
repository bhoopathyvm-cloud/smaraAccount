import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/models/quote_provider.dart';

/// A last-trade price in minor units plus the quote's ISO currency.
class FetchedQuote {
  const FetchedQuote({required this.priceMinor, required this.currency});

  final int priceMinor;
  final String currency;
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

  Future<FetchedQuote?> fetchQuote({
    required QuoteProvider provider,
    String? ticker,
    String? isin,
  }) async {
    final symbol = _symbol(ticker: ticker, isin: isin);
    if (symbol == null) return null;
    try {
      return switch (provider) {
        QuoteProvider.stooq => await _fetchStooq(symbol),
        QuoteProvider.yahooFinance => await _fetchYahoo(symbol),
      };
    } catch (_) {
      return null;
    }
  }

  String? _symbol({String? ticker, String? isin}) {
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
    return FetchedQuote(
      priceMinor: (close * 100).round(),
      currency: 'USD',
    );
  }

  Future<FetchedQuote?> _fetchYahoo(String symbol) async {
    final uri = Uri.https('query1.finance.yahoo.com', '/v8/finance/chart/$symbol');
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
    return FetchedQuote(
      priceMinor: (price.toDouble() * 100).round(),
      currency: currency.toUpperCase(),
    );
  }
}
