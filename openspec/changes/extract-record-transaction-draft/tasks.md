## 1. Draft module

- [x] 1.1 Inventory form rules currently inlined in `RecordTransactionViewModel` (split expand/collapse/remainder, FX visibility, paid-from shortcuts, direction category clear, payee match/suggestions)
- [x] 1.2 Add `lib/domain/record_transaction/record_transaction_draft.dart` with `SplitLine` and `RecordTransactionDraft`
- [x] 1.3 Unit tests (`test/domain/record_transaction/record_transaction_draft_test.dart`): remainder, FX, card/bank filters, split expand/collapse, direction clears categories/shortcuts, `canSubmitSingle` / `canSubmitSplit`

## 2. Wire RecordTransactionViewModel

- [x] 2.1 Own a `RecordTransactionDraft`; update catalog snapshots from account/currency/category/payee stream listeners
- [x] 2.2 Forward public getters/setters to the draft; delete inlined implementations of those rules
- [x] 2.3 Keep `submit` / payee-usage / failure mapping on the ViewModel, reading draft fields
- [x] 2.4 Update `record_transaction_view.dart` import for `SplitLine` (domain module); remove duplicate `SplitLine` from the ViewModel file

## 3. Verify

- [x] 3.1 `dart analyze` clean; new draft unit tests green
- [x] 3.2 Existing `record_transaction_view_model_test.dart` (and view widget tests if any) still green
- [ ] 3.3 Full acceptance suite on macOS (`tool/run_acceptance_tests.sh -d macos`)
