## Context

`TransferViewModel.impliedRate` (`lib/ui/features/transfer/view_models/transfer_view_model.dart`)
computes a display-only "Your rate" for cross-currency transfers:

```dart
double? get impliedRate {
  final amount = _amountMinor;
  final destination = _destinationAmountMinor;
  if (!isCrossCurrency || amount == null || amount <= 0 || destination == null) {
    return null;
  }
  return destination / amount;
}
```

Separately, `submit()` already handles the "fee deducted from amount" case
correctly when posting to the ledger:

```dart
var transferAmountMinor = amountMinor;
if (hasFee && _feeDeductedFromAmount) {
  transferAmountMinor = amountMinor - feeAmountMinor;
  ...
}
```

i.e. when `feeDeductedFromAmount` is on, only `amountMinor - feeAmountMinor`
is actually converted to the destination currency — the fee itself is a
same-currency expense against the source account, not part of the
conversion. `impliedRate` doesn't apply this same adjustment, so it divides
by the full `amountMinor` instead of the amount that was actually
converted, understating the real rate whenever a deducted fee is present.

## Goals / Non-Goals

**Goals:**
- Make `impliedRate` consistent with what `submit()` actually posts: divide
  by the amount that is actually converted.

**Non-Goals:**
- Changing anything about `submit()`'s ledger-posting behavior — it was
  already correct. This is a display-only fix.
- Changing the "fee charged on top" (not deducted) path — that case already
  divides by the full amount correctly, since the full amount is what's
  converted.

## Decisions

- Compute the converted amount the same way `submit()` does:
  `_feeDeductedFromAmount && feeAmountMinor != null ? amount - feeAmountMinor : amount`,
  and divide the destination amount by that instead of by the raw
  `amountMinor`.
- Guard the case where the converted amount is zero or negative (fee ≥
  amount, which can happen transiently while the user is still typing,
  before `submit()`'s own validation would reject it) by returning `null`
  rather than a nonsensical or infinite rate.

## Risks / Trade-offs

- [A user mid-edit could see the rate flicker to blank while entering a fee
  close to the full amount.] → Mitigation: this matches the existing
  behavior for other incomplete/invalid states (e.g. amount not yet
  entered) — `impliedRate` is already `null` in those cases, so this is
  consistent, not a new class of behavior.
