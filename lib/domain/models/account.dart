import '../../data/database/tables/accounts_table.dart' show AccountType;

export '../../data/database/tables/accounts_table.dart' show AccountType;

/// Domain-facing view of an `accounts` row - the single financial account,
/// or an Income/Expense category (design.md: "one `accounts` table for
/// both the financial account and categories").
class Account({
  required final String id,
  required final String name,
  required final AccountType type,
  required final bool archived,
});
