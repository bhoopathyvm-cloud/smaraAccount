import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/models/exchange_rate_provider.dart';
import 'http/platform_http_client.dart';

/// Best-effort, offline-safe lookup of an indicative reference exchange
/// rate for a currency pair (design.md Decision 4). The request sends only
/// the two currency codes - never ledger amounts, account ids, or
/// descriptions. Never throws to the caller: any failure (timeout,
/// offline, unsupported pair, non-200, malformed/unexpected response body)
/// resolves to `null` instead, so a caller can treat "no rate" uniformly
/// without a try/catch of its own.
class ExchangeRateService {
  ExchangeRateService({http.Client? client})
    : _client = client ?? createPlatformHttpClient();

  final http.Client _client;

  static const _timeout = Duration(seconds: 5);

  /// Compiled into company-sync acceptance runs only
  /// (`--dart-define=COMPANY_SYNC_TEST=true`). Release / normal builds keep
  /// this false so production never uses fixed scenario rates (task 7.4).
  static const companySyncTest = bool.fromEnvironment('COMPANY_SYNC_TEST');

  /// Scenario rates for Acme Travel Co (GBP→EUR 1.17, JPY→EUR 0.0062).
  static const Map<String, double> companySyncFixedRates = {
    'GBP>EUR': 1.17,
    'EUR>GBP': 1 / 1.17,
    'JPY>EUR': 0.0062,
    'EUR>JPY': 1 / 0.0062,
  };

  /// Units of [to] currency equal to one unit of [from] currency
  /// (destination-per-source, matching the convention `TransferView` uses
  /// for the implied rate), or `null` on any failure.
  Future<double?> fetchRate({
    required String from,
    required String to,
    required ExchangeRateProvider provider,
  }) async {
    if (companySyncTest) {
      final key = '${from.toUpperCase()}>${to.toUpperCase()}';
      if (from.toUpperCase() == to.toUpperCase()) return 1.0;
      return companySyncFixedRates[key];
    }
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
