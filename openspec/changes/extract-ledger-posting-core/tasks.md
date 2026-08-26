## 1. Map and extract

- [x] 1.1 Inventory `LedgerRepository` posting/signing methods and private duplicate account/identity helpers; list callers
- [x] 1.2 Choose module name and package path; sketch interface (record, reverse, append signed, pending-transfer writes)
- [x] 1.3 Introduce shared chart/account read seam that breaks D1a-style cycles (no private `_watchFinancialAccounts` duplicate in posting)

## 2. Implement

- [x] 2.1 Move posting/signing implementation behind the new module; temporarily delegate from existing `LedgerRepository` methods
- [x] 2.2 Wire DI in `main.dart`; update repositories that call posting
- [x] 2.3 Remove duplicate private adapters once callers use the shared read seam
- [x] 2.4 Retarget unit/INTEGRATION tests to construct the posting module (or keep facade until green)

## 3. Verify

- [ ] 3.1 `dart analyze` clean; unit suites for journal/integrity green
- [ ] 3.2 `tool/run_acceptance_tests.sh -d macos core_ledger` green
- [ ] 3.3 Confirm no product-spec requirement files needed updating (behavior-preserving)
