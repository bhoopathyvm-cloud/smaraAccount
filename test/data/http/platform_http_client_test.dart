import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:smara_accounting/data/exchange_rate_service.dart';
import 'package:smara_accounting/data/http/platform_http_client.dart';
import 'package:smara_accounting/data/instrument_quote_service.dart';
import 'package:smara_accounting/domain/models/exchange_rate_provider.dart';
import 'package:smara_accounting/domain/models/quote_provider.dart';

/// os-provided-encryption task 5.1: on iOS and macOS the exchange-rate and
/// quote services use Apple's URL loading system; elsewhere `dart:io`.
void main() {
  test('iOS and macOS use URLSession, other platforms dart:io', () {
    expect(
      platformHttpClientKindFor(TargetPlatform.iOS),
      PlatformHttpClientKind.appleUrlSession,
    );
    expect(
      platformHttpClientKindFor(TargetPlatform.macOS),
      PlatformHttpClientKind.appleUrlSession,
    );
    for (final platform in [
      TargetPlatform.android,
      TargetPlatform.linux,
      TargetPlatform.windows,
      TargetPlatform.fuchsia,
    ]) {
      expect(
        platformHttpClientKindFor(platform),
        PlatformHttpClientKind.dartIo,
        reason: '$platform',
      );
    }
  });

  test('the dart:io client is an IOClient', () {
    final client = createPlatformHttpClient(platform: TargetPlatform.android);
    addTearDown(client.close);
    expect(client, isA<IOClient>());
  });

  test('services accept an injected client', () async {
    final seen = <Uri>[];
    final client = _RecordingClient(seen);
    final rates = ExchangeRateService(client: client);
    await rates.fetchRate(
      from: 'EUR',
      to: 'USD',
      provider: ExchangeRateProvider.frankfurter,
    );
    final quotes = InstrumentQuoteService(client: client);
    await quotes.fetchQuote(provider: QuoteProvider.stooq, ticker: 'AAPL.US');
    expect(seen, hasLength(greaterThanOrEqualTo(2)));
  });
}

class _RecordingClient extends http.BaseClient {
  _RecordingClient(this.seen);

  final List<Uri> seen;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    seen.add(request.url);
    return http.StreamedResponse(const Stream.empty(), 503);
  }
}
