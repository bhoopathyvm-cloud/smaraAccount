## ADDED Requirements

### Requirement: Dravidian Locales Supported
The app SHALL support UI locales Tamil (`ta`), Telugu (`te`), Malayalam (`ml`), and Kannada (`kn`) via ARB files that include every key present in the English template, including error and validation strings. Translations MAY be AI-generated for v1.

#### Scenario: User selects Tamil
- **WHEN** the user selects Tamil in the language picker
- **THEN** home, add spent/received, and error messages the user sees resolve from `app_ta.arb`
- **AND** any missing key falls back to English

#### Scenario: Script renders without tofu for sample screens
- **WHEN** the user opens Home and Add spent in each of `ta`, `te`, `ml`, and `kn`
- **THEN** localized labels are visible in the expected script (not replacement characters), given the bundled fonts

#### Scenario: Picker lists verified endonyms
- **WHEN** the user opens the language picker after this pack is shipped
- **THEN** Tamil, Telugu, Malayalam, and Kannada appear, each labeled with its native-script name (தமிழ், తెలుగు, മലയാളം, ಕನ್ನಡ)
