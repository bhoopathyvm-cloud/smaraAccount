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

/// Fallback transaction description a CSV import writes when no column
/// supplies one (`lib/domain/csv/csv_parser.dart`). A system-generated
/// sentinel like the group/account/category seeds above, not user-typed
/// text, so it gets the same localize-for-display treatment.
const kSystemDescriptionCsvImport = 'CSV import';

/// Same fallback pattern as [kSystemDescriptionCsvImport], for OFX imports
/// (`lib/domain/ofx/ofx_parser.dart`).
const kSystemDescriptionOfxImport = 'OFX import';

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
    kSystemDescriptionCsvImport => l10n.systemDescriptionCsvImport,
    kSystemDescriptionOfxImport => l10n.systemDescriptionOfxImport,
    _ => stored,
  };
}

/// The value an editor (rename dialog, first-account-name field, ...)
/// should prefill for [stored]: the localized display text while it still
/// matches a system seed, otherwise the stored text as-is (a real user
/// rename). Editors MUST use this instead of [stored] directly, or a
/// Tamil-language editor would show the English seed inside an otherwise
/// Tamil field (i18n-full-ui-and-input-language design.md Decision 1).
String editingNameFor(AppLocalizations l10n, String stored) =>
    localizeStoredName(l10n, stored);

/// What to persist after editing a field prefilled with [editingNameFor].
/// If the user left [edited] equal to the localized display of
/// [storedOriginal], or retyped the English seed itself, this returns
/// [storedOriginal] unchanged so the seed keeps matching every locale's
/// mapping in [localizeStoredName]. Otherwise [edited] (trimmed) is a real
/// rename and is returned as typed.
String canonicalNameToPersist(
  AppLocalizations l10n,
  String storedOriginal,
  String edited,
) {
  final trimmed = edited.trim();
  if (trimmed == localizeStoredName(l10n, storedOriginal) ||
      trimmed == storedOriginal) {
    return storedOriginal;
  }
  return trimmed;
}
