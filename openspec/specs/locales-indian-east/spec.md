# locales-indian-east

## Purpose

UI locale pack for Eastern Indian languages (Bengali, Assamese, Odia, Manipuri, Bodo, Santali).

## Requirements

### Requirement: Eastern Indian Locales Supported
The app SHALL support UI locales Bengali (`bn`), Assamese (`as`), Odia (`or`), Manipuri (`mni`), Bodo (`brx`), and Santali (`sat`) via ARB files covering every English template key, including errors. Translations MAY be AI-generated for v1. Together with the other Indian locale packs, these complete India's 22 scheduled languages for UI purposes. Odia SHALL use language code `or`. Manipuri v1 SHALL use Meitei Mayek when a font is available. Santali v1 SHALL use Ol Chiki when a font is available.

#### Scenario: User selects Bengali
- **WHEN** the user selects Bengali in the language picker
- **THEN** home, add spent/received, and error messages the user sees resolve from `app_bn.arb`
- **AND** missing keys fall back to English

#### Scenario: All six eastern locales appear in the picker
- **WHEN** the user opens the language picker after this pack is shipped
- **THEN** Bengali, Assamese, Odia, Manipuri, Bodo, and Santali are listed as selectable locales

#### Scenario: Rare-script endonyms
- **WHEN** the user opens the language picker after this pack is shipped with Meitei Mayek and Ol Chiki fonts available
- **THEN** Manipuri is labeled ꯃꯩꯇꯩꯂꯣꯟ and Santali is labeled ᱥᱟᱱᱛᱟᱲᱤ
