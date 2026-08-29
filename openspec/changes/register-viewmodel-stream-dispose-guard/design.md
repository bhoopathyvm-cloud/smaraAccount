## Context

Found 2026-08-29 in the first-ever Android acceptance run (unblocked by
`android-compile-sdk-37`). `RegisterViewModel._onAccounts` runs on every
emission of the accounts stream and, each time, kicks off:

```dart
_categoryRepository.watchCategories(includeArchived: true).first.then((cats) {
  _categoriesById = {for (final c in cats) c.id: c};
  _recompute(_lastEntries);
});
```

`Stream.first` completes with `StateError('No element')` on an empty stream.
When a test (or a real backup restore) closes the Drift database, the
categories query stream closes without emitting, the pending `.first` future
errors, nothing is awaiting it, and it becomes an unhandled async error.

## Goals / Non-Goals

**Goals:**
- No unhandled exception when the view model outlives its repository streams.
- Keep the existing behaviour when the stream does emit.

**Non-Goals:**
- Reworking how the register loads categories (the one-shot-read-inside-a-
  stream-callback pattern is odd, but replacing it is a separate cleanup).
- A general "all view models are dispose-safe" audit — fix the one site with a
  demonstrated failure; note the pattern for others.

## Decisions

### 1. Guard with a disposed flag, not just an error catch

Catching the `StateError` alone would silence the symptom but still let a
disposed view model call `_recompute` / `notifyListeners`. Add a `_disposed`
bool set in `dispose()`; every async continuation returns early if it is set.
The empty-stream case additionally resolves to "no categories" rather than an
error.

### 2. `firstOrNull` semantics for the categories read

Use a read that yields `null`/`[]` on an empty stream instead of throwing
(e.g. `.cast<List<Category>?>().firstWhere((_) => true, orElse: () => null)`,
or `await for` with a fallback, or `package:collection`'s stream helper if
already available). An empty result means the recompute runs without category
names — acceptable for the one recompute that races teardown.

## Risks / Trade-offs

- **[Risk]** A real early-startup emission is genuinely empty and we now skip
  enrichment → **Mitigation:** `_onAccounts` re-runs on the next accounts
  emission and on the categories subscription elsewhere; a transient empty read
  self-heals.
- **[Trade-off]** One more `_disposed` check pattern in this file; small.

## Migration Plan

1. Add `_disposed` handling to `RegisterViewModel`.
2. Make the categories read tolerate an empty stream.
3. Unit test the teardown race.
4. Re-run `core_ledger_test.dart` on an Android device to confirm the late
   throw is gone.
5. Rollback = revert the file.

## Open Questions

- None. A broader dispose-safety sweep of other view models is worth a
  follow-up but is not required here.
