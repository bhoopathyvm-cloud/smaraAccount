## MODIFIED Requirements

### Requirement: Statement import wizard state lives on StatementImportSession
The system SHALL keep statement-import wizard review state (preview rows, selection, categories, currency mismatch, skipped-row counts used for summary, accepted rows for posting) on `StatementImportSession`. `StatementImportViewModel` MUST orchestrate repository I/O and forward review mutations to the session rather than owning parallel row lists.

#### Scenario: Preview mutations are unit-testable without a ChangeNotifier
- **WHEN** a test constructs a `StatementImportSession`, applies preview rows, toggles selection, and sets a group category
- **THEN** `acceptedRows` and `rowGroups` reflect those mutations with `package:test` alone

#### Scenario: Confirm import posts session accepted rows
- **WHEN** the ViewModel confirms import
- **THEN** it posts `session.acceptedRows` via the repository and advances the session to summary
