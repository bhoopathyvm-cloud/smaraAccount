## Context

`displayBalanceMinor`, `_buildHomeOverview`, and `RegisterProjection` each skip unverified / superseded entries. Posting still injects `displayBalanceMinor` from the facade. Architecture review ranked this Strong: changing one loop lets Home disagree with Register.

## Goals / Non-Goals

**Goals:**
- Domain `ActiveBalanceEngine` (or equivalent): entries + account types → display/raw sums.
- Posting uses the engine; drop the facade callback.
- Register projection keeps counterpart labels; shares “which entries count.”

**Non-Goals:**
- Changing Option A signs or quarantine UI treatment.
- SQL-optimized balance queries (optional later, same interface).

## Decisions

### Decision 1 — Domain module, in-process

**Options:** (A) Static helpers on LedgerRepository; (B) Domain engine; (C) SQL-only balances.

**Decision: B.** Tests hit the engine without Drift. C is a later adapter behind the same interface.

### Decision 2 — Register projection stays the label/sign module

Do not merge CSV/UI labels into the engine. Engine = exclusion + optional fold; projection = row DTO + labels. Projection should call the same exclusion helper so running balance cannot drift.

### Decision 3 — Posting owns or injects the engine

Construct the engine with a journal-read port if needed, or pass snapshots. Avoid `LedgerRepository` tear-off.

## Risks / Trade-offs

- **[Risk]** Double-load of entries (overview + engine) → **Mitigation:** overview passes the list it already loaded.
- **[Trade-off]** One more type in DI.

## Migration Plan

1. Extract exclusion + fold; unit-test quarantined/superseded cases.
2. Switch `displayBalanceMinor` and overview.
3. Point posting at the engine; delete callback.

## Open Questions

- Whether engine also folds investment portfolio cash or only journal display balances.
