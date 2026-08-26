## Context

`_buildSettlePendingTransfer` walks `HomeViewModel.overview?.pendingTransfers`. `PendingTransferSummary` is assembled only in `_buildHomeOverview`. Architecture review ranked this Strong: deep-link locality is broken.

## Goals / Non-Goals

**Goals:**
- Id → summary at the ledger (or pending-transfer) read seam.
- Router/settle VM take `pendingTransferId` only.
- One join implementation for Home list and settle.

**Non-Goals:**
- Changing settlement posting rules.
- A new Drift table.

## Decisions

### Decision 1 — Lookup lives with ledger reads, not Home

**Options:** (A) Keep deriving from Home; (B) `LedgerRepository.pendingTransferSummary(id)`; (C) Dedicated small module.

**Decision: B** unless ledger facade is already too wide — then C next to overview builder. Prefer one join helper both call.

### Decision 2 — Null means already settled / missing

Preserve today's copy and empty-state when lookup returns null.

## Risks / Trade-offs

- **[Risk]** Extra query on settle vs in-memory Home list → **Mitigation:** acceptable; correctness over sharing UI state.
- **[Trade-off]** Home still watches a list; settle does a point lookup.

## Migration Plan

1. Extract join helper; Home uses it per row / for the list.
2. Add `summaryFor(id)`; router switches.
3. Widget test: settle without Home overview loaded.

## Open Questions

- Whether summary type stays in `home_overview.dart` or moves to a pending-transfer model file.
