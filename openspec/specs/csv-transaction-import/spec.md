# csv-transaction-import

## Purpose

Import bank/credit-card statement history from user-supplied CSV files via
an explicit, never-inferred column mapping (with reusable named profiles
for repeat imports from the same source layout), flowing through the same
review/dedupe/categorize/post pipeline `ofx-transaction-import` defines.
(Purpose derived from the `csv-transaction-import` change; refine as the
capability evolves.)

## Requirements

### Requirement: Parse CSV Statement Files via Column Mapping
The system SHALL parse a user-supplied CSV file into a normalized list of parsed transactions using an explicit, user-supplied column mapping: which column is the transaction date (with an explicit date format, never inferred), which column(s) supply the description, the amount convention (a single signed amount column, or separate debit and credit columns), and, optionally, which column supplies an external reference id. The system SHALL NOT attempt to guess column meaning from header text. The system SHALL assume the file's first row is a header row unless the user indicates otherwise, in which case columns SHALL be referenced positionally. A row that cannot be parsed under the supplied mapping SHALL be reported to the user as a skipped row with a reason, and SHALL NOT abort parsing of the remaining file. A file that cannot be read as CSV at all SHALL be rejected before any mapping or preview step.

#### Scenario: Parse a CSV file with a header row using a column mapping
- **WHEN** the user supplies a CSV file with a header row and maps its date, amount, and description columns
- **THEN** the system produces a parsed transaction for each data row using that mapping

#### Scenario: Parse a headerless CSV file using positional mapping
- **WHEN** the user indicates a selected file has no header row and maps fields to column positions instead
- **THEN** the system parses each row using those column positions

#### Scenario: A malformed row does not abort the file
- **WHEN** one row in an otherwise-parseable CSV file has a value that doesn't fit the mapped date format or amount convention
- **THEN** that row is reported to the user as skipped with a reason
- **AND** all other valid rows in the file still parse normally

#### Scenario: A file that isn't CSV at all is rejected
- **WHEN** the user selects a file that cannot be read as delimited CSV data
- **THEN** the system rejects the import before offering a column-mapping step

#### Scenario: The mapping screen previews parsed rows before committing
- **WHEN** the user has supplied a column mapping for a selected file
- **THEN** the system shows a preview of the first several rows parsed under that mapping, so the user can visually confirm the date format and amounts look correct before proceeding

### Requirement: Specify the File's Currency During Mapping
Since a CSV file has no embedded currency indicator, the system SHALL require the user to specify the file's currency as part of the column-mapping step, defaulting the suggestion to the target financial account's group currency when the target account is already known.

#### Scenario: Currency defaults to the target account's currency
- **WHEN** the user maps a CSV file and the target financial account is already selected
- **THEN** the currency field defaults to that account's group currency

#### Scenario: User overrides the suggested currency
- **WHEN** the user changes the defaulted currency during mapping
- **THEN** the parsed transactions carry the currency the user specified, not the account's default

### Requirement: Save and Reuse Import Profiles
The user SHALL be able to save a completed column mapping as a named, reusable profile. When a later CSV file's header row exactly matches a saved profile's stored header fingerprint, the system SHALL offer that profile as the default mapping, allowing the user to skip directly to the preview step. A file whose header row does not exactly match any saved profile SHALL NOT have a profile auto-selected, but every saved profile SHALL remain available for the user to select manually. The user SHALL be able to rename or delete a saved profile.

#### Scenario: Save a mapping as a named profile
- **WHEN** the user completes a column mapping for a file and chooses to save it with a name
- **THEN** a profile is created storing that file's header row as a fingerprint alongside the mapping

#### Scenario: A later file with matching headers offers the saved profile
- **WHEN** the user imports a new CSV file whose header row exactly matches a saved profile's fingerprint
- **THEN** the system offers that profile as the default mapping, and confirming it skips directly to the preview step

#### Scenario: A file with non-matching headers does not auto-select a profile
- **WHEN** the user imports a CSV file whose header row does not exactly match any saved profile's fingerprint
- **THEN** no profile is auto-selected
- **AND** the user can still choose a saved profile manually or map the file fresh

#### Scenario: Rename a saved profile
- **WHEN** the user renames a saved profile
- **THEN** the new name is used everywhere the profile is offered or selected

#### Scenario: Delete a saved profile
- **WHEN** the user deletes a saved profile
- **THEN** it is no longer offered or selectable for future imports

### Requirement: CSV Rows Flow Through the Shared Statement-Import Review and Posting Pipeline
Once parsed, CSV transaction rows SHALL be reviewed, duplicate-checked, categorized, and posted using the same account-matching, duplicate-detection, category-suggestion, and posting behavior `ofx-transaction-import` already defines for parsed transactions - no separate review or posting behavior exists for CSV-sourced rows.

#### Scenario: CSV rows appear in the same preview screen as OFX rows
- **WHEN** the user has parsed a CSV file into rows via a column mapping
- **THEN** those rows are shown in the same preview/review screen used for OFX-parsed rows, with the same duplicate-flagging, category-suggestion, and select/deselect behavior

#### Scenario: CSV rows are deduplicated using the shared reference-id-or-fallback logic
- **WHEN** a CSV file includes a mapped external-reference-id column
- **THEN** a repeat import of a row with the same reference id for the same financial account is flagged as a possible duplicate, exactly as a repeat OFX `FITID` would be

#### Scenario: CSV rows without a mapped reference id use the fallback match key
- **WHEN** a CSV file has no external-reference-id column mapped
- **THEN** duplicate detection falls back to the same (date, amount, direction, description) match key used for OFX rows lacking a `FITID`

### Requirement: Skipped-Row Reasons Are Shown to the User
When CSV parsing reports one or more skipped rows, the system SHALL display each skipped row's reason to the user on the import flow before posting, not only a count of skipped rows. Displaying the reasons SHALL NOT block the user from continuing with the rows that parsed successfully under the supplied mapping.

#### Scenario: Skipped-row reasons are listed after a partial parse
- **WHEN** an otherwise-parseable CSV file contains one or more rows that do not fit the mapped date format or amount convention
- **THEN** the import flow shows each skipped row's reason
- **AND** the successfully parsed rows remain available for preview and posting
