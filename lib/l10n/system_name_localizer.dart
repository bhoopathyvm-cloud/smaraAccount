import 'generated/app_localizations.dart';

/// Seeded English names stored in SQLite. Display-layer localization applies
/// only while the stored value still matches the original seed.
const kSystemGroupCashEquivalents = 'Cash & cash equivalents';
const kSystemGroupPensionRetirement = 'Pension & retirement';
const kSystemGroupCreditShortTerm = 'Credit & short-term debt';
const kSystemGroupLoansMortgages = 'Loans & mortgages';
const kSystemGroupInvestments = 'Investments';
const kSystemAccountCashBank = 'Cash & Bank';
const kStarterIncomeCategories = ['Salary', 'Other Income'];
const kStarterExpenseCategories = [
  'Groceries',
  'Rent/Mortgage',
  'Utilities',
  'Transport',
  'Food out',
  'Phone',
  'Health',
  'Other Expense',
];

String localizeStoredName(AppLocalizations l10n, String stored) {
  return switch (stored) {
    kSystemGroupCashEquivalents => l10n.systemGroupCashEquivalents,
    kSystemGroupPensionRetirement => l10n.systemGroupPensionRetirement,
    kSystemGroupCreditShortTerm => l10n.systemGroupCreditShortTerm,
    kSystemGroupLoansMortgages => l10n.systemGroupLoansMortgages,
    kSystemGroupInvestments => l10n.systemGroupInvestments,
    kSystemAccountCashBank => l10n.systemAccountCashBank,
    'Salary' => l10n.systemCategorySalary,
    'Other Income' => l10n.systemCategoryOtherIncome,
    'Groceries' => l10n.systemCategoryGroceries,
    'Rent/Mortgage' => l10n.systemCategoryRentMortgage,
    'Utilities' => l10n.systemCategoryUtilities,
    'Transport' => l10n.systemCategoryTransport,
    'Food out' => l10n.systemCategoryFoodOut,
    'Phone' => l10n.systemCategoryPhone,
    'Health' => l10n.systemCategoryHealth,
    'Other Expense' => l10n.systemCategoryOtherExpense,
    _ => stored,
  };
}
