# statement-import-session

## Purpose

TBD

## Requirements

### Requirement: Import wizard session is a deep module
The system SHALL keep statement-import wizard step, CSV mapping draft, and transitions in a Flutter-free session module. The ViewModel MUST be a thin adapter over that module (subscribe, forward, expose snapshot), not the owner of mapping fields and step transitions.

#### Scenario: Session tests do not need widgets
- **WHEN** unit tests drive CSV mapping validity, step changes, and confirm-import preconditions
- **THEN** they call the session interface directly (no `WidgetTester`)

#### Scenario: Views stay free of repository calls
- **WHEN** the wizard UI renders
- **THEN** it still talks only to the ViewModel; preview/post remain on `StatementImportRepository`

### Requirement: Preview batching stays on the repository
This change SHALL NOT replace `buildPreviewRows`. The session calls that repository interface when a preview is needed.

#### Scenario: Preview still batched
- **WHEN** the session builds preview after mapping/account selection
- **THEN** it uses the existing `buildPreviewRows` seam (one batched suggestion pass)

### Requirement: Statement import wizard state lives on StatementImportSession
The system SHALL keep statement-import wizard review state (preview rows, selection, categories, currency mismatch, skipped-row counts used for summary, accepted rows for posting) on `StatementImportSession`. `StatementImportViewModel` MUST orchestrate repository I/O and forward review mutations to the session rather than owning parallel row lists.

#### Scenario: Preview mutations are unit-testable without a ChangeNotifier
- **WHEN** a test constructs a `StatementImportSession`, applies preview rows, toggles selection, and sets a group category
- **THEN** `acceptedRows` and `rowGroups` reflect those mutations with `package:test` alone

#### Scenario: Confirm import posts session accepted rows
- **WHEN** the ViewModel confirms import
- **THEN** it posts `session.acceptedRows` via the repository and advances the session to summary
