## Why

The two rules a pending-transfer settlement turns on - which account the
settlement resolves to, and whether the shortfall path applies - are stated
twice, in two different shapes:

- `SettlePendingDraft` (UI form) computes `effectiveSettledToAccountId` and
  `isShortfallComparable` from a `PendingTransferSummary`.
- `LedgerPosting.settlePendingTransfer` (write path) recomputes
  `resolvedTarget` and `isShortfallComparable` from a Drift row.

They agree today, but nothing keeps them agreeing: a future edit to one
(e.g. how a foreign-transaction resolves its target) could silently let the
form offer a fee field the write path rejects, or vice versa. Architecture
review cycle 19.

## What Changes

- Add Flutter-free `PendingTransferSettlement` under `lib/domain/transfer/`
  owning `resolvedTargetAccountId` + `isShortfallComparable`, resolved from
  primitives (kind, sourceAccountId, chosen settledToAccountId).
- `SettlePendingDraft` resolves `effectiveSettledToAccountId` and
  `isShortfallComparable` through it.
- `LedgerPosting.settlePendingTransfer` resolves `resolvedTarget` and
  `isShortfallComparable` through it.
- Structure, not behavior: the resolved values are identical to today's.

## Capabilities

### New Capabilities
- `pending-transfer-settlement`: one owner for target resolution and
  shortfall-path comparability across the settle form and the write path.

### Modified Capabilities
- (none for product behavior)

## Impact

- `SettlePendingDraft` (domain) + `LedgerPosting` (data) both delegate.
- New domain module + unit tests; existing settle draft/repo/acceptance
  tests continue to pass unchanged.
