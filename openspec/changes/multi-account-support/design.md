## Context

`core-ledger-single-account` established a double-entry ledger with one `accounts` table holding both the single financial account (`type = asset`) and Income/Expense categories. The archived design explicitly anticipated this change: more `asset` rows in the same table, plus transfers. `ledger-integrity-signing` ships as schema version 2 and signs every journal write; any new write path (transfer, opening balance) MUST go through the same chained signing path in `LedgerRepository`.

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
- Bank sync, CSV import, multi-currency / FX, interest auto-calculation, budgets/envelopes. (Multi-currency is expected as a follow-on change layered on top of this one — see the forward-reference note under Decision 1.)
- Multi-device sync, shared household accounts, permissions.
- Auto-creating dozens of bank-specific subtypes beyond what groups + asset/liability cover.

## Decisions

### 1. Extend the existing `accounts` table; add `account_groups`

Keep one chart-of-accounts table. Financial accounts are rows with `type` in `{asset, liability}`. Categories remain `{income, expense}`. A fourth type, `equity`, is added for the single internal system row that balances opening-balance entries (Decision 4) - not user-facing, not a "financial account" in the product sense.

```
account_groups
  id            TEXT PRIMARY KEY
  name          TEXT NOT NULL
  kind          TEXT NOT NULL  -- AccountGroupKind via textEnum (illustrative)
  sort_order    INTEGER NOT NULL
  is_system     INTEGER NOT NULL  -- starter groups cannot be deleted or archived
  created_at    INTEGER NOT NULL

accounts  (extended)
  ...existing columns...
  type          TEXT NOT NULL  -- ADD 'liability' AND 'equity' to enum (see Decision 4 - equity is a single internal system row)
  group_id      TEXT NULL REFERENCES account_groups(id)
                -- required for asset/liability; NULL for income/expense/equity
  sort_order    INTEGER NOT NULL DEFAULT 0
```

**No `include_in_net_worth` column in this change.** Design drafts once carried it “for future flexibility,” but there is no user-facing toggle requirement and Golden Rule #1 forbids shipping behavior (or schema for behavior) that isn’t in a spec scenario. v1 includes every financial account’s balance in group totals and net position (archived accounts still count — the money/debt is still real; they are only omitted from pickers). A later change can add an exclude-from-net-worth toggle with a proper requirement if needed.

**Why groups as a first-class table (not a free-text tag)?** The home screen’s primary job is rollups by liquidity/debt purpose. A fixed set of system groups (seeded, renameable) matches balance-sheet practice and the user’s examples (cash equivalents, mortgages, pension).

**v1 group CRUD scope (resolved):** only the four system groups, renameable by the user. No user-created custom groups in this change — keeps Home predictable and avoids an unscoped management UI. Custom groups can be a later additive change.

**Starter system groups (seeded on migrate / first confirm)** — use **stable well-known string ids** (e.g. `group_cash_equivalents`), not random UUIDs, so `onUpgrade` backfill and tests can address them reliably without name-matching:

| Well-known id (example) | Name | Kind | Typical accounts |
|-------------------------|------|------|------------------|
| `group_cash_equivalents` | Cash & cash equivalents | asset | Salary/checking, savings, cash wallet |
| `group_pension_retirement` | Pension & retirement | asset | Pension fund balance (cash-style tracking) |
| `group_credit_short_term` | Credit & short-term debt | liability | Private credit, credit cards |
| `group_loans_mortgages` | Loans & mortgages | liability | Private loan, mortgage principal |

Similarly seed the equity account with a stable id (e.g. `account_opening_balance_equity`).

**Alternative considered:** subtype enum on each account (`checking`, `savings`, `mortgage`, …) with hardcoded UI buckets. Rejected — inflexible for “private loan” vs “mortgage”, and fights custom naming. Groups give the rollup; account name gives the identity.

**Alternative considered:** Firefly-style liability subtypes (loan/debt/mortgage) as separate account types. Deferred — `liability` + group is enough for v1; subtype metadata can be added later without a rewrite.

**`kind` is a Dart enum column, not a raw string.** Every closed set in this codebase so far (`AccountType`, `VerificationBreakReason`, `IntegrityEventType`) is a real Dart `enum` stored via Drift's `textEnum<T>()`, per Golden Rule #5 ("No magic strings"). `account_groups.kind` (`AccountGroupKind { assetGroup, liabilityGroup }`) should follow the same pattern rather than comparing raw `'asset_group'`/`'liability_group'` strings - the pseudo-schema above is illustrative, not literal DDL to copy.

**System groups are permanent: renameable, never deleted, never archived.** `is_system` marks the four seeded groups. Empty groups are simply omitted from Home (Decision 5 / home-overview empty-group rule), so an archive column/API for groups is unnecessary in this change. Financial accounts themselves *are* archivable, except the last active one (Decision 6).


**Forward reference: future currency layer.** A follow-on change (`multi-currency-support`, already drafted as a sibling OpenSpec change) is expected to add `currency` on `account_groups` and replace the single blended net position with per-currency net positions, plus provisional settlement for unknown FX amounts. This change intentionally keeps `account_groups` free of currency columns so that follow-on can add them without rework; do not fold multi-currency into this change.

### 2. Signed amounts with normal-balance awareness for liabilities

Keep signed `amount_minor` on postings (sum to zero per entry). **Locked convention (Option A — same storage signs for every financial account; liability display flips):**

Transfers and income/expense always write the financial leg with the same sign rules whether F is asset or liability. That keeps `recordTransfer` simple (`source −amount`, `destination +amount`) and keeps every entry summing to zero.

| User action on financial account F | F’s posting (asset or liability) | Offset posting |
|------------------------------------|----------------------------------|----------------|
| Money in + Income | `+amount` | Income `−amount` |
| Money out + Expense | `−amount` | Expense `+amount` |
| Transfer out of F (source) | `−amount` | other financial `+amount` |
| Transfer into F (destination) | `+amount` | other financial `−amount` |
| Opening balance asset display O > 0 | asset `+O` | equity `−O` |
| Opening balance liability owed O > 0 | liability `−O` | equity `+O` |

**Display:**
- Asset display balance = `sum(included postings on F)`.
- Liability display balance (**amount owed**) = `−sum(included postings on F)`.
  - Card purchase (money out + Expense): F gets `−amount` → owed rises.
  - Payment transfer checking → card: card gets `+amount` → owed falls.
  - Opening owed O: F gets `−O` → owed = O.

Repository returns display balances; Views never reinterpret raw signs.

**Purchase vs payment:** a credit-card *purchase* is money out + Expense on the liability. A credit-card *payment* from checking is a **transfer** (checking → card), not an expense.

**Alternative considered:** explicit debit/credit columns — still deferred. **Alternative considered:** liability display = `+sum` with flipped transfer signs for liability legs — rejected because mixed asset↔liability transfers would no longer be a uniform source−/dest+ pair and would be easy to get wrong.

**Every balance/aggregate query excludes quarantined and superseded postings** (`is_verified = 0` and migration-superseded), matching `watchSummary` / register.

**`watchSummary`'s `AccountType` switch must ignore `liability` and `equity` explicitly** (Dart exhaustiveness). Transfers/opening balances stay out of income/expense totals because only income/expense arms accumulate.

### 3. Transfers are a dedicated repository method

`recordTransfer({fromAccountId, toAccountId, amountMinor, transactionDate, description?})`:
- Both accounts MUST be active financial accounts (`asset` or `liability`).
- Amount MUST be positive.
- Creates one journal entry with exactly two postings (from −amount effect, to +amount effect under the signed convention), **no Income/Expense category**.
- Goes through the same integrity hash/sign/chain path as `recordTransaction`.

**Why not reuse income/expense with a hidden “Transfer” category?** That pollutes income/expense summaries (a known pitfall in poorly modeled multi-account apps). Firefly/Actual treat transfers as distinct for the same reason.

**Reversal already covers transfers.** `reverseEntry` copies postings with negated amounts and does not assume an income/expense leg — it works for transfers and opening-balance entries without a new API. Spec/UI should offer Reverse on those register rows the same way as today.

**Register ViewModel must be rewritten, not lightly patched.** `RegisterViewModel` today assumes every entry is “one category posting + one asset posting” (`watchEntries()` globally). That collapses for:
- transfers (two financial accounts, no category),
- opening balances (financial + equity),
- multi-account filtering (only entries that post to the selected account).

The repository should expose an account-scoped entry stream (or equivalent query). Each register row should resolve a counterpart label: category name, counterparty account name (transfer), or a fixed “Opening balance” label — and direction/amount relative to the **viewed** account’s posting.

### 4. Opening / starting balance as a system equity offset (internal)

When creating an account with a non-zero starting balance, post a balanced entry against an internal, non-user-facing equity/opening-balance account (or a dedicated system account of type that does not appear in category pickers). This keeps the ledger balanced from day one without inventing fake income.

**This requires a fourth `AccountType` value, not reuse of `asset`/`liability`/`income`/`expense`.** Add `AccountType.equity` for exactly one system-seeded row (`Opening Balance Equity` or similar), created once alongside the four starter groups. It must be excluded from every user-facing surface that lists accounts or categories: the category picker, the financial-account picker for transactions/transfers, the account-management list, the home overview's account rows and group totals, and net-worth/income-expense aggregates.

**Critical: `watchCategories()` today is a denylist (`type != asset`).** That must become an allowlist (`type IN (income, expense)`) in this change — otherwise `liability` and `equity` rows would leak into category pickers and the register’s category-name lookup. Same allowlist rule as the financial-account picker (`type IN (asset, liability)`): never “everything except …”. `group_id` is `NULL` for the equity row (like income/expense), so it never needs its own group and can’t accidentally get folded into a group total.

**Alternative considered:** allow unbalanced “balance adjustments.” Rejected — violates double-entry invariants already in the product.

### 5. Home overview is the default landing surface

Add a Home destination as the first shell tab (before Register). It shows:
1. Overall net position (= Σ asset display balances − Σ liability display balances for all financial accounts, including archived — see Decision 1: no exclude toggle in v1).
2. Sections per account group that has at least one member account (system sort order), each with group total and member accounts + balances (archived members shown, clearly indicated). Empty groups are omitted.
3. Tap account → that account’s register.

Register becomes **account-scoped** (picker or deep-link from Home). Summary gains an optional account filter; default remains all accounts (income/expense only — transfers and opening balances excluded).

### 6. Migration from single-account installs

Drift schema migration:
1. Create `account_groups` and seed the four system groups.
2. Add `group_id`, `sort_order` to `accounts`; extend `AccountType` with `liability` and `equity`; seed the system equity account.
3. Assign the existing sole `asset` financial account (from schema version 2 / integrity-signing era) to **Cash & cash equivalents**; keep its id so historical postings remain valid.
4. Income/Expense category rows keep `group_id = NULL`.

No journal rewrite required for the happy path (balances unchanged).

**Archiving the last active financial account is rejected.** The ledger must always have at least one active `{asset, liability}` account available for recording. Archiving is allowed only when another active financial account remains.

### 7. Integrity-signing interaction

Any new write (`recordTransfer`, opening-balance entry, future account-related posts) MUST use the existing chain tip + sign path. Archiving/renaming financial accounts, reassigning a financial account's group, and renaming groups are metadata updates (not journal mutations) and do not create chain entries — same as category rename/archive today. Reassignment only ever changes which group total an account's *existing* balance contributes to going forward; it does not touch any posted entry, and MUST be rejected if the destination group's kind doesn't match the account's type (same allowlist rule as creation — see the "Financial account requires a group" requirement).

### 8. Investment accounts explicitly reserved

Do not introduce an `investment` account type or group in this change. A future change can add an Investment group/type with valuation rules; pension here is **balance tracking only** (contributions/withdrawals as money in/out).

## Risks / Trade-offs

- **[Risk] Liability sign convention confuses users** → Mitigation: locked storage/display table above; Repository returns display balances; unit tests cover purchase vs payment-via-transfer.
- **[Risk] Transfers miscounted as income/expense** → Mitigation: dedicated method; summary only accumulates income/expense account types; exhaustive switch ignores liability/equity.
- **[Risk] Register ViewModel silently mis-labels transfers** → Mitigation: rewrite account-scoped register with counterpart labels; tests for transfer and opening-balance rows.
- **[Risk] Migration couples to integrity chain** → Mitigation: metadata-only migration; no re-sign of history for adding groups.
- **[Risk] Empty Home groups clutter UI** → Mitigation: omit or de-emphasize groups with zero member accounts.
- **[Trade-off] Groups are coarse; no custom groups in v1** → Acceptable for clarity; custom groups deferred.
- **[Trade-off] Pension without investment math** → User asked to defer investment domain; document in UI that pension is tracked as a balance, not portfolio performance.
- **[Trade-off] No per-account exclude-from-net-worth** → Avoids shipping schema without a requirement; add later if needed.

## Migration Plan

1. Ship Drift migration + seed groups + equity account + backfill existing asset account.
2. Update Repository APIs; **remove** `_financialAccount()` in the same change (Golden Rule #9 — no compatibility window). Every call site takes an explicit financial-account id or uses list/default-for-UI helpers that are intentional new APIs.
3. Rewrite register for account scope + transfer/opening-balance row labels.
4. Ship Home UI + account management; make Home the initial route.
5. Update record-transaction/summary for account selection.
6. Rollback: forward-only schema (standard Drift); uninstall/reinstall is not a rollback — treat as usual SQLite migration discipline.

**Schema version and interaction with `ledger-integrity-signing`'s upgrade guard.** `core-ledger-single-account` shipped as schemaVersion 1; `ledger-integrity-signing` is schemaVersion 2, with an `onUpgrade(1, 2)` that *throws* if it finds any existing `journal_entries` rows. This change becomes schemaVersion 3. Test both paths per Drift Migration Rule #5: `onCreate` (full schema + seeded groups + equity + starter `Cash & Bank`) and `onUpgrade(2, 3)` (add columns/tables, seed groups + equity, backfill the existing asset account into Cash & cash equivalents). Whether `onUpgrade(2, 3)` needs a reject-if-unsafe guard like its predecessor is an implementation call — flag the precedent, don't prescribe the answer.


**Fresh installs keep auto-creating one starter financial account** (`Cash & Bank` under Cash & cash equivalents) in `confirmFirstIdentity`, same as today. Multiple accounts remain opt-in additive; no new mandatory “create your first account” onboarding step.

## Open Questions

- *(none unresolved)* Credit cards as liabilities, system groups only (renameable, no custom groups in v1), summary defaulting to all accounts, and fresh installs keeping one auto-created starter account are locked as the proposal defaults above / in Decisions.
