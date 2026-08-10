## Why

`transfer-entry-and-cost-tracking` added an optional transfer fee, but it only
models one real-world pattern: the fee charged **on top of** the transferred
amount (e.g. a domestic bank wire that moves the full amount and separately
debits a wire fee). It cannot model the equally common pattern where the fee
is **deducted from** the amount you send - e.g. sending 100 CHF via Wise,
where Wise takes a 1.62 CHF fee and only converts/delivers the remaining
98.38 CHF. Today, entering a fee always adds it on top, so a Wise-style
transfer would incorrectly debit the source account for amount + fee instead
of just amount, and would forward the pre-fee amount instead of the
post-fee amount to the destination/FX conversion.

## What Changes

- Add a per-transfer toggle, off by default: "Fee is deducted from the
  amount above." Off preserves today's behavior (fee posts as an additional
  debit; the transfer moves the entered amount in full). On changes what the
  entered "Amount" represents: it becomes the total debited from the source
  account, and the transfer itself (and any cross-currency conversion) moves
  `amount - fee` instead of `amount`.
- Validate that `amount - fee` stays positive when the toggle is on; reject
  the submit otherwise (a fee that would zero out or exceed the transfer
  itself is not a valid transfer).
- No change to how the fee entry itself posts (still a same-currency
  money-out expense transaction against the source account, independent of
  and reversible independently from the transfer entry) - only which amount
  `recordTransfer` is called with changes.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `multi-account-ledger`: the "Transfer Between Financial Accounts" /
  transfer-fee requirement gains a deducted-fee mode alongside the existing
  additive-fee mode.

## Impact

- `lib/ui/features/transfer/view_models/transfer_view_model.dart`: new
  `feeDeductedFromAmount` bool state + setter; `submit()` computes the
  transfer's own amount (and, for a known-rate cross-currency transfer, the
  destination amount) from `amount - fee` when the toggle is on, and
  validates the result stays positive.
- `lib/ui/features/transfer/views/transfer_view.dart`: a checkbox in the Fee
  section, shown alongside the existing fee fields.
- Test coverage for both modes, including the cross-currency case (the
  amount actually converted must be the post-fee amount).
