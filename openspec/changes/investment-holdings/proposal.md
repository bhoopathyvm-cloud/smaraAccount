## Why

An investment account is not a lump-sum asset and not a dealing desk. It
is a wrapper with three parts the user already understands: **cash** that
moves to and from their other accounts, an **inventory** of instruments
they hold, and **buy/sell** at a real price plus **brokerage**. Inventory
is an asset whose market value moves; without a current price the
portfolio figure is fiction. The ledger today has no place for that
shape — only a Pension & retirement *group* and ordinary cash accounts.

## What Changes

- A user-facing **investment account** has two books that stay in one
  wrapper: a **cash** balance, and an **inventory** of instruments
  (quantity + cost). Cash in and out is an ordinary transfer with the
  user's other financial accounts.
- **Buy** and **sell** are first-class actions, not broker orders. Buy:
  quantity, price paid, brokerage. Sell: quantity, price received,
  brokerage. Brokerage is a separate expense, the same idea as a transfer
  fee. The app does not place, route, or execute orders.
- Inventory quantity is the holding. **Portfolio value** = cash + Σ(quantity
  × last fetched market price). That value is what the user sees as "what
  this account is worth now."
- **Background quotes** from a fixed set of free market-data services,
  sending only ticker/ISIN (not quantities, costs, or account names).
  Failed or stale quotes are labeled; they never rewrite the signed
  ledger. When no quote exists yet, cost is shown with a not-a-market-price
  indication.
- Seed an **Investments** system asset group. Out of scope: broker login,
  order tickets, corporate actions, and AI research (separate change:
  `investment-research-enablement` — tap a name, open a browser, no API).

## Capabilities

### New Capabilities

- `investment-holdings`: investment-account wrapper (cash + inventory),
  buy/sell with brokerage, instruments, and background market prices for
  portfolio value.

### Modified Capabilities

- `multi-account-ledger`: seed Investments; create an investment-flagged
  asset account as a cash+inventory wrapper; flag immutable.
- `accounts-home-overview`: an investment account's headline figure on
  home is portfolio value (cash + inventory at last quote), labeled as a
  market estimate; the signed book (cash + inventory at cost) remains
  available and is what quarantine/supersession still apply to.

## Impact

- Additive schema: investment flag, paired internal inventory account (or
  equivalent), instruments, holdings, quote cache.
- Buy/sell repository methods on the signed write path; brokerage as a
  separate expense entry against the wrapper's cash.
- Quote service (predefined free providers) + foreground/background
  refresh while home or holdings is visible.
- Holdings UI: cash, inventory list, buy, sell, brokerage; tap-to-research
  is the sibling change.
- Tests for cash in/out, buy/sell math, brokerage, quote cache, and home
  portfolio-value display.
