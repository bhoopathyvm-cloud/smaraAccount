## ADDED Requirements

### Requirement: Ledger CSV serialization lives behind a domain exporter
The system SHALL serialize register projection legs to CSV through a Flutter-free `buildLedgerCsv` module (field escaping, locale-independent amounts, oldest-first order, Verified column). `LedgerRepository.exportLedgerCsv` MUST load and project entries, then call that module rather than inlining serialization helpers.

#### Scenario: Comma in description is quoted
- **WHEN** a description contains a comma
- **THEN** the CSV field is double-quoted

#### Scenario: Amounts use period decimals
- **WHEN** exporting a USD amount
- **THEN** the Amount column uses a period decimal with no grouping separators
