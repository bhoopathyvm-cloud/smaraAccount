## Context

`StatementImportViewModel` (~628 lines) owns `_checkCurrencyAndBuildPreview`, looping rows with `matchCategoryRule` then per-row `await suggestCategoryFor`. Domain already has rule matching; repository owns suggest/post. PayeeRepository may be injected unused in preview. N+1 async and split policy hurt tests and large imports.

## Goals / Non-Goals

**Goals:**
- One `buildPreviewRows` (name TBD) at repository or domain-behind-repository seam.
- Batched suggestion queries where the repository currently does per-id work.
- ViewModel orchestrates steps only; preview is a single call.

**Non-Goals:**
- Redesigning the multi-step import wizard UI files (already split in prior architecture work).
- Changing CSV/OFX parsing formats.
- Import category rule editor UX changes.

## Decisions

### Decision 1 — Repository method wrapping domain categorizer

**Options:** (A) Pure domain function with injected suggest port; (B) All logic in repository; (C) Keep loop in ViewModel but batch suggests only.

**Decision: A or B with one external call from ViewModel.** Prefer domain categorizer + repository adapter for suggest/dedupe so unit tests can fake the suggest port. ViewModel MUST NOT await per row.

### Decision 2 — DTO stays UI-bindable

Return the same preview row shape the UI already binds, or a domain DTO mapped once in the ViewModel without re-categorizing.

### Decision 3 — Preserve acceptance CSV/OFX paths

No harness changes unless finder timing improves from faster preview.

## Risks / Trade-offs

- **[Risk]** Batching changes suggestion order → **Mitigation:** parity tests on fixture statements before/after.
- **[Trade-off]** Repository grows deeper — acceptable; ViewModel should shrink.

## Migration Plan

1. Extract buildPreview with parity tests.
2. Switch ViewModel; delete loop.
3. Optimize batching behind the same interface.

## Open Questions

- Whether PayeeRepository belongs in preview (wire or remove unused injection).
