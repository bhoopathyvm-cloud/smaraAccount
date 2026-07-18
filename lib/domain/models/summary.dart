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
