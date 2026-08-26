## ADDED Requirements

### Requirement: Single register projection interface
The system SHALL compute register display rows (running balance, quarantine exclusion, split counterpart labels, fixability cues, and balance deltas) through one projection module. Both the Register UI and ledger CSV export MUST obtain row semantics from that module.

#### Scenario: UI and export share projection
- **WHEN** the Register view model builds rows and when CSV export builds entry rows for the same ledger state
- **THEN** both call the same projection interface rather than reimplementing counterpart/sign/quarantine rules separately

#### Scenario: Projection is testable without widgets
- **WHEN** unit tests exercise liability sign, quarantine exclusion, and split counterpart labeling
- **THEN** those tests call the projection module directly (no `WidgetTester` required)

### Requirement: Behavior parity unless a bug is fixed
Unifying projection SHALL preserve current Register UI outcomes. If export previously disagreed with the Register, the change MUST document the chosen semantics and cover them with a test.

#### Scenario: Register acceptance still passes
- **WHEN** register-related acceptance scenarios run after unification
- **THEN** they pass without scenario rewrites that weaken assertions
