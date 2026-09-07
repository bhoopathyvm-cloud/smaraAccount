## 1. Draft module

- [x] 1.1 Inventory fee/rate/cross-currency rules in `TransferViewModel`
- [x] 1.2 Add `lib/domain/transfer/transfer_order_draft.dart`
- [x] 1.3 Unit tests for `transferAmountMinor`, `impliedRate` (fee on/off), cross-currency, readiness helpers

## 2. Wire TransferViewModel

- [x] 2.1 Own a `TransferOrderDraft`; sync currencies from catalog on account/currency changes
- [x] 2.2 Forward getters/setters; delete inlined fee/rate math
- [x] 2.3 Keep reference-rate fetch and two-step submit on the ViewModel

## 3. Verify

- [x] 3.1 `dart analyze` clean; draft unit tests green
- [x] 3.2 Existing `transfer_view_model_test.dart` green
- [ ] 3.3 Full acceptance suite on macOS
