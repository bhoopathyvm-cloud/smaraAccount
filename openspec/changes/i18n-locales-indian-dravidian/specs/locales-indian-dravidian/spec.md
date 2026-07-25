## ADDED Requirements

### Requirement: Dravidian Locales Supported
The app SHALL support UI locales Tamil (`ta`), Telugu (`te`), Malayalam (`ml`), and Kannada (`kn`) via ARB files that include every key present in the English template, including error and validation strings. Translations MAY be AI-generated for v1.

#### Scenario: User selects Tamil
- **WHEN** the user selects Tamil in the language picker
- **THEN** primary UI chrome and mapped error messages resolve from `app_ta.arb`
- **AND** any missing key falls back to English

#### Scenario: Script renders without tofu for sample screens
- **WHEN** the user opens Home and Record Transaction in each of `ta`, `te`, `ml`, and `kn`
- **THEN** localized labels are visible in the expected script (not replacement characters), given the bundled fonts
