## 1. Engine

- [x] 1.1 Extract exclusion policy (verified, not superseded) + display fold into a domain module
- [x] 1.2 Unit tests: quarantined and superseded entries omitted; liability sign unchanged

## 2. Callers

- [x] 2.1 `displayBalanceMinor` and `_buildHomeOverview` use the engine
- [x] 2.2 Align register projection running-balance skips with the same helper
- [x] 2.3 `LedgerPosting` uses the engine; remove `displayBalanceMinor` facade callback

## 3. Verify

- [x] 3.1 Ledger, register-projection, and posting-related unit tests green
- [x] 3.2 `dart analyze` clean
