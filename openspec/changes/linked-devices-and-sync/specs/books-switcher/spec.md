## Purpose

Let one device hold several fully separate sets of books and switch among
them, each with its own Signing Identity, Linked devices, and Books Copies
— a prerequisite for shared accounts and expense claims (project C).

## ADDED Requirements

### Requirement: Several Books Sets on One Device
The system SHALL allow a device to hold more than one books set at a time. Each set SHALL be fully separate: its own ledger database, Signing Identity (private key), Linked devices membership, shared settings, and Books Copies. Actions in one set SHALL NOT change another set's entries or keys.

#### Scenario: Second books set is independent
- **WHEN** the user creates or opens a second books set on a device that already has one
- **THEN** the second set has its own key and empty or restored books
- **AND** recording in the second set does not add entries to the first

#### Scenario: Books Copy is per set
- **WHEN** the user saves a Books Copy while one set is active
- **THEN** the copy contains only that set's books and books settings

### Requirement: Books Switcher UI
The system SHALL provide a books switcher that lists the device's books sets by user-visible name (for example "My household" and "Acme Ltd – travel") and lets the user switch the active set. After a switch, Home, Register, Settings for those books, Linked devices, and Sync now SHALL all refer to the newly active set.

#### Scenario: Switch changes what Home shows
- **WHEN** the user switches from books set A to books set B
- **THEN** Home and Register show set B's accounts and entries
- **AND** Linked devices lists set B's membership

#### Scenario: Names are user-visible
- **WHEN** the user opens the books switcher
- **THEN** each set is listed under the name the user gave it

### Requirement: One Database File Per Books Set
Each books set SHALL be stored as its own SQLite database file under the app support directory. The active books set id SHALL be stored in device preferences (SharedPreferences), not inside a single shared ledger file.

#### Scenario: Files are distinct on disk
- **WHEN** two books sets exist on the device
- **THEN** each has its own database file under the app support directory
- **AND** the active books id in device preferences selects which file the app opens

#### Scenario: Removing a set does not delete unrelated files
- **WHEN** the user removes one books set from the device
- **THEN** only that set's database file and its private key material are removed
- **AND** other sets remain usable
