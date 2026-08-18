## MODIFIED Requirements

### Requirement: User Guide Covers Every Shipped Feature
The repository SHALL contain a user guide at `docs/user-guide.md` that documents, in everyday words, every screen and flow currently reachable in the app, including Settings language (same as the phone vs pick a language), that recovery words stay English, that notes you typed and names you changed are not translated, that money still looks like `1234.56` with a code such as USD, and that the phone's spoken screen reader usually follows the phone's language, not the in-app choice. The guide SHALL NOT describe planned or proposed functionality that has not shipped. The guide SHALL use the same household words as the app (Spent, Received, Fix, Moved money) and SHALL NOT teach debit, credit, journal, or ledger vocabulary.

#### Scenario: Language setting is documented when reachable
- **WHEN** the language list is reachable in Settings
- **THEN** the user guide explains same-as-the-phone vs picking a language, that switching updates the running app, and what is not translated (typed notes, recovery words, how money looks in this version)
