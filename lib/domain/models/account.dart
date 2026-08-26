import 'account_type.dart';

export 'account_type.dart';

/// Domain-facing view of an `accounts` row — a financial account,
/// Income/Expense category, or the internal equity offset.
class Account {
  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.archived,
    this.groupId,
    this.sortOrder = 0,
    this.holdsInvestments = false,
    this.investmentOwnerAccountId,
    this.monthlyLimitMinor,
    this.isCreditCard = false,
  });

  final String id;
  final String name;
  final AccountType type;
  final bool archived;
  final String? groupId;
  final int sortOrder;
  final bool holdsInvestments;
  final String? investmentOwnerAccountId;

  /// monthly-category-limits: only ever set for an Expense category
  /// (`LedgerRepository.setCategoryMonthlyLimit` rejects any other type),
  /// informational month-to-date progress display only - never enforced
  /// against posting.
  final int? monthlyLimitMinor;

  /// credit-card-household-flow: only ever true for a Liability account,
  /// set at creation and immutable after - a label and capture-flow
  /// default, not a new account type or posting shape.
  final bool isCreditCard;

  bool get isFinancial =>
      type == AccountType.asset || type == AccountType.liability;

  bool get isInvestmentAccount => isFinancial && holdsInvestments;
  bool get isInvestmentInventoryAccount =>
      type == AccountType.inventory && investmentOwnerAccountId != null;
}
