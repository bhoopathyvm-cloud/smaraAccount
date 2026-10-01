/// Derived status of a Claim from its items and settlement
/// (shared-accounts-and-expense-claims design Decision 3).
enum ClaimStatus { draft, submitted, partlyApproved, approved, paid, rejected }
