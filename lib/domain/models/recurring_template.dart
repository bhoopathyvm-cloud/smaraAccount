import 'transaction_direction.dart';

/// A recurring transaction template (recurring-templates design.md
/// Decisions): a monthly bill/income pattern the user defines once and
/// records with one tap when due - never posted automatically (spec:
/// "Recurring Transaction Templates").
class RecurringTemplate {
  const RecurringTemplate({
    required this.id,
    required this.name,
    required this.direction,
    required this.financialAccountId,
    required this.categoryId,
    required this.amountMinor,
    required this.dayOfMonth,
    this.lastRecordedYearMonth,
  });

  final String id;
  final String name;
  final TransactionDirection direction;
  final String financialAccountId;
  final String categoryId;
  final int amountMinor;

  /// 1-31. A month shorter than this clamps to that month's last day (e.g.
  /// 31 is due on Feb 28/29) - see [effectiveDayOfMonth].
  final int dayOfMonth;

  /// 'YYYY-MM' of the last calendar month this template was recorded in,
  /// or null if never recorded - prevents the same due item from being
  /// offered again after the user has already acted on it this month.
  final String? lastRecordedYearMonth;
}

/// [template] joined with its financial account/category names, already
/// filtered to "due" (mirrors [PendingTransferSummary]'s precedent of
/// resolving names in the repository layer, not the ViewModel).
class DueRecurringTemplate {
  const DueRecurringTemplate({
    required this.template,
    required this.financialAccountName,
    required this.categoryName,
    required this.currency,
  });

  final RecurringTemplate template;
  final String financialAccountName;
  final String categoryName;

  /// The financial account's own currency (localized-money-formatting) -
  /// resolved in the repository layer, same as [PendingTransferSummary].
  final String currency;
}

/// [dayOfMonth] clamped to the actual number of days in [year]/[month] -
/// a day-31 template is due on the last day of a 30-day month, not
/// silently skipped.
int effectiveDayOfMonth(int dayOfMonth, int year, int month) {
  final daysInMonth = DateTime(year, month + 1, 0).day;
  return dayOfMonth > daysInMonth ? daysInMonth : dayOfMonth;
}

/// 'YYYY-MM' for [date] - the granularity [RecurringTemplate.lastRecordedYearMonth]
/// is compared at.
String yearMonthOf(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';

/// Whether [template] should be surfaced as due on [today]: its
/// effective day-of-month has arrived or passed, and it hasn't already
/// been recorded this calendar month.
bool isTemplateDue(RecurringTemplate template, DateTime today) {
  final effectiveDay = effectiveDayOfMonth(
    template.dayOfMonth,
    today.year,
    today.month,
  );
  if (today.day < effectiveDay) return false;
  return template.lastRecordedYearMonth != yearMonthOf(today);
}
