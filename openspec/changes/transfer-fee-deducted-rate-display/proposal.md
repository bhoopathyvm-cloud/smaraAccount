## Why

On the Transfer screen, when a transfer fee is marked "deducted from the
amount", the displayed "Your rate" divides the destination amount by the
*full* source amount entered — not by the amount actually converted
(source amount minus the fee). This understates the real conversion rate
the user is getting and is misleading, even though it's purely a
display-time calculation (the amounts actually posted to the ledger were
always correct).

## What Changes

- Fix the implied-rate calculation so that, when the fee is deducted from
  the amount, it divides the destination amount by `amount - fee` (the
  amount actually converted) instead of the full entered amount.
- When the fee is not deducted (charged on top), the calculation is
  unchanged: destination amount divided by the full source amount.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities
- `reference-exchange-rate-lookup`: the "implied rate" scenario now
  specifies that when a deducted transfer fee is present, the implied rate
  must be computed against the amount actually converted (source amount
  minus the deducted fee), not the full entered source amount.

## Impact

- `lib/ui/features/transfer/view_models/transfer_view_model.dart` (`impliedRate` getter)
- No API, schema, or ledger-posting changes — display-only.
