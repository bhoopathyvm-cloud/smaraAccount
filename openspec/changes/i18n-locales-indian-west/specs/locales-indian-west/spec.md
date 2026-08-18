## ADDED Requirements

### Requirement: Western Indian Locales Supported
The app SHALL support UI locales Marathi (`mr`), Gujarati (`gu`), Konkani (`kok`), and Sindhi (`sd`) via ARB files covering every English template key, including errors. Translations MAY be AI-generated for v1. Sindhi v1 SHALL use Arabic script and RTL.

#### Scenario: User selects Marathi
- **WHEN** the user selects Marathi in the language picker
- **THEN** primary UI chrome and mapped errors resolve from `app_mr.arb`
- **AND** missing keys fall back to English

#### Scenario: Gujarati script visible
- **WHEN** the user opens a primary screen with locale `gu`
- **THEN** localized labels render in Gujarati script given bundled fonts

#### Scenario: Sindhi uses RTL and Arabic script
- **WHEN** the active locale is Sindhi
- **THEN** the app's text direction is RTL
- **AND** the language picker labels it سنڌي
