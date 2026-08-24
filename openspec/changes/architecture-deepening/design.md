## Context

`lib/data/repositories/ledger_repository.dart` is 4,152 lines and ~76 public methods, constructed once at the app root (`main.dart`'s `ProxyProvider<AppDatabase, LedgerRepository>`) and injected — the whole class — into every ViewModel that needs any of it: 23 files in total. `StatementImportRepository` is already split out as its own class (`ProxyProvider2<AppDatabase, LedgerRepository, StatementImportRepository>`), proving the pattern already works in this codebase; this change extends it to the concepts still bundled into `LedgerRepository` itself.

Separately, four views (`account_management_view.dart`, `statement_import_view.dart`, `recurring_template_management_view.dart`, `register_view.dart`) each independently carry a defensive comment about the same bug: disposing a dialog's `TextEditingController` immediately after `showDialog`'s Future resolves races the dialog route's exit animation, which still rebuilds the `TextField` for a few more frames. One of the four (`account_management_view.dart`) crashed on it in production (`38de78a`) before the workaround was written; the other three carry the same comment without ever having crashed, which reads as the workaround being copied forward rather than derived independently each time — the underlying race was never fixed at a seam, just reproduced defensively.

Third, `statement_import_view.dart` is 1,115 lines holding six already-distinct step widgets (`_ChooseSourceStep`, `_PickFileStep`, `_SelectAccountStep`, `_MapColumnsStep`, `_PreviewStep`, `_SummaryStep` + `_CategoryRuleManagementView`) as private classes in one file.

## Goals / Non-Goals

**Goals:**
- Every existing capability's requirements, scenarios, and observable behavior are preserved exactly. This is a restructuring change, not a behavior change.
- `LedgerRepository` shrinks to the core journal concept its name promises: recording/reversing/fixing a transaction, the home/summary read streams, and `close()`.
- Six new repositories, one per domain concept currently bundled into `LedgerRepository`, each depended on only by the ViewModels that actually use it.
- One `showManagedDialog` module in `lib/ui/core/` that owns a dialog's `TextEditingController`(s) end to end, migrated onto by all four affected views.
- `statement_import_view.dart` split into one file per step widget.
- Each extraction is applied as a complete, atomic slice: the old surface is gone from `LedgerRepository` in the same slice its replacement lands, per Golden Rule #9 — no compatibility window, no leftover call site on the old method.

**Non-Goals:**
- No Drift schema change. No table, column, or migration touched.
- No change to the `acceptance-test-suite` change's harness or test files (`integration_test/acceptance/`) — that work lives on an unmerged branch and isn't reachable from this one; its call sites (`LedgerRepository(database: ...)`, `AppLockService`, etc.) will need their own follow-up once both land, tracked as a task here rather than silently left broken.
- No change to `main.dart`'s overall DI approach (still `provider`/`ProxyProvider`, not a new DI mechanism) — narrower wiring within the existing pattern, not a new one.
- No attempt to also split `account_management_view.dart`'s or `statement_import_view.dart`'s ViewModels — this change is about the Repository layer and the two named UI files only.

## Decisions

### D1 — Repository split boundaries

One repository per cluster, named after the domain concept, confirmed by which methods each existing ViewModel actually calls together (not just by method-name prefix):

| New class | Owns (from `LedgerRepository`) | Confirmed sole caller cluster |
|---|---|---|
| `IdentityRepository` | `acknowledgeIdentity`, `confirmFirstIdentity`, `currentIdentity`, `generateFirstIdentity`, `hasMatchingStoredKey`, `migrateToNewIdentityAfterKeyLoss`, `restoreIdentity`, `resumePendingIdentity`, `stashPendingPhraseWords`, `verifyChain`, `exportKeystoreFile` | `RecoveryPhraseSetupViewModel`, `RestoreIdentityViewModel` — confirmed to call only this cluster (plus `verifyChain`) |
| `LedgerBackupRepository` | `exportLedgerBackup`, `restoreLedgerBackup` | Settings' backup/restore dialogs. Operates on the raw SQLite file (`AppDatabase.resolveDatabaseFile()` + WAL checkpoint), not through any other repository — a true leaf |
| `AccountRepository` | `createAccountGroup`, `renameAccountGroup`, `archiveAccountGroup`, `unarchiveAccountGroup`, `deleteAccountGroup`, `changeAccountGroupCurrency`, `backfillGroupCurrencies`, `needsCurrencyBackfill`, `reassignFinancialAccountGroup`, `createFinancialAccount`, `renameFinancialAccount`, `archiveFinancialAccount`, `unarchiveFinancialAccount`, `watchFinancialAccounts`, `recordArchivedAccountCloseoutTransfer` | `AccountManagementViewModel` calls both the account-group *and* financial-account methods together — one repository, not two, contrary to the review's looser sketch |
| `CategoryRepository` | `addCategory`, `archiveCategory`, `renameCategory`, `unarchiveCategory`, `setCategoryMonthlyLimit`, `watchCategories` | `CategoryManagementViewModel` |
| `PayeeRepository` | `createPayee`, `deletePayee`, `findOrCreatePayeeByName`, `renamePayee`, `recordPayeeUsage`, `watchPayees` | `PayeeManagementViewModel` |
| `RecurringTemplateRepository` | `createRecurringTemplate`, `deleteRecurringTemplate`, `updateRecurringTemplate`, `recordDueTemplate`, `watchRecurringTemplates` | `RecurringTemplateManagementViewModel`, `HomeViewModel` |
| `InvestmentRepository` | `createInstrument`, `archiveInstrument`, `renameInstrument`, `cacheInstrumentQuote`, `recordBuy`, `recordSell`, `recordDividend`, `watchInstruments` | Holdings feature (not exhaustively traced here; grouping follows the review's method-name clustering, confirmed self-consistent by `recordBuy`'s own dependencies below) |
| `LedgerRepository` (slimmed) | `recordTransaction`, `recordSplitTransaction`, `recordTransfer`, `settlePendingTransfer`, `reverseEntry`, `fixPostedTransaction`, `hasAnyJournalEntries`, `displayBalanceMinor`, `exportLedgerCsv`, `watchHomeOverview`, `watchSummary`, `watchEntriesForAccount`, `close` | `RegisterViewModel`, `SummaryViewModel`, `HomeViewModel` |

`recordArchivedAccountCloseoutTransfer` moves to `AccountRepository`, not the core repository, despite posting a transfer entry: closing out an *archived account* is fundamentally an account-lifecycle operation (it only exists to let `AccountRepository`'s own archive flow finish cleanly), and `RegisterViewModel` already calls it alongside other register-scoped account operations. It composes the core `LedgerRepository`'s transfer-posting for the entry itself (see D2), the same way `RecurringTemplateRepository.recordDueTemplate` does.

### D2 — Cross-repository dependencies: a fixed, one-directional graph

Traced from what each cluster's own methods actually call today (`_require*` private helpers, or a direct call to another cluster's public method):

```
Leaves (depend only on AppDatabase):
  AccountRepository, CategoryRepository, PayeeRepository, LedgerBackupRepository

One level up:
  IdentityRepository        -> AccountRepository
    (confirmFirstIdentity seeds the starter account groups)
  InvestmentRepository      -> AccountRepository, CategoryRepository
    (recordBuy validates the cash account and the buy/sell category)
  LedgerRepository (core)   -> AccountRepository
    (recordTransaction validates the financial account)

Top:
  RecurringTemplateRepository -> LedgerRepository (core)
    (recordDueTemplate posts through recordTransaction directly)
```

No cluster depends on `RecurringTemplateRepository`, `InvestmentRepository`, `IdentityRepository`, or `LedgerBackupRepository` — nothing sits above them, so this graph has no cycle by construction. A repository takes its dependency the same way `StatementImportRepository` already takes `LedgerRepository` today: a constructor parameter, wired by a `ProxyProvider2`/`ProxyProvider3` in `main.dart`.

### D3 — DI wiring stays inside `provider`'s existing `ProxyProvider` pattern

Each new repository gets its own `ProxyProvider<AppDatabase, X>` (or `ProxyProvider2`/`3` where D2 adds a dependency), mirroring `StatementImportRepository`'s existing registration. Every `ChangeNotifierProxyProvider<LedgerRepository, XViewModel>` that D1's table shows using only one cluster's methods narrows to that repository; a ViewModel spanning clusters (e.g. `HomeViewModel`: core + `RecurringTemplateRepository` + `InvestmentRepository`) takes each it needs, the same multi-dependency shape `ChangeNotifierProxyProvider2` already uses elsewhere in `main.dart`.

Net effect on `main.dart`: six new one-line `ProxyProvider` registrations; each existing `ChangeNotifierProxyProvider<LedgerRepository, X>` either narrows its generic parameter or gains a second/third one. No new pattern introduced.

### D4 — Sequencing: one repository extracted per task group, each a complete slice

Given the size (23 dependent files, ~76 methods), this lands as one task group per new repository rather than one atomic diff, but each group is a *complete* slice per Golden Rule #9: the methods move, every call site updates in the same group, the old methods are deleted from `LedgerRepository` in the same group, and the group's own tests pass before the next one starts. This is incremental delivery, not a compatibility window — there is never a moment where both the old and new home for a given method both exist.

Order (leaves first, matching D2's dependency graph, so nothing is extracted before what it depends on):
1. `AccountRepository` (leaf, and the most-depended-on by other new repositories)
2. `CategoryRepository`, `PayeeRepository`, `LedgerBackupRepository` (leaves, independent of each other and of step 1)
3. `IdentityRepository`, `InvestmentRepository` (depend on step 1, and step 2's `CategoryRepository` for Investment)
4. Slim `LedgerRepository` down to the core cluster, wiring in its new `AccountRepository` dependency
5. `RecurringTemplateRepository` (depends on the now-slimmed core repository from step 4)

### D5 — `showManagedDialog` owns controller lifecycle end to end

```dart
Future<T?> showManagedDialog<T>({
  required BuildContext context,
  required int controllerCount,
  required Widget Function(
    BuildContext dialogContext,
    List<TextEditingController> controllers,
  ) builder,
});
```

Creates `controllerCount` controllers, hands them to `builder`, awaits `showDialog`, and disposes the controllers only once the route has actually finished animating out (matching the fix already applied once in `account_management_view.dart`'s crash commit, generalized to a seam instead of a per-call-site workaround). Callers that need pre-filled text (e.g. rename dialogs) pass initial values; `showManagedDialog` sets them on the created controllers before invoking `builder`. All four affected views migrate their dialogs onto it in this change.

### D6 — `statement_import_view.dart` file split

One file per step widget under `lib/ui/features/statement_import/views/`: `choose_source_step.dart`, `pick_file_step.dart`, `select_account_step.dart`, `map_columns_step.dart`, `preview_step.dart`, `summary_step.dart` (folding in `_CategoryRuleManagementView`, since it's only reachable from the summary/app-bar action). `statement_import_view.dart` keeps `StatementImportView` itself — the `switch` that routes between steps — and shrinks to roughly 120 lines. Mechanical: each step widget is already self-contained: this is a `git mv`-plus-import-fix change, no logic touched.

## Risks / Trade-offs

- **[Risk] A slip while relocating core journal-posting code (`recordTransaction`, `_postProvisionalEntry`, etc.) corrupts the immutability/signing invariants (Golden Rule #6, #7).** → Mitigation: D4 sequences the core `LedgerRepository` extraction *after* every leaf repository, once the mechanical pattern (move methods + private helpers verbatim, update call sites, delete the old copy) is proven on lower-stakes clusters first. No logic is rewritten during the move, only relocated.
- **[Risk] `main.dart`'s provider graph is easy to get subtly wrong — a missed `ChangeNotifierProxyProvider` update silently leaves a ViewModel holding a stale/wrong-typed dependency.** → Mitigation: `flutter analyze` catches a type mismatch at the provider/ViewModel boundary immediately (constructor parameter types), so this fails loudly at compile time, not silently at runtime.
- **[Risk] The `acceptance-test-suite` branch (unmerged) constructs `LedgerRepository` and friends directly in its harness; this change will break that branch's build when the two are reconciled.** → Mitigation: called out explicitly in tasks.md as a follow-up task for whoever merges both, not silently absorbed here — out of this change's reach since that branch isn't visible from this one.
- **[Trade-off] Five task groups instead of one PR means `LedgerRepository` is in an intermediate, partially-slimmed state for several groups.** → Accepted: each intermediate state is itself fully consistent (Golden Rule #9's "complete slice," not a fork), and `flutter analyze`/the full test suite passes at the end of every group, not just the last one.

## Migration Plan

No data migration — no schema, table, or on-disk format changes. The "migration" here is purely a code move, sequenced per D4. Rollback for any one task group is a plain revert of that group's commit, since each group is independently consistent.

## Open Questions

- **Exact final class names** (`AccountRepository` vs `FinancialAccountRepository`, etc.) — the table above is a proposal; happy to rename before tasks.md locks them in.
- **`InvestmentRepository`'s boundary** wasn't traced as exhaustively as the other six (its ViewModel call-site audit wasn't run the way D1's table was for the others) — worth a quick confirmation pass at the start of that task group rather than assuming the review's method-name grouping is complete.
