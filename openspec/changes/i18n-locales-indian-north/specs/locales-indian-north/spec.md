## ADDED Requirements

### Requirement: Northern Indian Locales Supported
The app SHALL support UI locales Hindi (`hi`), Urdu (`ur`), Punjabi (`pa`), Nepali (`ne`), Sanskrit (`sa`), Dogri (`doi`), Kashmiri (`ks`), and Maithili (`mai`) via ARB files covering every English template key, including errors. Translations MAY be AI-generated for v1.

#### Scenario: User selects Hindi
- **WHEN** the user selects Hindi in the language picker
- **THEN** primary UI chrome and mapped errors resolve from `app_hi.arb`
- **AND** missing keys fall back to English

#### Scenario: Urdu uses RTL layout
- **WHEN** the active locale is Urdu
- **THEN** the app's text direction is RTL for Material widgets that respect locale directionality
