import 'package:smara_accounting/l10n/default_currency.dart';
import 'package:test/test.dart';

void main() {
  group('defaultCurrencyForLocale', () {
    test('English defaults to USD', () {
      expect(defaultCurrencyForLocale('en'), 'USD');
    });

    test('all 22 Indian scheduled languages default to INR', () {
      const indian = [
        'ta', 'te', 'ml', 'kn', 'hi', 'ur', 'pa', 'ne', 'sa', 'doi', 'ks',
        'mai', 'mr', 'gu', 'kok', 'sd', 'bn', 'as', 'or', 'mni', 'brx', 'sat',
      ];
      expect(indian.length, 22);
      for (final code in indian) {
        expect(defaultCurrencyForLocale(code), 'INR', reason: code);
      }
    });

    test('euro-area and approximated European languages default to EUR', () {
      for (final code in const ['de', 'fr', 'es', 'it', 'pt', 'hu', 'ro', 'nl']) {
        expect(defaultCurrencyForLocale(code), 'EUR', reason: code);
      }
    });

    test('east-Asian languages map to their own currencies', () {
      expect(defaultCurrencyForLocale('ja'), 'JPY');
      expect(defaultCurrencyForLocale('zh'), 'CNY');
      expect(defaultCurrencyForLocale('ko'), 'KRW');
    });

    test('other single-economy approximations', () {
      expect(defaultCurrencyForLocale('ar'), 'SAR');
      expect(defaultCurrencyForLocale('ru'), 'RUB');
      expect(defaultCurrencyForLocale('id'), 'IDR');
      expect(defaultCurrencyForLocale('tr'), 'TRY');
      expect(defaultCurrencyForLocale('vi'), 'VND');
      expect(defaultCurrencyForLocale('th'), 'THB');
      expect(defaultCurrencyForLocale('ms'), 'MYR');
      expect(defaultCurrencyForLocale('uk'), 'UAH');
      expect(defaultCurrencyForLocale('pl'), 'PLN');
    });

    test('an unknown code falls back to USD', () {
      expect(defaultCurrencyForLocale('zz'), 'USD');
      expect(defaultCurrencyForLocale(''), 'USD');
    });
  });
}
