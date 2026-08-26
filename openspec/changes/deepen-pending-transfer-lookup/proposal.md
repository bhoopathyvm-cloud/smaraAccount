## Why

The settle-pending-transfer route scans `HomeViewModel.overview?.pendingTransfers` for a `PendingTransferSummary`. Names, currency, and amount are computed only inside home overview assembly. A cold open or deep link on `/settle-pending-transfer/:id` reports “already settled” when Home has not loaded, even if the row exists.

## What Changes

- Deepen a `PendingTransferLookup` (method on the ledger read seam or a small module) that returns the same joined summary Home uses.
- Router and settle ViewModel take `pendingTransferId` only — no `HomeViewModel` dependency.
- Home overview continues to list summaries via the same lookup/join, not a second copy.

## Capabilities

### New Capabilities
- `pending-transfer-lookup`: id → joined pending-transfer summary (names, currency, amount) independent of Home screen state.

### Modified Capabilities
- (none — product pending-transfer settlement requirements unchanged)

## Impact

- `lib/ui/app_router.dart` `_buildSettlePendingTransfer`
- `lib/data/repositories/ledger_repository.dart` overview pending assembly
- Settle pending transfer view model / widget tests
- Deep-link / cold-open coverage (unit or widget)
