## MODIFIED Requirements

### Requirement: File import and export work under sandbox
The app SHALL retain the ability to open a user-selected file (OFX/CSV import) and save a file to a user-chosen location (CSV export, Books Copy) while sandboxed.

#### Scenario: Import still opens a file picker
- **WHEN** a user starts an OFX or CSV import on a sandboxed macOS build
- **THEN** the file-open dialog appears and the chosen file is read successfully

#### Scenario: Export and backup still save to a chosen location
- **WHEN** a user exports a CSV or saves a copy of the books on a sandboxed macOS build
- **THEN** the save dialog appears and the file is written successfully to the chosen location
