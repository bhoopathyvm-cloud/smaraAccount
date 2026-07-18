/// Total income and total expense (both positive minor-unit magnitudes)
/// posted within a user-selected date range (Income vs. Expense Summary
/// requirement).
class Summary {
  const Summary({
    required this.totalIncomeMinor,
    required this.totalExpenseMinor,
  });

  final int totalIncomeMinor;
  final int totalExpenseMinor;
}
