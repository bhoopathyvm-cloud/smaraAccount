## 1. AccountRepository (leaf; most depended-on by later groups)

- [ ] 1.1 Create `lib/data/repositories/account_repository.dart` with `AccountRepository({required AppDatabase database, required LedgerRepository ledgerRepository})`, moving `createAccountGroup`, `renameAccountGroup`, `archiveAccountGroup`, `unarchiveAccountGroup`, `deleteAccountGroup`, `changeAccountGroupCurrency`, `backfillGroupCurrencies`, `needsCurrencyBackfill`, `reassignFinancialAccountGroup`, `createFinancialAccount`, `renameFinancialAccount`, `archiveFinancialAccount`, `unarchiveFinancialAccount`, `watchFinancialAccounts`, `watchAccountGroups` (design.md's corrected caller audit — missing from the original list), `recordArchivedAccountCloseoutTransfer` out of `LedgerRepository`, verbatim.
- [ ] 1.2 Create `lib/data/repositories/repository_date_utils.dart` with a public top-level `dateOnly(DateTime date)` (moved verbatim from `LedgerRepository._dateOnly`, design.md D1a) — needed by both this repository and the core one. Update every call site in `LedgerRepository` from `_dateOnly` to the imported `dateOnly`.
- [ ] 1.3 Move `_requireCloseoutEligibleFinancialAccount` and `_postOpeningBalance` into `AccountRepository`, staying private there (each has exactly one caller, design.md D1a). `_postOpeningBalance` calls `ledgerRepository.appendSignedEntry` for the write.
- [ ] 1.4 In `LedgerRepository`: rename `_appendSignedEntry` → public `appendSignedEntry`, `_postTransfer` → public `postTransferEntry` (design.md D1a) — both stay in `LedgerRepository`; `AccountRepository` calls them through its `ledgerRepository` dependency. **`_requireActiveFinancialAccount` and `_groupCurrencyFor` are copied to `AccountRepository`, not moved**: `LedgerRepository`'s own copies stay, private, exactly as they are today. Moving them instead would make `LedgerRepository` depend on `AccountRepository` too, alongside `AccountRepository`'s existing dependency on `LedgerRepository` — a circular constructor dependency Dart can't construct (each needs an instance of the other to be built first). Two small, private, read-only validation queries duplicated is a better trade than a cycle; `AccountRepository`'s own copies can stay private too, since nothing outside `AccountRepository` calls them once `AccountRepository` doesn't hand them out.
- [ ] 1.5 `recordArchivedAccountCloseoutTransfer` calls `ledgerRepository.postTransferEntry` and `ledgerRepository.displayBalanceMinor` (design.md D2) rather than duplicating posting logic.
- [ ] 1.6 Update `main.dart`: `AccountRepository`'s provider becomes `ProxyProvider2<AppDatabase, LedgerRepository, AccountRepository>` (`LedgerRepository` built first, from `AppDatabase` alone — it gains no new constructor dependency, per 1.4). `LedgerRepository`'s own provider is unchanged in this group.
- [ ] 1.7 Update every corrected caller (design.md D1's "corrected caller audit" note) to take `AccountRepository` for the methods this group moved: `AccountManagementViewModel`, `RegisterViewModel`, `StatementImportViewModel`, `RecurringTemplateManagementViewModel`, `RecordTransactionViewModel`, `CorrectionViewModel`, `SettlePendingTransferViewModel`, `TransferViewModel`, `HoldingsViewModel`, `SummaryViewModel`, `FirstAccountNameViewModel`, `CurrencyBackfillViewModel` — each keeps `LedgerRepository` too wherever it still calls a core method.
- [ ] 1.8 Update `lib/data/repositories/statement_import_repository.dart` to take `AccountRepository` for `watchAccountGroups`/`watchFinancialAccounts`, keeping `LedgerRepository` for `recordTransaction`/`watchEntriesForAccount` (its `CategoryRepository` dependency for `watchCategories` lands in group 2).
- [ ] 1.9 Update `lib/ui/app_router.dart`'s `buildAppRouter(...)` to take `AccountRepository` for its `needsCurrencyBackfill` call (its `IdentityRepository` dependency for `currentIdentity`/`hasMatchingStoredKey`/`verifyChain` lands in group 3); update `main.dart`'s call site.
- [ ] 1.10 Delete the moved methods (but not `_requireActiveFinancialAccount`/`_groupCurrencyFor` — see 1.4) from `LedgerRepository`. Confirm no remaining call site references the moved ones there.
- [ ] 1.11 `flutter analyze` clean; full `flutter test` passes unmodified.

## 2. CategoryRepository, PayeeRepository, LedgerBackupRepository (independent leaves)

- [ ] 2.1 Create `lib/data/repositories/category_repository.dart`, moving `addCategory`, `archiveCategory`, `renameCategory`, `unarchiveCategory`, `setCategoryMonthlyLimit`, `watchCategories`. Register its `ProxyProvider`; update `CategoryManagementViewModel`.
- [ ] 2.2 Create `lib/data/repositories/payee_repository.dart`, moving `createPayee`, `deletePayee`, `findOrCreatePayeeByName`, `renamePayee`, `recordPayeeUsage`, `watchPayees`. Register its `ProxyProvider`; update `PayeeManagementViewModel` and any other caller of `recordPayeeUsage`/`findOrCreatePayeeByName` (check `RecordTransactionViewModel` and the statement-import category-rule flow).
- [ ] 2.3 Create `lib/data/repositories/ledger_backup_repository.dart`, moving `exportLedgerBackup`, `restoreLedgerBackup` (a true leaf — operates on the raw database file, no dependency on any other repository). Register its `ProxyProvider`; update `SettingsViewModel`.
- [ ] 2.4 Delete the moved methods from `LedgerRepository`. Confirm no remaining call site references them there.
- [ ] 2.5 `flutter analyze` clean; full `flutter test` passes unmodified.

## 3. IdentityRepository, InvestmentRepository (depend on group 1, and group 2's CategoryRepository)

- [ ] 3.1 Create `lib/data/repositories/identity_repository.dart` with `IdentityRepository({required AppDatabase database, required AccountRepository accountRepository})`, moving `acknowledgeIdentity`, `confirmFirstIdentity`, `currentIdentity`, `generateFirstIdentity`, `hasMatchingStoredKey`, `migrateToNewIdentityAfterKeyLoss`, `restoreIdentity`, `resumePendingIdentity`, `stashPendingPhraseWords`, `verifyChain`, `exportKeystoreFile`. `confirmFirstIdentity`'s call to `_seedSystemGroupsEquityAndClearing` becomes a call through `accountRepository`.
- [ ] 3.2 Register `ProxyProvider3<AppDatabase, AccountRepository, ..., IdentityRepository>`; update `RecoveryPhraseSetupViewModel` and `RestoreIdentityViewModel`.
- [ ] 3.3 Before moving `InvestmentRepository`'s methods, audit every ViewModel that calls `createInstrument`/`archiveInstrument`/`renameInstrument`/`cacheInstrumentQuote`/`recordBuy`/`recordSell`/`recordDividend`/`watchInstruments` (design.md's Open Questions flags this cluster's boundary wasn't traced as exhaustively as the others) — confirm the grouping holds before creating the file.
- [ ] 3.4 Create `lib/data/repositories/investment_repository.dart` with `InvestmentRepository({required AppDatabase database, required AccountRepository accountRepository, required CategoryRepository categoryRepository})`, moving the confirmed method set.
- [ ] 3.5 Register its `ProxyProvider`; update the holdings feature's ViewModel(s) and `HomeViewModel` (for `watchInstruments`).
- [ ] 3.6 Delete the moved methods from `LedgerRepository`. Confirm no remaining call site references them there.
- [ ] 3.7 `flutter analyze` clean; full `flutter test` passes unmodified.

## 4. Slim LedgerRepository to the core journal concept

- [ ] 4.1 Confirm `LedgerRepository` now holds only `recordTransaction`, `recordSplitTransaction`, `recordTransfer`, `settlePendingTransfer`, `reverseEntry`, `fixPostedTransaction`, `hasAnyJournalEntries`, `displayBalanceMinor`, `exportLedgerCsv`, `watchHomeOverview`, `watchSummary`, `watchEntriesForAccount`, `close`, plus `AccountRepository` as a constructor dependency (for `recordTransaction`'s account validation, per design.md D2).
- [ ] 4.2 Update `main.dart`'s `LedgerRepository` provider to a `ProxyProvider2<AppDatabase, AccountRepository, LedgerRepository>`.
- [ ] 4.3 Re-check every remaining `ChangeNotifierProxyProvider<LedgerRepository, X>` in `main.dart` against what its ViewModel actually calls now — narrow or add a second/third generic parameter per design.md D3.
- [ ] 4.4 `flutter analyze` clean; full `flutter test` passes unmodified.

## 5. RecurringTemplateRepository (depends on the now-slimmed core LedgerRepository)

- [ ] 5.1 Create `lib/data/repositories/recurring_template_repository.dart` with `RecurringTemplateRepository({required AppDatabase database, required LedgerRepository ledgerRepository})`, moving `createRecurringTemplate`, `deleteRecurringTemplate`, `updateRecurringTemplate`, `recordDueTemplate`, `watchRecurringTemplates`. `recordDueTemplate`'s call to `recordTransaction` becomes a call through `ledgerRepository`.
- [ ] 5.2 Register its `ProxyProvider2`; update `RecurringTemplateManagementViewModel` and `HomeViewModel`.
- [ ] 5.3 Delete the moved methods from `LedgerRepository`. Confirm no remaining call site references them there.
- [ ] 5.4 `flutter analyze` clean; full `flutter test` passes unmodified.

## 6. Repository-split verification

- [ ] 6.1 Confirm `LedgerRepository` contains only the core-journal methods listed in 4.1 — no leftover method from any other cluster.
- [ ] 6.2 Confirm the dependency graph matches design.md D2 exactly: `grep` each new repository's constructor for unexpected dependencies.
- [ ] 6.3 Full `flutter test` run, unmodified test files, all green (internal-architecture spec: "Existing test suite passes unmodified").
- [ ] 6.4 Add a task note (not code) flagging that the unmerged `acceptance-test-suite` branch constructs `LedgerRepository` directly in `integration_test/acceptance/support/acceptance_harness.dart` and will need updating for the new repositories once both branches are reconciled — out of this change's reach.

## 7. `showManagedDialog`

- [ ] 7.1 Add `showManagedDialog<T>` to `lib/ui/core/` (design.md D5): creates `controllerCount` `TextEditingController`s (with optional initial text), hands them to `builder`, awaits `showDialog`, and disposes them only after the route's exit animation completes.
- [ ] 7.2 Add a widget test asserting a controller created by `showManagedDialog` is not disposed while the dialog's exit transition is still rendering (internal-architecture spec: "Closing a managed dialog never disposes its controller mid-animation").
- [ ] 7.3 Migrate `account_management_view.dart`'s dialogs (create/rename group, create/rename account) onto `showManagedDialog`; delete the old hand-rolled controller lifecycle.
- [ ] 7.4 Migrate `statement_import_view.dart`'s dialogs (rename profile, save backup, restore backup) onto `showManagedDialog`.
- [ ] 7.5 Migrate `recurring_template_management_view.dart`'s create/edit template dialog onto `showManagedDialog`.
- [ ] 7.6 Migrate `register_view.dart`'s closeout dialog onto `showManagedDialog`.
- [ ] 7.7 `flutter analyze` clean; full `flutter test` passes unmodified; existing dialog-related widget tests still pass unmodified.

## 8. Split `statement_import_view.dart` into one file per step

- [ ] 8.1 Move `_ChooseSourceStep` to `lib/ui/features/statement_import/views/choose_source_step.dart`.
- [ ] 8.2 Move `_PickFileStep` to `pick_file_step.dart`.
- [ ] 8.3 Move `_SelectAccountStep` to `select_account_step.dart`.
- [ ] 8.4 Move `_MapColumnsStep` (and its `_ProfileAction` enum) to `map_columns_step.dart`.
- [ ] 8.5 Move `_PreviewStep` (and `_PreviewRow`, `_SkippedRowsSection`) to `preview_step.dart`.
- [ ] 8.6 Move `_SummaryStep` and `_CategoryRuleManagementView` to `summary_step.dart`.
- [ ] 8.7 `statement_import_view.dart` keeps only `StatementImportView` and its step-routing `switch`; each moved class becomes public (or exported via a shared `part`/import) so the switch can still reach it.
- [ ] 8.8 `flutter analyze` clean; full `flutter test` passes unmodified.

## 9. Final verification

- [ ] 9.1 Full `flutter test` run across the whole suite, no test file modified for this change.
- [ ] 9.2 `dart format --output=none --set-exit-if-changed .` and `flutter analyze` both clean.
- [ ] 9.3 Manually exercise, in a real build: create/rename/archive an account group and a financial account; record a transaction; export and restore a ledger backup; add/edit a recurring template and let one come due; record a buy/sell/dividend; open and cancel each migrated dialog mid-animation (rapid open/close) to confirm no dispose-crash; walk the CSV import wizard end to end. Confirms Definition of Done's manual-verification bar for a change with no automated UI-level regression coverage of its own beyond the existing suite.
