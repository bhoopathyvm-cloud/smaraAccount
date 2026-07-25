## ADDED Requirements

### Requirement: European Locales Supported
The app SHALL support UI locales German (`de`), French (`fr`), Spanish (`es`), Italian (`it`), Portuguese (`pt`), Hungarian (`hu`), and Romanian (`ro`) via ARB files covering every English template key, including errors. Translations MAY be AI-generated for v1.

#### Scenario: User selects German
- **WHEN** the user selects German in the language picker
- **THEN** primary UI chrome and mapped errors resolve from `app_de.arb`
- **AND** missing keys fall back to English

#### Scenario: Portuguese uses a single locale tag
- **WHEN** Portuguese is selected
- **THEN** the active locale is `pt` (not a separate regional variant requirement in v1)
