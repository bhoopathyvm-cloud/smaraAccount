## 1. Fix the implied-rate calculation

- [x] 1.1 Update `impliedRate` in `lib/ui/features/transfer/view_models/transfer_view_model.dart` to divide by `amountMinor - feeAmountMinor` when `feeDeductedFromAmount` is true, instead of the full `amountMinor`
- [x] 1.2 Guard against a zero/negative converted amount (fee ≥ amount) by returning `null`

## 2. Verify

- [x] 2.1 `flutter analyze` passes with no new warnings
- [x] 2.2 `flutter test test/ui/features/transfer/view_models/transfer_view_model_test.dart` passes

## 3. Regression tests

- [x] 3.1 Add a test: no fee present, implied rate is destination/amount
- [x] 3.2 Add a test: fee present but not deducted, implied rate is unaffected (still destination/amount)
- [x] 3.3 Add a test: fee deducted, implied rate is destination/(amount - fee), and differs from the naive destination/amount
- [x] 3.4 Add a test: deducted fee ≥ amount, implied rate is null
- [x] 3.5 Verified the tests actually catch the regression: reverted the fix locally, confirmed the deducted-fee tests fail with the old (wrong) value, then restored the fix
