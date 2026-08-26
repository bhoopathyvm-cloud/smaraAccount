/// Whether a pending item is a transfer between two financial accounts, or
/// the account-currency leg of a foreign-currency income/expense
/// transaction (multi-currency-support design.md Decision 4).
enum PendingTransferKind { transfer, foreignTransaction }

/// pending: the provisional entry has posted, awaiting settlement.
/// settled: closed - either delivered to the destination, or returned to
/// the source (with any shortfall posted as a fee), per design.md
/// Decision 5.
enum PendingTransferStatus { pending, settled }
