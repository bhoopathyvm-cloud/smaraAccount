## ADDED Requirements

### Requirement: Displayed Calendar Dates Follow The UI Locale
Dates shown as household chrome (register rows, date-range chips, transfer/record date labels, holdings trade dates) SHALL use the active UI locale's date pattern. They SHALL NOT be formatted as a fixed `yyyy-MM-dd` string. Ledger **amounts** SHALL continue to follow each currency's conventions, not the UI locale.

#### Scenario: Register row date in Tamil locale
- **WHEN** the UI locale is Tamil and a register row is shown
- **THEN** the row's date is formatted with the Tamil/UI locale date pattern
- **AND** the amount on that row still uses the entry's currency formatting

### Requirement: App Title Follows The UI Locale
The window / task-switcher title SHALL come from `AppLocalizations` for the active locale (existing `appTitle` key or equivalent), not a hardcoded English `MaterialApp.title`.

#### Scenario: Title after choosing Tamil
- **WHEN** the user selects Tamil as the app language
- **THEN** the app title shown to the OS is the Tamil `appTitle` string

### Requirement: Biometric And System Permission Copy Follow The UI Locale
In-app biometric unlock prompts SHALL use the active UI locale. Platform permission usage strings (Face ID / Touch ID) SHALL have localized Info.plist entries for each supported app locale.

#### Scenario: Biometric sheet is not stuck on English
- **WHEN** the UI locale is Tamil and the lock screen offers biometrics
- **THEN** the reason string passed to the authenticator is the Tamil unlock reason
- **AND** it is not the English ARB value

### Requirement: Material Overlay Chrome Matches The UI Locale Or A Script Sibling
Date pickers, text-selection toolbars, and other Material/Cupertino overlay chrome SHALL use Flutter's locale pack when one exists for the UI language (including Tamil). For supported app locales that Flutter does not ship Material translations for, the system SHALL attach Material/Cupertino delegates for a documented script-sibling locale (Devanagari → Hindi, Perso-Arabic → Urdu) rather than leaving that chrome in English while ARB labels are translated. Locales with no honest sibling MAY keep English Material chrome.

#### Scenario: Tamil date picker chrome is Tamil
- **WHEN** the UI locale is Tamil and the user opens a date picker
- **THEN** the picker's action labels (OK/Cancel or equivalent) are Tamil Material localizations

#### Scenario: Sanskrit uses Hindi Material chrome
- **WHEN** the UI locale is Sanskrit (`sa`) and the user opens a date picker
- **THEN** the picker chrome uses Hindi Material localizations
- **AND** SMARA ARB labels on the rest of the screen remain Sanskrit
