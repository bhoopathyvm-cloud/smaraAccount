import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/models/exchange_rate_provider.dart';

/// Best-effort, offline-safe lookup of an indicative reference exchange
/// rate for a currency pair (design.md Decision 4). The request sends only
/// the two currency codes - never ledger amounts, account ids, or
/// descriptions. Never throws to the caller: any failure (timeout,
/// offline, unsupported pair, non-200, malformed/unexpected response body)
/// resolves to `null` instead, so a caller can treat "no rate" uniformly
/// without a try/catch of its own.
class ExchangeRateService {
  ExchangeRateService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  static const _timeout = Duration(seconds: 5);

  /// Units of [to] currency equal to one unit of [from] currency
  /// (destination-per-source, matching the convention `TransferView` uses
  /// for the implied rate), or `null` on any failure.
  Future<double?> fetchRate({
    required String from,
    required String to,
    required ExchangeRateProvider provider,
  }) async {
    try {
      final uri = switch (provider) {
        ExchangeRateProvider.frankfurter => Uri.https(
          'api.frankfurter.app',
          '/latest',
          {'from': from, 'to': to},
        ),
        ExchangeRateProvider.openErApi => Uri.https(
          'open.er-api.com',
          '/v6/latest/$from',
        ),
      };
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;
      final rates = decoded['rates'];
      if (rates is! Map<String, dynamic>) return null;
      final rate = rates[to];
      return rate is num ? rate.toDouble() : null;
    } catch (_) {
      // Network errors, timeouts, malformed JSON, and unexpected response
      // shapes are all equally "no rate available" to the caller - this
      // lookup is display-only and must never surface an exception.
      return null;
    }
  }
}
