import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/domain/models/recurring_template.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';

void main() {
  group('effectiveDayOfMonth', () {
    test('returns dayOfMonth unchanged when the month has enough days', () {
      expect(effectiveDayOfMonth(15, 2026, 1), equals(15));
    });

    test('clamps to the last day of a shorter month', () {
      // February 2026 (not a leap year) has 28 days.
      expect(effectiveDayOfMonth(31, 2026, 2), equals(28));
      expect(effectiveDayOfMonth(30, 2026, 2), equals(28));
    });

    test('clamps to 29 for February in a leap year', () {
      expect(effectiveDayOfMonth(31, 2028, 2), equals(29));
    });

    test('clamps to 30 for a 30-day month', () {
      expect(effectiveDayOfMonth(31, 2026, 4), equals(30));
    });
  });

  group('yearMonthOf', () {
    test('formats as zero-padded YYYY-MM', () {
      expect(yearMonthOf(DateTime(2026, 3, 15)), equals('2026-03'));
      expect(yearMonthOf(DateTime(2026, 11, 1)), equals('2026-11'));
    });
  });

  group('isTemplateDue', () {
    RecurringTemplate templateWithDay(
      int dayOfMonth, {
      String? lastRecordedYearMonth,
    }) {
      return RecurringTemplate(
        id: 't1',
        name: 'Rent',
        direction: TransactionDirection.moneyOut,
        financialAccountId: 'account-1',
        categoryId: 'category-1',
        amountMinor: 150000,
        dayOfMonth: dayOfMonth,
        lastRecordedYearMonth: lastRecordedYearMonth,
      );
    }

    test('not due before its day-of-month arrives', () {
      final template = templateWithDay(15);
      expect(isTemplateDue(template, DateTime(2026, 3, 10)), isFalse);
    });

    test('due on its exact day-of-month', () {
      final template = templateWithDay(15);
      expect(isTemplateDue(template, DateTime(2026, 3, 15)), isTrue);
    });

    test('still due (overdue) after its day-of-month has passed', () {
      final template = templateWithDay(15);
      expect(isTemplateDue(template, DateTime(2026, 3, 20)), isTrue);
    });

    test('not due again once already recorded this calendar month', () {
      final template = templateWithDay(15, lastRecordedYearMonth: '2026-03');
      expect(isTemplateDue(template, DateTime(2026, 3, 20)), isFalse);
    });

    test('due again the following month even if recorded last month', () {
      final template = templateWithDay(15, lastRecordedYearMonth: '2026-03');
      expect(isTemplateDue(template, DateTime(2026, 4, 15)), isTrue);
    });

    test('a day-31 template is due on Feb 28 in a non-leap year', () {
      final template = templateWithDay(31);
      expect(isTemplateDue(template, DateTime(2026, 2, 28)), isTrue);
      expect(isTemplateDue(template, DateTime(2026, 2, 27)), isFalse);
    });
  });
}
