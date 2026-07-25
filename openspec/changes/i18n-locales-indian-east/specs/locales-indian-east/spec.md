## ADDED Requirements

### Requirement: Eastern Indian Locales Supported
The app SHALL support UI locales Bengali (`bn`), Assamese (`as`), Odia (`or`), Manipuri (`mni`), Bodo (`brx`), and Santali (`sat`) via ARB files covering every English template key, including errors. Translations MAY be AI-generated for v1. Together with the other Indian locale packs, these complete India's 22 scheduled languages for UI purposes.

#### Scenario: User selects Bengali
- **WHEN** the user selects Bengali in the language picker
- **THEN** primary UI chrome and mapped errors resolve from `app_bn.arb`
- **AND** missing keys fall back to English

#### Scenario: All six eastern locales appear in the picker
- **WHEN** the user opens the language picker after this pack is shipped
- **THEN** Bengali, Assamese, Odia, Manipuri, Bodo, and Santali are listed as selectable locales
