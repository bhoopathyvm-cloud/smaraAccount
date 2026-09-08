## ADDED Requirements

### Requirement: Calendar and stored-precision dates live in domain
The system SHALL format user transaction calendar dates as `YYYY-MM-DD` and truncate timestamps to Drift-stored second precision through a Flutter-free domain module. CSV export and repository posting MUST share that module rather than duplicating ISO formatting.

#### Scenario: CSV export uses domain dateOnly
- **WHEN** `buildLedgerCsv` writes a Date column
- **THEN** it formats via domain `dateOnly`, not a private exporter helper
