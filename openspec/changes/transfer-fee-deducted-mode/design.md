## Context

`transfer-entry-and-cost-tracking`'s `TransferViewModel.submit()` posts a
transfer for the entered `amountMinor`, then - if a fee was entered -
separately debits the source account for `feeAmountMinor` as an independent
expense transaction. That models an *additive* fee: total debited =
amount + fee, and the full `amountMinor` is what gets converted/delivered.

Some real transfers work the other way: the amount the user enters is the
total leaving their account, and the fee is carved out of it before
conversion/delivery (Wise and similar remittance services). This change adds
a second mode for that case without touching how the fee entry itself posts.

## Goals / Non-Goals

**Goals:**
- Let the user express "the fee comes out of the amount I'm sending" for a
  single transfer, via a simple toggle - default off (unchanged behavior).
- Keep the fee's own posting mechanics identical in both modes: still a
  same-currency money-out expense entry against the source account,
  independent of and reversible independently from the transfer entry.
- Work for both same-currency and known-rate cross-currency transfers.

**Non-Goals:**
- No change to the provisional (unknown-rate) cross-currency path beyond
  using the post-fee amount as the provisional amount - settlement logic is
  untouched.
- No per-category default for fee mode (Option 3 from the fee-mode
  discussion) - this is a per-transfer toggle, not a category setting.
- No change to how the fee amount/category are validated (still: positive
  amount, active expense category, both required together).

## Decisions

**Decision 1: Toggle changes what `amountMinor` is passed to `recordTransfer`, not a new repository API.**
When the toggle is on and a valid fee is present, `submit()` computes
`transferAmountMinor = amountMinor - feeAmountMinor` and passes that to
`recordTransfer` instead of the raw entered amount. The fee's own
`recordTransaction` call is unchanged (still posts `feeAmountMinor`). Total
debited from the source account is therefore
`(amountMinor - feeAmountMinor) + feeAmountMinor == amountMinor` - exactly
what the user entered, matching "I sent 100 CHF total."
When the toggle is off (default), behavior is byte-for-byte what
`transfer-entry-and-cost-tracking` already implemented.

**Decision 2: The destination amount field's meaning is unchanged.**
For a known-rate cross-currency transfer, `destinationAmountMinor` is still
whatever the user enters directly (e.g. "Wise says I'll receive ₹9114") -
it is not derived from the toggle. Only the source-side `amountMinor`
changes with the toggle. This keeps the field's contract simple: it is
always "the known amount that arrives," independent of how the source side
is composed.

**Decision 3: Validate `amount > fee` up front when deducting.**
If the toggle is on and `feeAmountMinor >= amountMinor`, reject the submit
before any repository call with a specific message ("the fee must be less
than the amount for a deducted-fee transfer"), rather than letting
`recordTransfer` reject a zero/negative amount with a more generic message.

## Risks / Trade-offs

- A user could flip the toggle after already entering a fee amount that
  happens to be valid in both modes (e.g. a very small fee) - the two modes
  produce different ledger amounts, so switching it silently changes what
  will be posted next submit. Mitigated by the amount/fee fields and toggle
  all living in the same visible form; no separate confirmation step is
  warranted for a pre-submit toggle.
