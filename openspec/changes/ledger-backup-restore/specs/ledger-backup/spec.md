## Purpose

Let the user export an encrypted, restorable copy of the local ledger
database to a location they choose, and restore from it — a backup of
the books, distinct from recovery-phrase/keystore identity restoration.

## ADDED Requirements

### Requirement: User-Controlled Ledger Backup
The system SHALL let the user export an encrypted backup of the raw local ledger database file, passphrase-protected, to a file location they choose via the platform file saver. The backup SHALL include the `signing_identities` table (public keys and metadata only) so a restored ledger can be fully signature-verified without requiring a private key. The system SHALL NOT include any private key material in the backup.

#### Scenario: Export backup
- **WHEN** the user exports a ledger backup with a passphrase
- **THEN** an encrypted file is written to the location they chose
- **AND** the file contains no private key material

#### Scenario: Backup includes what verification needs
- **WHEN** a backup is exported
- **THEN** it includes the signing identities' public keys and metadata alongside the ledger data, so `verifyChain` can fully verify the restored chain

### Requirement: Restoring a Backup Replaces the Local Ledger
The system SHALL let the user restore a ledger from a valid encrypted backup file, replacing the local ledger database after an explicit confirmation naming what will be replaced. Restoring SHALL NOT merge the backup with existing local data. Restoring onto a device that already has an active signing identity different from the backup's SHALL be rejected with an explanation; restoring onto a device with no active identity yet SHALL adopt the backup's identity.

#### Scenario: Restore replaces books after confirmation
- **WHEN** the user restores from a valid backup and confirms the replacement
- **THEN** the local ledger's accounts, entries, and balances match the backup exactly
- **AND** the restored chain verifies successfully using the identities included in the backup

#### Scenario: Restoring a foreign identity onto a set-up device is rejected
- **WHEN** the user attempts to restore a backup whose active signing identity differs from the device's own active identity
- **THEN** the system rejects the restore and explains that this would combine two different identities' books rather than restore the user's own

#### Scenario: Restore onto a fresh device still needs the private key to record
- **WHEN** the user restores a backup onto a device with no prior identity
- **THEN** the restored ledger is readable and fully verified immediately
- **AND** recording a new entry is not possible until the matching private key is separately restored via recovery phrase or keystore
