## Why

`TransferOrderDraft` owns fee-deducted amount math, but transfer→fee posting composition still lives in `TransferViewModel`. Settlement already composes shortfall fees inside `LedgerPosting`; outbound transfer fees do not. Architecture review cycle 8 — named Non-Goal leftover from `extract-transfer-order-draft`.

## What Changes

- Add `LedgerRepository.recordTransferWithOptionalFee` that posts the transfer then the optional fee expense, preserving today's partial-failure behavior (`validationTransferSavedFeeFailed` when fee fails after transfer succeeds).
- Slim `TransferViewModel.submit` to validate via draft then call that one method.
- Update ViewModel unit tests to assert the composed call.

## Capabilities

### New Capabilities
- `transfer-fee-posting`: one repository module method owning transfer ± optional fee composition.

### Modified Capabilities
- (none — product partial-failure semantics unchanged)

## Impact

- `lib/data/repositories/ledger_repository.dart`
- `lib/ui/features/transfer/view_models/transfer_view_model.dart`
- `test/ui/features/transfer/view_models/transfer_view_model_test.dart`
- Regenerated mockito mocks
