# statement-import-preview

## Purpose

TBD

## Requirements

### Requirement: Batched preview construction at one seam
The system SHALL build statement-import preview rows (duplicate flags, rule matches, suggested categories) through one module interface invoked by the statement-import ViewModel. The ViewModel MUST NOT loop transactions with per-row `await` suggestion calls for categorization.

#### Scenario: Single call builds preview
- **WHEN** the user reaches the import preview step with a parsed transaction list and active category rules
- **THEN** the ViewModel obtains the full preview row list from one repository/domain seam call

#### Scenario: Preview policy is unit-testable without widgets
- **WHEN** unit tests cover rule match precedence and suggestion fallback for a multi-row fixture
- **THEN** those tests exercise the preview module directly

### Requirement: Import outcomes unchanged
Batching preview SHALL NOT change which category is suggested or which rows are marked duplicate for a given fixture relative to pre-change behavior, except intentional bug fixes covered by tests.

#### Scenario: CSV and OFX acceptance still pass
- **WHEN** `tool/run_acceptance_tests.sh -d macos` runs the csv_import and ofx_import groups after the change
- **THEN** those groups pass
