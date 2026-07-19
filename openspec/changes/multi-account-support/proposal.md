## Why

The app today is a single-account ledger. Real personal finances almost always span several purpose-specific accounts — salary checking, savings, private loans, credit cards, mortgages, pension funds — and users need one place to see each balance and how those balances roll up into liquid assets vs. debt. Industry practice (personal balance sheets, Firefly III asset/liability accounts, Actual Budget on-/off-budget tracking, cash-and-cash-equivalents grouping) consistently treats this as: many financial accounts, typed as assets or liabilities, grouped for a net-worth-style overview, with transfers between them. That overview is the natural home screen once multi-account exists.

## What Changes

- Allow the user to create, rename, archive, and list **multiple financial accounts** (not only the single seeded asset account).
- Classify each financial account as an **asset** (money you hold) or a **liability** (money you owe), covering salary/checking, savings, private loans, credit accounts, mortgages, and pension-fund tracking balances — anything where money mainly comes in and goes out.
- Assign every financial account to an **account group** used for home-screen rollups. Starter groups cover the common personal-finance buckets drawn from balance-sheet practice:
  - **Cash & cash equivalents** — readily accessible money (checking, savings, cash wallet)
  - **Credit & short-term debt** — revolving credit / private credit balances
  - **Loans & mortgages** — longer-term borrowing (private loans, mortgage principal)
  - **Pension & retirement** — pension-fund / retirement balances tracked as money in/out (not investment portfolio valuation)
- Provide a **home overview** that lists every active financial account with its current balance, and shows **group totals** (assets and liabilities by group) plus an overall net position (total assets − total liabilities).
- Support **transfers** between financial accounts (e.g. salary → savings) as first-class, balanced journal entries that do not use Income/Expense categories.
- When recording income/expense transactions, the user **selects which financial account** the money moves into or out of.
- Per-account register (running balance for the selected account) remains available; the existing income-vs-expense summary continues to work across (or filtered by) accounts.
- **BREAKING** (domain contract): the “exactly one financial account” rule from `core-ledger-single-account` is lifted. Existing installs migrate the current single asset account into the new model under Cash & cash equivalents.

## Capabilities

### New Capabilities
- `multi-account-ledger`: multiple asset/liability financial accounts (CRUD/archive), account selection on income/expense posting, transfers between financial accounts, per-account balances and registers.
- `accounts-home-overview`: home dashboard listing all accounts with current balances; account-group rollups for assets/liabilities; overall net position.

### Modified Capabilities
- `core-ledger-single-account`: remove the single-financial-account constraint; transaction recording and register requirements expand to operate in a multi-account context (account selection, per-account register). Starter Income/Expense categories, immutability, and reversal model remain.

## Impact

- Extends the existing Drift `accounts` model (today: `asset` / `income` / `expense`) with liability financial accounts, account-group membership, and display ordering — without abandoning double-entry postings.
- Updates `LedgerRepository` record/register/summary paths to require or accept a financial-account id; adds transfer posting.
- New UI: home overview (default landing), account management, account picker on record-transaction, transfer flow; register becomes account-scoped.
- Existing single-account data migrates in place (one default account + default groups).
- **Explicitly out of scope (separate future change):** investment / brokerage accounts with holdings, market valuation, performance, or asset-allocation views. Pension here means tracking the fund’s cash-style balance as money in/out only.
- Also out of scope: bank sync/import, multi-currency FX, budgets/envelopes, interest auto-accrual, and multi-device sync.
