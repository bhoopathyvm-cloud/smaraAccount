## ADDED Requirements

### Requirement: Repository Layering Preserves Existing Behavior
The system SHALL split `LedgerRepository` into one repository per domain concept (identity, ledger backup, accounts, categories, payees, recurring templates, investments) plus a slimmed core `LedgerRepository`, without changing any existing capability's observable behavior. No requirement or scenario in any other `openspec/specs/<capability>/spec.md` file changes as part of this split.

#### Scenario: Existing test suite passes unmodified
- **WHEN** the repository split is complete
- **THEN** every existing unit, widget, and integration test passes without any test file being modified to accommodate the split

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
