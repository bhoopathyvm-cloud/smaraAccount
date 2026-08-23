# locales-east-asian

## Purpose

UI locale pack for East Asian languages (Japanese, Simplified Chinese, Korean).

## Requirements

### Requirement: East Asian Locales Supported
The app SHALL support UI locales Japanese (`ja`), Simplified Chinese (`zh`), and Korean (`ko`) via ARB files covering every English template key, including errors. Translations MAY be AI-generated for v1. Traditional Chinese SHALL NOT be treated as Simplified Chinese: when Traditional is unsupported, those device locales SHALL resolve to English.

#### Scenario: User selects Japanese
- **WHEN** the user selects Japanese in the language picker
- **THEN** home, add spent/received, and error messages the user sees resolve from `app_ja.arb`
- **AND** missing keys fall back to English

#### Scenario: CJK glyphs render
- **WHEN** the user opens a primary screen in `ja`, `zh`, or `ko`
- **THEN** localized labels render with CJK glyphs (not tofu), given bundled or platform CJK fonts

#### Scenario: Traditional Chinese devices do not get Simplified
- **WHEN** the user follows the device language and the device locale is `zh_TW` or `zh_Hant` and Traditional Chinese is not supported
- **THEN** the app uses English
- **AND** it does not activate `zh`
