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
    required this.currency,
    required this.archived,
  });

  final String id;
  final String name;
  final AccountGroupKind kind;
  final int sortOrder;
  final bool isSystem;

  /// ISO 4217 code (e.g. 'USD'). Null only for a group on a database
  /// migrated from schemaVersion 3 that hasn't been through the one-time
  /// currency backfill yet (multi-currency-support design.md Decision 1).
  final String? currency;

  /// Always false for a system group - only a user-created group can be
  /// archived (custom-account-groups design.md Decision 3).
  final bool archived;
}
