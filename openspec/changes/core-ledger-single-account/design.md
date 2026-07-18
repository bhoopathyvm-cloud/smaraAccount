## Context

This is the first change implemented against the project's newly-settled
standing conventions: `Specs/architecture/smara-architecture.md` (Flutter,
Provider, Drift, MVVM + Repository, no backend), `Specs/architecture/smara-tech-guidelines.md`
(golden rules, testing/migration rules), and `Specs/design/smara-design-system.md`
(3-color rule). This design covers only what's specific to the
`core-ledger-single-account` capability: the schema and the mechanics behind
the nine requirements in `specs/core-ledger-single-account/spec.md`.

## Goals / Non-Goals

**Goals:**
- A Drift schema that supports: one fixed financial account, archivable
  Income/Expense categories, immutable double-entry journal entries with
  two distinct timestamps, and reversal-by-new-entry.
- Repository methods that make the "user never picks debit/credit" and
  "recorded-at is never user-supplied" requirements structurally true, not
  just convention.

**Non-Goals** (unchanged from `proposal.md`):
- Multiple financial accounts or transfers
- Any device/sync concept
- Multi-user roles, tax codes, receipts, period closing, multi-currency, invoicing

## Decisions

### Schema: one `accounts` table for both the financial account and categories

```
accounts
  id            TEXT PRIMARY KEY (uuid)
  name          TEXT NOT NULL
  type          TEXT NOT NULL CHECK (type IN ('asset','income','expense'))
  archived_at   INTEGER NULL   -- null = active
  created_at    INTEGER NOT NULL

journal_entries
  id                  TEXT PRIMARY KEY (uuid)
  transaction_date    TEXT NOT NULL   -- user-supplied, date only
  recorded_at         INTEGER NOT NULL -- system-captured, DateTime.now(), never user input
  description         TEXT NULL
  reverses_entry_id    TEXT NULL REFERENCES journal_entries(id)
  created_at          INTEGER NOT NULL

postings
  id            TEXT PRIMARY KEY (uuid)
  entry_id      TEXT NOT NULL REFERENCES journal_entries(id)
  account_id    TEXT NOT NULL REFERENCES accounts(id)
  amount_minor  INTEGER NOT NULL   -- signed; postings in one entry sum to 0
  line_number   INTEGER NOT NULL
```

Exactly one `accounts` row has `type = 'asset'` — this is the single
financial account required for this change. It is seeded on first launch
and is never archivable (archiving is only offered for `income`/`expense`
rows, per the Category Management requirement).

**Why one table for account + categories, not two separate tables?**
All three are "things a posting can reference," and `multi-account-support`
(next change) will add more `asset`-type rows to this same table rather than
introduce a parallel concept. Alternative considered: a separate
`categories` table distinct from `accounts` — rejected because it would
need to be merged back into a unified chart-of-accounts table as soon as
transfers between accounts are added, which is known to be coming next.

### Amount validation happens before postings are derived

`recordTransaction`'s user-facing `amountMinor` parameter (a positive
magnitude; direction is a separate field) is validated to be greater than
zero before any posting is derived or written. A zero or negative value
throws `InvalidTransactionAmountException` (a domain exception per
`smara-tech-guidelines.md`'s error handling pattern - named for what it
actually checks, since the postings the system derives are always
balanced by construction; this validates the user-supplied input, not
debit/credit balance) and no `journal_entries`/`postings` rows are
written. This is Repository-level validation, not a `CHECK` constraint on
`postings.amount_minor`, because that column stores the signed per-posting
value (`+amount`/`-amount`) — the positivity rule applies to the
user-supplied magnitude before the sign is derived, not to the stored
column itself.

### Signed-amount postings instead of explicit debit/credit columns

Each entry has exactly two postings whose `amount_minor` values sum to
zero. Recording money in sets the asset posting to `+amount` and the
income-category posting to `-amount`; money out is the reverse. This
directly implements the "balances to zero" and "user never picks
debit/credit" requirements without exposing debit/credit terminology
anywhere in the Repository's public API or the UI.

**Alternative considered:** canonical `debit_minor`/`credit_minor` columns
with normal-balance-aware sign handling. Rejected for this change only
because it adds complexity (normal balance depends on account type) that
has no payoff until a broader account-type set (liabilities, equity)
exists. The signed-postings convention is fully encapsulated inside
`LedgerRepository` — no ViewModel or View ever sees a raw sign — so this
can be swapped for canonical debit/credit internally later without
touching UI code.

### Reversal is a new entry referencing the original

`reverses_entry_id` on `journal_entries` records which entry a reversal
targets. Reversing copies the original entry's postings with `amount_minor`
negated and inserts them as a new entry. Entering the corrected transaction
afterward is just another call to the ordinary "record a transaction" path
— no code links it back to the reversal, matching the resolved requirement.

### Immutability is enforced by Repository surface, not database triggers

`LedgerRepository` exposes `recordTransaction` and `reverseEntry` — no
`updateEntry` or `deleteEntry` method exists anywhere in the codebase.
Database-level `BEFORE UPDATE`/`BEFORE DELETE` triggers (as explored in
earlier architecture drafts) are **not** added in this change: the threat
model here is single-device, single-user, no adversarial multi-party trust
yet. That hardening becomes relevant once the LAN-sync change introduces
multiple devices reading each other's data; revisit there.

### Starter category set

The exact starter categories seeded by `onCreate` (Starter Chart of
Accounts requirement):

```
Income
  - Salary
  - Other Income

Expense
  - Groceries
  - Rent/Mortgage
  - Utilities
  - Transport
  - Other Expense
```

A small, generic set chosen to cover common cases without overwhelming
first use; all are renameable, extendable, and archivable per the
Category Management requirement, so this is a starting point, not a
fixed taxonomy.

### Archived categories

`archived_at` is set (not deleted) when a category is archived. The
new-transaction category picker filters `WHERE type IN ('income','expense')
AND archived_at IS NULL`. Historical views (register, summary) never filter
on `archived_at` — an archived category's past entries render exactly as
before.

## Risks / Trade-offs

- **Signed-postings convention is a simplification** → Mitigated by
  keeping it entirely inside `LedgerRepository`; revisit when
  `multi-account-support` introduces account types with different normal
  balances.
- **No tamper-evidence (hash chain/signatures)** → Acceptable now: no
  multi-device trust model exists yet. Revisit when LAN sync is scoped.
- **Drift requires a `build_runner` codegen step** → Documented in
  `tasks.md` as part of initial project setup, not left implicit.

## Migration Plan

First schema version (`schemaVersion = 1`): `onCreate` creates all three
tables and seeds the single asset account plus the starter Income/Expense
categories. No prior version exists, so no upgrade path is needed yet.
