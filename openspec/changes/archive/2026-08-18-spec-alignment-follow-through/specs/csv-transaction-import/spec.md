## ADDED Requirements

### Requirement: Skipped-Row Reasons Are Shown to the User
When CSV parsing reports one or more skipped rows, the system SHALL display each skipped row's reason to the user on the import flow before posting, not only a count of skipped rows. Displaying the reasons SHALL NOT block the user from continuing with the rows that parsed successfully under the supplied mapping.

#### Scenario: Skipped-row reasons are listed after a partial parse
- **WHEN** an otherwise-parseable CSV file contains one or more rows that do not fit the mapped date format or amount convention
- **THEN** the import flow shows each skipped row's reason
- **AND** the successfully parsed rows remain available for preview and posting
