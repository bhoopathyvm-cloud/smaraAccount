import '../../data/database/tables/account_groups_table.dart'
    show AccountGroupKind;

export '../../data/database/tables/account_groups_table.dart'
    show AccountGroupKind;

/// Domain-facing view of an `account_groups` row.
class AccountGroup {
  const AccountGroup({
    required this.id,
    required this.name,
    required this.kind,
    required this.sortOrder,
    required this.isSystem,
  });

  final String id;
  final String name;
  final AccountGroupKind kind;
  final int sortOrder;
  final bool isSystem;
}
