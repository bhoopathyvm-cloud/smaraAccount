# internal-architecture

## Purpose

TBD

## Requirements

### Requirement: Repository Layering Preserves Existing Behavior
The system SHALL split `LedgerRepository` into one repository per domain concept (identity, ledger backup, accounts, categories, payees, recurring templates, investments) plus a slimmed core `LedgerRepository`, without changing any existing capability's observable behavior. No requirement or scenario in any other `openspec/specs/<capability>/spec.md` file changes as part of this split.

#### Scenario: Existing test suite preserves behavior
- **WHEN** the repository split is complete
- **THEN** every existing unit, widget, and integration test passes. Test files MAY retarget constructors and method receivers to the new repository types (the same mechanical call-site update production code receives); they MUST NOT change scenario assertions, expected values, or the behavior under test.

#### Scenario: No repository depends on one that isn't in its declared dependency graph
- **WHEN** any of the seven repositories is constructed
- **THEN** its constructor accepts only the dependencies design.md's D2 graph names for it, so no circular or undeclared cross-repository dependency exists

### Requirement: Dialog-Owned Text Controllers Survive Their Exit Animation
The system SHALL dispose a dialog's `TextEditingController`(s), created via `showManagedDialog`, only after the dialog route has finished animating out — not immediately when `showDialog`'s Future resolves.

#### Scenario: Closing a managed dialog never disposes its controller mid-animation
- **WHEN** a dialog created via `showManagedDialog` is dismissed (confirmed, cancelled, or backgrounded away from)
- **THEN** its `TextEditingController`(s) remain valid for every frame the dialog route's exit transition still renders, and no "A TextEditingController was used after being disposed" error is thrown

#### Scenario: Every existing managed-dialog call site is migrated
- **WHEN** `account_management_view.dart`, `statement_import_view.dart`, `recurring_template_management_view.dart`, or `register_view.dart` shows a dialog that owns a `TextEditingController`
- **THEN** it does so through `showManagedDialog`, not a hand-rolled `showDialog` + local controller pair

### Requirement: View Model Stream Listeners Are Teardown-Safe
A `ChangeNotifier` view model that subscribes to repository streams SHALL NOT,
after its `dispose()` has run, raise an unhandled error, call
`notifyListeners`, or read from a resource (such as a database connection) that
teardown may have closed. Where a stream listener is `async` and `await`s
mid-callback, the view model SHALL check a disposed flag after each `await`
before touching state, and SHALL attach an `onError` handler to each
subscription so a query that fails because the connection closed during
teardown is not surfaced as an unhandled asynchronous error.

#### Scenario: Emission resolves after dispose
- **WHEN** a repository stream delivers a value to an `async` view-model
  listener, the listener suspends at an `await`, and the view model is disposed
  before that `await` completes
- **THEN** nothing is thrown, no `notifyListeners` fires, and no read is made
  against the closed resource

#### Scenario: Stream errors during teardown are absorbed
- **WHEN** a subscribed repository query is in flight as the database
  connection closes (the view's own disposal, or an acceptance test's
  device reset) and the stream emits an error
- **THEN** the disposed view model absorbs it rather than letting it escape as
  an unhandled async error

#### Scenario: Errors while the view model is alive still surface
- **WHEN** a subscribed stream emits an error while the view model has not been
  disposed
- **THEN** the error is not swallowed
