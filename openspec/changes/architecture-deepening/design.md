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
| `LedgerBackupRepository` | `exportLedgerBackup`, `restoreLedgerBackup` | Settings' backup/restore dialogs. **Corrected, not a true leaf** (caught during group 2 implementation): `restoreLedgerBackup` calls `LedgerRepository.currentIdentity()` to compare the device's active identity against the backup's, and constructs its own throwaway `LedgerRepository` (needing its own `SigningKeyService`, defaulted the same way `LedgerRepository` itself defaults one) wrapping a temp file to validate the backup's identity/chain before replacing the real database. Depends on `LedgerRepository` (core) — see D2 |
| `AccountRepository` | `createAccountGroup`, `renameAccountGroup`, `archiveAccountGroup`, `unarchiveAccountGroup`, `deleteAccountGroup`, `changeAccountGroupCurrency`, `backfillGroupCurrencies`, `needsCurrencyBackfill`, `reassignFinancialAccountGroup`, `createFinancialAccount`, `renameFinancialAccount`, `archiveFinancialAccount`, `unarchiveFinancialAccount`, `watchFinancialAccounts`, `watchAccountGroups`, `recordArchivedAccountCloseoutTransfer` | `AccountManagementViewModel` calls both the account-group *and* financial-account methods together — one repository, not two, contrary to the review's looser sketch. **Corrected caller audit** (see note below the table): also `RegisterViewModel`, `StatementImportViewModel`, `RecurringTemplateManagementViewModel`, `RecordTransactionViewModel`, `CorrectionViewModel`, `SettlePendingTransferViewModel`, `TransferViewModel`, `HoldingsViewModel`, `SummaryViewModel`, `FirstAccountNameViewModel`, `CurrencyBackfillViewModel`, `StatementImportRepository`, and `app_router.dart` directly (`needsCurrencyBackfill`) |
| `CategoryRepository` | `addCategory`, `archiveCategory`, `renameCategory`, `unarchiveCategory`, `setCategoryMonthlyLimit`, `watchCategories`, `watchCategoryTotals` | `CategoryManagementViewModel`. Corrected (re-audited via a multiline-safe grep sweep during group 2 implementation, which also caught `RegisterViewModel` missing from the original corrected list): also `RegisterViewModel`, `StatementImportViewModel`, `RecurringTemplateManagementViewModel`, `RecordTransactionViewModel`, `CorrectionViewModel`, `SettlePendingTransferViewModel`, `TransferViewModel`, `HomeViewModel`, `HoldingsViewModel`, `StatementImportRepository` |
| `PayeeRepository` | `createPayee`, `deletePayee`, `findOrCreatePayeeByName`, `renamePayee`, `recordPayeeUsage`, `watchPayees` | `PayeeManagementViewModel`. Corrected: also `RecordTransactionViewModel`, `StatementImportViewModel` |
| `RecurringTemplateRepository` | `createRecurringTemplate`, `deleteRecurringTemplate`, `updateRecurringTemplate`, `recordDueTemplate`, `watchRecurringTemplates`, `watchDueRecurringTemplates` | `RecurringTemplateManagementViewModel`, `HomeViewModel` |
| `InvestmentRepository` | `createInstrument`, `archiveInstrument`, `renameInstrument`, `cacheInstrumentQuote`, `recordBuy`, `recordSell`, `recordDividend`, `watchInstruments`, `watchHoldingsForAccount`, `watchInstrumentsHeldInAccount` | `HoldingsViewModel` (also needs `AccountRepository` and core `LedgerRepository` directly — see corrected caller note), `HomeViewModel` (`watchInstruments` only) |
| `LedgerRepository` (slimmed) | `recordTransaction`, `recordSplitTransaction`, `recordTransfer`, `settlePendingTransfer`, `reverseEntry`, `fixPostedTransaction`, `hasAnyJournalEntries`, `displayBalanceMinor`, `exportLedgerCsv`, `watchHomeOverview`, `watchSummary`, `watchEntries`, `watchEntriesForAccount`, `close` | `RegisterViewModel`, `SummaryViewModel`, `HomeViewModel`. Corrected: also `TransferViewModel`, `RecordTransactionViewModel`, `CorrectionViewModel`, `SettlePendingTransferViewModel`, `KeyLossMigrationViewModel` (`watchEntries`), `HoldingsViewModel` (`displayBalanceMinor`), `StatementImportRepository`, and `app_router.dart` directly (`hasAnyJournalEntries`) |

`recordArchivedAccountCloseoutTransfer` moves to `AccountRepository`, not the core repository, despite posting a transfer entry: closing out an *archived account* is fundamentally an account-lifecycle operation (it only exists to let `AccountRepository`'s own archive flow finish cleanly), and `RegisterViewModel` already calls it alongside other register-scoped account operations. It composes the core `LedgerRepository`'s transfer-posting for the entry itself (see D2), the same way `RecurringTemplateRepository.recordDueTemplate` does.

**Corrected caller audit (found during group 1's implementation).** The table above was originally built from a regex that missed multiline `_ledgerRepository\n  .method()` calls — a real gap, not a stylistic one. A full, multiline-safe re-audit of all 23 consumer files found:
- Six methods missing from every cluster's list above: `watchAccountGroups` (Account — turns out to be one of the most-called methods in the app), `watchCategoryTotals` (Category), `watchDueRecurringTemplates` (RecurringTemplate), `watchHoldingsForAccount` + `watchInstrumentsHeldInAccount` (Investment), `watchEntries` (Core).
- Two consumers not accounted for anywhere in the original design: `lib/ui/app_router.dart` calls `LedgerRepository` methods directly for its redirect guard (`currentIdentity`, `hasMatchingStoredKey`, `verifyChain` — Identity; `needsCurrencyBackfill` — Account; `hasAnyJournalEntries` — Core), so `buildAppRouter(...)`'s signature grows to accept `IdentityRepository` and `AccountRepository` alongside the existing `LedgerRepository`, cascading into `main.dart`'s call site. `lib/data/repositories/statement_import_repository.dart` — itself a repository, not a ViewModel — needs `AccountRepository` (`watchAccountGroups`, `watchFinancialAccounts`), `CategoryRepository` (`watchCategories`), and core `LedgerRepository` (`watchEntriesForAccount`, `recordTransaction`), growing from one dependency to four, the same cross-repository composition pattern already designed for `RecurringTemplateRepository`/`InvestmentRepository`.
- `HoldingsViewModel` needs `AccountRepository` (`watchFinancialAccounts`, `watchAccountGroups`) and core `LedgerRepository` (`displayBalanceMinor`) in addition to `InvestmentRepository` — three repositories, not one.

### D1a — Newly-public cross-repository helpers (found during group 1)

Two previously-private helpers turned out to be needed by a sibling repository across a file boundary and had to become public (no leading underscore) — Dart's leading-underscore privacy is per-*file*, not per-*class*, so a helper only `LedgerRepository`'s own methods used before now needs a real public name once a caller in a different file needs it:

- `LedgerRepository.appendSignedEntry` (was `_appendSignedEntry`) — the core signing/chaining/write primitive every posting method calls; stays in `LedgerRepository`, called by `AccountRepository`'s opening-balance posting through its `ledgerRepository` dependency.
- `LedgerRepository.postTransferEntry` (was `_postTransfer`) — stays in `LedgerRepository`, shared by `recordTransfer` (direct call, same class) and `AccountRepository.recordArchivedAccountCloseoutTransfer` (through its `ledgerRepository` dependency, per task 1.2).

**`_requireActiveFinancialAccount` and `_groupCurrencyFor` are duplicated, not moved or shared.** The obvious move — relocate both to `AccountRepository`, public, called by `LedgerRepository` through a new dependency — would make `LedgerRepository` depend on `AccountRepository` *and* `AccountRepository` depend on `LedgerRepository` (for `appendSignedEntry`/`postTransferEntry` above): a circular constructor dependency Dart cannot construct, since each class's constructor would require an already-built instance of the other. Found and corrected during task 1.4's implementation, not anticipated when D2 first called this graph one-directional. Each repository keeps its own private copy of these two small, read-only validation queries instead — the pragmatic trade against introducing a cycle, given both are read-only lookups with no risk of write-behavior divergence between the two copies.

`_requireCloseoutEligibleFinancialAccount` and `_postOpeningBalance` move to `AccountRepository` and stay private there — each has exactly one caller, both now inside the same file. The tiny pure `_dateOnly` formatter (used by nearly every posting method across every cluster) moves to a new shared `lib/data/repositories/repository_date_utils.dart` as a public top-level `dateOnly` function, rather than being duplicated per file — pure formatting with zero dependencies, unlike the two validation helpers above, so sharing it introduces no cycle risk.

### D2 — Cross-repository dependencies: a fixed, one-directional graph

Traced from what each cluster's own methods actually call today (`_require*` private helpers, or a direct call to another cluster's public method):

```
Leaves (depend only on AppDatabase):
  CategoryRepository, PayeeRepository, LedgerRepository (core)
    (LedgerRepository keeps its own private copies of the two validation
    helpers AccountRepository also needs - see D1a - rather than depending
    on AccountRepository, which would create a cycle)

One level up:
  AccountRepository -> LedgerRepository (core)
    (recordArchivedAccountCloseoutTransfer and the opening-balance post
    both call LedgerRepository's posting primitives - D1a)
  LedgerBackupRepository -> LedgerRepository (core)
    (restoreLedgerBackup compares against currentIdentity() - corrected,
    see the LedgerBackupRepository table row above; not the true leaf
    the original review sketch assumed)

Two levels up:
  IdentityRepository   -> AccountRepository
    (confirmFirstIdentity seeds the starter account groups)
  InvestmentRepository -> AccountRepository, CategoryRepository
    (recordBuy validates the cash account and the buy/sell category)

Top:
  RecurringTemplateRepository -> LedgerRepository (core)
    (recordDueTemplate posts through recordTransaction directly)
  StatementImportRepository   -> AccountRepository, CategoryRepository, LedgerRepository (core)
    (corrected caller audit: CSV/OFX import needs account/category pickers
    and posts through recordTransaction, same as it needs LedgerRepository
    today)

Not a repository, but the same graph applies:
  app_router.dart (buildAppRouter) -> IdentityRepository, AccountRepository, LedgerRepository (core)
    (its redirect guard reads currentIdentity/hasMatchingStoredKey/verifyChain,
    needsCurrencyBackfill, and hasAnyJournalEntries directly - corrected
    caller audit)
```

No cluster depends on `RecurringTemplateRepository`, `InvestmentRepository`, `IdentityRepository`, or `LedgerBackupRepository` — nothing sits above them, so this graph has no cycle by construction, and `LedgerRepository` never depends on `AccountRepository` (D1a explains why: it would close a cycle, since `AccountRepository` already depends on `LedgerRepository`). A repository takes its dependency the same way `StatementImportRepository` already takes `LedgerRepository` today: a constructor parameter, wired by a `ProxyProvider2`/`ProxyProvider3` in `main.dart`. `app_router.dart` isn't a class with a constructor — it takes the three repositories as extra positional parameters to `buildAppRouter(...)`, same as it already takes `LedgerRepository` and `StatementImportRepository` today.

### D3 — DI wiring stays inside `provider`'s existing `ProxyProvider` pattern

Each new repository gets its own `ProxyProvider<AppDatabase, X>` (or `ProxyProvider2`/`3` where D2 adds a dependency), mirroring `StatementImportRepository`'s existing registration. Every `ChangeNotifierProxyProvider<LedgerRepository, XViewModel>` that D1's table shows using only one cluster's methods narrows to that repository; a ViewModel spanning clusters (e.g. `HomeViewModel`: core + `RecurringTemplateRepository` + `InvestmentRepository`) takes each it needs, the same multi-dependency shape `ChangeNotifierProxyProvider2` already uses elsewhere in `main.dart`.

Net effect on `main.dart`: six new one-line `ProxyProvider` registrations; each existing `ChangeNotifierProxyProvider<LedgerRepository, X>` either narrows its generic parameter or gains a second/third one. No new pattern introduced.

### D4 — Sequencing: one repository extracted per task group, each a complete slice

Given the size (23 dependent files, ~76 methods), this lands as one task group per new repository rather than one atomic diff, but each group is a *complete* slice per Golden Rule #9: the methods move, every call site updates in the same group, the old methods are deleted from `LedgerRepository` in the same group, and the group's own tests pass before the next one starts. This is incremental delivery, not a compatibility window — there is never a moment where both the old and new home for a given method both exist.

Order (leaves first, matching D2's dependency graph, so nothing is extracted before what it depends on):
1. `AccountRepository` (leaf, and the most-depended-on by other new repositories)
2. `CategoryRepository`, `PayeeRepository` (leaves), `LedgerBackupRepository` (depends only on the core `LedgerRepository`, which has existed unslimmed since before step 1) — all three independent of each other and of step 1's `AccountRepository`
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
