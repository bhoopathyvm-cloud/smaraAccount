import '../models/account.dart';
import '../models/account_currency_catalog.dart';
import '../models/transaction_direction.dart';
import '../transaction/categories_for_direction.dart';

/// Mutable Fix-this correction form state: prefilled amount/direction/
/// category/account/date/description, plus direction-filtered categories
/// and submit readiness.
///
/// Catalog snapshots ([financialAccounts], [allCategories], [currencies])
/// are updated by the ViewModel from repository streams. This module
/// never touches Drift, a Repository, or Flutter.
class CorrectionDraft {
  CorrectionDraft({
    required int amountMinor,
    required TransactionDirection direction,
    required String categoryId,
    required String financialAccountId,
    required DateTime transactionDate,
    String? description,
  }) : amountMinor = amountMinor,
       direction = direction,
       categoryId = categoryId,
       financialAccountId = financialAccountId,
       transactionDate = transactionDate,
       description = description;

  // --- Catalog snapshots (owned by ViewModel streams) ---

  List<Account> financialAccounts = const [];
  List<Account> allCategories = const [];
  AccountCurrencyCatalog currencies = AccountCurrencyCatalog.empty;

  // --- Form fields ---

  int amountMinor;
  TransactionDirection direction;
  String? categoryId;
  String? financialAccountId;
  DateTime transactionDate;
  String? description;

  /// The selected account's own currency, or null until catalogs resolve.
  String? get currency => currencies.currencyFor(financialAccountId);

  /// Active categories matching the currently selected direction (income
  /// for Received, expense for Spent) - same rule as record-transaction.
  List<Account> get categories =>
      categoriesForDirection(allCategories, direction);

  bool get canSubmit => categoryId != null && financialAccountId != null;

  void setAmountMinor(int? value) {
    if (value == null) return;
    amountMinor = value;
  }

  void setDirection(TransactionDirection value) {
    if (direction == value) return;
    direction = value;
    // The previously-selected category almost certainly doesn't match the
    // new direction's category type (income vs expense) - clear it rather
    // than silently keep an invalid selection, same as record-transaction.
    categoryId = null;
  }

  void setCategoryId(String? value) {
    categoryId = value;
  }

  void setFinancialAccountId(String? value) {
    financialAccountId = value;
  }

  void setTransactionDate(DateTime value) {
    transactionDate = value;
  }

  void setDescription(String? value) {
    description = value;
  }
}
