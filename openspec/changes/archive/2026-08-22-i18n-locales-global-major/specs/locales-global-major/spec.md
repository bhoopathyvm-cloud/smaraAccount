## ADDED Requirements

### Requirement: Global Major Locales Supported
The app SHALL support UI locales Arabic (`ar`), Russian (`ru`), Indonesian (`id`), Turkish (`tr`), Vietnamese (`vi`), Thai (`th`), Malay (`ms`), Ukrainian (`uk`), Polish (`pl`), and Dutch (`nl`) via ARB files covering every English template key, including errors. Translations MAY be AI-generated for v1.

#### Scenario: User selects Arabic
- **WHEN** the user selects Arabic in the language picker
- **THEN** home, add spent/received, and error messages the user sees resolve from `app_ar.arb`
- **AND** text direction is RTL
- **AND** missing keys fall back to English

#### Scenario: Cyrillic and Thai locales selectable
- **WHEN** the user opens the language picker
- **THEN** Russian, Ukrainian, and Thai are listed and can be activated

#### Scenario: Device Arabic regional locale follows Arabic
- **WHEN** the user follows the device language and the device locale is `ar_EG` and `ar` is supported
- **THEN** the app uses Arabic and RTL

#### Scenario: Legacy Android Indonesian tag
- **WHEN** the user follows the device language and the device locale language code is `in` and `id` is supported
- **THEN** the app uses Indonesian (`id`)
