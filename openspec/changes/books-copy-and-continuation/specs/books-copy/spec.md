## Purpose

Let a person save one passphrase-protected copy of their books and restore it on this or any device, for backup, for moving to a new phone, or for giving a copy to someone. The copy never contains a private key, so no one has to manage a key.

## ADDED Requirements

### Requirement: Books Copy Contents
A Books Copy SHALL be a single passphrase-encrypted file containing the complete ledger data (every entry and all master data such as accounts, categories, account groups, payees, category rules, import profiles, recurring templates and investment data), the public signing identities needed to verify every entry, and the books' settings (settings that affect the books' numbers, such as reference rates, quote provider and default exchange). It SHALL NOT contain device settings: app language, display preferences, research tool, App Lock (PIN, biometrics and idle-timeout settings) and backup-reminder state. A Books Copy SHALL NOT contain any private key material.

#### Scenario: A saved copy holds books, public identities and settings
- **WHEN** a Books Copy is saved and then decrypted with the correct passphrase
- **THEN** it yields the ledger data, the signing identities' public keys and metadata, and the books' settings
- **AND** it contains no private key material and no device settings (app language, display preferences, research tool, App Lock, reminder state)

#### Scenario: A copy can be fully verified without a private key
- **WHEN** a Books Copy is opened for restore
- **THEN** every entry's hash, chain link and signature can be checked using only the public identities inside the copy

### Requirement: Save a Copy of My Books
The system SHALL let the user save a Books Copy from Settings, labeled "Save a copy of my books", at any time, protected by a passphrase they choose, to a location they choose. Saving a copy SHALL NOT be required to keep using the app, and SHALL record when the copy was saved and how many entries existed, for the backup reminder.

#### Scenario: Saving writes one encrypted file to a chosen location
- **WHEN** the user chooses "Save a copy of my books", enters a passphrase and picks a location
- **THEN** one encrypted Books Copy file is written there
- **AND** the time of the save is recorded as the last copy saved

#### Scenario: A blank passphrase is refused
- **WHEN** the user tries to save a copy with an empty or whitespace-only passphrase
- **THEN** the save is refused with the same passphrase message used everywhere else and no file is written

### Requirement: Startup Choice Between New Setup and Restore From a Copy
On first launch, before any signing identity is generated or any account is created, the system SHALL present the user an explicit choice between New setup and "Restore from a copy".

#### Scenario: New setup proceeds as ordinary first-time onboarding
- **WHEN** the user chooses New setup
- **THEN** a signing identity is generated automatically, and the user is guided to name a first account and record a first transaction, with no acknowledgment screen or other block following

#### Scenario: Restore from a copy gives immediately usable books
- **WHEN** the user chooses "Restore from a copy" and restores a valid Books Copy or legacy backup file
- **THEN** the user lands directly in their restored, fully verified books, continued under this device's own new identity and ready to record new entries, without going through guided first-account or first-transaction onboarding

### Requirement: Restore From a Copy Is Offered Before and After Setup
The system SHALL offer "Restore from a copy" both on the first-launch screen (before any setup) and in Settings (on a device already in use), so that a person who chose New setup, or whose phone arrived with the app pre-installed, can still bring in their books.

#### Scenario: Restore offered on first launch
- **WHEN** the app is launched for the first time
- **THEN** the first-launch screen offers "Restore from a copy" alongside New setup

#### Scenario: Restore offered in Settings after New setup
- **WHEN** a user who already completed New setup opens Settings
- **THEN** "Restore from a copy" is available there

### Requirement: Restoring Replaces This Device's Books
Restoring a Books Copy SHALL replace this device's books and the books' settings entirely, and SHALL leave the device settings (app language, display preferences, research tool, App Lock, reminder state) unchanged; it SHALL NOT merge them with existing local data. When the device already has data, the system SHALL first show a warning stating that all entries and the books' settings on this device will be replaced, listing the counts of what will be replaced (entries, categories, accounts, payees, category rules, recurring templates, instruments and any other master data with a non-zero count), and offering "Save a copy first", which saves a Books Copy of the current books before continuing. The restore SHALL proceed only after explicit confirmation.

#### Scenario: Warning lists what will be replaced
- **WHEN** the user starts "Restore from a copy" in Settings on a device holding 3 entries, 5 categories and 2 accounts
- **THEN** a warning states that all entries and the books' settings on this device will be replaced and shows "3 entries, 5 categories, 2 accounts"
- **AND** nothing is replaced until the user confirms

#### Scenario: Save a copy first before replacing
- **WHEN** the user taps "Save a copy first" on the warning
- **THEN** a Books Copy of the current books is saved through the normal save flow, and the user returns to the warning to confirm or cancel

#### Scenario: Restore replaces rather than merges
- **WHEN** the user confirms the restore
- **THEN** afterwards the device's entries, master data and books' settings match the copy exactly, and none of the device's previous entries remain

#### Scenario: Device settings are kept
- **WHEN** a device set to German, with App Lock on, restores a copy saved on a device set to English
- **THEN** the app is still in German and App Lock is still on with the same PIN after the restore

#### Scenario: No warning on an empty device
- **WHEN** the user restores from the first-launch screen on a device with no books
- **THEN** no replacement warning is shown

### Requirement: A Copy That Fails Verification Is Refused Completely
Before replacing anything, the system SHALL verify the whole copy: the passphrase, the file format, and every entry's hash, chain link and signature against the public identities in the copy. If any check fails, the restore SHALL be refused with a plain explanation, and the device's existing books, settings and key SHALL remain exactly as they were.

#### Scenario: Wrong passphrase leaves the device untouched
- **WHEN** the user restores a copy with an incorrect passphrase
- **THEN** the restore is refused and no local data, settings or key material changes

#### Scenario: A tampered copy is refused
- **WHEN** the user restores a copy in which any entry was altered after it was signed
- **THEN** the system shows "This copy couldn't be verified and wasn't restored" and the device's books are unchanged

### Requirement: Older Backup Files Are Still Accepted
"Restore from a copy" SHALL accept files saved by earlier versions of the app as a ledger backup or a device migration bundle. Any private key material inside a legacy device migration bundle SHALL be ignored and never stored.

#### Scenario: A legacy device migration bundle restores without its key
- **WHEN** the user restores a device migration bundle saved by an earlier version
- **THEN** its books are restored and verified like any Books Copy
- **AND** the private key inside the file is discarded and the device continues under its own new key

#### Scenario: A legacy ledger backup restores
- **WHEN** the user restores a ledger backup saved by an earlier version
- **THEN** its books are restored and verified like any Books Copy, with the device's current settings kept because the legacy file contains none

### Requirement: Restore Ends in Continuation and Explains the Other Device
After a successful restore, this device SHALL continue the restored books under its own new Signing Identity (see `device-continuation`), so new entries can be recorded immediately. The success screen SHALL explain that entries recorded later on the device the copy came from will not appear on this device, and that bringing them over later means saving a new copy there and restoring it here, which replaces this device's books.

#### Scenario: Restored books are immediately usable
- **WHEN** a restore succeeds
- **THEN** the user lands in the restored, verified books and can record a new transaction without any further key step

#### Scenario: Success screen explains the other device
- **WHEN** a restore succeeds
- **THEN** the success screen says that later entries made on the other device won't appear here and how to bring them over

#### Scenario: The other device is not blocked
- **WHEN** a copy saved on device A is restored on device B
- **THEN** device A keeps working normally and nothing on device A changes
