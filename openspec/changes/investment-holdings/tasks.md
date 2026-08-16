## 1. Schema and seeds

- [ ] 1.1 Additive migration: `holds_investments` on `accounts`; internal inventory companion id (or type) never user-selectable; `instruments` (name, kind, ticker, isin, archived_at); `holdings` (account_id, instrument_id, quantity_scaled, cost_minor); `instrument_quotes` cache (instrument_id, price_minor, currency, fetched_at).
- [ ] 1.2 Seed `group_investments` on first identity and on upgrade. Creating an investment account also creates its hidden inventory leg in the same group/currency.

## 2. Cash in/out and account flag

- [ ] 2.1 `createFinancialAccount(holdsInvestments)` only for assets; flag immutable; liability + flag rejected.
- [ ] 2.2 Transfers involving an investment account move **cash only**; reject cash-out greater than cash.
- [ ] 2.3 `watchFinancialAccounts` / home / pickers never list the internal inventory companion.

## 3. Buy, sell, brokerage

- [ ] 3.1 `recordBuy`: qty, unit price, brokerage ≥ 0, expense category required iff brokerage > 0; insufficient cash rejected; posts inventory + cash + optional expense in one signed entry (or cash+inventory plus independent fee entry following transfer-fee failure rules).
- [ ] 3.2 `recordSell`: qty ≤ held; cash += qty×price − brokerage; inventory reduced at average cost; gain/loss income or expense; brokerage expense when > 0.
- [ ] 3.3 Zero brokerage posts no fee entry. Archived investment account rejects buy/sell.

## 4. Quotes and portfolio value

- [ ] 4.1 Predefined free quote provider enum; request ticker/ISIN only; cache prices; no journal write.
- [ ] 4.2 Refresh while Home or holdings is in the foreground; Settings can disable all quote HTTP.
- [ ] 4.3 Portfolio value = cash + Σ(qty × last price or cost); missing/stale/disabled labeled; skip live price if quote currency ≠ group currency (use cost).
- [ ] 4.4 Home group total and net position use portfolio value for investment accounts, labeled as a market estimate; holdings header also shows book (cash + cost).

## 5. Tests

- [ ] 5.1 Cash in/out; cash-out exceeding cash rejected; inventory unchanged by transfers.
- [ ] 5.2 Buy with and without brokerage; insufficient cash; inventory and cash math.
- [ ] 5.3 Sell at gain and loss with brokerage; over-sell rejected; average cost.
- [ ] 5.4 Quote HTTP includes no quantity/cost/account fields; failed quote does not block buy/sell; disable stops requests.
- [ ] 5.5 Home net position uses portfolio value; book still visible on the account view.

## 6. UI and docs

- [ ] 6.1 Create-account: investment toggle (asset only). Holdings view: cash, inventory, Buy, Sell, brokerage field (`MoneyAmountField` / `EntityPickerField` / `confirmDestructiveAction` as elsewhere).
- [ ] 6.2 No order ticket, no broker connect. Instrument management: create/rename/archive.
- [ ] 6.3 User guide: cash in/out, inventory, buy/sell, brokerage, quotes as estimates, not dealing.
- [ ] 6.4 `dart analyze` and full test suite.
