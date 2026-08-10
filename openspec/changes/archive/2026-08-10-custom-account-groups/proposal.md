## Why

Account groups are currently limited to four fixed system groups seeded once at onboarding (two asset, two liability) — `multi-account-ledger`'s "Account Groups for Financial Accounts" requirement explicitly states the user cannot create additional ones. This was a reasonable starting scope for a single-currency ledger, but it becomes a real constraint under `multi-currency-support`, where a group's currency is fixed once it has active accounts: a user who wants a third or fourth currency (or simply wants to organize accounts beyond "cash" vs. "retirement"/"credit" vs. "loans" — e.g. a separate group for business accounts) has nowhere to put it. Letting users create their own account groups removes that ceiling without touching any of the existing group-based rollup, reassignment, or per-currency net-position machinery.

## What Changes

- Users can create a new account group: name, kind (asset or liability), and currency (ISO 4217 code), following the same currency rules `multi-currency-support` already established for the four system groups.
- A user-created group behaves exactly like a system group for every existing purpose (financial-account assignment, reassignment target, home-overview rollup, currency-change-while-empty) — nothing about *using* a group changes based on who created it.
- Users can archive a user-created group once it has zero *active* member accounts (matching the existing "empty groups are de-emphasized" pattern, but this time as an explicit action rather than just visual de-emphasis) — but this is a *user-created-group-only* action, and it is one-way: there is no un-archive path, matching how account archiving already works.
- The four system groups remain permanent and un-archivable, exactly as today — this change does not loosen that rule.
- Deleting a group (permanently, not just archiving) is out of scope for this change — see Open Questions in design.md.

## Capabilities

### New Capabilities

(none — this extends the existing account-groups behavior rather than introducing a new domain)

### Modified Capabilities

- `multi-account-ledger`: the "Account Groups for Financial Accounts" requirement changes from "the user SHALL NOT be able to create additional custom account groups" to allowing user-created groups (with a currency, per `multi-currency-support`); the "System Account Groups Are Permanent and Renameable" requirement is clarified to distinguish system groups (permanent, un-archivable) from user-created groups (archivable once they have zero active member accounts).

## Impact

- `lib/data/repositories/ledger_repository.dart`: new `createAccountGroup` method; `archiveAccountGroup` (currently dead/rejects-always code from `multi-account-support`, per the 360° review during that change) becomes real for user-created groups only.
- `lib/data/database/tables/account_groups_table.dart` / migration: `is_system` already exists (added by `multi-account-support`) and is exactly the flag needed to keep system groups permanent. Archiving itself does need a schema change — a new nullable `archived_at` column (an empty group can still be referenced by a since-archived account, so soft-archiving rather than deleting the row is required) — plus a `schemaVersion` bump; see design.md.
- `lib/ui/features/account_management/`: new "Create group" action; archive action for user-created groups.
- Sequencing: depends on `multi-currency-support` (a group's currency is set at creation) — implement after that change archives, matching the dependency discipline `multi-currency-support` itself used against `multi-account-support`.
