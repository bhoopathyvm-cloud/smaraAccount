## Why

An architecture review of `lib/` (the codebase-design skill's deepening pass) found three concrete shallow spots, all evidenced by real friction already paid: `LedgerRepository` is a 4,152-line, ~76-method god-repository spanning seven unrelated domain concepts, depended on by 23 files; the same "a dialog's `TextEditingController` must not be disposed before its exit animation finishes" bug was independently rediscovered in four separate views (one of them after it actually crashed in production); and `statement_import_view.dart` bundles six already-distinct step widgets into one 1,115-line file, hurting navigability. None of the three changes user-facing behavior — the point is to make the next feature and the next bug fix cheaper, not to change what the app does.

## What Changes

- Split `LedgerRepository` into one repository per domain concept — identity/signing, whole-ledger backup, account groups, payees, recurring templates, investments — keeping `LedgerRepository` itself for the core journal (record/reverse/fix a transaction, home/summary streams). Extends the precedent `StatementImportRepository` already set as a separately-split repository.
- Add a `showManagedDialog` module to `lib/ui/core/` that owns a dialog's `TextEditingController`(s) end to end — creation through disposal after the exit animation completes — and migrate the four affected views (`account_management_view.dart`, `statement_import_view.dart`, `recurring_template_management_view.dart`, `register_view.dart`) onto it.
- Split `statement_import_view.dart`'s six step widgets (`_ChooseSourceStep`, `_PickFileStep`, `_SelectAccountStep`, `_MapColumnsStep`, `_PreviewStep`, `_SummaryStep`/`_CategoryRuleManagementView`) into one file per step under `lib/ui/features/statement_import/views/`.
- Rewire `lib/main.dart`'s provider graph and every affected ViewModel's constructor to depend on the narrower repository each one actually uses, instead of the whole of `LedgerRepository`.

All three are internal restructuring: no Drift schema change, no new or changed user-facing behavior, no change to what any existing spec scenario asserts.

## Capabilities

### New Capabilities

- `internal-architecture`: the testable contract for this change itself — every other capability's behavior is preserved exactly (verified by the existing suite passing unmodified), plus the one genuine behavior change this change makes: a dialog's `TextEditingController` is no longer disposed before its exit animation finishes.

### Modified Capabilities

None — every existing product capability's requirements and scenarios are preserved exactly; none of their spec files change.

## Impact

- **Repositories**: `lib/data/repositories/ledger_repository.dart` split into `ledger_repository.dart` (slimmed) plus `identity_repository.dart`, `ledger_backup_repository.dart`, `account_group_repository.dart`, `payee_repository.dart`, `recurring_template_repository.dart`, `investment_repository.dart` (exact names confirmed in design.md).
- **DI wiring**: `lib/main.dart`'s `MultiProvider` list — one new `ProxyProvider`/`ProxyProvider2` per new repository, and every `ChangeNotifierProxyProvider<LedgerRepository, XViewModel>` that only needs one slice narrows to that repository.
- **ViewModels**: every ViewModel currently constructed with `required LedgerRepository ledgerRepository` for a single concern (e.g. `PayeeManagementViewModel`, `RecurringTemplateManagementViewModel`, `AccountManagementViewModel`'s group-only methods) takes the narrower repository instead. ViewModels that genuinely span concepts (e.g. one that both records a transaction and touches account groups) take both.
- **UI**: `lib/ui/core/` gains `showManagedDialog`; four view files migrate their dialogs onto it. `lib/ui/features/statement_import/views/` gains five new files; `statement_import_view.dart` shrinks to routing between them.
- **Tests**: unit tests for the six extracted repositories (currently exercised as `LedgerRepository` methods); no behavior-level test changes expected, since call sites keep the same method names and semantics, just on a narrower receiver.
- **No changes**: Drift schema/migrations, `AppDatabase`, any spec under `openspec/specs/`, CI workflows, the acceptance-test-suite harness (`integration_test/acceptance/`) or its test files — those construct `LedgerRepository` etc. directly and will need their own follow-up once this lands, tracked as a task rather than done silently here.
