## Context

See proposal.md for why. The previous draft treated holdings as an off-ledger schedule and marks as user-typed. That does not match the intended wrapper: **cash**, **inventory**, **buy/sell at a price plus brokerage**, and **live portfolio value** from a free quote feed.

Constraints that still hold: signed journal entries are the book; no broker API; no order routing; network follows the FX pattern (predefined providers, identifiers only); Views do not call Repositories.

## Goals / Non-Goals

**Goals:**
- One user-facing investment account = cash + inventory.
- Transfers in/out move only cash.
- Buy/sell record quantity, unit price, brokerage; update cash and inventory; post through `_appendSignedEntry`.
- Background quotes → portfolio value = cash + Σ(qty × price).
- Home uses that portfolio value, labeled as a market estimate.

**Non-Goals:**
- Placing orders at a broker or exchange.
- Corporate actions, options, shorts, FX-denominated lots inside a single wrapper (holding currency = group currency).
- AI research (`investment-research-enablement`).
- Capitalizing brokerage into cost basis (brokerage is an expense, like a transfer fee).

## Decisions

### 1. One wrapper, two internal asset legs
Creating an investment account creates:
- the user-visible **cash** asset (flagged `holdsInvestments`)
- a paired internal **inventory** asset (cost of holdings), never in pickers or as a separate home row (same hide rule as equity/clearing)

Buy: Dr inventory (qty × price), Dr expense (brokerage if > 0), Cr cash (qty × price + brokerage).  
Sell: Dr cash (qty × price − brokerage), Dr expense (brokerage if > 0), Cr inventory (average cost × qty), Cr income / Dr extra expense for the remaining gain/loss so the entry balances.

The user never picks those internal inventory accounts. Transfers to "the investment account" always hit cash. Reject a cash-out that exceeds cash (inventory is not spendable cash).

**Alternative considered:** inventory only in a table, buy just credits cash without an inventory posting. Rejected — the trial balance would not show inventory as an asset.

### 2. Buy/sell are records, not orders
The UI is Buy and Sell (price, qty, brokerage). There is no ticket sent anywhere. This is still not "direct share dealing": SMARA does not execute. The user types what they paid or received.

### 3. Brokerage is an expense, not cost
Matches transfer fees: positive brokerage requires an active expense category; zero brokerage posts nothing extra. Cost basis of inventory is qty × price only, so average cost stays comparable to the trade price.

### 4. Average cost on sell
v1 does not do FIFO lots. Realized gain/loss = proceeds (qty × price) − average cost removed. Brokerage is a separate expense, not netted into the gain line.

### 5. Quotes: predefined free providers, identifiers only
Fixed enum (concrete providers chosen at apply from a currently free, no-key HTTP API — e.g. a Stooq-style daily quote — same "adding a provider is a code change" rule as FX). Query string: ticker and/or ISIN. Multiply by local quantity on device. Cache `(instrument_id, price_minor, currency, fetched_at)`. Refresh when Home or holdings is visible (periodic while those routes are showing), not a forever OS background daemon.

Disable flag in Settings (SharedPreferences). Default **enabled** so portfolio value works without a scavenger hunt; user can turn it off (then cost/cache only).

When quote currency ≠ group currency: do not silently FX-convert (architecture: no blended FX in net worth). Skip that instrument's live price and use cost, labeled. A later change can reuse the FX lookup if we ever want a converted mark.

### 6. Home headline is portfolio value
`A + I − L` where I is cash + inventory at last quote/cache/cost. Label "est." / market estimate. Book (cash + inventory at cost) stays on the holdings header so the signed book is still inspectable. Quarantined cash postings still drop out of the cash leg.

## Risks / Trade-offs

- [Risk] Free quote APIs change or rate-limit. → Mitigation: cache, stale label, disable setting, predefined list we can swap in a code change.
- [Risk] Portfolio value on home is not the signed book. → Mitigation: explicit market-estimate label; book still on the account view; quotes never post.
- [Risk] User expects the app to buy on the market. → Mitigation: copy on Buy/Sell: "Record a trade that already happened"; no broker buttons.
- [Risk] Fifth system group plus internal inventory accounts clutter pickers. → Mitigation: hide internal inventory type the same way as clearing.

## Migration Plan

Additive schema version + seed Investments group + no journal backfill. Existing asset accounts remain non-investment. Rollback: revert; unused tables/columns sit idle.

## Open Questions

None that block apply. FIFO lots and quote FX conversion are later changes if wanted.
