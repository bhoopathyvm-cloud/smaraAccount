## ADDED Requirements

### Requirement: East Asian Locales Supported
The app SHALL support UI locales Japanese (`ja`), Simplified Chinese (`zh`), and Korean (`ko`) via ARB files covering every English template key, including errors. Translations MAY be AI-generated for v1.

#### Scenario: User selects Japanese
- **WHEN** the user selects Japanese in the language picker
- **THEN** primary UI chrome and mapped errors resolve from `app_ja.arb`
- **AND** missing keys fall back to English

#### Scenario: CJK glyphs render
- **WHEN** the user opens a primary screen in `ja`, `zh`, or `ko`
- **THEN** localized labels render with CJK glyphs (not tofu), given bundled or platform CJK fonts
