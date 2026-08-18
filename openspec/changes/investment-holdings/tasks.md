## 1. Schema and seeds

- [ ] 1.1 Additive migration: `holds_investments` on `accounts`; internal inventory companion id (or type) never user-selectable; `instruments` (name, kind [fixed enum: stock, ETF, mutual fund, bond, other — informational only], ticker, isin, archived_at) — global, no account_id, same sharing model as categories; `investment_lots` (account_id, instrument_id, quantity_scaled, unit_cost_minor, source [`cash_purchase` | `non_cash_acquisition`], acquired_at, locked_until, journal_entry_id) — replaces a single aggregate holdings row so lock-until, source, and reversal are representable; `instrument_quotes` cache (instrument_id, price_minor, currency, fetched_at).
- [ ] 1.2 Seed `group_investments` on first identity and on upgrade. Creating an investment account also creates its hidden inventory leg in the same group/currency.
- [ ] 1.3 Update every existing "four system groups" assumption to five: `account_groups_table.dart` comments, sortOrder allocation (currently 0-3, add Investments at 4), `app_database_migration_test.dart`'s "seeds the four system groups..." test name/assertions, and specifically `ledger_repository_test.dart`'s `createAccountGroup` test — its comment "The four seeded system groups occupy sortOrder 0-3" and `expect(created.sortOrder, equals(4))` for a newly created user group must become `equals(5)` once Investments occupies slot 4. Also sync `openspec/specs/multi-account-ledger/spec.md`'s "four system account groups" wording (two spots) to five when this change archives.

## 2. Cash in/out and account flag

- [ ] 2.1 `createFinancialAccount(holdsInvestments)` only for assets; flag immutable; liability + flag rejected.
- [ ] 2.2 Transfers involving an investment account move **cash only**; reject cash-out greater than cash; cross-currency funding uses the existing `foreign-currency-settlement` path unchanged.
- [ ] 2.3 `watchFinancialAccounts` / home / pickers never list the internal inventory companion.
- [ ] 2.3b Investment account cash remains selectable in the ordinary record-transaction (income/expense) screen, unmodified — the escape hatch for custody/maintenance/wire fees not covered by Buy/Sell/Dividend/brokerage. Never touches inventory.
- [ ] 2.4 Archiving an investment account with a positive cash balance is allowed, using the existing archived-account closeout-transfer mechanism unchanged; no investment-specific archiving rule for cash. Unlike an ordinary archived account, the closeout-eligibility check must re-trigger whenever cash goes positive again (not just once), since a later sell or dividend (task 3.2, 3.3) can do that on an archived account.

## 3. Buy, sell, dividend, brokerage

- [ ] 3.1 `recordBuy`: qty, unit price (always positive), transaction date, funding source, optional lock-until date. Cash-funded: posts one entry (Dr inventory, Cr cash for qty×price only — no brokerage in this entry); insufficient cash for qty×price rejected. Non-cash acquisition: no brokerage field, active income category required, posts inventory + income, no cash leg. Creates one `investment_lots` row per buy.
- [ ] 3.2 `recordSell`: qty ≤ *sellable* quantity (held minus still-locked, as of the sell's transaction date, not just total held); cash += qty×price (full proceeds, no brokerage in this entry); inventory reduced at date-ordered average cost (task 3.4); gain/loss income or expense. Reject with a clear "locked until <date>" message when the requested quantity exceeds what's unlocked.
- [ ] 3.2b Brokerage (cash-funded buy or sell, when positive): post as a **second, independent** money-out expense entry against cash and the chosen expense category, after the buy/sell entry — mirror the existing transfer-fee repository method exactly, including "buy/sell already posted, fee post fails → leave buy/sell posted, don't roll back, surface partial success" and independent reversibility.
- [ ] 3.3 `recordDividend`: instrument (any of the account's instruments, including one currently at zero quantity — ex-dividend/payment-date lag), positive amount, transaction date, active income category. Posts cash + income only; no lot, no quantity change.
- [ ] 3.4 Compute an instrument's *current* quantity, average cost, and sellable quantity by replaying its non-reversed lots and sells in **transaction-date order** (mirror `RegisterViewModel`'s running-balance approach) — not from a maintained running total. A backdated buy recomputes *current* quantity/cost only; it must NOT alter the dollar amount of any already-posted sell's realized gain/loss journal entry (immutability).
- [ ] 3.5 Buy, sell, and dividend entries support the existing reversal mechanism (a new swapped-side entry, original stays visible — not deletion). Reversing a sell or dividend is always accepted (a dividend reversal never touches quantity/cost). Reversing a buy is rejected if replaying the instrument's history with that buy's contribution removed would make quantity negative at any point (a later sell already depends on it) — surface which sell(s) block it.
- [ ] 3.6 Zero brokerage posts no fee entry. Archived investment account rejects buy and non-cash acquisition, but still permits sell and dividend.

## 4. Quotes, portfolio value, and unrealized gain/loss

- [ ] 4.1 Predefined free quote provider enum; request ticker/ISIN only; cache prices; no journal write.
- [ ] 4.2 Refresh while Home or holdings is in the foreground; Settings can disable all quote HTTP. This toggle is separate from and clearly distinguishable from `reference-exchange-rate-lookup`'s existing "Fetch reference exchange rates" toggle in the same Settings screen (different concept, different label, e.g. "Fetch market prices for investments").
- [ ] 4.3 Portfolio value = cash + Σ(qty × last price or cost); missing/stale/disabled labeled; skip live price if quote currency ≠ group currency (use cost).
- [ ] 4.4 Holdings view shows, per instrument, unrealized gain/loss = (qty × last price/cache/cost) − lot cost.
- [ ] 4.5 Home group total and net position use portfolio value for investment accounts, labeled as a market estimate; holdings header also shows book (cash + cost).

## 5. Tests

- [ ] 5.1 Cash in/out; cash-out exceeding cash rejected; inventory unchanged by transfers; cross-currency funding follows `foreign-currency-settlement`.
- [ ] 5.2 Cash-funded buy with and without brokerage; insufficient cash; inventory and cash math.
- [ ] 5.3 Non-cash acquisition: posts income not cash; rejected without an income category; combined with a cash-funded buy reproduces a "buy 3, get 1 free" scenario correctly. The same instrument held in two different investment accounts tracks independent quantity/cost per account (lots scoped by account_id), while renaming/archiving the instrument affects both accounts (global, matching categories).
- [ ] 5.4 Lock-until: a locked lot's quantity is excluded from sellable quantity; becomes sellable once the transaction date reaches lock-until; rejection message states the date. End-to-end: a non-cash acquisition WITH a lock-until date (the full "buy 3, get 1 free with a vesting period" case) correctly posts income, adds 4 total units, and excludes only the locked unit from sellable quantity.
- [ ] 5.5 Dividend: increases cash, posts income, never changes inventory.
- [ ] 5.6 Sell at gain and loss with brokerage; over-sell (and over-sell-of-unlocked-only) rejected; date-ordered average cost.
- [ ] 5.7 Backdated buy recomputes an instrument's *current* quantity/cost correctly; previously recorded sells' already-posted realized gain/loss amounts are verified UNCHANGED (regression test for the immutability rule, not just a happy-path check).
- [ ] 5.8 Reversing a buy with no dependent later sell removes its contribution and reverses cash/income; reversing a buy whose units a later sell already relied on is rejected; reversing a sell always succeeds and restores units/cost and cash/gain-loss; reversing a dividend always succeeds and never touches quantity/cost; brokerage fee entries reverse independently of their buy/sell.
- [ ] 5.9 Archiving an investment account succeeds with a positive cash balance; its closeout transfer works exactly as for any other account; sell and dividend continue to work after archiving; buy and non-cash acquisition are rejected after archiving; a closeout transfer, a later sell, then a second closeout transfer all succeed in sequence (repeatable eligibility, not lifetime-once); a dividend on a no-longer-held instrument still posts.
- [ ] 5.10 Quote HTTP includes no quantity/cost/account fields; failed quote does not block buy/sell/dividend; disable stops requests.
- [ ] 5.11 Unrealized gain/loss matches (market contribution − book cost) per instrument.
- [ ] 5.12 Home net position uses portfolio value; book still visible on the account view.

## 6. UI and docs

- [ ] 6.1 Create-account: investment toggle (asset only). Holdings view: cash, inventory (with unrealized gain/loss), Buy (funding-source choice, optional lock-until date), Sell, Dividend, brokerage field (`MoneyAmountField` / `EntityPickerField` / `confirmDestructiveAction` as elsewhere).
- [ ] 6.2 No order ticket, no broker connect. Instrument management: create/rename/archive. Rename/archive use a menu or edit icon on the inventory row, NOT a tap on the instrument name itself — `investment-research-enablement` claims that exact tap target for opening research, so the two must not collide.
- [ ] 6.3 User guide: cash in/out, inventory, buy/sell (including a non-cash acquisition example and lock-until), dividends, quotes as estimates, not dealing, and that archiving allows a positive-cash closeout transfer (repeatable) while sell and dividend stay available for winding down inventory and recording a late payout.
- [ ] 6.4 `dart analyze` and full test suite.
