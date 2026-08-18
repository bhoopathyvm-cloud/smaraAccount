## Context

See proposal.md for why. The previous draft treated holdings as an off-ledger schedule and marks as user-typed. That does not match the intended wrapper: **cash**, **inventory**, **buy/sell at a price plus brokerage**, and **live portfolio value** from a free quote feed.

An end-user review of that draft (before this revision) found that a common, non-exotic scenario had no home in the model at all: an employer share-purchase match ("buy 3, get 1 free") with a lock-in period. The instinct to just relax Buy's price to allow zero turned out to be the wrong fix — a lone or zero-valued posting doesn't fit this app's own invariant that every entry is a real, non-degenerate double-entry pair. The actual fix is that a "free" share still has a real cost basis (its fair value at acquisition) and a real funding source, just not cash: it's compensation/gift income, the same shape the app already uses for a category-side posting everywhere else. The remaining root cause was that holdings were a single aggregate `(account, instrument) → quantity, cost` row, which couldn't carry a lock-in date, a funding source, or survive a later correction without corrupting the average. This revision fixes that (lots, not an aggregate row) and closes the gaps that fell out of the same review: dividends, reversal of buy/sell/dividend, date-ordered computation for backdated entries (without ever rewriting an already-posted realized gain/loss), explicit trade-currency handling, and archiving with a nonzero balance.

Constraints that still hold: signed journal entries are the book; no broker API; no order routing; network follows the FX pattern (predefined providers, identifiers only); Views do not call Repositories.

## Goals / Non-Goals

**Goals:**
- One user-facing investment account = cash + inventory.
- Transfers in/out move only cash, in the account's own currency, using the existing (same-currency or cross-currency) transfer rules unchanged.
- Buy/sell record quantity, a positive unit price, brokerage; update cash and inventory; post through `_appendSignedEntry`.
- A Buy may be a non-cash acquisition (employer match, grant, gift) funded by an income posting instead of cash, still at a real positive price (fair value), optionally carrying a lock-until date that Sell respects.
- A dividend records income against cash with no inventory change.
- Current quantity and average cost per instrument are computed by replaying that instrument's buy/sell history in transaction-date order, not maintained as a running total — so a backdated entry resolves current state correctly by construction, without ever rewriting an already-posted sell's realized gain/loss (that stays immutable, like any posted entry).
- Buy, sell, and dividend entries can be reversed like any other journal entry.
- Background quotes → portfolio value = cash + Σ(qty × price); holdings view also shows unrealized gain/loss (portfolio value contribution − book cost).
- Home uses portfolio value, labeled as a market estimate.
- An investment account archives like any other account, using the existing positive-balance-then-closeout-transfer mechanism for cash, repeatable each time cash goes positive again; Sell and Dividend stay available afterward so inventory can be wound down at the user's own pace and a late dividend can still be recorded.

**Non-Goals:**
- Placing orders at a broker or exchange.
- Full ESPP mechanics: payroll deduction accumulation, offering periods, look-back pricing. This change covers only the *acquisition* (a lot at a positive price the user supplies) and an optional lock-until date — not how that lot's price or timing was determined.
- Single-step dividend reinvestment (DRIP) — a reinvested dividend is a dividend entry followed by an ordinary Buy.
- Specific-lot/FIFO selection on sell — sell still reduces quantity/cost by the date-ordered average across all *unlocked* lots, not a user-chosen lot. (Lots exist to carry lock-until and source, not to offer tax-lot selection.)
- Corporate actions (splits, spin-offs, mergers), options, shorts, FX-denominated lots inside a single wrapper (holding currency = group currency).
- Instrument search/autocomplete against a quote provider — tickers/ISINs remain freehand text.
- Historical portfolio performance over time — portfolio value is a point-in-time figure, not a tracked series.
- AI research (`investment-research-enablement`).
- Capitalizing brokerage into cost basis (brokerage is an expense, like a transfer fee).

## Decisions

### 1. One wrapper, two internal asset legs
Creating an investment account creates:
- the user-visible **cash** asset (flagged `holdsInvestments`)
- a paired internal **inventory** asset (cost of holdings), never in pickers or as a separate home row (same hide rule as equity/clearing)

Buy, cash-funded: Dr inventory (qty × price), Cr cash (qty × price) — one entry. Brokerage, if positive, is a **second, independent entry**: Dr expense (brokerage), Cr cash (brokerage) — same shape as Decision 6 and the existing transfer-fee pattern, posted after the buy and reversible independently of it.
Buy, non-cash acquisition (Decision 2): Dr inventory (qty × price), Cr income (qty × price) — treated as compensation/gift income received in kind, the same shape as any other income posting. No cash leg, no brokerage (there is nothing to pay a broker for). Price stays a positive, required field for both funding sources — a "free" employer-matched share still needs a real cost basis (its fair value at acquisition, e.g. the same market price as the shares bought alongside it), not a fabricated zero. Every entry keeps the app's existing two-posting-minimum shape; nothing here introduces a lone or zero-valued posting.
Sell: Dr cash (qty × price), Cr inventory (average cost × qty), Cr income / Dr extra expense for the remaining gain/loss so the entry balances — one entry. Brokerage, if positive, is again a second, independent entry exactly as for Buy.
Dividend: Dr cash (amount), Cr income (amount). No inventory posting.

The user never picks those internal inventory accounts. Transfers to "the investment account" always hit cash. Reject a cash-out that exceeds cash (inventory is not spendable cash).

**Alternative considered:** inventory only in a table, buy just credits cash without an inventory posting. Rejected — the trial balance would not show inventory as an asset.

### 2. Lots, not a single aggregate holdings row
`holdings(account_id, instrument_id, quantity, cost)` as one mutable row per instrument cannot represent a locked-until date, a funding source, or a clean reversal, because merging every acquisition into a single running average erases which units were which. Each Buy (cash-funded or non-cash) creates a **lot**: `(account_id, instrument_id, quantity, unit_cost_minor, source, acquired_at, locked_until, journal_entry_id)`. `source` is `cash_purchase` or `non_cash_acquisition` (employer match / grant / gift — a single value covers all of them; this change does not need to distinguish *why* a lot was non-cash, only that its value came from income rather than a cash outflow). Inventory display sums quantity and cost across an instrument's lots — the user still sees one row per instrument, not a lot list, matching the original wrapper shape.

### 3. Current quantity/cost computed by date-ordered replay; past realized gain/loss stays immutable
Current quantity and average cost for an instrument are computed on read by replaying that instrument's lots and sells in **transaction-date order**, same-date ties broken by `recordedAt` — the same principle `RegisterViewModel` already uses for running balance. This resolves backdating cleanly for anything *forward-looking*: recording a forgotten early Buy after later Sells were already entered brings current quantity/cost in line with the full history, correctly informing the next buy or sell.

What it deliberately does **not** do is rewrite a Sell's already-posted realized gain/loss. That dollar amount was posted into an immutable journal entry at the time the Sell was recorded, using whatever average cost existed then — a later backdated Buy changing the "true" average cost doesn't and can't retroactively change a number already signed into the ledger (Golden Rule #7). An initial pass at this decision claimed backdating recomputes "any dependent realized gain/loss," which quietly violated that rule. If the user wants a historical Sell's gain/loss corrected, they reverse it and re-record it — an explicit, visible correction, not a silent rewrite.

**Reversal is not exclusion.** This app's reversal mechanism (`core-ledger-single-account`) doesn't delete or hide the original entry — it posts a *new*, swapped-side entry, dated when the reversal happens, and both remain in history forever. For cash this is harmless: addition is commutative, so `+X` then `-X` nets to the same balance regardless of when the reversal lands relative to other entries. For inventory it is **not** automatically harmless, because quantity can't go negative: reversing an early Buy after a later Sell has already drawn down part of what that Buy contributed can, once replayed, ask the instrument to hold fewer units than were already sold. **Reversing a Buy is therefore rejected if it would make the replayed quantity negative at any point** (spec.md's "Buy, Sell, and Dividend Entries Can Be Reversed, Unless the Reversal Would Imply Negative Quantity") — the user reverses or adjusts the dependent Sell first. Reversing a Sell has no equivalent hazard (it only ever adds units back) and is always accepted; reversing a Dividend is always accepted too, since a dividend never touches quantity or cost in the first place.

**Trade-off:** replay cost grows with an instrument's trade count. Acceptable at this project's scale (same reasoning already accepted for register balance); revisit only if it becomes a measured problem.

### 4. Locked-until is this app's own record, not broker enforcement
A lot's `locked_until` blocks a Sell in *this app* from reducing quantity below what's still locked, as of the transaction date. It does not and cannot know whether the user's actual broker would enforce the same restriction — it's the user's own record of a restriction they told the app about. Buy/Sell copy makes this an informational guard, not a claim that SMARA enforces real-world trading restrictions.

### 5. Buy/sell are records, not orders
The UI is Buy and Sell (price, qty, brokerage). There is no ticket sent anywhere. This is still not "direct share dealing": SMARA does not execute. The user types what they paid or received.

### 6. Brokerage is an expense, not cost
Matches transfer fees: positive brokerage requires an active expense category; zero brokerage posts nothing extra. Cost basis of inventory is qty × price only, so average cost stays comparable to the trade price.

### 7. Average cost on sell; realized gain/loss uses ordinary categories
v1 does not do FIFO/specific lots for selling. Realized gain/loss = proceeds (qty × price) − average cost removed, posted through the same income/expense category picker used elsewhere, so it appears in the ordinary Summary view alongside other income/expense — accepted, not hidden: a dedicated investment-only report is a separate, later change if wanted. Brokerage is a separate expense, not netted into the gain line.

### 8. Dividends are a distinct action, tied to an instrument but not to currently holding it
A dividend is not a Buy (no quantity/price/lot) and not a transfer (no source account). It posts income against the investment account's cash directly: amount, transaction date, income category. It can target any of the account's instruments, not only ones with a currently positive quantity — the ex-dividend and payment dates are often days apart, so a user can legitimately sell a position entirely and still receive (and need to record) a dividend for it afterward. Reinvesting is a manual dividend + Buy, not a single combined action (Non-Goals).

### 9. Trade price is always in the account's own currency
Buy/sell/dividend amounts are entered and posted in the investment account's group currency; the app performs no currency conversion on a trade itself (distinct from the quote-currency question in Decision 10). A user holding a foreign-priced instrument converts the price themselves before entering it, same as they would when hand-entering any other foreign-currency transaction the app doesn't natively convert.

### 10. Quotes: predefined free providers, identifiers only
Fixed enum (concrete providers chosen at apply from a currently free, no-key HTTP API — e.g. a Stooq-style daily quote — same "adding a provider is a code change" rule as FX). Query string: ticker and/or ISIN. Multiply by local quantity on device. Cache `(instrument_id, price_minor, currency, fetched_at)`. Refresh when Home or holdings is visible (periodic while those routes are showing), not a forever OS background daemon.

Disable flag in Settings (SharedPreferences). Default **enabled** so portfolio value works without a scavenger hunt; user can turn it off (then cost/cache only). This is a distinct toggle from `reference-exchange-rate-lookup`'s existing "Fetch reference exchange rates" setting (currency-pair FX rates for cross-currency transfers) — a different concept (instrument market price vs. currency exchange rate), a different provider list, and a separate on/off state. Its label must read unambiguously differently from the existing FX toggle when both sit in the same Settings screen (e.g. "Fetch market prices for investments"), so a user can't mistake one for the other.

When quote currency ≠ group currency: do not silently FX-convert (architecture: no blended FX in net worth). Skip that instrument's live price and use cost, labeled. A later change can reuse the FX lookup if we ever want a converted mark.

### 11. Home headline is portfolio value; holdings view adds unrealized gain/loss
`A + I − L` where I is cash + inventory at last quote/cache/cost. Label "est." / market estimate. Book (cash + inventory at cost) stays on the holdings header so the signed book is still inspectable. The holdings view additionally shows, per instrument, unrealized gain/loss = (quantity × last price/cache/cost) − lot cost — plain subtraction of numbers already computed, no new data source. Quarantined cash postings still drop out of the cash leg.

### 12. Archiving composes with the existing closeout mechanism; Sell and Dividend are the release valves; closeout repeats
`multi-account-ledger`'s main spec already lets a user archive a financial account with a positive balance, then run a full-balance closeout transfer to zero it out — an initial draft of this decision wrongly assumed archiving needed to be blocked until balance was already zero, inventing a divergent rule where a composing one already existed. (`archived-account-closeout`, in flight separately, only *implements* that already-specified mechanism; it doesn't define new archiving semantics to track.)

For an investment account's **cash**, no special rule is needed: it archives and closes out exactly like any other account's balance. For **inventory**, the existing closeout transfer doesn't fit — it moves cash between financial accounts, and inventory isn't cash. Rather than invent an inventory-specific closeout action (or force a full liquidation before archiving is even allowed), **Sell and Dividend remain available on an archived investment account** — Sell is the natural existing action that turns inventory into cash, usable at the user's own pace across as many sells as they want; Dividend keeps working because it resolves an already-earned economic event (the ex-dividend/payment-date lag means a dividend can legitimately arrive after the account is already archived), not a new position. Buy and non-cash acquisition stay blocked once archived — both would open or grow a position, unlike Sell/Dividend which only wind one down. This is deliberately asymmetric with cash's single-shot closeout: cash has no market-timing risk, so one atomic transfer is fine; forcing an immediate full-position sale to satisfy an archiving precondition would expose the user to a bad forced price, so gradual sell-down is the more honest design for something whose value moves.

Because Sell and Dividend can both add cash back to an archived account *after* it was already closed out once, **the closeout transfer must be re-offered every time cash goes positive again**, not treated as a lifetime-once affordance — unlike an ordinary archived account, whose balance can never become positive again post-closeout because nothing can post to it at all.

## Risks / Trade-offs

- [Risk] Free quote APIs change or rate-limit. → Mitigation: cache, stale label, disable setting, predefined list we can swap in a code change.
- [Risk] Portfolio value on home is not the signed book. → Mitigation: explicit market-estimate label; book still on the account view; quotes never post.
- [Risk] User expects the app to buy on the market. → Mitigation: copy on Buy/Sell: "Record a trade that already happened"; no broker buttons.
- [Risk] Fifth system group plus internal inventory accounts clutter pickers. → Mitigation: hide internal inventory type the same way as clearing.
- [Risk] User believes a `locked_until` date is enforced by their real broker. → Mitigation: explicit "this is your own note, not a real restriction" copy (Decision 4).
- [Risk] Replaying lot history on every read grows with trade count. → Mitigation: same accepted trade-off as register balance replay; add caching only if it's ever measured as a real cost.
- [Risk] Realized gain/loss mixed into ordinary Summary could read as noisy to a user who wants "just my spending." → Mitigation: accepted for v1 (Decision 7); a separate investment report is future scope, not blocking this change.

## Migration Plan

Additive schema version + seed Investments group + no journal backfill. Existing asset accounts remain non-investment. Rollback: revert; unused tables/columns sit idle.

## Open Questions

None that block apply. Specific-lot/FIFO tax-basis selection, single-step DRIP, instrument search, and quote FX conversion are later changes if wanted.
