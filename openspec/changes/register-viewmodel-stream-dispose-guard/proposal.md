## Why

`RegisterViewModel._onAccounts` reads the category list with a one-shot
`_categoryRepository.watchCategories(includeArchived: true).first.then(...)`
(`lib/ui/features/register/view_models/register_view_model.dart:194`).
`Stream.first` throws `StateError: Bad state: No element` if the stream closes
without ever emitting. That happens whenever the Drift database is torn down
while the view model is still alive — backup restore (which closes the DB and
asks the user to relaunch) and app shutdown — and the resulting error is an
**unhandled asynchronous exception**, not something any caller can catch.

It surfaced in the Android acceptance run (`core_ledger_test.dart`, "record a
transaction through onboarding …") as:

> The following StateError was thrown running a test (but after the test had
> completed): Bad state: No element
> RegisterViewModel._onAccounts.<anonymous closure> (register_view_model.dart:194:75)

The test's own assertions had already passed; the late throw failed it anyway.
It reproduces intermittently because it depends on whether the categories
stream emits once before teardown wins the race.

## What Changes

- `RegisterViewModel` tracks its disposed state and stops applying async
  results after `dispose()`.
- The one-shot categories read tolerates an empty/closed stream instead of
  throwing — no categories simply means no category-name enrichment for that
  recompute.
- A unit test covers "accounts emit, then the view model is disposed and the
  categories stream closes empty" and asserts no exception escapes.

## Capabilities

### Modified Capabilities

- `register-projection`: the register view model's asynchronous reads
  complete quietly when the underlying repository streams close (on disposal
  or database teardown) rather than raising an unhandled error.

## Impact

- `lib/ui/features/register/view_models/register_view_model.dart`
- `test/ui/features/register/view_models/register_view_model_test.dart`
- No user-visible behaviour change in normal operation; this removes a
  late-teardown crash path.
