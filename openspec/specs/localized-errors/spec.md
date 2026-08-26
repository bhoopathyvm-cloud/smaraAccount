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

### Requirement: Import Skip Reasons Are Shown Localized
CSV and OFX skipped-row reasons SHALL be stored as stable codes (with structured fill-ins such as the raw date or pattern), not English sentences. The import preview SHALL map those codes through `AppLocalizations` for the active locale. The skipped row's raw fragment MAY remain as in the file.

#### Scenario: Tamil speaker sees a localized skip reason
- **WHEN** the UI locale is Tamil and a CSV row is skipped for a missing date
- **THEN** the skipped-rows list shows the Tamil message for that skip code
- **AND** it does not show the English sentence `Missing date.`

#### Scenario: Parser does not emit display English
- **WHEN** the CSV or OFX parser skips a row
- **THEN** the skip payload identifies a stable code
- **AND** the UI does not need to parse an English sentence to choose a translation

### Requirement: User-Visible Fill-Ins Are Not Raw Exception Text
When a localized error template has a fill-in placeholder, that fill-in SHALL be a structured value (amount, date, id, nested error code) or a generic household phrase. The UI SHALL NOT show `Exception.toString()` or other English debug text inside an otherwise translated message.

#### Scenario: Nested failure stays household language
- **WHEN** a transfer fee save fails with an unexpected exception and the UI locale is not English
- **THEN** the user-visible message does not include the exception's English `toString()`
- **AND** the screen still shows a localized generic or mapped failure

### Requirement: Every Failure Surface Uses The Localized Mapper
Every screen that can show a repository or validation failure, including first-week setup, SHALL map through `errorMessageFor` / `localizeCaughtError` (or equivalent) with the active `AppLocalizations`. Screens SHALL NOT display a ViewModel's English-only `errorMessage` to the user.

#### Scenario: First-week setup failure is localized
- **WHEN** first-week setup fails to create an optional account and the UI locale is Tamil
- **THEN** the message on that screen is Tamil
- **AND** it is not a raw English exception string
