## Why

Credit card is two accounts + transfer; invisible to households.

## What Changes

- Mark a liability account as a credit card at creation (a flag,
  matching the `holdsInvestments`-style pattern already used for
  investment accounts — a label on an ordinary account, not a new
  account type or new posting mechanics).
- Recording spent offers "Paid from card" vs "Paid from bank" — both are
  the existing record-transaction flow with the financial account
  pre-filtered/pre-selected by which the user picked; no new posting
  path.
- "Pay card" is offered as a labeled action, but is an ordinary transfer
  (bank → card) using the existing transfer mechanism unchanged — paying
  down a card is moving money, not a new kind of entry.

## Capabilities

### New Capabilities

- `credit-card-household-flow`: the card flag, capture-flow labeling,
  and the "Pay card" labeled transfer entry point.

### Modified Capabilities

- `multi-account-ledger`: liability accounts gain an optional
  `isCreditCard` flag, immutable after creation like the investment flag.
- `user-guide`

**Not modified**, checked against the current implementation before
scoping this: `accounts-home-overview`. Every account, asset or
liability, already shows its own display balance per row on Home
(`balance.displayBalanceMinor`) — a credit card's amount owed is already
visible exactly like any other liability's, with no new behavior needed.
"Prominently" is a styling choice for the flagged row, not a new
requirement.

## Impact

- `multi-account-ledger` schema: `isCreditCard` boolean on liability
  accounts, set at creation, immutable.
- UI: credit-card toggle at liability-account creation; "Paid from card"
  / "Paid from bank" framing on the record screen when the user has a
  flagged card; a "Pay card" action that pre-fills an ordinary transfer
  from bank to card.
- Tests and user guide.
