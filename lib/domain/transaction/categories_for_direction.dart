import '../models/account.dart';
import '../models/transaction_direction.dart';

/// Active categories matching [direction] (income for money-in, expense
/// for money-out). Shared by record / correction / recurring drafts.
List<Account> categoriesForDirection(
  Iterable<Account> allCategories,
  TransactionDirection direction,
) {
  final categoryType = direction == TransactionDirection.moneyIn
      ? AccountType.income
      : AccountType.expense;
  return allCategories.where((a) => a.type == categoryType).toList();
}
