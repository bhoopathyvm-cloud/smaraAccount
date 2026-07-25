## Context

`account_groups` (added by `multi-account-support`, extended with `currency` by `multi-currency-support`) currently holds exactly four rows, seeded once at onboarding with well-known constant ids (`groupCashEquivalentsId`, etc.) referenced directly throughout the codebase - the seeding logic, migrations, and existing tests. `LedgerRepository` already has `archiveAccountGroup`/`deleteAccountGroup` methods, but both unconditionally reject (dead-ish code kept only so the shape exists, per the 360° review during `multi-account-support`). There is no `createAccountGroup` at all.

This change makes groups a real, growable resource: users create their own (name, kind, currency), and can archive one once it stops being useful — while the four system groups keep their current permanent, un-archivable status untouched.

## Goals / Non-Goals

**Goals:**
- Let the user create a new account group with a name, kind (asset/liability), and currency.
- Let the user archive a user-created group once it has zero *active* member accounts (mirroring the existing group-currency-change guard's definition of "empty").
- Preserve every existing group-based behavior unchanged for both system and user-created groups (assignment, reassignment, rollups, per-currency net position).
- Keep the four system groups exactly as permanent and un-archivable as they are today.

**Non-Goals:**
- Permanently deleting a group (even an empty, never-used one) - out of scope; see Open Questions.
- Un-archiving a group - out of scope, matching the fact that accounts have no unarchive path either.
- Reordering groups (`sortOrder` on a new group is simply "after every existing group") - no drag-and-drop reordering UI.
- Any change to currency rules themselves - a new group follows exactly the currency-assignment and change-while-empty rules `multi-currency-support` already established.

## Decisions

### 1. `account_groups.id` gains a client-generated default, matching `accounts.id`

Today `AccountGroups.id` is a plain `text()()` - every existing insert (the four system-group seeds) supplies an explicit well-known constant. A user-created group has no such constant, so `id` needs `.clientDefault(() => const Uuid().v4())()`, exactly like `Accounts.id` already does. This is a Dart-side default only (no DDL/schema change, no migration needed) - existing seeding code is unaffected since it continues to pass an explicit id, which simply overrides the default.

### 2. Archiving needs a new `account_groups.archived_at` column

An empty group (zero *active* accounts) can still have **archived** accounts pointing at it via `group_id` - reassigning an account away from a group is optional, and an already-archived account's group is never touched. `accounts.group_id` has no Drift-level `.references()` foreign-key declaration today, so permanently deleting such a group wouldn't even fail loudly - it would silently orphan that reference, leaving any account still pointing at it unable to resolve its group's name or currency the next time it's displayed. So archiving must be a soft flag, exactly like `accounts.archived_at`, not a row deletion. This is a real schema change: `account_groups.archived_at DateTime NULL`, requiring a `schemaVersion` bump and a migration (`onCreate` needs nothing extra since a fresh install never has archived groups; `onUpgrade` adds the nullable column, defaulting every existing group to not-archived).

**Alternative considered:** delete the row when a group has zero accounts of any kind (active or archived). Rejected - it's an extra existence check for marginal benefit (an archived group costs nothing sitting unused), and it forecloses ever surfacing "this account's group was archived on <date>" in a register/history view later.

### 3. System groups reject archiving via `isSystem`, not via a separate flag

`isSystem` already exists and is exactly "seeded system group, never user-created." `archiveAccountGroup` rejects immediately if `isSystem` is true, before even checking active-member-count - matching `multi-account-ledger`'s existing "System group cannot be archived" requirement, unchanged.

### 4. `watchAccountGroups()` gains an `includeArchived` parameter, matching `watchFinancialAccounts`

Every group-picker call site (create-account group dropdown, reassignment target dropdown) needs archived groups filtered out by default. But several call sites need to resolve *every* group regardless of archived status - anything that looks up an existing account's own group to display its name/currency (Transfer/RecordTransaction/Settle Pending Transfer ViewModels' `currencyFor` helpers, Account Management's group list, the Home overview) must keep working for an account still sitting in a since-archived group. `watchAccountGroups({bool includeArchived = false})` mirrors `watchFinancialAccounts`'s existing convention exactly; every currency-resolution call site is audited to pass `includeArchived: true`, every *picker* call site keeps the default `false`.

### 5. Creating a group requires a non-empty currency - the first repository-level currency check in this codebase

Neither `confirmFirstIdentity` nor `changeAccountGroupCurrency` validates the currency string's shape at all today - every existing currency value reaches the Repository only after a UI screen's own regex (`^[A-Z]{3}$`) already validated it, so there was never a need for a second check. `createAccountGroup` doesn't have that guarantee the same way (nothing stops a future caller from skipping the picker UI), and an empty string would silently violate the intent of a `NOT NULL` currency column, so it gets a minimal repository-level check: reject an empty/blank currency. This deliberately does **not** retrofit full ISO-4217-shape validation onto `confirmFirstIdentity` or `changeAccountGroupCurrency` - that's a pre-existing gap, out of scope here. `sortOrder` for a new group is `(max existing sortOrder across all groups) + 1`, so it always sorts after every existing group on the Home overview and pickers, matching the seeded groups' existing 0-3 ordering scheme.

## Risks / Trade-offs

- **[Risk] A user creates many similarly-named or redundant groups over time** → Mitigation: none needed structurally - this mirrors how a user can already create many financial accounts; archiving handles the "used to be useful, isn't anymore" case, same as accounts.
- **[Risk] Missing an `includeArchived: true` call site silently drops a historical account's group name/currency from view** → Mitigation: this is exactly the kind of regression the existing account-archiving pattern already had to get right once; audit every existing `watchAccountGroups()` call site as part of implementation (tasks.md), don't just add the parameter and stop.
- **[Trade-off] No un-archive and no permanent delete** → Accepted for v1 scope; both are additive later if requested, and archiving a group by mistake is low-stakes (it just stops appearing as a picker option, its accounts if any are unaffected).

## Migration Plan

1. `schemaVersion` bump (next after `multi-currency-support`'s; confirm the exact number once that change archives). Adds `account_groups.archived_at` (nullable) and `account_groups.id`'s client-side UUID default (no DDL impact from the latter).
2. No backfill needed - every existing group (system or otherwise) lands with `archived_at = NULL`, i.e. not archived, which is correct for all of them.
3. Rollback: forward-only schema, same discipline as prior changes.

## Open Questions

- Should a user-created group ever be permanently deletable (not just archived), at least when it has *zero* accounts of any kind, active or archived? Proposed default: no, not in this change - keep the mental model simple ("archive" is the only lifecycle action on a group, exactly like accounts), revisit if users report groups clutter over time.
- Is there a sensible limit on the number of user-created groups? Proposed default: no artificial limit - nothing in the existing design assumes a small, fixed group count other than the four well-known ids, which remain hardcoded constants alongside a growing, dynamically-id'd set.
