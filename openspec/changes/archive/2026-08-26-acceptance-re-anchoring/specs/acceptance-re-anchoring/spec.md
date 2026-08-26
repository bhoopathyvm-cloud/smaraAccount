## ADDED Requirements

### Requirement: Real-Build Coverage of Post-Quarantine Re-Anchoring
The system SHALL provide an acceptance test that drives a real launched build through the GUI to: record an entry, induce a detectable ledger tamper, restart into quarantine (lock badge on the tampered row), then record a second clean entry via the Register FAB flow. After that second entry, the tampered row SHALL still show the quarantine indicator and the new entry SHALL NOT.

#### Scenario: Second clean entry after quarantine does not carry the lock badge
- **WHEN** the acceptance test completes quarantine on restart and records a second transaction through the real Register FAB and record UI
- **THEN** the Register shows the lock indicator on the tampered historical row only, and the newly recorded row has no quarantine lock indicator

#### Scenario: Missing Register FAB after quarantine is treated as a defect to fix
- **WHEN** investigation finds the Register FAB absent or unfindable after the acceptance restart path
- **THEN** the change fixes the product UI and/or acceptance harness so the FAB is reliably available for the re-anchoring scenario, rather than skipping re-anchoring or recording via a repository backdoor
