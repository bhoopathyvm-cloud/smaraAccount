import 'package:http/http.dart' as http;
import 'package:smara_accounting/data/exchange_rate_service.dart';
import 'package:smara_accounting/domain/models/exchange_rate_provider.dart';
import 'package:test/test.dart';

void main() {
  test('COMPANY_SYNC_TEST define is off in the default test configuration', () {
    // Release / normal unit runs must not bake in fixed rates (task 7.4).
    expect(ExchangeRateService.companySyncTest, isFalse);
  });

  test('fixed scenario rates are documented for company sync', () {
    expect(ExchangeRateService.companySyncFixedRates['GBP>EUR'], 1.17);
    expect(ExchangeRateService.companySyncFixedRates['JPY>EUR'], 0.0062);
  });

  test(
    'without COMPANY_SYNC_TEST, fetchRate still talks to the network path',
    () async {
      // Default config: companySyncTest is false, so a failing client yields null.
      final service = ExchangeRateService(client: _AlwaysFailClient());
      final rate = await service.fetchRate(
        from: 'GBP',
        to: 'EUR',
        provider: ExchangeRateProvider.frankfurter,
      );
      expect(rate, isNull);
    },
  );
}

class _AlwaysFailClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    throw StateError('network unreachable');
  }
}
