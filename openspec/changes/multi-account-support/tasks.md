## 1. Schema and domain model

- [x] 1.1 Add `account_groups` Drift table (`id`, `name`, `kind`, `sort_order`, `is_system`, `created_at`); `kind` is a real Dart enum (`AccountGroupKind { assetGroup, liabilityGroup }`) via `textEnum<AccountGroupKind>()`, matching the project's existing closed-set convention (`AccountType`, `VerificationBreakReason`) — not a raw string column. No `archived_at` on groups in this change (system groups are never archived; empty groups are omitted on Home).
- [x] 1.2 Extend `accounts`: add `liability` and `equity` to `AccountType` (`equity` is the single internal system row that balances opening-balance entries — never shown in any user-facing picker or overview); add `groupId`, `sortOrder` (no `includeInNetWorth` column in this change)
- [x] 1.3 Bump `schemaVersion` to 3 (ledger-integrity-signing is 2). Write both paths per smara-tech-guidelines.md's Drift Migration Rule #5: `onCreate` (schema + seeded groups + equity account + starter financial account in Cash & cash equivalents) and `onUpgrade(2, 3)` (add columns/tables, backfill the existing asset account into Cash & cash equivalents, seed system groups + equity). Decide whether `onUpgrade(2, 3)` needs an existing-rows guard like `ledger-integrity-signing`'s `onUpgrade(1, 2)`.
- [x] 1.4 Update domain `Account` model and add domain models for `AccountGroup` / overview DTOs (group total, net position, display balance)
- [x] 1.5 Add or extend domain exceptions for invalid transfer, missing group, account-type/group-kind mismatch, non-positive opening balance when one is supplied, attempting to archive/delete a system group, and archiving the last active financial account

## 2. Repository: accounts, balances, transfers

- [x] 2.1 Seed system groups (stable well-known ids), the system equity account (stable id), and one starter financial account (`Cash & Bank` under Cash & cash equivalents) in `confirmFirstIdentity`; keep `onUpgrade(2, 3)` migration path for existing DBs
- [x] 2.2 Implement financial-account CRUD: create (with optional opening balance), rename, reassign group, archive (reject if last active), list active/all; type is set only at create (no type-change API). Financial-account picker queries `type IN (asset, liability)` explicitly (allowlist). **Change `watchCategories()` from `type != asset` denylist to `type IN (income, expense)` allowlist** so liability/equity never appear as categories. Update `addCategory` to reject `liability`/`equity` as well as `asset`.
- [x] 2.3 Implement opening-balance posting against the internal system equity account using the locked sign table in design.md Decision 2, through `_appendSignedEntry` (not an ad hoc write path)
- [x] 2.4 Update `recordTransaction` to require `financialAccountId`; use the locked sign table (same financial-leg signs for asset and liability). Remove `_financialAccount()` in this change (Golden Rule #9).
- [x] 2.5 Implement `recordTransfer` (source `−amount`, destination `+amount`, positive amount, distinct active financial accounts, integrity path, no income/expense)
- [x] 2.6 Implement per-account display balance and account-scoped register entry stream — MUST exclude quarantined and migration-superseded entries; liability display owed = `−sum(postings)`
- [x] 2.7 Update income/expense summary: optional financial-account filter; make `AccountType` switch exhaustive (`liability`/`equity` ignored); transfers/opening balances must not affect income/expense totals
- [x] 2.8 Implement home overview query: accounts by group (including archived members), group totals, overall net position — same quarantine/supersession exclusion as 2.6
- [x] 2.9 Implement system-group rename; reject archive/delete of system groups; support reassigning a financial account to another matching-kind group; no custom-group create API in this change

## 3. Unit tests (repository / domain)

- [x] 3.1 Tests: create asset/liability accounts, group assignment rules, archive hides from pickers, cannot archive last active account, cannot change account type after create; `watchCategories` returns only income/expense (never liability/equity)
- [x] 3.2 Tests: migration backfill assigns legacy account to Cash & cash equivalents without changing balance; `onCreate` and `onUpgrade(2, 3)` both tested per Drift Migration Rule #5 (mirror `test/data/database/app_database_migration_test.dart`)
- [x] 3.3 Tests: income/expense posting against asset and liability; liability display owed rises on purchase and falls on transfer payment from an asset account
- [x] 3.4 Tests: transfer success (including asset→liability payment), same-account rejection, non-positive rejection, summary excludes transfers, reverse transfer restores balances
- [x] 3.5 Tests: opening balance for asset and liability; reject zero/negative opening balance when supplied; equity account never appears in financial-account picker or home overview
- [x] 3.6 Tests: home overview group totals and net position (A − L); archived account still contributes to totals
- [x] 3.7 Tests: quarantined or migration-superseded entry excluded from per-account balance, group totals, and net position, while remaining visible in that account's register
- [x] 3.8 Tests: archiving or deleting a system group is rejected; renaming a system group updates the name; reassigning an account moves its balance contribution between group totals; reassigning to a mismatched-kind group is rejected; empty groups are omitted from home overview sections

## 4. UI: account management and recording flows

- [x] 4.1 Add Account management feature (list/create/rename/archive accounts; type + group pickers including reassign group; rename system groups; surface archive-last-account errors)
- [x] 4.2 Update Record Transaction UI/ViewModel to require financial-account selection (default to starter / last-used account when only convenience UX)
- [x] 4.3 Add Transfer UI/ViewModel (from, to, amount, date, optional description)
- [x] 4.4 Rewrite Register UI/ViewModel to be account-scoped: counterpart label for category / counterparty account / opening balance; direction relative to viewed account; keep reverse action for transfers
- [x] 4.5 Update Summary UI/ViewModel with optional account filter; transfers and opening balances excluded from totals

## 5. UI: home overview and navigation

- [x] 5.1 Build Home overview view (net position, group sections, account rows with balances, archived indication)
- [x] 5.2 Wire Home as default landing route in `go_router` / `AppShell` (first destination)
- [x] 5.3 Navigate from Home account row to that account’s register
- [x] 5.4 Add shell destination for Accounts (management) without overcrowding primary tabs if needed (e.g. overflow/settings entry)

## 6. Widget / integration coverage and polish

- [x] 6.1 Widget tests for Home overview grouping, net position, and archived indication
- [x] 6.2 Widget or integration test: create second account, transfer (including payment to a liability), verify balances on Home and register counterpart labels
- [x] 6.3 Run `dart analyze` and fix issues introduced by this change
- [ ] 6.4 Manual smoke: migrate existing DB, confirm legacy account under Cash & cash equivalents with correct balance
