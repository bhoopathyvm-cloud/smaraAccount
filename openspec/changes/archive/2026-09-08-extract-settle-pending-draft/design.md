## Context

Cycle 7. Small draft deepen matching RecordTransactionDraft / TransferOrderDraft.

## Goals / Non-Goals

**Goals:** Shortfall/comparability/currency rules in a Flutter-free draft.
**Non-Goals:** Changing settle posting rules in LedgerRepository.

## Decisions

### Decision 1 — Draft takes PendingTransferSummary + target currency snapshot
VM updates `targetAccountCurrency` from catalog when accounts/selection change.

## Risks / Trade-offs

- Low; port literally.

## Migration Plan

1. Draft + tests. 2. Wire VM. 3. Acceptance; archive; merge.

## Open Questions

- None.
