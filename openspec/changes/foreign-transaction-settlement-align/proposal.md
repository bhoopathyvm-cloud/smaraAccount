## Why

`foreign-currency-settlement` still says a pending foreign-currency
transaction settles with the same-currency shortfall comparison used when
a transfer returns to its source. Apply-time code and tests do the
opposite, on purpose: the provisional clearing leg is in the
transaction's native currency, the settled amount is in the account's
currency, and comparing those two numbers as one shortfall is wrong. The
repository documents this as a correction that never got a spec delta.
Golden Rule #1 is currently broken in both directions — the main spec
describes behavior the tests would treat as a regression.

## What Changes

- Update the settlement requirement so a pending item of kind
  foreign-currency transaction always settles to the transaction's own
  financial account and follows the same no-shortfall path as settling a
  transfer to its destination: no shortfall comparison, no fee/loss
  entry, reject a supplied fee category, reject a zero settled amount.
- Leave transfer settlement unchanged (destination = no shortfall;
  source = same-currency shortfall/fee).
- Keep the existing tests that already lock the corrected behavior;
  add any missing scenario coverage so the spec and tests name the same
  rule.
- Do not change how provisional foreign-currency transactions are posted.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `foreign-currency-settlement`: "Settle a Pending Transfer or
  Transaction" no longer requires same-currency shortfall comparison for
  `foreignTransaction`. That kind uses the destination-delivery
  (no-shortfall) path against the transaction's own account.

## Impact

- `openspec/specs/foreign-currency-settlement/spec.md` (after archive).
- Comments on `LedgerRepository.settlePendingTransfer` and
  `SettlePendingTransferViewModel` should cite the updated spec, not
  "corrected during apply."
- Existing repository tests around foreign-transaction settlement stay;
  add a named case for zero-amount rejection if one is missing.
- No schema or posting-path change.
