import '../../data/database/tables/accounts_table.dart' show AccountType;

export '../../data/database/tables/accounts_table.dart' show AccountType;

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
  });

  final String id;
  final String name;
  final AccountType type;
  final bool archived;
  final String? groupId;
  final int sortOrder;

  bool get isFinancial =>
      type == AccountType.asset || type == AccountType.liability;
}
