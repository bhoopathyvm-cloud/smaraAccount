/// A remembered payee name with optional defaults (payees-and-spending-memory
/// design.md Decision 1): recording a transaction whose description
/// matches [name] (via `normalizeDescription`, the same normalization
/// import category rules already use) suggests [defaultCategoryId] and
/// [defaultFinancialAccountId], always overridable. Both defaults double
/// as "last used" - each successfully recorded transaction for this payee
/// updates them to whatever was actually used.
class Payee {
  const Payee({
    required this.id,
    required this.name,
    this.defaultCategoryId,
    this.defaultFinancialAccountId,
  });

  final String id;
  final String name;
  final String? defaultCategoryId;
  final String? defaultFinancialAccountId;
}
