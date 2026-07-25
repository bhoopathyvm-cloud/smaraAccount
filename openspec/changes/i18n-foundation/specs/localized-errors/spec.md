## ADDED Requirements

### Requirement: Domain Errors Are Language-Agnostic
Domain and repository layers SHALL signal user-visible failures using stable error codes (or equivalent typed errors), not localized or English prose intended for display. Exception types MAY carry structured parameters (amounts, ids, currencies) needed to format a message.

#### Scenario: Repository rejects an invalid transfer
- **WHEN** `LedgerRepository` rejects a transfer for a business-rule violation
- **THEN** the thrown error exposes a stable error code (and any format parameters)
- **AND** the error does not require the UI to parse an English sentence to choose a translation

### Requirement: UI Maps Error Codes to Localized Strings
The UI layer (views or ViewModels with access to `AppLocalizations`) SHALL map each user-visible error code to a localized string, including interpolated parameters. Validation messages authored in ViewModels SHALL also use localization keys rather than hardcoded English.

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
