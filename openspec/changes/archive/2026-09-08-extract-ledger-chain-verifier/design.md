## Context

Cycle 9. `extract-ledger-chain-store` already shared tip/cache; verification walk still on Identity.

## Goals / Non-Goals

**Goals:** Leaf verifier; Identity is lifecycle-only; callers inject Verifier.
**Non-Goals:** Moving key-loss migration onto the verifier.

## Decisions

### Decision 1 — No Identity facade for verifyChain
Callers and tests use `LedgerChainVerifier` directly (finish the seam).

### Decision 2 — Same constructor defaulting pattern as Identity
Optional `SigningKeyService` / `LedgerChainStore`; required `AppDatabase`.

### Decision 3 — `ChainVerificationResult` moves with the verifier
Identity re-exports nothing; update imports.

## Risks / Trade-offs

- **[Risk]** Miss migration genesis-reset rule (`migratedFromEntryId`) → Mitigation: move logic literally; keep comment.
- **[Risk]** ADR 0002 cycle → Mitigation: no Identity/Account/Ledger deps on Verifier.

## Migration Plan

1. Extract module. 2. Wire DI + callers. 3. Update tests/mocks. 4. Acceptance; archive; merge.

## Open Questions

- None.
