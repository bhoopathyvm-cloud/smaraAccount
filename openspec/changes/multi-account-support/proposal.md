## Why

The app today is a single-account ledger. Real personal finances almost always span several purpose-specific accounts — salary checking, savings, private loans, credit cards, mortgages, pension funds — and users need one place to see each balance and how those balances roll up into liquid assets vs. debt. Industry practice (personal balance sheets, Firefly III asset/liability accounts, Actual Budget on-/off-budget tracking, cash-and-cash-equivalents grouping) consistently treats this as: many financial accounts, typed as assets or liabilities, grouped for a net-worth-style overview, with transfers between them. That overview is the natural home screen once multi-account exists.

## What Changes

- Allow the user to create, rename, archive, and list **multiple financial accounts** (not only the single seeded asset account).
- Classify each financial account as an **asset** (money you hold) or a **liability** (money you owe), covering salary/checking, savings, private loans, credit accounts, mortgages, and pension-fund tracking balances — anything where money mainly comes in and goes out.
- Assign every financial account to an **account group** used for home-screen rollups. v1 seeds four system groups (renameable; not user-creatable): Cash & cash equivalents, Credit & short-term debt, Loans & mortgages, Pension & retirement.
- Provide a **home overview** that lists every financial account (active and archived, with archived clearly indicated) with its current balance, and shows **group totals** (assets and liabilities by group) plus an overall net position (total assets − total liabilities).
- Support **transfers** between financial accounts (e.g. salary → savings, or checking → credit card payment) as first-class, balanced journal entries that do not use Income/Expense categories. Existing reversal remains available for transfers.
- When recording income/expense transactions, the user **selects which financial account** the money moves into or out of.
- Per-account register (running balance for the selected account) remains available and correctly renders income/expense, transfer, and opening-balance rows; the existing income-vs-expense summary continues to work across (or filtered by) accounts and excludes transfers/opening balances.
- Prevent archiving the last active financial account. System account groups are renameable but not deletable or archivable (empty groups are omitted on Home instead).
- **BREAKING** (domain contract): the “exactly one financial account” rule from `core-ledger-single-account` is lifted. Existing installs migrate the current single asset account into the new model under Cash & cash equivalents.

## Capabilities

### New Capabilities
- `multi-account-ledger`: multiple asset/liability financial accounts (CRUD/archive), account selection on income/expense posting, transfers between financial accounts, per-account balances and registers.
- `accounts-home-overview`: home dashboard listing all accounts with current balances; account-group rollups for assets/liabilities; overall net position.

### Modified Capabilities
- `core-ledger-single-account`: remove the single-financial-account constraint; transaction recording and register requirements expand to operate in a multi-account context (account selection, per-account register). Starter Income/Expense categories, immutability, and reversal model remain.

## Impact

- Extends the existing Drift `accounts` model (today: `asset` / `income` / `expense`) with `liability` financial accounts, an internal `equity` opening-balance offset account, account-group membership, and display ordering — without abandoning double-entry postings.
- Bumps Drift `schemaVersion` to 3 (after `ledger-integrity-signing`'s 2). All new balance/aggregate queries must exclude quarantined and migration-superseded postings the same way `watchSummary` already does.
- Updates `LedgerRepository` record/register/summary paths to require or accept a financial-account id; adds transfer and opening-balance posting through `_appendSignedEntry`; removes the single-account `_financialAccount()` helper in the same change (no compatibility window).
- Rewrites the register ViewModel: today’s “category posting + the other posting” assumption breaks for transfers and opening balances.
- New UI: home overview (default landing), account management, account picker on record-transaction, transfer flow; register becomes account-scoped.
- Existing single-account data migrates in place (one default account + four system groups + system equity account).
- **Explicitly out of scope (separate future change):** investment / brokerage accounts with holdings, market valuation, performance, or asset-allocation views. Pension here means tracking the fund’s cash-style balance as money in/out only.
- Also out of scope: bank sync/import, multi-currency FX (follow-on `multi-currency-support`), budgets/envelopes, interest auto-accrual, multi-device sync, per-account “include in net worth” toggles, and user-created custom account groups (v1 = four system groups, renameable).
