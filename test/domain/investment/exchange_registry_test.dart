import 'package:smara_accounting/domain/investment/exchange_registry.dart';
import 'package:test/test.dart';

void main() {
  test('every registry entry has a unique code and MIC', () {
    final codes = kExchangeRegistry.map((e) => e.code).toList();
    expect(codes.toSet().length, equals(codes.length));
    expect(kExchangeRegistry.length, greaterThanOrEqualTo(20));
  });

  test('exchangeForCode finds a known code and rejects unknown/null', () {
    expect(exchangeForCode('SIX')?.currency, equals('CHF'));
    expect(exchangeForCode('US')?.yahooSuffix, equals(''));
    expect(exchangeForCode('NOPE'), isNull);
    expect(exchangeForCode(null), isNull);
  });

  test('exchangeForYahooSuffix maps a suffix to its exchange', () {
    expect(exchangeForYahooSuffix('.SW')?.code, equals('SIX'));
    expect(exchangeForYahooSuffix('.sw')?.code, equals('SIX'));
    expect(exchangeForYahooSuffix('.NS')?.currency, equals('INR'));
    expect(exchangeForYahooSuffix(''), isNull);
    expect(exchangeForYahooSuffix('.ZZ'), isNull);
  });

  test('first-run default follows the device region', () {
    expect(defaultExchangeForRegion('CH').code, equals('SIX'));
    expect(defaultExchangeForRegion('IN').code, equals('NSE'));
    expect(defaultExchangeForRegion('US').code, equals('US'));
    expect(defaultExchangeForRegion('DE').code, equals('XETRA'));
  });

  test('unknown or missing region falls back to the global default', () {
    expect(defaultExchangeForRegion('ZZ').code, equals(kDefaultExchangeCode));
    expect(defaultExchangeForRegion(null).code, equals(kDefaultExchangeCode));
  });

  test('resolveDefaultExchange prefers a valid stored code', () {
    expect(
      resolveDefaultExchange(storedCode: 'LSE', regionCode: 'CH').code,
      equals('LSE'),
    );
  });

  test('resolveDefaultExchange falls back to region then default', () {
    expect(
      resolveDefaultExchange(storedCode: 'GONE', regionCode: 'CH').code,
      equals('SIX'),
    );
    expect(
      resolveDefaultExchange(storedCode: null, regionCode: null).code,
      equals(kDefaultExchangeCode),
    );
  });

  test('national fallback endpoints are declared for NSE and Frankfurt', () {
    expect(
      exchangeForCode('NSE')?.nationalEndpoint,
      equals(NationalQuoteEndpoint.nseIndia),
    );
    expect(
      exchangeForCode('XETRA')?.nationalEndpoint,
      equals(NationalQuoteEndpoint.boerseFrankfurt),
    );
    expect(exchangeForCode('US')?.nationalEndpoint, isNull);
  });
}
