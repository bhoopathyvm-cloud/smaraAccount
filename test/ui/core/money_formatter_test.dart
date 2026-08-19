import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/ui/core/money_formatter.dart';

void main() {
  group('formatAmountMinor', () {
    test('USD: two decimal digits, comma-grouped thousands', () {
      expect(formatAmountMinor(123456, 'USD'), equals('1,234.56'));
    });

    test('INR: lakhs/crores grouping, not Western thousands grouping', () {
      // ₹10,00,000.00 (ten lakh), not ₹1,000,000.00.
      expect(formatAmountMinor(100000000, 'INR'), equals('10,00,000.00'));
    });

    test('JPY: no decimal point or minor-unit digits', () {
      expect(formatAmountMinor(1000, 'JPY'), equals('1,000'));
    });

    test('EUR: period grouping, comma decimal separator', () {
      expect(formatAmountMinor(1250000, 'EUR'), equals('12.500,00'));
    });

    test('a negative amount keeps its sign', () {
      expect(formatAmountMinor(-500, 'USD'), equals('-5.00'));
    });

    test('an unmapped/unusual currency code falls back to the Western '
        'convention rather than throwing', () {
      expect(formatAmountMinor(123456, 'ZZZ'), equals('1,234.56'));
    });

    test('the same amount and currency format identically regardless of '
        'which currency was formatted immediately before it (no shared '
        'mutable locale state leaking between calls)', () {
      formatAmountMinor(100000000, 'INR');
      expect(formatAmountMinor(123456, 'USD'), equals('1,234.56'));
    });
  });

  group('parseAmountToMinor', () {
    test('USD: a period-decimal amount parses directly', () {
      expect(parseAmountToMinor('12.34', 'USD'), equals(1234));
    });

    test('EUR: a comma-decimal amount parses as its own convention', () {
      expect(parseAmountToMinor('12,50', 'EUR'), equals(1250));
    });

    test('JPY: a whole-number string parses with zero minor-unit digits', () {
      expect(parseAmountToMinor('1000', 'JPY'), equals(1000));
    });

    test('a grouping separator in the input is stripped before parsing', () {
      expect(parseAmountToMinor('1,234.56', 'USD'), equals(123456));
    });

    test('empty and whitespace-only strings return null', () {
      expect(parseAmountToMinor('', 'USD'), isNull);
      expect(parseAmountToMinor('   ', 'USD'), isNull);
    });

    test('unparseable text returns null, not zero', () {
      expect(parseAmountToMinor('abc', 'USD'), isNull);
      expect(parseAmountToMinor('12.34.56', 'USD'), isNull);
    });
  });
}
