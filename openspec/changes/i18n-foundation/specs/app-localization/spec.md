## ADDED Requirements

### Requirement: User-Facing Copy Lives in Localization Resources
All words the user can see — buttons, titles, empty states, tips, spoken labels, snackbars, dialogs, and import skip reasons — SHALL come from Flutter gen-l10n (`AppLocalizations`) backed by ARB files. English (`app_en.arb`) SHALL be the template and source of truth. Hardcoded English sentences SHALL NOT remain in views or ViewModels after this is implemented.

#### Scenario: Labels on English
- **WHEN** the app language is English
- **THEN** every main tab, dialog title, and action button is resolved via `AppLocalizations`
- **AND** the visible words match the English ARB values

#### Scenario: Missing translation falls back to English
- **WHEN** the chosen language is missing a key that exists in the English template
- **THEN** the app shows the English template words for that key

#### Scenario: Settings rate-source names are translated
- **WHEN** the user opens Settings and the rate-source list
- **THEN** each name the user sees comes from `AppLocalizations`, not a hardcoded enum string

### Requirement: User-Visible English Is Everyday Household Language
English ARB values, error messages, language-picker labels, unchanged default names, notes the app wrote, import skip reasons, Settings copy, and the translator glossary SHALL use everyday household words a person can follow without bookkeeping training. They SHALL NOT use debit, credit, journal, posting, ledger, financial account, reverse, archive, net position, money in, money out, or settlement as the words on screen. Internal code names MAY stay as they are.

The English dictionary SHALL match `household-language-voice`: **Spent** and **Received** (not Money in/out), **Add spent** / **Add received**, **Moved money**, **Fix**, **Hide from new entries**, **What you have minus what you owe**, **Money in transit**, **Account**, **Starting amount**, **Money arrived**, **Moving fee**, **Amount that didn't arrive**, **Moved to {name}**, **Same as the phone**, **Use this language**, **Recovery words**, **Something went wrong.**

#### Scenario: Add-money screen uses Spent and Received
- **WHEN** the user opens the add spent / add received screen in English
- **THEN** the direction labels are Spent and Received
- **AND** they are not Money in or Money out

#### Scenario: Fix is not called Reverse
- **WHEN** the user sees the action that corrects an already-saved line
- **THEN** the button or menu says Fix
- **AND** it does not say Reverse or Reversal

#### Scenario: Translator glossary uses household words
- **WHEN** a locale pack is translated from the glossary
- **THEN** the glossary lists Spent, Received, Fix, and Moved money (and the other household terms)
- **AND** it does not ask translators to translate journal entry, posting, or reversal as product words

### Requirement: Language Preference
The system SHALL let the user use the same language as the phone, or pick a language the app supports. Same-as-the-phone SHALL be the default and SHALL be a separate row from choosing English. The choice SHALL persist across app restarts in ordinary app preferences (not the secret key store). If the phone's language is not one the app supports, the app SHALL use English until a language pack adds it. Each language in the picker SHALL show that language's own name first, plus an English name, so someone who cannot read English can still find theirs and someone scanning a long list can still search in English.

#### Scenario: Default follows the phone when supported
- **WHEN** the user has not picked a language and the phone's language is one the app supports
- **THEN** the app uses that language

#### Scenario: Setup screens respect the language before an identity exists
- **WHEN** the user is still on the recovery-words setup screens and has not confirmed a signing identity
- **AND** same-as-the-phone or a chosen language is in effect
- **THEN** those screens still show translated chrome for the active language

#### Scenario: Choosing English ignores a supported phone language
- **WHEN** the user chooses English while the phone is set to a different supported language
- **THEN** the app stays in English until they change the choice

#### Scenario: Same as the phone is selectable
- **WHEN** the user opens the language list
- **THEN** a "Same as the phone" (or equivalent translated) row is listed separately from English

#### Scenario: A chosen language persists
- **WHEN** the user picks a supported language in Settings
- **THEN** later launches keep that language until they change it

#### Scenario: Language change applies immediately
- **WHEN** the user picks a different supported language
- **THEN** the running app updates to that language without restarting
- **AND** left-to-right vs right-to-left updates in the same refresh when needed

#### Scenario: Unsupported phone language
- **WHEN** the phone's language is not one the app supports
- **THEN** the app uses English

#### Scenario: Regional Chinese does not silently become Simplified
- **WHEN** the phone language is `zh_TW`, `zh_HK`, or `zh_Hant` and Traditional Chinese is not supported
- **THEN** the app uses English
- **AND** it does not switch to Simplified Chinese (`zh`) just because the language code is `zh`

#### Scenario: Regional Hindi uses Hindi
- **WHEN** the user has not picked a language and the phone is `hi_IN` and Hindi is supported
- **THEN** the app uses Hindi

#### Scenario: Chosen language later removed
- **WHEN** the stored language is no longer supported
- **THEN** the app drops that choice and behaves as same-as-the-phone, then English

#### Scenario: Picker shows each language's own name
- **WHEN** the user opens the language list
- **THEN** each language is labeled with its own script (e.g. "தமிழ்" for Tamil, "हिन्दी" for Hindi) plus an English name

#### Scenario: Picker is searchable once multiple languages exist
- **WHEN** more than one language is listed and the user opens the language list
- **THEN** they can filter by typing part of the native name or the English name

### Requirement: AI-Draft Locale Policy for v1
Follow-on language packs MAY ship AI-generated ARB translations of the household English template. The English template SHALL remain human-maintained. Linguistic polish and Crowdin (or equivalent) SHALL NOT be required to ship a language pack in v1.

#### Scenario: Language pack adds a language without human review gate
- **WHEN** a pack adds `app_<locale>.arb` generated by AI from the English template
- **THEN** that language may appear in the language list
- **AND** missing keys still fall back to English

### Requirement: Recovery Words Stay English
Recovery-word generation and confirmation SHALL keep using the English word list no matter which language the rest of the app is in.

#### Scenario: UI in a non-English language
- **WHEN** the user views or confirms recovery words while the app is not in English
- **THEN** those words are still the English recovery words

### Requirement: Numeric Amounts Are Not Locale-Reformatted in v1
Money on screen SHALL keep the existing `1234.56` style (dot, no grouping) in every language. Currency SHALL stay a short code such as USD or INR, not a local symbol or local grouping. A later change may change this; this change SHALL NOT.

#### Scenario: Amount formatting is the same in every language
- **WHEN** the user views any screen showing money, in any supported language
- **THEN** the amount looks like `1234.56`
- **AND** the currency is a code such as USD or INR, not a local symbol

#### Scenario: Amount digits stay left-to-right in a right-to-left language
- **WHEN** the app language is right-to-left and money is shown
- **THEN** the digits appear in the same left-to-right order as in English (e.g. `1234.56`, not reversed)

### Requirement: Unchanged Default Names Show Translated Household Labels
Default group names, starter category names, the starter account name, and the few internal names that appear in the list of lines, when they still match the original stored default, SHALL show the household translated label. Names the user changed SHALL be shown exactly as stored.

#### Scenario: Unchanged default group name
- **WHEN** a system group still has its original stored name and a translation exists
- **THEN** the UI shows the household label for the active language

#### Scenario: Unchanged starter account name
- **WHEN** the starter account still has its original stored name and a translation exists
- **THEN** the UI shows the household label for the active language

#### Scenario: User-renamed account or category
- **WHEN** the stored name differs from the original default
- **THEN** the UI shows the stored name without translation

### Requirement: Text the User Typed Is Never Translated
Notes the user typed, custom account and category names, and other words they entered SHALL be shown exactly as stored in every language. The system SHALL NOT run them through `AppLocalizations` or an AI translator.

#### Scenario: Custom note stays as typed
- **WHEN** the user saved a line with a typed note and later switches language
- **THEN** that note still appears exactly as typed

### Requirement: Notes the App Wrote Show Household Labels When Unchanged
A closed list of notes the app wrote that still equal their original stored English (`Opening balance`, `Settlement`, `Transfer fee / shortfall`) SHALL display as household labels: **Starting amount**, **Money arrived**, **Moving fee** / **Amount that didn't arrive**. A note the user edited, or that is not on that list, SHALL be shown as stored.

#### Scenario: Unchanged starting-amount note
- **WHEN** a saved line's note is still the app's starting-amount template
- **THEN** the list of lines shows Starting amount (translated) for the active language
- **AND** it does not show Opening balance as the on-screen words

#### Scenario: Moved-money counterpart label is household language
- **WHEN** the list of lines shows money moved to another account
- **THEN** the counterpart line uses a translated string such as Moved to {account name}
- **AND** it does not concatenate a hardcoded English `"Transfer: "` prefix

### Requirement: Import Skip Reasons Are Localized
Skip reasons on a bank-file preview SHALL be identified by stable codes from the parser and mapped to `AppLocalizations` in household English (then translated). They SHALL NOT be shown as hardcoded parser sentences.

#### Scenario: Skipped row shows a translated reason
- **WHEN** the import preview lists a skipped row and the active language has a translation for that reason
- **THEN** the visible reason is the translated household string for that code
