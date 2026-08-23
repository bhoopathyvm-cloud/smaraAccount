# localized-errors

## Purpose

Domain failures use stable error codes; the UI maps those codes to household localized strings.

## Requirements

### Requirement: Domain Errors Are Language-Agnostic
Domain, repository, and statement-parser layers SHALL signal failures the user might see using stable error codes (or equivalent typed errors), not sentences meant for the screen. Exception types MAY carry structured parameters (amounts, ids, currencies) needed to fill in a message. `Exception.toString()` MAY include the code and parameters for logs and tests but SHALL NOT be the string shown to the user.

#### Scenario: Repository rejects invalid moved money
- **WHEN** `LedgerRepository` rejects moved money for a business-rule violation
- **THEN** the thrown error exposes a stable error code (and any fill-in parameters)
- **AND** the error does not require the UI to parse an English sentence to choose a translation

#### Scenario: Parser skip reasons are codes
- **WHEN** the OFX or CSV parser skips a row for a known reason
- **THEN** the skip is identified by a stable code
- **AND** the parser does not require the UI to parse an English sentence to choose a translation

### Requirement: UI Maps Error Codes to Localized Strings
The UI layer (views, or ViewModels given `AppLocalizations` / a mapper by the view) SHALL map each user-visible error code to a household localized string, including fill-in parameters. Validation messages written in ViewModels SHALL also use localization keys rather than hardcoded English. An unrecognized code SHALL produce a generic everyday message such as "Something went wrong." and SHALL NOT crash the screen.

#### Scenario: User sees a translated hide-account failure
- **WHEN** hiding the last account they still use fails with the corresponding error code
- **AND** the active language has a translation for that error key
- **THEN** the message is the translated household string for that key
- **AND** it does not say archive or financial account

#### Scenario: English error wording matches the household ARB
- **WHEN** the active language is English
- **THEN** mapped error text matches the English ARB values for those error keys
- **AND** those values use everyday household words (see app-localization household-language requirement)

#### Scenario: ViewModel-authored validation message is localized
- **WHEN** a ViewModel rejects a form because of a missing required field it detected itself (not a Repository-thrown error)
- **THEN** the displayed message comes from an `AppLocalizations` key for the active language, not a hardcoded English string in the ViewModel

#### Scenario: Unknown error code does not crash
- **WHEN** the UI receives an error code with no ARB mapping
- **THEN** the user sees a generic everyday message such as "Something went wrong."
- **AND** the screen remains usable
