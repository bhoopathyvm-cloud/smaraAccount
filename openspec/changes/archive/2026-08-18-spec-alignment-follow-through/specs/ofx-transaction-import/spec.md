## ADDED Requirements

### Requirement: Skipped-Row Reasons Are Shown to the User
When OFX parsing reports one or more skipped rows, the system SHALL display each skipped row's reason to the user on the import flow before posting, not only a count of skipped rows. Displaying the reasons SHALL NOT block the user from continuing with the rows that parsed successfully.

#### Scenario: Skipped-row reasons are listed after a partial parse
- **WHEN** an otherwise-parseable OFX file contains one or more rows that cannot be parsed
- **THEN** the import flow shows each skipped row's reason
- **AND** the successfully parsed rows remain available for account matching and preview
