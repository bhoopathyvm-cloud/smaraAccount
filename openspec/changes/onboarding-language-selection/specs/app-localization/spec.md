## MODIFIED Requirements

### Requirement: Recovery Phrase Language Follows UI Locale Where a Standard Wordlist Exists
BIP39 recovery phrase generation and confirmation SHALL use the BIP39-standard wordlist matching the active UI locale, for the subset of supported locales that have an official BIP39 wordlist available to this app (French, Italian, Spanish, Portuguese, Japanese, Korean, Simplified Chinese). For every other non-English supported locale, recovery phrase generation and confirmation SHALL continue to use the English wordlist, and the system SHALL show the user an explicit, plain-language notice — before the recovery phrase is first generated — that it will be in English because no standard wordlist exists yet for their chosen language. English behaves exactly as before, with no notice shown.

#### Scenario: UI locale has an official BIP39 wordlist
- **WHEN** the active UI locale is French, Italian, Spanish, Portuguese, Japanese, Korean, or Simplified Chinese
- **THEN** the recovery phrase is generated and confirmed using that language's official BIP39 wordlist

#### Scenario: UI locale has no official BIP39 wordlist
- **WHEN** the active UI locale is any supported locale other than English or the seven listed above
- **THEN** the recovery phrase is generated and confirmed using the English wordlist
- **AND** the user sees an explicit notice, before the phrase is generated, stating that the recovery phrase will be in English

#### Scenario: English UI is unaffected
- **WHEN** the active UI locale is English
- **THEN** the recovery phrase is generated in English exactly as before this change, with no notice shown
