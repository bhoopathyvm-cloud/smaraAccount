## MODIFIED Requirements

### Requirement: User Guide Covers Every Shipped Feature
The repository SHALL contain a user guide at `docs/user-guide.md` that documents, in end-user terms, every screen and flow currently reachable in the app, including Settings language preference (follow device vs pin a language), that BIP39 recovery words stay English, that typed descriptions and renamed accounts are not translated, that amounts stay in the existing numeric-dot format in this change, and that TalkBack/VoiceOver typically follow the phone language rather than the in-app picker. The guide SHALL NOT describe planned or proposed functionality that has not shipped.

#### Scenario: Language setting is documented when reachable
- **WHEN** the language picker is reachable in Settings
- **THEN** the user guide explains follow-device vs pinning a language, that switching updates the running app, and what is not translated (typed text, recovery words, amounts in this version)
