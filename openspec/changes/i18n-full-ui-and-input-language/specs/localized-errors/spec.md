## ADDED Requirements

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
