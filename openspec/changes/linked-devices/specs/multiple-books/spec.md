## Purpose

Let one device hold several fully separate sets of books, for example household books and a company's travel account, and switch between them.

## ADDED Requirements

### Requirement: Several Separate Sets of Books
A device SHALL be able to hold more than one set of books. Each set SHALL have its own name, entries, master data, Signing Identity, linked devices, Books Copies and books settings, and no data SHALL be shared between sets.

#### Scenario: Two sets stay separate
- **WHEN** a person records an entry in "My household"
- **THEN** it does not appear in "Acme Ltd – travel", and the two sets have different signing keys

### Requirement: Books Switcher
The system SHALL show which set of books is open and SHALL let the person switch to another set, create a new set, or join one by adding a device. App Lock and device settings SHALL apply to the whole app, not to each set.

#### Scenario: Switching books
- **WHEN** a person opens the books switcher and chooses "Acme Ltd – travel"
- **THEN** the app shows that set's Home, register and settings

#### Scenario: Creating a second set
- **WHEN** a person chooses "New books" in the switcher
- **THEN** a new, empty set is created with its own Signing Identity and starter categories, and the existing set is unchanged

### Requirement: Existing Books Become the First Set
On update, a device's existing books SHALL become its first set, unchanged and fully verified, named after the household by default.

#### Scenario: Update keeps existing books
- **WHEN** a device with existing books installs the version with the books switcher
- **THEN** its books open as the first set with every entry and balance unchanged
