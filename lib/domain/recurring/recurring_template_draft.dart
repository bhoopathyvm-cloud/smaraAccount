import '../models/account.dart';
import '../models/transaction_direction.dart';
import '../transaction/categories_for_direction.dart';

/// Mutable recurring-template add/edit form state: name, direction,
/// account, category, amount, day-of-month, plus direction-filtered
/// categories and submit readiness.
///
/// Catalog snapshots are supplied by the dialog/ViewModel. This module
/// never touches Drift, a Repository, or Flutter.
class RecurringTemplateDraft {
  RecurringTemplateDraft({
    this.name = '',
    this.direction = TransactionDirection.moneyOut,
    this.financialAccountId,
    this.categoryId,
    this.amountMinor,
    this.dayOfMonth,
  });

  factory RecurringTemplateDraft.fromTemplate({
    required String name,
    required TransactionDirection direction,
    required String financialAccountId,
    required String categoryId,
    required int amountMinor,
    required int dayOfMonth,
  }) {
    return RecurringTemplateDraft(
      name: name,
      direction: direction,
      financialAccountId: financialAccountId,
      categoryId: categoryId,
      amountMinor: amountMinor,
      dayOfMonth: dayOfMonth,
    );
  }

  List<Account> financialAccounts = const [];
  List<Account> allCategories = const [];

  String name;
  TransactionDirection direction;
  String? financialAccountId;
  String? categoryId;
  int? amountMinor;
  int? dayOfMonth;

  List<Account> get categories =>
      categoriesForDirection(allCategories, direction);

  bool get canSubmit {
    final amount = amountMinor;
    final day = dayOfMonth;
    return name.trim().isNotEmpty &&
        financialAccountId != null &&
        categoryId != null &&
        amount != null &&
        amount > 0 &&
        day != null &&
        day >= 1 &&
        day <= 31;
  }

  void setDirection(TransactionDirection value) {
    if (direction == value) return;
    direction = value;
    categoryId = null;
  }
}
