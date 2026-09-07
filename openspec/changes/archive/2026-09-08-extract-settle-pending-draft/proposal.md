## Why

Shortfall comparability and settled-amount currency are domain visibility rules buried in `SettlePendingTransferViewModel`. Lookup was deepened; settlement form policy was not. Architecture review cycle 7.

## What Changes

- Add Flutter-free `SettlePendingDraft` under `lib/domain/transfer/` (or `settle_pending/`).
- ViewModel owns streams + submit; draft owns `isShortfallComparable`, `shortfallMinor`, settled-amount currency selection rules.
- Include statement-import-session spec clarification (ViewModel owns `buildPreviewRows` call).

## Capabilities

### New Capabilities
- `settle-pending-draft`: form rules for settling a pending transfer/foreign transaction.

### Modified Capabilities
- (none for product behavior)

## Impact

- settle pending ViewModel
- New domain draft + tests
