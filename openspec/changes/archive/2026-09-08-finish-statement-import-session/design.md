## Context

Cycle 6. Prior extract left a shallow session; finish the seam in one change.

## Goals / Non-Goals

**Goals:** Session owns preview/review wizard state; VM is I/O adapter.
**Non-Goals:** Moving `buildPreviewRows` / parse onto the session (I/O stays on repo).

## Decisions

### Decision 1 — Session applies preview drafts, does not call the repository
VM calls `buildPreviewRows`, then `session.applyPreview(...)`.

### Decision 2 — CSV bytes stay on VM
Raw file bytes are I/O artifacts for re-parse; session keeps header/mapping only via existing draft + optional header row if needed for UI. Keep `_csvBytes` on VM.

## Risks / Trade-offs

- **[Risk]** Step assignment regressions OFX vs CSV → Mitigation: named transitions; existing widget/VM tests.

## Migration Plan

1. Expand session + unit tests. 2. Thin VM. 3. Acceptance; archive; merge.

## Open Questions

- None.
