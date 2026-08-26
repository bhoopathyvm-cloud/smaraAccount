## 1. Capture current behavior

- [x] 1.1 Document current RegisterViewModel row rules vs `exportLedgerCsv` counterpart/label helpers (note any divergence)
- [x] 1.2 Add or extend unit fixtures that freeze current UI row semantics (sign, quarantine, splits)

## 2. Extract projection

- [x] 2.1 Create `RegisterProjection` (or equivalent) module returning register rows from entries + context
- [x] 2.2 Switch `RegisterViewModel` to the projection; delete duplicated recompute helpers
- [x] 2.3 Switch `exportLedgerCsv` to consume projection rows; keep CSV formatting only
- [x] 2.4 If UI/export diverged, pick documented semantics and cover with a test

## 3. Verify

- [x] 3.1 Projection unit tests cover balance sign, quarantine exclusion, split labels
- [x] 3.2 Register/export-related unit tests green; spot-check acceptance register search / core ledger on macOS
