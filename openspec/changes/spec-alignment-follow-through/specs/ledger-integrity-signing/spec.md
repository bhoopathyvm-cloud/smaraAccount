## ADDED Requirements

### Requirement: Migration-Superseded Entries Are Visibly Marked
A journal entry superseded by a true key-loss migration SHALL remain visible in the register and SHALL be marked as a historical, superseded record. The mark SHALL be distinct from the unverifiable/quarantine treatment used after a chain break. The superseded entry's amounts SHALL remain excluded from running balance and summary totals.

#### Scenario: A superseded entry is labeled in the register
- **WHEN** the user views the register after a true key-loss migration
- **THEN** each pre-migration entry is shown with a historical/superseded indication
- **AND** the entry is not hidden
- **AND** its amount is not included in the running balance
