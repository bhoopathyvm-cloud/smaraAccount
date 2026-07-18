import '../../data/database/tables/accounts_table.dart' show AccountType;

export '../../data/database/tables/accounts_table.dart' show AccountType;

/// Domain-facing view of an `accounts` row - the single financial account,
/// or an Income/Expense category (design.md: "one `accounts` table for
/// both the financial account and categories").
class Account {
  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.archived,
  });

  final String id;
  final String name;
  final AccountType type;
  final bool archived;
}
