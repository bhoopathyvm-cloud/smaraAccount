import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:smara_accounting/data/exchange_rate_service.dart';
import 'package:smara_accounting/domain/models/exchange_rate_provider.dart';

// The .timeout(...) branch inside fetchRate is exercised by having the
// fake client's request throw directly (a TimeoutException, in spirit)
// rather than actually waiting out the real 5-second timeout - the
// service's catch-all treats any thrown error identically, so this
// reaches the same "no rate available" path without slowing the suite.
void main() {
  group('frankfurter', () {
    test('success normalizes to destination-per-source', () async {
      final service = ExchangeRateService(
        client: MockClient((request) async {
          expect(request.url.host, equals('api.frankfurter.app'));
          expect(request.url.queryParameters['from'], equals('USD'));
          expect(request.url.queryParameters['to'], equals('EUR'));
          return http.Response('{"rates": {"EUR": 0.92}}', 200);
        }),
      );

      final rate = await service.fetchRate(
        from: 'USD',
        to: 'EUR',
        provider: ExchangeRateProvider.frankfurter,
      );

      expect(rate, equals(0.92));
    });

    test('non-200 response resolves to null', () async {
      final service = ExchangeRateService(
        client: MockClient((request) async => http.Response('', 500)),
      );

      final rate = await service.fetchRate(
        from: 'USD',
        to: 'EUR',
        provider: ExchangeRateProvider.frankfurter,
      );

      expect(rate, isNull);
    });

    test('malformed response body resolves to null', () async {
      final service = ExchangeRateService(
        client: MockClient((request) async => http.Response('not json', 200)),
      );

      final rate = await service.fetchRate(
        from: 'USD',
        to: 'EUR',
        provider: ExchangeRateProvider.frankfurter,
      );

      expect(rate, isNull);
    });

    test('a request timeout resolves to null', () async {
      final service = ExchangeRateService(
        client: MockClient((request) async => throw Exception('timed out')),
      );

      final rate = await service.fetchRate(
        from: 'USD',
        to: 'EUR',
        provider: ExchangeRateProvider.frankfurter,
      );

      expect(rate, isNull);
    });
  });

  group('open.er-api.com', () {
    test('success normalizes to destination-per-source', () async {
      final service = ExchangeRateService(
        client: MockClient((request) async {
          expect(request.url.host, equals('open.er-api.com'));
          expect(request.url.path, equals('/v6/latest/USD'));
          return http.Response('{"rates": {"EUR": 0.91}}', 200);
        }),
      );

      final rate = await service.fetchRate(
        from: 'USD',
        to: 'EUR',
        provider: ExchangeRateProvider.openErApi,
      );

      expect(rate, equals(0.91));
    });

    test('non-200 response resolves to null', () async {
      final service = ExchangeRateService(
        client: MockClient((request) async => http.Response('', 404)),
      );

      final rate = await service.fetchRate(
        from: 'USD',
        to: 'EUR',
        provider: ExchangeRateProvider.openErApi,
      );

      expect(rate, isNull);
    });

    test('malformed response body resolves to null', () async {
      final service = ExchangeRateService(
        client: MockClient(
          (request) async => http.Response('{"rates": "oops"}', 200),
        ),
      );

      final rate = await service.fetchRate(
        from: 'USD',
        to: 'EUR',
        provider: ExchangeRateProvider.openErApi,
      );

      expect(rate, isNull);
    });

    test('a request timeout resolves to null', () async {
      final service = ExchangeRateService(
        client: MockClient((request) async => throw Exception('timed out')),
      );

      final rate = await service.fetchRate(
        from: 'USD',
        to: 'EUR',
        provider: ExchangeRateProvider.openErApi,
      );

      expect(rate, isNull);
    });
  });
}
