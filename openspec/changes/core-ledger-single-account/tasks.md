> Note: this change is implementable and testable on its own, but per
> `ledger-integrity-signing/design.md`'s Migration Plan, do not cut a public
> release until that change's signing layer also lands — the two are meant
> to ship together, even though they're specified as separate changes.

## 1. Project Setup

- [x] 1.1 Create the Flutter project (`flutter create`) targeting macOS, iOS, Android, Windows
- [x] 1.2 Add dependencies: `drift`, `drift_flutter`, `provider`, `go_router`, `uuid` (`drift_flutter` supersedes the originally-planned `sqlite3_flutter_libs`, which pub.dev confirms is EOL/no-op as of 0.6.0 in favor of `drift_flutter`'s `driftDatabase()` cross-platform connection helper — verified at implementation time)
- [x] 1.3 Add dev dependencies: `drift_dev`, `build_runner`, `test`, `mockito`, `coverage`
- [x] 1.4 Set up `lib/` per `smara-architecture.md`'s project structure (`data/`, `domain/`, `ui/core/`, `ui/features/`)
- [x] 1.5 Configure `dart analyze` / `dart format` as pre-commit checks per `smara-tech-guidelines.md` (`tool/git-hooks/pre-commit`, installed via `git config core.hooksPath tool/git-hooks`)

## 2. Drift Schema

- [ ] 2.1 Define `accounts` table (id, name, type, archived_at, created_at) per `design.md`
- [ ] 2.2 Define `journal_entries` table (id, transaction_date, recorded_at, description, reverses_entry_id, created_at)
- [ ] 2.3 Define `postings` table (id, entry_id, account_id, amount_minor, line_number)
- [ ] 2.4 Implement `onCreate`: seed the single asset account + the starter Income/Expense category set per `design.md`'s "Starter category set" (Income: Salary, Other Income; Expense: Groceries, Rent/Mortgage, Utilities, Transport, Other Expense)
- [ ] 2.5 Run `build_runner` to generate Drift code; verify generated code compiles

## 3. Domain Models

- [ ] 3.1 Define `Account` domain model (id, name, type, archived) with `dart-use-primary-constructors` style
- [ ] 3.2 Define `TransactionDirection` enum (`in`, `out`) using `dart-use-pattern-matching` for any branching logic
- [ ] 3.3 Define `JournalEntry` and `Posting` domain models

## 4. Ledger Repository

- [ ] 4.1 Implement `watchEntries()` — reactive stream of the register, ordered by transaction date
- [ ] 4.2 Implement `watchCategories({includeArchived})` — for pickers (active only) vs. historical views (all)
- [ ] 4.3 Implement `recordTransaction(amountMinor, direction, categoryId, transactionDate)` — validates `amountMinor > 0` (throws `UnbalancedEntryException` and writes nothing if not), derives the two postings, stamps `recorded_at` automatically via `DateTime.now()`, writes entry + postings in one Drift transaction
- [ ] 4.4 Implement `reverseEntry(entryId)` — inserts a new entry with swapped posting amounts, `reverses_entry_id` set, as an independent action with no required follow-up
- [ ] 4.5 Implement `addCategory(name, type)`, `renameCategory(id, newName)`, `archiveCategory(id)`
- [ ] 4.6 Implement `watchSummary(dateRange)` — total income and total expense for the range
- [ ] 4.7 Confirm no `updateEntry`/`deleteEntry` method exists anywhere on the Repository's public API (immutability enforced by omission, per Golden Rule #7)

## 5. ViewModels

- [ ] 5.1 `RegisterViewModel` — exposes entries + running balance, calls `watchEntries()`
- [ ] 5.2 `RecordTransactionViewModel` — form state (amount, direction, category, date), calls `recordTransaction`
- [ ] 5.3 `CategoryManagementViewModel` — rename/add/archive actions
- [ ] 5.4 `SummaryViewModel` — date range selection, calls `watchSummary`
- [ ] 5.5 Wire domain exceptions (e.g. invalid amount) to an `errorMessage`-style getter on each ViewModel, per `smara-tech-guidelines.md` error handling rules

## 6. Views

- [ ] 6.1 `RegisterView` — list of entries with running balance, direction shown via icon/sign only (no color), per `smara-design-system.md`
- [ ] 6.2 `RecordTransactionView` — amount/direction/category/date form; category picker excludes archived categories
- [ ] 6.3 `SummaryView` — date range picker + income/expense totals
- [ ] 6.4 Category management screen (rename/add/archive), destructive "Archive" action styled per the design system's destructive-button pattern
- [ ] 6.5 Apply `flutter-build-responsive-layout` for phone vs. desktop layouts
- [ ] 6.6 Add widget previews for new screens via `flutter-add-widget-preview`
- [ ] 6.7 Wire `go_router` routes for register / record transaction / summary / category management

## 7. Testing

- [ ] 7.1 Unit tests (`dart-add-unit-test`) for every Repository method: money-in postings, money-out postings, zero/negative amount rejected, reversal linkage, archive filtering, summary totals
- [ ] 7.2 Unit tests for every ViewModel public method, mocking the Repository (`dart-generate-test-mocks`)
- [ ] 7.3 Widget tests (`flutter-add-widget-test`): archived category absent from picker, running balance renders per row, direction shown without color
- [ ] 7.4 Integration tests (`flutter-add-integration-test`): record money in → register/balance update; reverse a posted entry → original stays, new entry appears; archive a category → hidden from picker, visible in history
- [ ] 7.5 Generate coverage report (`dart-collect-coverage`)

## 8. Quality Gates

- [ ] 8.1 `dart analyze` clean, `dart fix --apply` run
- [ ] 8.2 Verify every scenario in `specs/core-ledger-single-account/spec.md` has a corresponding passing test
- [ ] 8.3 Run through the Definition of Done checklist in `smara-tech-guidelines.md`
