## Context

`architecture-deepening` split Category/Payee/Backup/Account repositories out of `LedgerRepository`, then hit D1a/D2 cycles and duplicated account-read and identity lookup *inside* `LedgerRepository` instead of introducing a cycle-free read seam. Posting/signing (`appendSignedEntry`, `recordTransaction`, reverse, pending transfers) remains entangled with overview aggregation and CSV export in one ~1,756-line module.

## Goals / Non-Goals

**Goals:**
- One deep posting module with a small interface for sign/chain/record/reverse/pending transfers.
- Cycle-free chart/account read seam shared by overview and export (no private duplicate adapters in the posting file).
- Existing unit, INTEGRATION, and acceptance journal scenarios pass unmodified.
- Clear dependency direction so leaf repositories do not force posting to import their types in a cycle.

**Non-Goals:**
- Changing integrity algorithms, quarantine semantics, or user-visible posting rules.
- Unifying register projection (separate change: `unify-register-projection`).
- Lifting Drift enums (separate change: `lift-domain-enums-from-drift`).
- Schema migrations.

## Decisions

### Decision 1 — Extract posting as an internal module, not another “god” repository

**Options:** (A) Move only crypto helpers; (B) Extract `LedgerPostingService` / `LedgerPostingRepository` owning write path; (C) Split reads and writes into two peer repositories with equal surface area.

**Decision: B.** Callers that post transactions learn one small interface; overview/export stay read-oriented. Exact type name (`…Service` vs `…Repository`) chosen to match existing DI conventions in `main.dart`.

### Decision 2 — Shared account chart reader for cycle break

**Options:** (A) Keep private duplicates in LedgerRepository; (B) Inject `AccountRepository` into LedgerRepository (risks cycle); (C) Thin read-only chart mapper/module both can use without A→B→A.

**Decision: C.** Prefer a small read seam both posting and account packages can depend on without importing each other.

### Decision 3 — Behavior-preserving extraction first

Move code behind the new interface with tests green before any cleanup of overview/export ownership. Register projection extraction is out of scope here.

## Risks / Trade-offs

- **[Risk]** DI graph breaks mid-migration → **Mitigation:** extract behind facade methods on `LedgerRepository` that delegate, then retarget ViewModels in a second pass.
- **[Risk]** Cycle reappears with investment/import callers → **Mitigation:** audit import graph in design tasks before cutting public constructors.
- **[Trade-off]** Temporary dual surface (facade + new module) until callers migrate.

## Migration Plan

1. Extract module; delegate from existing methods.
2. Retarget DI and tests.
3. Remove duplicates and dead private helpers.
4. Rollback = revert commit; no data migration.

## Open Questions

- Final module name (`LedgerPostingService` vs repository naming).
- Whether home overview stays on slimmed `LedgerRepository` or moves with the chart reader in the same PR.
