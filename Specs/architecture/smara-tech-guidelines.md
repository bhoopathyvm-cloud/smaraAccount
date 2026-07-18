# SmaraAccounting — Technical Guidelines

> Structure and discipline borrowed from an earlier project's guidelines
> document — the golden-rules format, the cleanup discipline, the layered
> testing strategy. None of that project's stack (Java, Spring Boot, Vue,
> Liquibase, PostgreSQL) applies. Everything below is written for Flutter /
> Dart, client-only, no server.

## The Golden Rules

```
1. Spec first — never implement behavior that isn't in an OpenSpec
    specs/<capability>/spec.md scenario. If it's not covered, stop and
    write the spec delta first.
2. Generate, then implement — use Drift's build_runner codegen for
    tables/DAOs. Never hand-write what codegen produces.
3. Test first — write a failing test (dart-add-unit-test /
    flutter-add-widget-test), then implement.
4. No print() — use a proper logging package. Nothing shipped writes to
    stdout directly.
5. No magic strings — direction (in/out), category type (income/expense),
    and similar fixed sets are enums, never raw strings compared by value.
6. No manual recorded-at — the system sets every entry's recorded-at
    timestamp automatically. Only the transaction date is user-supplied.
    No code path accepts a client-provided recorded-at.
7. Posted journal entries are immutable — no code path issues an UPDATE
    or DELETE against journal_entries or postings once a row exists.
    Corrections are always a new entry.
8. Zero tolerance for abandoned/vulnerable dependencies — check a
    package's last-publish date and open issues before adding it;
    don't add a second package that does what one already in pubspec.yaml
    already does.
9. Remove obsolete code — don't leave it behind.
    A change that replaces a widget, ViewModel, Repository method,
    Drift table/column, or dependency removes the old one in the same
    change.
    Exception: a documented compatibility window (reason, owner, expiry
    condition, cleanup task in the OpenSpec design.md) — not silence.
```

---

## Code Lifecycle & Cleanup Rules

Elaborates Golden Rule #9.

```
WHEN A CHANGE REPLACES:
  - a View, ViewModel, or Repository method
  - a Drift table, column, or query
  - a dependency

REMOVE THE OLD ONE IN THE SAME CHANGE.
  Not "later." Not "in a follow-up." The same change.
  A replaced method still called from one leftover call site is not
  "removed" — find the site, update it, delete the old method.
```

```
COMPATIBILITY WINDOW EXCEPTION

Old and new paths may coexist temporarily ONLY when the OpenSpec
design.md documents all four of:
  1. Reason        — why can't this be a single atomic change?
  2. Owner         — who is responsible for the cleanup?
  3. Expiry        — when/what condition removes the old path?
  4. Cleanup task  — a concrete tasks.md item, not a TODO comment

A compatibility window with no documented expiry is not a window,
it's a permanent fork. Don't create one.
```

```
WHAT STAYS, EVEN THOUGH IT LOOKS OLD:

  Applied Drift schema migrations — IMMUTABLE once shipped.
    A migration that no longer matches current model direction is not
    "obsolete code" — write a new migration for the next schema version,
    never edit an old one.

  Regression tests for retained behavior — a test isn't obsolete just
    because the code under test was refactored. Only delete a test
    when the behavior it covers no longer exists.
```

---

## Responsibility Boundaries

Applies the MVVM + Repository layering from `smara-architecture.md`.

### Views

```dart
// Views are lean. No business logic, no Repository calls.
// Listen to the ViewModel; render what it exposes.

class RegisterView extends StatelessWidget {
  const RegisterView({super.key, required this.viewModel});

  final RegisterViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return RegisterList(entries: viewModel.entries);
      },
    );
  }
}
```

- Use `flutter-build-responsive-layout` for adaptive layouts (phone vs. desktop).
- Use `flutter-fix-layout-issues` when debugging overflow/unbounded-constraint errors.
- Use `flutter-add-widget-preview` when adding a new UI component, so it previews in isolation before wiring it to a real ViewModel.

### ViewModels

```dart
// All UI state and orchestration lives here.
// Extends ChangeNotifier. Injected with Repositories via constructor.
// Never touches Drift directly — only calls Repository methods.
// Every public method gets a unit test.

class RegisterViewModel extends ChangeNotifier {
  RegisterViewModel({required LedgerRepository ledgerRepository})
      : _ledgerRepository = ledgerRepository;

  final LedgerRepository _ledgerRepository;

  List<JournalEntry> _entries = const [];
  List<JournalEntry> get entries => _entries;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    _entries = await _ledgerRepository.watchEntries().first;
    _isLoading = false;
    notifyListeners();
  }
}
```

### Repositories

```dart
// The only layer that talks to Drift.
// Exposes domain models, never Drift's generated row classes.
// A transaction's journal_entries + postings rows are written in a
// single Drift transaction — never committed separately.

class LedgerRepository {
  LedgerRepository({required AppDatabase database}) : _db = database;

  final AppDatabase _db;

  Stream<List<JournalEntry>> watchEntries() {
    // Drift reactive query — emits automatically on write.
  }

  Future<void> recordTransaction({
    required int amountMinor,
    required TransactionDirection direction,
    required CategoryId categoryId,
    required DateTime transactionDate,
  }) async {
    await _db.transaction(() async {
      // insert journal_entries row + two postings rows together
    });
  }

  Future<void> reverseEntry(JournalEntryId entryId) async {
    // insert a new entry with swapped debit/credit, referencing entryId
    // never UPDATE or DELETE the original row
  }
}
```

### Domain Models

- Immutable data classes. Prefer the `dart-use-primary-constructors` style
  for concise, immutable models.
- Use `dart-use-pattern-matching` (switch expressions / sealed classes) for
  closed sets like `TransactionDirection` (`in` / `out`) instead of string
  comparisons or nested `if`/`else` chains.

---

## Error Handling

```dart
// Domain exceptions, not raw Drift/SQLite exceptions, cross the
// Repository boundary.

class UnbalancedEntryException implements Exception {
  UnbalancedEntryException(this.message);
  final String message;
}

class ImmutableEntryModificationAttempt implements Exception {
  ImmutableEntryModificationAttempt(this.entryId);
  final JournalEntryId entryId;
}

// ViewModels catch domain exceptions and expose them as UI-facing state
// (e.g. an errorMessage getter) — never let a raw exception reach a View.
```

---

## Testing Rules

```
Structure: mirror lib/ under test/ and integration_test/
Naming:    <name>_test.dart

UNIT (dart-add-unit-test):
  Every Repository and ViewModel public method, every branch.
  Given/When/Then structure in comments.
  Mock Repository dependencies in ViewModel tests
    (dart-generate-test-mocks — mockito + build_runner).

WIDGET (flutter-add-widget-test):
  Every View: renders correct data for given state, responds to taps/
  input as expected (e.g. archived category absent from picker,
  running balance shown per row).

INTEGRATION (flutter-add-integration-test):
  Full user journeys, e.g.:
    - record money in → appears in register → balance updates
    - reverse a posted entry → original stays visible, new entry appears
    - archive a category → disappears from picker, stays visible in
      historical entries

COVERAGE (dart-collect-coverage):
  Generate an LCOV report. No fixed percentage gate yet — track the
  trend; don't let it silently drop.

STATIC ANALYSIS (dart-run-static-analysis):
  dart analyze must be clean before every commit — not discovered in
  review. Use dart fix --apply for mechanical fixes first.

BUG REGRESSION:
  Every bug found in development or use gets a permanent regression
  test near the code it covers. A test is only deleted once the
  behavior it covers no longer exists.
```

---

## Drift Schema Migration Rules

```
1. One schema version bump per logical change
   Good:  version 3 adds a column, version 4 adds an index
   Bad:   one version jump adds several unrelated tables/columns

2. Never edit a shipped migration
   Once a schema version has been released, its onUpgrade step is
   immutable. Add a new version instead — Drift's schema versioning
   assumes this.

3. Migrations change shape only, never business data
   All UUIDs and timestamps for domain rows (journal_entries,
   postings, etc.) are generated in Dart code at write time — never
   invented by a migration script.

4. journal_entries and postings are immutable at the schema level too
   A migration may add a column or index to these tables. It must
   never contain an UPDATE or DELETE against existing rows in them.

5. Test both paths before release
   - Fresh install: schemaVersion 0 → current, via onCreate
   - Upgrade: onUpgrade from every prior shipped version → current
   Both must succeed without error.

6. Comment every migration step — what and why, not just what.
```

---

## Definition of Done

### Feature Complete

- [ ] Behavior matches an OpenSpec `specs/<capability>/spec.md` scenario exactly — no undocumented drift
- [ ] Domain/Repository logic has unit tests covering all public methods and branches
- [ ] Every new/changed View has a widget test
- [ ] Multi-screen user flows have an integration test
- [ ] `dart analyze` is clean; `dart fix --apply` has been run
- [ ] No hardcoded strings for closed sets — enums used throughout
- [ ] No `print()` left in shipped code
- [ ] 3-color rule respected throughout — no ad hoc colors introduced
- [ ] Touch targets are minimum 44px height
- [ ] Obsolete widgets/ViewModels/Repository methods/dependencies this change replaces are removed, not left behind (Golden Rule #9)
- [ ] No code path updates or deletes a posted `journal_entries`/`postings` row

---

## Build Quality Gates

```
WRAPPERS / LOCKED VERSIONS
  Commit pubspec.lock. Use flutter pub get, not an ad hoc global
  pub — every contributor resolves the exact same dependency graph.

CENTRALIZED VERSIONS
  Dependency versions live in pubspec.yaml — not pinned differently
  per feature branch.

FORMATTING / STATIC ANALYSIS
  dart format and dart analyze run before committing, not discovered
  in review (dart-run-static-analysis).

ACCIDENTAL DEPENDENCY PREVENTION
  Don't add a package that duplicates something already in
  pubspec.yaml (e.g. a second HTTP client, a second state-management
  package) without removing the old one in the same change.

CI QUALITY GATES (once CI exists)
  flutter test and dart analyze run on every push. A red check
  blocks merge — it isn't advisory.
```
