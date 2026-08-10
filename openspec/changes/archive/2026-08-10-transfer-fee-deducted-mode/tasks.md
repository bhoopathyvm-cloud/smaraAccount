## 1. ViewModel

- [x] 1.1 Add `feeDeductedFromAmount` bool state (default `false`) + setter to `TransferViewModel`
- [x] 1.2 In `submit()`, when a valid fee is present and `feeDeductedFromAmount` is true, validate `feeAmountMinor < amountMinor` before any repository call; reject with a specific message if not
- [x] 1.3 When deducting, compute `transferAmountMinor = amountMinor - feeAmountMinor` and pass that to `recordTransfer` as its `amountMinor` instead of the raw entered amount - `destinationAmountMinor` (when supplied) passes through unchanged
- [x] 1.4 Confirm the fee's own `recordTransaction` call is unaffected (still posts the entered `feeAmountMinor`) in both modes

## 2. View

- [x] 2.1 Add a checkbox/switch in the Fee section: "Fee is deducted from the amount above" (off by default), wired to the new ViewModel state
- [x] 2.2 Add brief helper copy clarifying the two modes (fee on top vs. fee deducted)

## 3. Tests

- [x] 3.1 ViewModel/unit test: deducted mode posts `recordTransfer` with `amount - fee` and `recordTransaction` with the entered fee, for a same-currency transfer
- [x] 3.2 ViewModel/unit test: deducted mode with a known destination amount passes that destination amount through unchanged while still reducing the source-side amount
- [x] 3.3 ViewModel/unit test: a fee greater than or equal to the amount in deducted mode is rejected before any repository call
- [x] 3.4 ViewModel/unit test: additive mode (toggle off) is unchanged from existing behavior - regression check against the existing fee tests
- [x] 3.5 Widget test: the checkbox is present in the Fee section and toggling it updates the ViewModel
- [x] 3.6 Run `dart analyze` and the full test suite; fix any regressions
