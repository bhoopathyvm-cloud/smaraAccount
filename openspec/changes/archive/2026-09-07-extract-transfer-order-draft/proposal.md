## Why

`TransferViewModel` (~400 lines) owns cross-currency visibility, fee-deducted transfer amount math, and implied-rate calculation inside a ChangeNotifier. Those rules need ledger/account mocks to unit-test, while the real partial-failure story (transfer saved, fee failed) correctly stays in submit orchestration. Architecture review cycle 2 continues the draft deepen pattern from `RecordTransactionDraft` / `BuyOrderDraft`.

## What Changes

- Add Flutter-free `lib/domain/transfer/transfer_order_draft.dart` with mutable `TransferOrderDraft` holding from/to accounts, amounts, fee fields, currency snapshots, plus computed `isCrossCurrency`, `impliedRate`, `transferAmountMinor`, and readiness/validation helpers.
- `TransferViewModel` owns one draft, forwards setters, keeps stream subscriptions, reference-rate fetch I/O, and two-step submit (transfer then optional fee).
- Preserve existing validation error codes and posting behavior.

## Capabilities

### New Capabilities
- `transfer-order-draft`: Flutter-free draft for transfer form fields, fee-deducted amount math, implied rate, and submit readiness.

### Modified Capabilities
- (none — transfer / multi-currency / fee product behavior unchanged)

## Impact

- `lib/ui/features/transfer/view_models/transfer_view_model.dart`
- New `lib/domain/transfer/transfer_order_draft.dart`
- New `test/domain/transfer/transfer_order_draft_test.dart`
- `test/ui/features/transfer/view_models/transfer_view_model_test.dart`
- No Drift schema change; no ADR 0002 conflict
