## Context
Cycle 10. Record/transfer/settle drafts already extracted; Correction leftover.

## Goals / Non-Goals
**Goals:** Leaf `CorrectionDraft`; VM is streams + fix orchestration.
**Non-Goals:** Shared `categoriesForDirection` helper with Record (later unify-); RecurringTemplateDraft.

## Decisions
### Decision 1 — Mirror RecordTransactionDraft shape
Mutable draft with catalog snapshots + form fields; VM notifies on mutation.

### Decision 2 — Prefill via constructor
Draft constructed with initial amount/direction/category/account/date/description from the Fix entry.

### Decision 3 — `canSubmit` on draft
Expose readiness so UI/VM can share one rule (`categoryId` + `financialAccountId` present; amount already required at prefill).

## Risks
- Direction clear must stay identical — port literally; keep VM regression test.
