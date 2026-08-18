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
  user's other financial accounts. Cash also remains selectable for an
  ordinary income/expense transaction, unmodified — the escape hatch for
  a custody, maintenance, or wire fee that isn't Buy/Sell/Dividend/
  brokerage, without inventing a bespoke action for each one.
- **Buy** and **sell** are first-class actions, not broker orders. Buy:
  quantity, a positive price paid, brokerage. Sell: quantity, price
  received, brokerage. Brokerage is a separate expense, the same idea as
  a transfer fee. The app does not place, route, or execute orders.
  Buy/sell price is always in the investment account's own group
  currency; the app does not convert a foreign-priced trade.
- **Non-cash acquisitions** (employer share match, an outright grant, a
  gift) are recorded the same way as a Buy — same positive price, since
  a "free" share still has a real cost basis (its fair value at
  acquisition) — but funded by an income posting instead of a cash
  outflow. A Buy MAY carry an optional **lock-until date**; the system
  rejects a Sell that would reduce quantity below what is still locked
  as of the transaction date. This covers "buy 3, employer matches 1"
  and typical vesting/holding-period restrictions without modeling
  payroll deduction or ESPP offering-period mechanics.
- **Dividends**: a cash dividend is recorded as income against the
  investment account's cash, with no inventory change. Reinvesting a
  dividend (DRIP) is done as a dividend followed by an ordinary Buy — no
  single-step auto-reinvestment in this change.
- Holdings (quantity and average cost per instrument) are **computed by
  replaying that instrument's buy/sell history in transaction date
  order**, same-day ties broken by recording order, the same principle
  the register already uses for running balance — so a backdated entry
  recomputes correctly instead of corrupting the running average — a
  historical sell's already-posted realized gain/loss is never silently
  rewritten by a later backdated entry, matching this app's immutable-
  posted-entries rule. Buy, sell, and dividend entries **can be reversed**
  like any other journal entry (a new, swapped-side entry — the original
  is never deleted), except that reversing a Buy is rejected if a later
  Sell already relied on its units, since inventory (unlike cash) can't
  go negative.
- Inventory quantity is the holding. **Portfolio value** = cash + Σ(quantity
  × last fetched market price). The holdings view also shows **unrealized
  gain/loss** (portfolio value contribution − book cost) per instrument.
  That value is what the user sees as "what this account is worth now."
- **Background quotes** from a fixed set of free market-data services,
  sending only ticker/ISIN (not quantities, costs, or account names).
  Failed or stale quotes are labeled; they never rewrite the signed
  ledger. When no quote exists yet, cost is shown with a not-a-market-price
  indication.
- **Archiving** an investment account needs no special rule for cash — it
  already can be archived with a positive balance and closed out via the
  full-balance transfer `multi-account-ledger` already specifies for any
  account, offered again each time cash goes positive, not just once.
  Inventory has no such transfer (a closeout transfer moves cash, not
  shares), so **Sell and Dividend stay available on an archived
  investment account** — Sell lets holdings wind down at the user's own
  pace instead of forcing one immediate full liquidation just to archive,
  and Dividend keeps working because a dividend can legitimately arrive
  after the account is archived (the ex-dividend/payment-date lag). Buy
  and non-cash acquisition stop working once archived, since both open or
  grow a position rather than wind one down.
- Seed an **Investments** system asset group. Out of scope: broker login,
  order tickets, corporate actions (splits, spin-offs, mergers),
  single-step DRIP, specific-lot/FIFO tax-basis selection on sell
  (average cost only), instrument search/autocomplete against a
  provider (identifiers are freehand text), historical portfolio
  performance over time (point-in-time value only), and AI research
  (separate change: `investment-research-enablement` — tap a name, open
  a browser, no API).

## Capabilities

### New Capabilities

- `investment-holdings`: investment-account wrapper (cash + inventory),
  buy/sell with brokerage (including non-cash, income-funded acquisitions
  with an optional lock-until date, and dividends), date-ordered holdings
  computation with reversal support, instruments, and background market
  prices for portfolio value and unrealized gain/loss.

### Modified Capabilities

- `multi-account-ledger`: seed Investments; create an investment-flagged
  asset account as a cash+inventory wrapper; flag immutable; its cash
  closes out via the existing archived-account closeout transfer,
  repeatable rather than lifetime-once; Sell and Dividend are carved out
  as still permitted on an archived investment account.
- `accounts-home-overview`: an investment account's headline figure on
  home is portfolio value (cash + inventory at last quote), labeled as a
  market estimate; the signed book (cash + inventory at cost) remains
  available and is what quarantine/supersession still apply to.
- `foreign-currency-settlement`: cash transfers into or out of an
  investment account in a different currency follow the existing
  cross-currency transfer/settlement rules unchanged — no special-casing
  for the investment wrapper.
- `user-guide`: document investment accounts (cash, buy including
  non-cash acquisitions and lock-until, sell, dividends, quotes as a
  labeled estimate, unrealized gain/loss, and archiving/closeout).

## Impact

- Additive schema: investment flag, paired internal inventory account (or
  equivalent), instruments, per-acquisition lots (quantity, cost, source,
  optional lock-until date — not a single aggregate row per instrument),
  quote cache.
- Buy/sell/dividend repository methods on the signed write path;
  brokerage as a separate expense entry against the wrapper's cash;
  holdings (quantity, average cost) computed by date-ordered replay of
  non-reversed lot history, not a maintained running total.
- Quote service (predefined free providers) + foreground/background
  refresh while home or holdings is visible.
- Holdings UI: cash, inventory list (with unrealized gain/loss), buy,
  sell, dividend, brokerage, lock-until indicator; tap-to-research is the
  sibling change.
- Tests for cash in/out, buy/sell math (including non-cash/income-funded
  acquisitions and lock-until), dividends, reversal/backdating
  recomputation (including the realized-gain/loss-immutability
  regression), brokerage, quote cache, sell-and-dividend-work-after-
  archive with repeatable closeout, and home portfolio-value display.
