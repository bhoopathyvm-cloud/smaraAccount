## Context

Cycle 4. Active balance engine already owns entry exclusion for raw sums; home still inlines section/net/pending assembly and investment portfolio folding.

## Goals / Non-Goals

**Goals:** One deep module for HomeOverview assembly + shared investment portfolio totals.
**Non-Goals:** Changing watch wiring; moving Drift pending-row mapping into domain.

## Decisions

### Decision 1 — Repository loads; engine assembles
Async Drift I/O stays in `LedgerRepository`. Engine is pure sync given already-fetched domain inputs.

### Decision 2 — Pending inputs are domain DTOs
Repo maps Drift rows + provisional entry verification into `HomeOverviewPendingInput` (includes `countsTowardNetPosition`).

### Decision 3 — Share `investmentPortfolioTotals(cash, holdings)`
Same fold Home and Holdings use.

## Risks / Trade-offs

- **[Risk]** Pending inclusion drift → Mitigation: unit tests for quarantined vs active pending.

## Migration Plan

1. Engine + tests. 2. Wire repo + holdings VM. 3. Acceptance; archive; merge.

## Open Questions

- None.
