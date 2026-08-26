## Why

Understanding “what a register row means” requires bouncing between `RegisterViewModel._recompute` (running balance, quarantine exclusion, split counterpart labels, fixability) and `LedgerRepository.exportLedgerCsv` (parallel counterpart labeling, hard-coded English). Both call `displayBalanceDeltaFor`, but label/format rules can diverge — liability sign bugs hide in call patterns, not one interface. Poor locality across the UI/data seam.

## What Changes

- Extract a `RegisterProjection` module that maps journal entries + account/category context → register rows (balance, quarantine, splits, fixability, counterpart labels).
- Have `RegisterViewModel` and `exportLedgerCsv` consume that projection; CSV keeps only formatting/serialization.
- Keep user-visible register and export outcomes identical unless a real divergence is found and intentionally fixed with tests.

## Capabilities

### New Capabilities
- `register-projection`: single projection interface for register display rows shared by UI and ledger CSV export.

### Modified Capabilities
- (none unless export/register alignment reveals a bug that must become a product requirement change — default is behavior-preserving)

## Impact

- `lib/ui/features/register/view_models/register_view_model.dart`, `register_row.dart`
- `lib/data/repositories/ledger_repository.dart` (`exportLedgerCsv`, `displayBalanceDeltaFor`, counterpart helpers)
- Register and export unit/widget tests; acceptance register scenarios remain GUI assertions only
- Natural follow-on after or alongside `extract-ledger-posting-core` if posting/export still sit in the same file
