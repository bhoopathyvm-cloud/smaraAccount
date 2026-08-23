# locales-european

## Purpose

UI locale pack for European languages (German, French, Spanish, Italian, Portuguese, Hungarian, Romanian).

## Requirements

### Requirement: European Locales Supported
The app SHALL support UI locales German (`de`), French (`fr`), Spanish (`es`), Italian (`it`), Portuguese (`pt`), Hungarian (`hu`), and Romanian (`ro`) via ARB files covering every English template key, including errors. Translations MAY be AI-generated for v1.

#### Scenario: User selects German
- **WHEN** the user selects German in the language picker
- **THEN** home, add spent/received, and error messages the user sees resolve from `app_de.arb`
- **AND** missing keys fall back to English

#### Scenario: Portuguese uses a single locale tag
- **WHEN** Portuguese is selected, or the device locale is `pt_BR` or `pt_PT` and the user is following the device language
- **THEN** the active locale is `pt` (not a separate regional variant requirement in v1)
