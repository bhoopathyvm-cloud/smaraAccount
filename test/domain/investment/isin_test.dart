import 'package:smara_accounting/domain/investment/isin.dart';
import 'package:test/test.dart';

void main() {
  group('validateIsin', () {
    test('well-formed ISINs with correct check digits are valid', () {
      expect(validateIsin('CH0244767585'), IsinCheck.valid); // UBS
      expect(validateIsin('US0378331005'), IsinCheck.valid); // Apple
      expect(validateIsin('IE00B3RBWM25'), IsinCheck.valid); // iShares ETF
      expect(validateIsin('GB0002634946'), IsinCheck.valid); // BAE Systems
    });

    test('blank input is treated as valid (ISIN is optional)', () {
      expect(validateIsin(''), IsinCheck.valid);
      expect(validateIsin('   '), IsinCheck.valid);
      expect(validateIsin(null), IsinCheck.valid);
    });

    test('lower case and surrounding whitespace are tolerated', () {
      expect(validateIsin('  ch0244767585 '), IsinCheck.valid);
    });

    test('a mistyped check digit warns but is not malformed', () {
      // Apple with the last digit bumped.
      expect(validateIsin('US0378331004'), IsinCheck.badCheckDigit);
      // A digit transposition inside the NSIN.
      expect(validateIsin('US0378313005'), IsinCheck.badCheckDigit);
    });

    test('wrong length or illegal characters are malformed', () {
      expect(validateIsin('US03783310'), IsinCheck.malformed);
      expect(validateIsin('US03783310055'), IsinCheck.malformed);
      expect(validateIsin('US03783-1005'), IsinCheck.malformed);
    });

    test('an unrecognised country prefix is malformed', () {
      expect(validateIsin('ZZ0378331005'), IsinCheck.malformed);
      expect(validateIsin('110378331005'), IsinCheck.malformed);
    });

    test('the supranational XS prefix is accepted', () {
      // XS eurobond ISIN with a valid check digit.
      expect(validateIsin('XS0629974352'), IsinCheck.valid);
    });
  });

  group('currencyForIsin', () {
    test('maps the country prefix to a listing currency', () {
      expect(currencyForIsin('CH0244767585'), equals('CHF'));
      expect(currencyForIsin('US0378331005'), equals('USD'));
      expect(currencyForIsin('IE00B3RBWM25'), equals('EUR'));
      expect(currencyForIsin('GB0002634946'), equals('GBP'));
    });

    test('returns null for an unmapped country or absent ISIN', () {
      expect(currencyForIsin('XS0629974352'), isNull);
      expect(currencyForIsin(null), isNull);
      expect(currencyForIsin(''), isNull);
    });
  });

  test('isinCountryCode extracts the first two characters', () {
    expect(isinCountryCode('ch0244767585'), equals('CH'));
    expect(isinCountryCode('U'), isNull);
  });
}
