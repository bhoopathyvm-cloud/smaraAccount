import 'package:smara_accounting/l10n/default_currency_for_locale.dart';
import 'package:smara_accounting/l10n/supported_locales.dart';
import 'package:test/test.dart';

void main() {
  group('defaultCurrencyForLocale', () {
    test('English defaults to USD', () {
      expect(defaultCurrencyForLocale('en'), 'USD');
    });

    test("India's scheduled languages default to INR", () {
      const indianLanguages = [
        'ta',
        'te',
        'ml',
        'kn',
        'hi',
        'ur',
        'pa',
        'ne',
        'sa',
        'doi',
        'ks',
        'mai',
        'mr',
        'gu',
        'kok',
        'sd',
        'bn',
        'as',
        'or',
        'mni',
        'brx',
        'sat',
      ];
      for (final code in indianLanguages) {
        expect(defaultCurrencyForLocale(code), 'INR', reason: code);
      }
    });

    test('a sample of other languages map to their documented currency', () {
      expect(defaultCurrencyForLocale('de'), 'EUR');
      expect(defaultCurrencyForLocale('ja'), 'JPY');
      expect(defaultCurrencyForLocale('zh'), 'CNY');
      expect(defaultCurrencyForLocale('ko'), 'KRW');
      expect(defaultCurrencyForLocale('ar'), 'SAR');
      expect(defaultCurrencyForLocale('ru'), 'RUB');
      expect(defaultCurrencyForLocale('pl'), 'PLN');
    });

    test('an unknown code falls back to USD', () {
      expect(defaultCurrencyForLocale('xx'), 'USD');
      expect(defaultCurrencyForLocale(''), 'USD');
    });

    test('every supported locale tag resolves to some currency', () {
      for (final tag in kSupportedLocaleTags) {
        expect(defaultCurrencyForLocale(tag), isNotEmpty, reason: tag);
      }
    });
  });
}
