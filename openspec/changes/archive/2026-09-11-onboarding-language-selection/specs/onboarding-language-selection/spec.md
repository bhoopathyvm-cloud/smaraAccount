## ADDED Requirements

### Requirement: Language is the first screen on first launch, and a choice is required
The system SHALL show a language-selection screen on a user's very first
launch, before the currency-selection screen and before the signing identity
is committed. The screen SHALL list every supported app locale labeled by its
own native name (endonym), plus a "Same as device" option, and SHALL
pre-highlight the locale the app currently resolves to (the device locale if
supported, otherwise English). The system SHALL require the user to
explicitly select a row — confirming the pre-highlighted one counts — before
the Continue action is enabled; there is no way to proceed without making an
explicit selection.

#### Scenario: First launch opens on the language screen
- **WHEN** the app starts and no signing identity exists yet
- **THEN** the first screen shown is the language-selection screen, ahead of
  the currency-selection screen

#### Scenario: Each language shows its own name
- **WHEN** the language-selection screen is shown
- **THEN** every supported locale is labeled with its native-script name (e.g.
  "தமிழ்", "हिन्दी"), not only an English label

#### Scenario: Continue is disabled until a row is selected
- **WHEN** the language screen first appears and no row has been tapped yet
- **THEN** the Continue action is disabled

#### Scenario: Confirming the pre-highlighted language is a valid choice
- **WHEN** the user taps the already-highlighted (device-resolved) row
- **THEN** Continue becomes enabled and proceeding moves to the
  currency-selection screen in that language

#### Scenario: Choosing "Same as device" is a valid choice
- **WHEN** the user taps "Same as device"
- **THEN** Continue becomes enabled, the preference is written as the
  system-locale sentinel, and the app continues following the device locale

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
  language pre-highlighted; tapping it (still required, per the mandatory
  Continue rule above) proceeds to the currency screen

### Requirement: The currency screen's default follows the chosen language
Immediately after language selection, the currency-selection screen's
pre-filled currency SHALL be derived from a language→currency lookup keyed
on the chosen language, instead of an unconditional fixed default. This
default SHALL remain a plain pre-fill: the user MAY change it via the
existing quick-pick chips or free-text entry with no restriction. This
lookup applies only at this first-launch screen and is not re-applied if
the language is changed later via Settings.

#### Scenario: Currency screen pre-fills from the chosen language
- **WHEN** the user selects a language on the onboarding screen and
  continues to the currency screen
- **THEN** the currency screen's pre-filled value is that language's default
  currency, not an unconditional fixed default

#### Scenario: The default remains freely editable
- **WHEN** the currency screen shows a language-derived default
- **THEN** the user can still pick any quick-pick chip or type any 3-letter
  ISO 4217 code, exactly as before this change

### Requirement: Recovery phrase generation discloses its English fallback where no matching wordlist exists
Before the recovery phrase is first generated, if the chosen UI language is
not English and has no official BIP39 wordlist available to this app, the
system SHALL show the user an explicit, plain-language notice that their
recovery phrase will be in English, and why, before the phrase is
generated. Locales with an official BIP39 wordlist available to this app
SHALL NOT show this notice (see the corresponding `app-localization`
requirement for which locales those are).

#### Scenario: Notice shown for a locale without a BIP39 wordlist
- **WHEN** the chosen UI language is, for example, Tamil or Hindi
- **THEN** before the recovery phrase is generated, the user sees a notice
  that the recovery phrase will be in English

#### Scenario: No notice for a locale with a BIP39 wordlist, or for English
- **WHEN** the chosen UI language is French, Italian, Spanish, Portuguese,
  Japanese, Korean, Simplified Chinese, or English
- **THEN** no English-fallback notice is shown
