## 1. Schema and domain model

- [ ] 1.1 Add `account_groups` Drift table (`id`, `name`, `kind`, `sort_order`, `is_system`, `archived_at`, `created_at`); `kind` is a real Dart enum (`AccountGroupKind { assetGroup, liabilityGroup }`) via `textEnum<AccountGroupKind>()`, matching the project's existing closed-set convention (`AccountType`, `VerificationBreakReason`) — not a raw string column
- [ ] 1.2 Extend `accounts`: add `liability` and `equity` to `AccountType` (`equity` is the single internal system row that balances opening-balance entries — never shown in any user-facing picker or overview); add `groupId`, `sortOrder`, `includeInNetWorth`
- [ ] 1.3 Bump `schemaVersion` to 3 (ledger-integrity-signing is 2). Write both paths per smara-tech-guidelines.md's Drift Migration Rule #5: `onCreate` (schema + seeded groups, no legacy account) and `onUpgrade(2, 3)` (add columns/tables, backfill the existing asset account into Cash & cash equivalents, seed the system equity account). Decide whether `onUpgrade(2, 3)` needs an existing-rows guard like `ledger-integrity-signing`'s `onUpgrade(1, 2)` — that one throws rather than attempt a real-data backfill it can't safely do.
- [ ] 1.4 Update domain `Account` model and add domain models for `AccountGroup` / overview DTOs (group total, net position)
- [ ] 1.5 Add or extend domain exceptions for invalid transfer, missing group, account-type/group-kind mismatch, and archiving a system group that still has active accounts

## 2. Repository: accounts, balances, transfers

- [ ] 2.1 Seed system groups, the system equity account, and default financial account assignment in `confirmFirstIdentity` (and keep migration path for existing DBs) — per the open question in design.md, default assumption is fresh installs keep auto-creating one starter account
- [ ] 2.2 Implement financial-account CRUD: create (with optional opening balance), rename, archive, list active/all; the financial-account picker queries `type IN (asset, liability)` explicitly (an allowlist), never "not income/expense" (a denylist that would leak the new `equity` type)
- [ ] 2.3 Implement opening-balance posting against the internal system equity account, through the same shared signing/chain path as `recordTransaction`/`reverseEntry` (`_appendSignedEntry` or equivalent) — not a separate ad hoc write path
- [ ] 2.4 Update `recordTransaction` to require `financialAccountId` and map signed amounts correctly for asset and liability accounts
- [ ] 2.5 Implement `recordTransfer` (two financial accounts, positive amount, integrity hash/sign/chain path, no income/expense)
- [ ] 2.6 Implement per-account balance and account-scoped register (running balance) queries — MUST exclude entries where `entry_verification_cache.is_verified = 0` and entries superseded by a true-key-loss migration, matching `watchSummary`'s existing exclusion logic exactly (see design.md's "Every balance/aggregate query excludes quarantined and superseded postings")
- [ ] 2.7 Update income/expense summary to exclude transfers and support optional financial-account filter
- [ ] 2.8 Implement home overview query: accounts by group, group totals, overall net position — same quarantine/supersession exclusion as 2.6
- [ ] 2.9 Implement system-group archive protection: reject archiving an `is_system` group with at least one active financial account

## 3. Unit tests (repository / domain)

- [ ] 3.1 Tests: create asset/liability accounts, group assignment rules, archive hides from pickers
- [ ] 3.2 Tests: migration backfill assigns legacy account to Cash & cash equivalents without changing balance; `onCreate` and `onUpgrade(2, 3)` both tested per Drift Migration Rule #5 (mirror `test/data/database/app_database_migration_test.dart`'s hand-built-old-schema approach from ledger-integrity-signing)
- [ ] 3.3 Tests: income/expense posting against selected account; liability display balance conventions
- [ ] 3.4 Tests: transfer success, same-account rejection, non-positive rejection, summary excludes transfers
- [ ] 3.5 Tests: opening balance sets current balance without affecting income/expense totals; system equity account never appears in the financial-account picker
- [ ] 3.6 Tests: home overview group totals and net position (A − L)
- [ ] 3.7 Tests: a quarantined (tampered) or migration-superseded entry is excluded from per-account balance, group totals, and net position, while remaining visible in that account's register
- [ ] 3.8 Tests: archiving a system group with active accounts is rejected; archiving one with zero active accounts succeeds

## 4. UI: account management and recording flows

- [ ] 4.1 Add Account management feature (list/create/rename/archive; type + group pickers)
- [ ] 4.2 Update Record Transaction UI/ViewModel to require financial-account selection
- [ ] 4.3 Add Transfer UI/ViewModel (from, to, amount, date, optional description)
- [ ] 4.4 Update Register UI/ViewModel to be account-scoped (account picker or route argument)
- [ ] 4.5 Update Summary UI/ViewModel with optional account filter; document that transfers are excluded

## 5. UI: home overview and navigation

- [ ] 5.1 Build Home overview view (net position, group sections, account rows with balances)
- [ ] 5.2 Wire Home as default landing route in `go_router` / `AppShell` (first destination)
- [ ] 5.3 Navigate from Home account row to that account’s register
- [ ] 5.4 Add shell destination for Accounts (management) without overcrowding primary tabs if needed (e.g. overflow/settings entry)

## 6. Widget / integration coverage and polish

- [ ] 6.1 Widget tests for Home overview grouping and net position display
- [ ] 6.2 Widget or integration test: create second account, transfer, verify balances on Home
- [ ] 6.3 Run `dart analyze` and fix issues introduced by this change
- [ ] 6.4 Manual smoke: migrate existing DB, confirm legacy account under Cash & cash equivalents with correct balance
