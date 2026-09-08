## 1. Draft module

- [x] 1.1 Add `lib/domain/transfer/closeout_transfer_draft.dart` (destination account/currency, date, description, amount; `isCrossCurrency`, `destinationAmountForSubmit`, `setDestinationAccount`)
- [x] 1.2 Domain unit tests (`test/domain/transfer/closeout_transfer_draft_test.dart`): cross vs same currency, amount-only-when-cross, clear-on-account-change, unknown currency

## 2. Wire the closeout dialog

- [x] 2.1 `RegisterView` closeout dialog owns one draft, deletes the scattered locals
- [x] 2.2 Remove dead `RegisterViewModel.isCloseoutCrossCurrency`; keep `closeoutSelectedAccount` orchestration and `currencyFor` lookup

## 3. Verify

- [x] 3.1 `dart analyze` clean; new domain tests green
- [x] 3.2 Existing register widget + ViewModel tests green
- [x] 3.3 Linux acceptance `group_archive` group green
