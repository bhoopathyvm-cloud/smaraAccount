## 1. Schema and seeds

- [ ] 1.1 Additive migration: `holds_investments` boolean on `accounts` (default false); `instruments` table (id, name, kind enum, ticker, isin, archived_at, created_at); `holdings` table (id, investment_account_id, instrument_id, quantity_scaled, cost_minor, mark_price_minor nullable, updated_at).
- [ ] 1.2 Seed system group `group_investments` ("Investments", asset, system) on `confirmFirstIdentity` and on upgrade for databases that lack it. Do not rewrite journal rows.

## 2. Domain and repository

- [ ] 2.1 Domain models: `Instrument`, `Holding`, instrument kind enum. No Drift row types across the repository boundary.
- [ ] 2.2 `createFinancialAccount` accepts `holdsInvestments` only when type is asset; flag is immutable; liability + flag is rejected.
- [ ] 2.3 Instrument create / rename / archive (no delete). Archived instruments excluded from acquire pickers.
- [ ] 2.4 `acquireHolding`: active investment account, active instrument, positive qty and cost, distinct active funding account; post via existing transfer path; update holding in the same DB transaction as the signed entry.
- [ ] 2.5 `disposeHolding`: qty ≤ held, average cost removed, destination distinct and active; post balanced entry (destination proceeds, investment cost removed, income/expense difference); reduce or remove the holding.
- [ ] 2.6 `setHoldingMark` / clear mark: write `mark_price_minor` only; never call `_appendSignedEntry`.

## 3. Repository tests

- [ ] 3.1 Create investment vs ordinary asset; flag immutable; liability cannot hold investments.
- [ ] 3.2 Acquire posts a transfer and increases quantity and cost; non-positive qty/cost rejected; archived investment account rejected.
- [ ] 3.3 Dispose at a gain and at a loss posts the three-leg (or two-leg equal) entry and reduces the holding; over-dispose rejected.
- [ ] 3.4 Setting or clearing a mark posts no journal entry and leaves display balance unchanged.
- [ ] 3.5 Home/net position still uses ledger balance when marks differ from cost.

## 4. UI

- [ ] 4.1 Account-create dialog: investment-account toggle for asset type only; use shared widgets.
- [ ] 4.2 Holdings view on an investment account: list holdings, acquire, dispose, mark; no order ticket or quote button.
- [ ] 4.3 Instrument management (create/rename/archive) using `EntityPickerField` and `confirmDestructiveAction` where destructive.
- [ ] 4.4 Home: optional muted secondary marked-value label; do not add it into group total or net position.

## 5. Widget / view-model tests and docs

- [ ] 5.1 Widget tests: acquire/dispose/mark on the holdings view; ordinary asset has no holdings affordance.
- [ ] 5.2 Document investment accounts, acquire/dispose, and that marks are estimates in `docs/user-guide.md`.
- [ ] 5.3 Run `dart analyze` and the full test suite.
