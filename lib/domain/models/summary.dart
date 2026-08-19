/// Total income and total expense (both positive minor-unit magnitudes)
/// posted within a user-selected date range (Income vs. Expense Summary
/// requirement).
///
/// Named LedgerSummary, not "Summary" - that collides with
/// package:flutter/foundation.dart's own Summary annotation class
/// whenever both are imported in the same file (e.g. any ViewModel).
class LedgerSummary {
  const LedgerSummary({
    required this.totalIncomeMinor,
    required this.totalExpenseMinor,
  });

  final int totalIncomeMinor;
  final int totalExpenseMinor;
}

/// One category's total (positive minor-unit magnitude) within a date
/// range (home-hub-capture: "this calendar month's spent totals grouped
/// by expense category and received totals by income category").
class CategoryTotal {
  const CategoryTotal({
    required this.categoryId,
    required this.categoryName,
    required this.isIncome,
    required this.totalMinor,
  });

  final String categoryId;
  final String categoryName;

  /// True for an income category, false for expense - mirrors
  /// `TransactionDirection` without importing it here (this is a plain
  /// aggregation result, not a transaction).
  final bool isIncome;
  final int totalMinor;
}
