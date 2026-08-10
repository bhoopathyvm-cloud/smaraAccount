## 1. Schema and domain model

- [x] 1.1 Add `.clientDefault(() => const Uuid().v4())()` to `AccountGroups.id` (matching `Accounts.id`'s existing convention) - no DDL change, existing seeded-group inserts are unaffected since they still pass an explicit id
- [x] 1.2 Add `account_groups.archived_at` (nullable `DateTime`), matching `accounts.archived_at`'s shape
- [x] 1.3 Bump `schemaVersion` (next after `multi-currency-support`'s; confirm the exact number once that change archives); write `onUpgrade` adding the new nullable column (no backfill needed - every existing group lands not-archived)
- [x] 1.4 Add `AccountGroup.archived` (bool, `required`, matching `Account.archived`'s existing precedent - not a defaulted field) to the domain model. This breaks every existing `const AccountGroup(...)` test fixture literal (at least `transfer_view_test.dart`, `home_view_test.dart`, `settle_pending_transfer_view_test.dart`, `account_management_view_test.dart`) - update each with `archived: false` as part of this task, not as an afterthought discovered by a failing `flutter analyze`

## 2. Repository

- [x] 2.1 Implement `createAccountGroup({name, kind, currency})`: rejects an empty/blank currency (neither `confirmFirstIdentity` nor `changeAccountGroupCurrency` validates currency shape today - this is a new, minimal repository-level check, not a retrofit of an existing pattern), assigns `sortOrder` as `(max existing sortOrder) + 1`, inserts with `isSystem: false`
- [x] 2.2 Implement `archiveAccountGroup` for real (currently an unconditional-reject stub): reject if `isSystem`; reject if already archived (mirroring `archiveFinancialAccount`'s existing "must currently be active" precondition via `_requireActiveFinancialAccount` - archiving is not idempotent for accounts today, and groups should follow the same rule); reject if the group has at least one active financial account (reuse `changeAccountGroupCurrency`'s existing active-member query); otherwise set `archived_at`
- [x] 2.3 Confirm `deleteAccountGroup` continues to unconditionally reject for every group (system or user-created) - no behavior change, just re-verify the existing rejection message still makes sense given archiving now exists as the real lifecycle action
- [x] 2.4 Add `includeArchived` parameter to `watchAccountGroups()`, defaulting to `false`, mirroring `watchFinancialAccounts`
- [x] 2.5 Audit every existing `watchAccountGroups()` call site and pass `includeArchived: true` wherever the caller resolves an existing account's own group (currency-lookup helpers in Transfer/RecordTransaction/Settle ViewModels, Account Management's full group list, `_buildHomeOverview`) - leave `includeArchived: false` (the default) for every group *picker* (create-account group dropdown, reassignment target dropdown)
- [x] 2.6 Ensure `_toDomainGroup` (or equivalent) maps `archived_at` to `AccountGroup.archived`

## 3. Unit tests (repository)

- [x] 3.1 Tests: `createAccountGroup` creates a non-system group with the given name/kind/currency and the next `sortOrder`; rejects a missing/empty currency
- [x] 3.2 Tests: `archiveAccountGroup` rejected for a system group regardless of member accounts; rejected for a user-created group with an active member account; rejected for a group that is already archived; succeeds for an empty user-created group and sets `archived`
- [x] 3.3 Tests: an archived group is excluded from `watchAccountGroups()`'s default (picker) results but included with `includeArchived: true`
- [x] 3.4 Tests: an account still assigned to an archived group continues to resolve that group's name/currency correctly (Home overview, Account Management) - the archived flag never breaks existing-account resolution
- [x] 3.5 Tests: `deleteAccountGroup` still unconditionally rejects, for both system and user-created (archived or not) groups
- [x] 3.6 Tests: `onCreate` and `onUpgrade` migration paths for the new `archived_at` column (mirror `test/data/database/app_database_migration_test.dart`'s hand-built-old-schema approach)

## 4. UI

- [x] 4.1 Add a "Create group" action to Account Management: name, kind (segmented control, matching the existing create-account dialog's pattern), currency (reuse the ISO-4217 text-field-plus-common-chips pattern from onboarding's currency picker)
- [x] 4.2 Add an "Archive" action for user-created groups. Today each group row has a single "Edit group" `IconButton`, not a menu - a user-created group's row needs a second action alongside it (or a `PopupMenuButton`, matching the pattern already used for per-account actions), while a system group's row keeps only "Edit group". Confirm-before-archive dialog matching the existing archive-account confirmation pattern.
- [x] 4.3 Ensure archived groups still render in Account Management (labeled "Archived", matching how archived accounts render) but are excluded from the create-account and reassignment group pickers

## 5. Widget / integration coverage and polish

- [x] 5.1 Widget tests: create-group dialog (validation, submission); archive-group action (confirmation, disabled/hidden for system groups, rejected-with-active-accounts error surfaced)
- [x] 5.2 Integration test: create a new group, create an account in it, archive fails while the account is active, archive the account, then archive the group successfully, verify it drops out of the reassignment picker but a historical account still shows its name
- [x] 5.3 Run `dart analyze` and fix issues introduced by this change
- [x] 5.4 Manual smoke: create a group, assign an account, verify Home overview rollup; archive an emptied group; confirm system groups still reject archiving — covered by the integration test in 5.2, which drives the real compiled macOS app end-to-end through this exact flow (not a mock)
