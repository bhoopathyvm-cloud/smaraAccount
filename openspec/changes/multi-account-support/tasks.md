## 1. Schema and domain model

- [ ] 1.1 Add `account_groups` Drift table (`id`, `name`, `kind`, `sort_order`, `is_system`, `archived_at`, `created_at`)
- [ ] 1.2 Extend `accounts`: add `liability` to `AccountType`; add `groupId`, `sortOrder`, `includeInNetWorth`
- [ ] 1.3 Write Drift migration that creates groups, seeds the four system groups, and backfills the existing asset account into Cash & cash equivalents
- [ ] 1.4 Update domain `Account` model and add domain models for `AccountGroup` / overview DTOs (group total, net position)
- [ ] 1.5 Add or extend domain exceptions for invalid transfer, missing group, and account-type/group-kind mismatch

## 2. Repository: accounts, balances, transfers

- [ ] 2.1 Seed system groups + default financial account assignment in `confirmFirstIdentity` (and keep migration path for existing DBs)
- [ ] 2.2 Implement financial-account CRUD: create (with optional opening balance), rename, archive, list active/all
- [ ] 2.3 Implement opening-balance posting against an internal system offset account (excluded from income/expense and category pickers)
- [ ] 2.4 Update `recordTransaction` to require `financialAccountId` and map signed amounts correctly for asset and liability accounts
- [ ] 2.5 Implement `recordTransfer` (two financial accounts, positive amount, integrity hash/sign/chain path, no income/expense)
- [ ] 2.6 Implement per-account balance and account-scoped register (running balance) queries
- [ ] 2.7 Update income/expense summary to exclude transfers and support optional financial-account filter
- [ ] 2.8 Implement home overview query: accounts by group, group totals, overall net position

## 3. Unit tests (repository / domain)

- [ ] 3.1 Tests: create asset/liability accounts, group assignment rules, archive hides from pickers
- [ ] 3.2 Tests: migration backfill assigns legacy account to Cash & cash equivalents without changing balance
- [ ] 3.3 Tests: income/expense posting against selected account; liability display balance conventions
- [ ] 3.4 Tests: transfer success, same-account rejection, non-positive rejection, summary excludes transfers
- [ ] 3.5 Tests: opening balance sets current balance without affecting income/expense totals
- [ ] 3.6 Tests: home overview group totals and net position (A − L)

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
