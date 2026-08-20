## Why

`multi-account-ledger` already requires a single full-balance closeout
transfer from an archived financial account with a positive display
balance, and it already requires the register's add-transaction control
to be disabled while that account is archived. Neither behavior shipped.
`recordTransfer` still rejects an archived source, there is no closeout
method or UI, and the register plus FAB stays enabled. A user who
archives an account that still holds money can see the balance and cannot
move it. An earlier change (`archived-account-restrictions`) specified
this, was archived with every task unchecked, and left the main spec
promising a door the app does not have.

## What Changes

- Implement the already-specified closeout: exactly one outbound transfer
  of the archived account's full current display balance to a different,
  active financial account. After it posts, the source balance is zero
  and the account is no longer eligible.
- Compute the closeout amount in the repository from the current display
  balance. Do not trust a caller-supplied amount.
- Surface closeout only from the archived account's register, not from
  the general Transfer screen (that screen keeps excluding archived
  accounts on both sides).
- Require a known destination-currency amount for a cross-currency
  closeout so the source leg is a single terminal entry — no pending
  transfer left on an account the user is retiring.
- Disable the register add-transaction FAB when the selected account is
  archived (import and transfer FABs already do this).
- Document the shipped closeout and archived-account restrictions in the
  user guide.

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `multi-account-ledger`: add the register-scoped closeout affordance and
  the known-rate-only rule for a cross-currency closeout. The posting
  rules for closeout and the disabled add-transaction control are already
  in the main spec; this change implements them and locks the UI/entry
  contract that the unfinished archive left only in design.md.

## Impact

- `lib/data/repositories/ledger_repository.dart`: extract `_postTransfer`,
  add `_requireCloseoutEligibleFinancialAccount` and
  `recordArchivedAccountCloseoutTransfer`.
- `lib/ui/features/register/view_models/register_view_model.dart` and
  `lib/ui/features/register/views/register_view.dart`: disable the plus
  FAB; offer closeout when the selected archived account has a positive
  balance.
- `test/data/repositories/ledger_repository_test.dart` and register
  view/view-model tests.
- `docs/user-guide.md`: archived-account restrictions and closeout.
