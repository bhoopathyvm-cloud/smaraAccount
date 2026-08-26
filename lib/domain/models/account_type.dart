/// Chart-of-accounts row type.
///
/// Financial accounts: [asset], [liability].
/// Categories: [income], [expense].
/// System offset for opening balances: [equity] (never user-facing).
/// System clearing account for cross-currency settlement: [clearing]
/// (never user-facing) - a distinct type, not reused from asset/liability,
/// so the existing `type IN (asset, liability)` picker allowlists exclude
/// it automatically rather than needing to filter it out by id everywhere
/// (multi-currency-support design.md Decision 3).
///
/// Investment inventory companion account: [inventory] (never user-facing),
/// used to keep holdings on-ledger as an asset without exposing that
/// internal leg in financial-account pickers.
enum AccountType {
  asset,
  liability,
  equity,
  clearing,
  inventory,
  income,
  expense,
}
