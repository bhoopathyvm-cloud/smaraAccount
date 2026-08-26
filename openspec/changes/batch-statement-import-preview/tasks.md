## 1. Extract preview builder

- [ ] 1.1 Capture current preview outputs for a multi-row fixture (categories, duplicates)
- [ ] 1.2 Implement `buildPreviewRows` (domain categorizer + repository, or repository-owned) with parity tests
- [ ] 1.3 Batch `suggestCategoryFor` (or equivalent) behind that interface — no per-row await from the ViewModel

## 2. Slim ViewModel

- [ ] 2.1 Replace `_checkCurrencyAndBuildPreview` loop with one seam call
- [ ] 2.2 Remove unused injections (e.g. PayeeRepository) if still unused after move
- [ ] 2.3 Keep currency gate behavior equivalent; cover with unit tests

## 3. Verify

- [ ] 3.1 Statement-import unit/widget tests green
- [ ] 3.2 `tool/run_acceptance_tests.sh -d macos` csv_import and ofx_import groups green
