## Why

`RecordTransactionViewModel` (~480 lines) owns split remainder math, foreign-currency visibility, paid-from-card/bank picker filters, and payee matching inside a ChangeNotifier whose interface is nearly as wide as the implementation. Those form rules need four mocked repositories to unit-test, and they are the same shape of draft state already extracted for holdings (`BuyOrderDraft`) and statement import (`CsvMappingDraft` / `StatementImportSession`). Architecture review cycle 1 flagged this as the highest-leverage deepening on a recent hot file.

## What Changes

- Add a Flutter-free `lib/domain/record_transaction/record_transaction_draft.dart` with `SplitLine` and mutable `RecordTransactionDraft` holding amount, direction, category/split lines, financial-account shortcuts, native-currency override, description/payee selection, plus computed `splitRemainderMinor`, `isForeignCurrency`, `financialAccountOptions`, category-type filtering helpers, and `canSubmitSingle` / `canSubmitSplit` readiness.
- `RecordTransactionViewModel` owns one draft, forwards setters that mutate it and `notifyListeners()`, keeps stream subscriptions and submit/payee-usage orchestration, and no longer defines the form-rule implementation inline.
- Preserve existing field visibility, validation error codes, and posting behavior — locality change, not product-behavior change.
- Move split/FX/shortcut unit coverage that currently goes through the ViewModel onto the draft where possible; keep ViewModel tests for submit orchestration and stream wiring.

## Capabilities

### New Capabilities
- `record-transaction-draft`: a Flutter-free draft module for the record-transaction form fields, split remainder, foreign-currency visibility, paid-from-card/bank filters, and submit readiness — testable with `package:test` without a ChangeNotifier or mocked repositories.

### Modified Capabilities
- (none — record-transaction / split-transactions / credit-card-household-flow / multi-currency product behavior unchanged)

## Impact

- `lib/ui/features/record_transaction/view_models/record_transaction_view_model.dart`
- `lib/ui/features/record_transaction/views/record_transaction_view.dart` (only if it imports `SplitLine` from the VM file — re-export or update import)
- New `lib/domain/record_transaction/record_transaction_draft.dart`
- New `test/domain/record_transaction/record_transaction_draft_test.dart`
- `test/ui/features/record_transaction/view_models/record_transaction_view_model_test.dart` (thin toward orchestration; draft rules move to domain tests)
- No Drift schema change; no ADR 0002 conflict (draft is a leaf domain module, no repository constructor deps)
