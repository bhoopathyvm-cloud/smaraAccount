## Why

The ledger today models cash, debt, and a Pension & retirement *group*,
but not the thing people actually hold inside a brokerage, ISA, or
similar wrapper: named instruments with a quantity and a cost. Users who
want to record "I hold these investments" currently have to fake it as a
lump-sum asset balance, which hides what they own and cannot support
later research. This change adds holdings as a schedule on an investment
account. It is not share dealing: no orders, no broker, no live market
execution.

## What Changes

- Let an asset financial account be marked, at creation, as an
  **investment account**. That flag is immutable (same rule as asset vs
  liability). Only investment accounts may hold positions.
- Seed a fifth system asset group, **Investments**, alongside the existing
  four. Users may still put an investment account in Pension & retirement
  or a custom asset group.
- Let the user define **instruments** (name, optional ticker, optional
  ISIN, kind) and **acquire / dispose** holdings against an investment
  account. Acquire and dispose post ordinary signed journal entries
  (capital in/out, and realized gain or loss on dispose). Quantity and
  cost live on a holdings schedule tied to those entries.
- Let the user type an optional **display mark** (last known price) per
  holding. Marks do not post, do not change the signed ledger, and do not
  enter home net position. Unrealized gain/loss is display-only.
- Dividends, fees, contributions, and withdrawals stay ordinary
  income/expense or transfers against the investment account.
- Out of scope: order tickets, broker sync, live quotes, corporate
  actions, fractional-share dealing venues, and any AI/news research
  (separate change: `investment-research-briefs`).

## Capabilities

### New Capabilities

- `investment-holdings`: instruments, lots, acquire/dispose, user-entered
  marks, and the investment-account flag — holdings as a register, not a
  dealing desk.

### Modified Capabilities

- `multi-account-ledger`: seed an Investments system group; allow an
  asset account to be created as an investment account; keep type and
  investment-flag immutable after creation.
- `accounts-home-overview`: an investment account still contributes its
  *ledger* display balance to group totals and net position; any marked
  value is a secondary estimate and SHALL NOT be added into net position.

## Impact

- New Drift tables for instruments, holdings/lots, and optional marks
  (additive schema version).
- `LedgerRepository` acquire/dispose methods that reuse the existing
  signed write path; no new ad hoc journal writer.
- Account-creation UI: investment-account flag; new holdings screen
  reachable from an investment account's register or the Accounts tab.
- Home overview: optional secondary marked-value label only; net position
  math unchanged.
- Tests for acquire/dispose posting, immutability of the flag, marks not
  posting, and net-position isolation.
