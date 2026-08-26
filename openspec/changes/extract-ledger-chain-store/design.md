## Context

Posting extraction left `_chainState` / `_updateChainState` / `_upsertVerificationCache` copied in `LedgerPosting` and `IdentityRepository` to avoid D1a (Identity → Account → Ledger). Posting also privately selects the current signing identity. Architecture review (main `ae41a9f`) ranked this Strong: deletion of either copy does not concentrate complexity.

## Goals / Non-Goals

**Goals:**
- One deep chain-store module for tip + verification-cache writes.
- Shared identity lookup so posting does not duplicate `currentIdentity`.
- Acyclic DI: store has no posting or identity write logic.

**Non-Goals:**
- Changing hash/sign algorithms or quarantine semantics.
- Moving `appendSignedEntry` itself into Identity.
- Schema migrations.

## Decisions

### Decision 1 — Store is a data module, not a repository god object

**Options:** (A) Put helpers on `AccountChartReader`; (B) New `LedgerChainStore`; (C) Identity owns the store, posting calls Identity.

**Decision: B.** Chart reader is accounts/groups. C recreates the cycle. Name may be `LedgerChainStore` to match existing `…Repository` / posting naming in `main.dart`.

### Decision 2 — Signing identity lookup is a second tiny seam if needed

If injecting Identity into posting cycles, keep a read-only lookup (db-only, like posting's private copy today) next to the store or on the store. Two adapters (posting + identity) justify the seam.

### Decision 3 — Behavior-preserving extraction

Delegate from existing private methods first; delete copies once both callers use the store.

## Risks / Trade-offs

- **[Risk]** Cycle returns if the store imports posting → **Mitigation:** store talks only to `AppDatabase`.
- **[Trade-off]** One more constructed type in DI.

## Migration Plan

1. Extract store; both call sites delegate.
2. Wire DI; keep facade methods if any.
3. Delete private copies.
4. Rollback = revert; no data migration.

## Open Questions

- Whether identity lookup lives on the store or a sibling `SigningIdentityLookup`.
