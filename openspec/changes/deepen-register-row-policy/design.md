## Context

Cycle 5. Projection already extracted; fixability/filter still shallow in the ViewModel.

## Goals / Non-Goals

**Goals:** Deep module for fixability + filter; ViewModel remains stream/submit seam.
**Non-Goals:** Server-side search; changing Fix product rules.

## Decisions

### Decision 1 — Amount text via callback
`filterRegisterRows` takes `amountTextFor(RegisterRow)` so locale formatting stays in the UI layer (`formatAmountMinor`) without domain importing UI.

### Decision 2 — Fixability takes category id set + reversed entry id set
Pure function of row + those sets — no ChangeNotifier.

## Risks / Trade-offs

- **[Risk]** End-exclusive date filter off-by-one → Mitigation: port literally + unit test.

## Migration Plan

1. Module + tests. 2. Wire VM. 3. Acceptance; archive; merge.

## Open Questions

- None.
