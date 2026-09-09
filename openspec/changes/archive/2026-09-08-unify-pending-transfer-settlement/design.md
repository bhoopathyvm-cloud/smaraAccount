## Context

Cycle 19. A `unify-` deepening: two divergent restatements of the same rule
(target resolution + shortfall comparability) collapse into one owner. Both
`SettlePendingDraft` and `LedgerPosting.settlePendingTransfer` are adapters
onto the same rule, so the seam is justified (two adapters, not one).

## Goals / Non-Goals

**Goals:** One Flutter-free owner for "resolved target account" and "is this
the shortfall path" that the settle form and the write path both resolve
through.
**Non-Goals:** Changing any settlement validation, posting legs, or currency
rules. This is structure, not behavior - resolved values are identical to
today.

## Decisions

### Decision 1 - Resolve from primitives, not a summary or a Drift row
The two consumers have different input shapes (`PendingTransferSummary` vs a
Drift `PendingTransfer` row), so the policy takes the primitive fields both
can supply: `kind`, `sourceAccountId`, and the chosen `settledToAccountId`.
It returns a small value with `resolvedTargetAccountId` and
`isShortfallComparable`. This keeps the module a leaf (domain, no Drift, no
repository) and avoids coupling it to either caller's type.

### Decision 2 - `resolvedTargetAccountId` is nullable
The draft can ask before the user has chosen a transfer target, so the
resolved target is null in that case (matching the draft's prior
`effectiveSettledToAccountId`). The write path passes a required
`settledToAccountId`, so it reads the value with `!`.

## Risks / Trade-offs

- Low. The rule is ported literally and both prior call sites are migrated in
  this change (no compatibility window). Verified equivalent for all four
  cases: transfer→source, transfer→destination, foreignTransaction, and
  transfer with no target yet.

## Migration Plan

1. Add `PendingTransferSettlement` + unit tests.
2. Wire `SettlePendingDraft` and `LedgerPosting` onto it; remove the inline
   restatements.
3. analyze + unit/widget/repo tests; settle-pending acceptance; archive; PR.

## Open Questions

- None.
