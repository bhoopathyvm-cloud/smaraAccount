## 1. Engine

- [ ] 1.1 Extract exclusion policy (verified, not superseded) + display fold into a domain module
- [ ] 1.2 Unit tests: quarantined and superseded entries omitted; liability sign unchanged

## 2. Callers

- [ ] 2.1 `displayBalanceMinor` and `_buildHomeOverview` use the engine
- [ ] 2.2 Align register projection running-balance skips with the same helper
- [ ] 2.3 `LedgerPosting` uses the engine; remove `displayBalanceMinor` facade callback

## 3. Verify

- [ ] 3.1 Ledger, register-projection, and posting-related unit tests green
- [ ] 3.2 `dart analyze` clean
