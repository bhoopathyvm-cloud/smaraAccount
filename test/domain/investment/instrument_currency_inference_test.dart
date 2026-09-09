import 'package:smara_accounting/domain/investment/exchange_registry.dart';
import 'package:smara_accounting/domain/investment/instrument_currency_inference.dart';
import 'package:test/test.dart';

void main() {
  final us = exchangeForCode('US')!;
  final six = exchangeForCode('SIX')!;

  group('inferTradingCurrency', () {
    test('an ISIN country takes precedence', () {
      expect(
        inferTradingCurrency(
          isin: 'US0378331005',
          ticker: 'AAPL.SW',
          defaultExchange: six,
        ),
        equals('USD'),
      );
      expect(
        inferTradingCurrency(isin: 'CH0244767585', defaultExchange: us),
        equals('CHF'),
      );
    });

    test('a recognised ticker suffix is used when no ISIN country', () {
      expect(
        inferTradingCurrency(ticker: 'UBSG.SW', defaultExchange: us),
        equals('CHF'),
      );
      expect(
        inferTradingCurrency(ticker: 'RELIANCE.NS', defaultExchange: us),
        equals('INR'),
      );
    });

    test('a bare ticker falls back to the default exchange currency', () {
      expect(
        inferTradingCurrency(ticker: 'UBSG', defaultExchange: six),
        equals('CHF'),
      );
      expect(
        inferTradingCurrency(ticker: 'AAPL', defaultExchange: us),
        equals('USD'),
      );
    });

    test('nothing typed falls back to the default exchange currency', () {
      expect(inferTradingCurrency(defaultExchange: six), equals('CHF'));
    });
  });

  group('suffixHintForCurrency', () {
    test('returns the market suffix a currency lists under', () {
      expect(suffixHintForCurrency('CHF'), equals('.SW'));
      expect(suffixHintForCurrency('GBP'), equals('.L'));
      expect(suffixHintForCurrency('INR'), equals('.NS'));
    });

    test('returns null for USD (bare ticker already targets US)', () {
      expect(suffixHintForCurrency('USD'), isNull);
    });

    test('returns null for a currency no registry exchange trades in', () {
      expect(suffixHintForCurrency('XYZ'), isNull);
    });
  });
}
