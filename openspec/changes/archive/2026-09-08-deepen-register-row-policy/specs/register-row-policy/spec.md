## ADDED Requirements

### Requirement: Register fixability and filter live behind one domain module
The system SHALL decide whether a register row is Fixable and which rows match search/date/direction filters through Flutter-free helpers. `RegisterViewModel` MUST forward to those helpers.

#### Scenario: Only single-category verified rows are fixable
- **WHEN** a row has exactly one counterpart that is a category, is verified, not a reversal, not superseded, and not already reversed
- **THEN** `isRegisterRowFixable` is true; transfers, splits, reversals, and quarantined rows are false

#### Scenario: Search matches description, category, or amount text
- **WHEN** filter query is non-empty
- **THEN** rows whose description, category name, or provided amount text contain the query (case-insensitive) remain

### Requirement: Existing register behavior preserved
Extracting the policy SHALL NOT change Fix eligibility or filter results.

#### Scenario: Existing register ViewModel tests still pass
- **WHEN** `register_view_model_test.dart` runs after the migration
- **THEN** it passes without weakening assertions
