## Context

Register UI builds rows in `RegisterViewModel`; CSV export rebuilds counterpart labels and related display rules in `LedgerRepository.exportLedgerCsv`. Shared helpers like `displayBalanceDeltaFor` exist, but running balance, quarantine exclusion, split labels, and fixability are not one projection — export can drift (including hard-coded English labels).

## Goals / Non-Goals

**Goals:**
- One `RegisterProjection` (or equivalent) module: entries + context → register rows.
- UI and CSV both consume it; CSV only formats.
- Unit tests cover sign/balance/quarantine/split labels at the projection interface.

**Non-Goals:**
- Changing export file format unless a proven bug requires it (document and test).
- Extracting posting core (separate change).
- i18n of export strings beyond aligning with projection labels already used in UI (prefer l10n if touching strings).

## Decisions

### Decision 1 — Projection is domain/data read-model, not a ViewModel method

**Options:** (A) Static helpers on `RegisterRow`; (B) Method on `LedgerRepository`; (C) Dedicated projection module called by ViewModel and export.

**Decision: C.** Deletion test: deleting the projection would scatter rules back into UI and export. Keep it independent of Flutter widgets.

### Decision 2 — RegisterRow remains the shared DTO

Projection returns the same conceptual row type the UI already uses (or a domain twin mapped 1:1) so export maps rows → CSV cells without re-deriving semantics.

### Decision 3 — Fix divergences intentionally

If UI and export disagree today, pick UI-correct semantics (or documented export semantics), add a test, then unify — do not silently average them.

## Risks / Trade-offs

- **[Risk]** Export consumers depend on English hard-coded labels → **Mitigation:** snapshot/golden or string assertions in unit tests before/after.
- **[Trade-off]** Slightly larger first PR if posting extraction not yet done and both live in `ledger_repository.dart`.

## Migration Plan

1. Extract projection with parity tests against current UI output.
2. Switch ViewModel, then export.
3. Delete duplicate helpers.

## Open Questions

- Exact package path (`lib/domain/register/` vs `lib/data/read_models/`).
