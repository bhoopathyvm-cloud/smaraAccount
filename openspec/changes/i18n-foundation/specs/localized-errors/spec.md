## ADDED Requirements

### Requirement: Domain Errors Are Language-Agnostic
Domain, repository, and statement-parser layers SHALL signal user-visible failures using stable error codes (or equivalent typed errors), not localized or English prose intended for display. Exception types MAY carry structured parameters (amounts, ids, currencies) needed to format a message. `Exception.toString()` MAY include the code and parameters for logs and tests but SHALL NOT be the string shown to the user.

#### Scenario: Repository rejects an invalid transfer
- **WHEN** `LedgerRepository` rejects a transfer for a business-rule violation
- **THEN** the thrown error exposes a stable error code (and any format parameters)
- **AND** the error does not require the UI to parse an English sentence to choose a translation

#### Scenario: Parser skip reasons are codes
- **WHEN** the OFX or CSV parser skips a row for a known reason
- **THEN** the skip is identified by a stable code
- **AND** the parser does not require the UI to parse an English sentence to choose a translation

### Requirement: UI Maps Error Codes to Localized Strings
The UI layer (views, or ViewModels given `AppLocalizations` / a mapper by the view) SHALL map each user-visible error code to a localized string, including interpolated parameters. Validation messages authored in ViewModels SHALL also use localization keys rather than hardcoded English. An unrecognized code SHALL produce a generic localized fallback message and SHALL NOT crash the screen.

#### Scenario: User sees a localized archive failure
- **WHEN** archiving the last active financial account fails with the corresponding error code
- **AND** the active locale has a translation for that error key
- **THEN** the user-visible message is the localized string for that key

#### Scenario: English locale error parity
- **WHEN** the active locale is English
- **THEN** mapped error text matches the English ARB values for those error keys

#### Scenario: ViewModel-authored validation message is localized
- **WHEN** a ViewModel rejects a form submission for a client-side validation reason it detects itself (not a Repository-thrown error), such as a missing required field
- **THEN** the displayed message comes from an `AppLocalizations` key for the active locale, not a hardcoded English string literal in the ViewModel

#### Scenario: Unknown error code does not crash
- **WHEN** the UI receives an error code with no ARB mapping
- **THEN** the user sees a generic localized failure message
- **AND** the screen remains usable
