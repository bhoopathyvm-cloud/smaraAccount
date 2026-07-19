    ## Context

`core-ledger-single-account` established a double-entry ledger with one `accounts` table holding both the single financial account (`type = asset`) and Income/Expense categories. The archived design explicitly anticipated this change: more `asset` rows in the same table, plus transfers. `ledger-integrity-signing` (in progress / adjacent) signs every journal write; any new write path (transfer, opening balance) MUST go through the same chained signing path in `LedgerRepository`.

Research inputs informing this design (not copied as product requirements):
- **Personal balance sheet practice** — assets vs liabilities; liquid “cash & cash equivalents”; retirement/pension; long-term debt (mortgage) vs short-term credit.
- **Firefly III** — asset vs liability financial accounts; transfers as first-class moves between them; income/expense as categories/counterparties.
- **Actual Budget** — list all accounts with balances; track debt/retirement for net worth even when not used for day-to-day cash flow.
- **Purpose-driven multi-account banking** — salary, bills/spending, savings as separate accounts the user already has at banks; the app mirrors that structure rather than forcing a single pot.

## Goals / Non-Goals

**Goals:**
- Multiple financial accounts (asset and liability), each belonging to an account group.
- Home overview: every account + current balance; group totals; overall net position.
- Income/expense posting against a chosen financial account; transfers between financial accounts.
- In-place migration of the existing single asset account into the default Cash & cash equivalents group.
- Preserve immutability, reversal, starter categories, and integrity-signing write path.

**Non-Goals:**
- Investment / brokerage accounts, holdings, market prices, performance (separate future change).
- Bank sync, CSV import, multi-currency / FX, interest auto-calculation, budgets/envelopes.
- Multi-device sync, shared household accounts, permissions.
- Auto-creating dozens of bank-specific subtypes beyond what groups + asset/liability cover.

## Decisions

### 1. Extend the existing `accounts` table; add `account_groups`

Keep one chart-of-accounts table. Financial accounts are rows with `type` in `{asset, liability}`. Categories remain `{income, expense}`.

```
account_groups
  id            TEXT PRIMARY KEY
  name          TEXT NOT NULL
  kind          TEXT NOT NULL  -- 'asset_group' | 'liability_group'
  sort_order    INTEGER NOT NULL
  is_system     INTEGER NOT NULL  -- starter groups cannot be deleted
  archived_at   INTEGER NULL
  created_at    INTEGER NOT NULL

accounts  (extended)
  ...existing columns...
  type          TEXT NOT NULL  -- ADD 'liability' to enum
  group_id      TEXT NULL REFERENCES account_groups(id)
                -- required for asset/liability; NULL for income/expense
  sort_order    INTEGER NOT NULL DEFAULT 0
  include_in_net_worth INTEGER NOT NULL DEFAULT 1
```

**Why groups as a first-class table (not a free-text tag)?** The home screen’s primary job is rollups by liquidity/debt purpose. A fixed set of system groups (seeded, renameable, reorderable later if needed) matches balance-sheet practice and the user’s examples (cash equivalents, mortgages, pension). Users can still create additional custom groups.

**Starter system groups (seeded on migrate / first confirm):**

| Group | Kind | Typical accounts |
|-------|------|------------------|
| Cash & cash equivalents | asset | Salary/checking, savings, cash wallet |
| Pension & retirement | asset | Pension fund balance (cash-style tracking) |
| Credit & short-term debt | liability | Private credit, credit cards |
| Loans & mortgages | liability | Private loan, mortgage principal |

**Alternative considered:** subtype enum on each account (`checking`, `savings`, `mortgage`, …) with hardcoded UI buckets. Rejected — inflexible for “private loan” vs “mortgage”, and fights custom naming. Groups give the rollup; account name gives the identity.

**Alternative considered:** Firefly-style liability subtypes (loan/debt/mortgage) as separate account types. Deferred — `liability` + group is enough for v1; subtype metadata can be added later without a rewrite.

### 2. Signed amounts with normal-balance awareness for liabilities

Keep signed `amount_minor` on postings (sum to zero per entry). Define display/balance conventions:

- **Asset account balance** = sum of postings to that account (money in increases).
- **Liability account balance** = sum of postings to that account, presented as amount owed. Recording “money out” to pay down a liability decreases the owed balance; drawing/credit increases it.
- Repository APIs expose a **display balance** and never force the UI to interpret raw signs for liabilities.

For income/expense against a liability (e.g. credit-card purchase as expense): debit expense / credit liability (increase debt) using the same direction+category UX; the Repository maps signs by account type.

**Alternative considered:** switch now to explicit debit/credit columns. Still deferred — encapsulation in `LedgerRepository` remains; liability mapping is the first payoff of that earlier decision, not a reason to rewrite storage yet.

### 3. Transfers are a dedicated repository method

`recordTransfer({fromAccountId, toAccountId, amountMinor, transactionDate, description?})`:
- Both accounts MUST be active financial accounts (`asset` or `liability`).
- Amount MUST be positive.
- Creates one journal entry with exactly two postings (from −amount effect, to +amount effect under the signed convention), **no Income/Expense category**.
- Goes through the same integrity hash/sign/chain path as `recordTransaction`.

**Why not reuse income/expense with a hidden “Transfer” category?** That pollutes income/expense summaries (a known pitfall in poorly modeled multi-account apps). Firefly/Actual treat transfers as distinct for the same reason.

### 4. Opening / starting balance as a system equity offset (internal)

When creating an account with a non-zero starting balance, post a balanced entry against an internal, non-user-facing equity/opening-balance account (or a dedicated system account of type that does not appear in category pickers). This keeps the ledger balanced from day one without inventing fake income.

**Alternative considered:** allow unbalanced “balance adjustments.” Rejected — violates double-entry invariants already in the product.

### 5. Home overview is the default landing surface

Add a Home destination as the first shell tab (before Register). It shows:
1. Overall net position (= Σ asset balances − Σ liability balances for accounts with `include_in_net_worth`).
2. Sections per account group (system sort order), each with group total and member accounts + balances.
3. Tap account → that account’s register.

Register becomes **account-scoped** (picker or deep-link from Home). Summary gains an optional account filter; default remains all accounts (income/expense only — transfers excluded).

### 6. Migration from single-account installs

Drift schema migration:
1. Create `account_groups` and seed the four system groups.
2. Add `group_id`, `sort_order`, `include_in_net_worth` to `accounts`; extend type check for `liability`.
3. Assign the existing sole `asset` financial account to **Cash & cash equivalents**; keep its id so historical postings remain valid.
4. Income/Expense category rows keep `group_id = NULL`.

No journal rewrite required for the happy path (balances unchanged).

### 7. Integrity-signing interaction

Any new write (`recordTransfer`, opening-balance entry, future account-related posts) MUST use the existing chain tip + sign path. Archiving/renaming accounts and groups are metadata updates (not journal mutations) and do not create chain entries — same as category rename/archive today.

### 8. Investment accounts explicitly reserved

Do not introduce an `investment` account type or group in this change. A future change can add an Investment group/type with valuation rules; pension here is **balance tracking only** (contributions/withdrawals as money in/out).

## Risks / Trade-offs

- **[Risk] Liability sign convention confuses users** → Mitigation: Repository returns display balances and direction labels tailored by account type (“Payment” / “Charge” copy can come later); unit tests lock the mapping.
- **[Risk] Transfers miscounted as income/expense** → Mitigation: dedicated method; summary queries exclude entries that have no income/expense posting.
- **[Risk] Migration couples to integrity chain** → Mitigation: metadata-only migration; no re-sign of history for adding groups.
- **[Risk] Too many groups overwhelm UI** → Mitigation: seed four; allow custom groups but keep Home sections collapsed by default if a group has zero accounts.
- **[Trade-off] Groups are coarse** → Acceptable for v1 clarity; subtypes can refine later without breaking group rollups.
- **[Trade-off] Pension without investment math** → User asked to defer investment domain; document in UI that pension is tracked as a balance, not portfolio performance.

## Migration Plan

1. Ship Drift migration + seed groups + backfill existing asset account.
2. Update Repository APIs; keep a compatibility helper that resolves “default financial account” for older call sites during the refactor.
3. Ship Home UI + account management; make Home the initial route.
4. Update register/record-transaction/summary for account selection.
5. Rollback: forward-only schema (standard Drift); uninstall/reinstall is not a rollback — treat as usual SQLite migration discipline.

## Open Questions

- Should credit cards default to **Credit & short-term debt** (liability) or be modeled as asset accounts with negative balance (Firefly’s optional advice)? **Proposal default: liability** — clearer for group rollups of debt.
- Are custom account groups user-creatable in v1, or only the four system groups + rename? **Proposal default: system groups + rename; custom groups if low cost during implementation.**
- Should the income/expense summary default to one account or all accounts? **Proposal default: all accounts**, with optional filter.
