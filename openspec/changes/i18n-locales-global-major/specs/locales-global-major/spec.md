## ADDED Requirements

### Requirement: Global Major Locales Supported
The app SHALL support UI locales Arabic (`ar`), Russian (`ru`), Indonesian (`id`), Turkish (`tr`), Vietnamese (`vi`), Thai (`th`), Malay (`ms`), Ukrainian (`uk`), Polish (`pl`), and Dutch (`nl`) via ARB files covering every English template key, including errors. Translations MAY be AI-generated for v1.

#### Scenario: User selects Arabic
- **WHEN** the user selects Arabic in the language picker
- **THEN** primary UI chrome and mapped errors resolve from `app_ar.arb`
- **AND** text direction is RTL
- **AND** missing keys fall back to English

#### Scenario: Cyrillic and Thai locales selectable
- **WHEN** the user opens the language picker
- **THEN** Russian, Ukrainian, and Thai are listed and can be activated
