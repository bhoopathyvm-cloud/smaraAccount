## ADDED Requirements

### Requirement: User-Facing Copy Lives in Localization Resources
All user-visible UI chrome, validation messages, empty states, tooltips, semantics labels, snackbars, and dialog copy SHALL be provided through Flutter gen-l10n (`AppLocalizations`) backed by ARB files. English (`app_en.arb`) SHALL be the template and source of truth. Hardcoded user-facing English literals in views and ViewModels SHALL NOT remain after this capability is implemented.

#### Scenario: Localized label on an English locale
- **WHEN** the app runs with locale `en`
- **THEN** every primary navigation label, dialog title, and action button text is resolved via `AppLocalizations`
- **AND** the visible copy matches the English ARB template values

#### Scenario: Missing translation falls back to English
- **WHEN** the active locale lacks a key that exists in the English template
- **THEN** the system displays the English template value for that key

#### Scenario: Settings provider labels are localized
- **WHEN** the user opens Settings and the rate-provider dropdown
- **THEN** each provider's visible name comes from `AppLocalizations`, not a hardcoded enum string

### Requirement: Language Preference
The system SHALL allow the user to follow the device locale or override it by pinning a supported app locale. Follow-device SHALL be the default and SHALL be a distinct picker choice from pinning English. The preference SHALL persist across app restarts in ordinary app preferences (not secure storage). Unsupported device locales SHALL resolve to English until a locale pack registers them. Each supported locale SHALL be labeled in the language picker using that language's own native name (endonym) as the primary label, with a secondary Latin or English name, so a user who cannot read English can still recognize their own language and a user scanning a long list can still find it.

#### Scenario: Default follows device when supported
- **WHEN** the user has not pinned a language and the device locale's language code matches a supported app locale
- **THEN** the app uses that locale

#### Scenario: Onboarding respects the locale before an identity exists
- **WHEN** the user is still on the recovery-phrase onboarding screens and has not confirmed a signing identity
- **AND** follow-device or a pinned locale is in effect
- **THEN** those screens still resolve chrome through `AppLocalizations` for the active locale

#### Scenario: Pinning English ignores a supported device locale
- **WHEN** the user pins English while the device locale is a different supported language
- **THEN** the app stays in English until the pin or follow-device choice changes

#### Scenario: Follow-device is selectable in the picker
- **WHEN** the user opens the language picker
- **THEN** a "Use device language" (or equivalent localized) row is listed separately from English

#### Scenario: Manual override persists
- **WHEN** the user pins a supported language in settings
- **THEN** subsequent launches use that language until changed

#### Scenario: Language change applies immediately
- **WHEN** the user selects a different supported language in the language picker
- **THEN** the currently running app's UI updates to the new language without requiring a restart
- **AND** text direction updates in the same rebuild when the new locale is RTL or LTR

#### Scenario: Unsupported device locale
- **WHEN** the device locale is not in `supportedLocales` (including after language-code matching)
- **THEN** the app uses English

#### Scenario: Regional Chinese does not silently become Simplified
- **WHEN** the device locale is `zh_TW`, `zh_HK`, or `zh_Hant` and Traditional Chinese is not a supported app locale
- **THEN** the app uses English
- **AND** it does not activate Simplified Chinese (`zh`) solely because the language code is `zh`

#### Scenario: Language-code matching for a regional locale
- **WHEN** the user has not pinned a language and the device locale is `hi_IN` and `hi` is supported
- **THEN** the app uses Hindi (`hi`)

#### Scenario: Pinned locale later removed
- **WHEN** the stored pinned locale is no longer in `supportedLocales`
- **THEN** the app stops using that pin and resolves as an unpinned preference (device, then English)

#### Scenario: Picker shows each language's native name
- **WHEN** the user opens the language picker
- **THEN** each supported language is labeled with its own native-script name (e.g. "தமிழ்" for Tamil, "हिन्दी" for Hindi) as the primary label, plus a secondary Latin or English name

#### Scenario: Picker is searchable once multiple locales exist
- **WHEN** more than one app locale is registered and the user opens the language picker
- **THEN** the user can filter the list by typing part of the native name or the English/Latin name

### Requirement: AI-Draft Locale Policy for v1
Follow-on locale packs MAY ship AI-generated ARB translations. The English template SHALL remain human-maintained. Linguistic polish and Crowdin (or equivalent) SHALL NOT be required to ship a locale pack in v1.

#### Scenario: Locale pack adds a language without human review gate
- **WHEN** a locale pack change adds `app_<locale>.arb` generated by AI from the English template
- **THEN** the locale is eligible to be listed in `supportedLocales`
- **AND** missing keys still fall back to English

### Requirement: Recovery Phrase Language Unchanged
BIP39 recovery phrase generation and confirmation SHALL continue to use the English wordlist regardless of the UI locale.

#### Scenario: UI in a non-English locale
- **WHEN** the user views or confirms a recovery phrase while the UI locale is not English
- **THEN** mnemonic words remain English BIP39 words

### Requirement: Numeric Amounts Are Not Locale-Reformatted in v1
Ledger amounts SHALL continue to render using the existing fixed numeric-dot format (e.g. `1234.56`) regardless of the active UI locale. Currency labels SHALL continue to use ISO 4217 codes rather than locale-specific symbols or grouping/decimal conventions. This SHALL hold even after locale packs add non-English UI text, since reformatting amounts per locale is explicitly deferred past this change (a later change may supersede it).

#### Scenario: Amount formatting is locale-invariant
- **WHEN** the user views any screen showing a ledger amount, in any supported locale
- **THEN** the amount renders in the same fixed numeric-dot format used for the English locale
- **AND** the currency is shown as its ISO 4217 code, not a locale-specific symbol

#### Scenario: Amount digits stay left-to-right in an RTL locale
- **WHEN** the UI locale is RTL and a ledger amount is shown
- **THEN** the digits appear in the same left-to-right order as in English (e.g. `1234.56`, not a reversed digit run)

### Requirement: System Default Names Display Localized When Unchanged
System-seeded account group names, starter category names, the seeded starter financial account name, and the display names of Opening Balance Equity and Transfers in transit that still match their original seeded English defaults SHALL be displayed using localized labels when available. User-renamed values SHALL be shown exactly as stored.

#### Scenario: Unchanged system group name
- **WHEN** a system group still has its seeded default name and a localization key exists for it
- **THEN** the UI shows the localized label for the active locale

#### Scenario: Unchanged starter financial account name
- **WHEN** the seeded starter financial account still has its default name and a localization key exists for it
- **THEN** the UI shows the localized label for the active locale

#### Scenario: User-renamed account or category
- **WHEN** the stored name differs from the seeded default
- **THEN** the UI shows the stored name without translation

### Requirement: User-Authored Text Is Never Translated
User-typed journal descriptions, custom account and category names, and other user-authored strings SHALL be shown exactly as stored in every locale. The system SHALL NOT run them through `AppLocalizations` or an AI translator.

#### Scenario: Custom description stays verbatim
- **WHEN** the user recorded a transaction with a typed description and later switches UI language
- **THEN** that description still appears exactly as typed

### Requirement: System-Generated Journal Descriptions Localize When Unchanged
A closed list of repository-authored journal descriptions that still equal their original English template (e.g. opening balance, settlement, transfer fee / shortfall) SHALL be displayed using localized labels. A description the user edited or that is not on that list SHALL be shown as stored.

#### Scenario: Unchanged opening-balance description
- **WHEN** a journal entry's stored description is still the system opening-balance template
- **THEN** the register shows the localized opening-balance label for the active locale

#### Scenario: Transfer counterpart label is localized
- **WHEN** the register shows a transfer against another financial account
- **THEN** the counterpart line uses a localized string with the other account's display name as a placeholder
- **AND** it does not concatenate a hardcoded English `"Transfer: "` prefix

### Requirement: Import Skip Reasons Are Localized
User-visible statement-import skip reasons SHALL be identified by stable codes from the parser and mapped to `AppLocalizations` in the import UI, not displayed as hardcoded English sentences from the parser.

#### Scenario: Skipped OFX row shows a localized reason
- **WHEN** the import preview lists a skipped row and the active locale has a translation for that skip-reason code
- **THEN** the visible reason text is the localized string for that code
