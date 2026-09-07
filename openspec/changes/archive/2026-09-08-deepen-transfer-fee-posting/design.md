## Context

Cycle 8. Draft owns amounts; posting composition still in VM.

## Goals / Non-Goals

**Goals:** Locality of transfer±fee orchestration behind LedgerRepository.
**Non-Goals:** Changing partial-failure into all-or-nothing atomicity (would be a product change).

## Decisions

### Decision 1 — Preserve partial failure
Transfer commits first; fee failure surfaces `validationTransferSavedFeeFailed`. Same as today.

### Decision 2 — Method on LedgerRepository facade
Thin wrapper over existing `recordTransfer` + `recordTransaction`; no LedgerPosting signature change required for this slice.

## Risks / Trade-offs

- **[Risk]** Mock/test churn → Mitigation: regenerate mocks; update transfer VM tests.

## Migration Plan

1. Add method. 2. Wire VM. 3. Update tests. 4. Acceptance; archive; merge.

## Open Questions

- None.
