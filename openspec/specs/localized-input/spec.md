# localized-input

## Purpose

TBD

## Requirements

### Requirement: Household Text Fields Follow The Selected Language
Name, payee, memo, description, and other household text fields SHALL accept the user's selected UI language script (including Tamil and other Indic scripts). Those fields SHALL NOT use input formatters that keep only Latin letters. ISO currency codes, PIN digits, BIP39 confirmation words, and ticker/ISIN fields MAY stay Latin-or-digit restricted.

#### Scenario: Tamil name is accepted in onboarding
- **WHEN** the UI locale is Tamil and the user types a Tamil account name into the first-account name field
- **THEN** the characters are kept
- **AND** saving stores that name as typed

#### Scenario: Currency code field stays Latin
- **WHEN** the user types into an ISO currency code field
- **THEN** only Latin letters are accepted
- **AND** the field does not request a Tamil keyboard hint

### Requirement: Input Method Hint Follows The Selected Language
Household text fields SHALL pass the active UI locale as an IME language hint (`TextField.hintLocales` or equivalent) so the platform can switch input language when it supports that hint. The system SHALL NOT require a restart after a language change for new fields to carry the new hint. The system SHALL NOT lock the device to a single keyboard layout (the user MAY still switch input sources).

#### Scenario: Language change updates IME hint without restart
- **WHEN** the user selects Tamil in Settings and then focuses a payee or account-name field
- **THEN** that field's IME hint includes the Tamil locale

#### Scenario: OS may ignore the hint
- **WHEN** the platform does not honor IME hints (typical desktop)
- **THEN** the field still accepts Tamil (or other) script if the user switches the OS keyboard
- **AND** the app does not crash or strip those characters

### Requirement: Unchanged System Names Appear Localized In Editors
When a text field is prefilled with a system-seeded account, group, or category name that still equals the original English seed, the field SHALL show the localized display name for the active locale. If the user saves without changing that displayed default, the system SHALL persist the original English seed so a later language switch still localizes. If the user types a different name, the system SHALL persist the typed name unchanged.

#### Scenario: First account field shows Tamil default
- **WHEN** the UI locale is Tamil and the seeded account is still named `Cash & Bank`
- **THEN** the first-account name field shows the Tamil label for that seed, not the English words `Cash & Bank`

#### Scenario: Saving the default does not freeze Tamil in the database
- **WHEN** the user continues without editing that localized default
- **THEN** the stored name remains the English seed
- **AND** switching the UI to another language shows that language's label

#### Scenario: Custom name is kept
- **WHEN** the user replaces the localized default with a name they typed
- **THEN** that typed name is stored and shown as-is in every locale

### Requirement: Placeholders And Inline Field Errors Match The Locale
Empty-field hints, helper text, and inline validation on text fields (including amount fields) SHALL come from `AppLocalizations` for the active locale. Hardcoded English literals such as `Enter a valid amount` SHALL NOT appear on those fields.

#### Scenario: Invalid amount error is Tamil
- **WHEN** the UI locale is Tamil and the user types a non-amount into an amount field
- **THEN** the field error is the Tamil ARB string for an invalid amount
- **AND** it is not the English sentence `Enter a valid amount`
