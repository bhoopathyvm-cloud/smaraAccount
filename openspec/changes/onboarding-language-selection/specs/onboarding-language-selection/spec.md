## ADDED Requirements

### Requirement: Language is the first screen on first launch
The system SHALL show a language-selection screen on a user's very first
launch, before the currency-selection screen and before the signing identity
is committed. The screen SHALL list every supported app locale labeled by its
own native name (endonym), SHALL pre-select the locale the app currently
resolves to (the device locale if supported, otherwise English), and SHALL let
the user continue without changing anything.

#### Scenario: First launch opens on the language screen
- **WHEN** the app starts and no signing identity exists yet
- **THEN** the first screen shown is the language-selection screen, ahead of
  the currency-selection screen

#### Scenario: Each language shows its own name
- **WHEN** the language-selection screen is shown
- **THEN** every supported locale is labeled with its native-script name (e.g.
  "தமிழ்", "हिन्दी"), not only an English label

#### Scenario: Continuing without choosing keeps the current language
- **WHEN** the user proceeds from the language screen without selecting a
  different language
- **THEN** the app keeps the locale it already resolved to and moves on to the
  currency-selection screen

### Requirement: The chosen language applies immediately and persists
Selecting a language on the onboarding screen SHALL update the running app's
UI to that language before the next screen is shown, and SHALL be written
through the same persisted language preference that Settings uses
(`preferredLocaleTag` via `LocaleController`). No new preference key SHALL be
introduced.

#### Scenario: Rest of onboarding is in the chosen language
- **WHEN** the user selects a language on the onboarding screen and continues
- **THEN** the currency screen, first-account screen, guided first entry, and
  recovery-phrase acknowledgment are all shown in the chosen language

#### Scenario: Choice survives a restart
- **WHEN** the user selects a language during onboarding and later relaunches
  the app
- **THEN** the app starts in that language until it is changed again

#### Scenario: Settings reflects the onboarding choice
- **WHEN** the user opens Settings after choosing a language during onboarding
- **THEN** the Settings language picker already shows that language as the
  active selection

### Requirement: The language screen appears only during first-launch onboarding
The language-selection screen SHALL be part of the first-launch flow only.
After onboarding has completed, changing the app language SHALL remain the
responsibility of the existing Settings language picker, and the onboarding
language screen SHALL NOT be reachable.

#### Scenario: Not shown after onboarding
- **WHEN** a user who has completed onboarding navigates the app
- **THEN** the onboarding language screen is never shown; language changes go
  through Settings

#### Scenario: Re-entered if the app is killed before identity is committed
- **WHEN** the app is closed during onboarding before the signing identity is
  committed, then reopened
- **THEN** the language screen is shown again with the previously chosen
  language pre-selected, and continuing proceeds to the currency screen
