# ledger-backup

## Purpose

Capability for ledger backup restore.

## Requirements

### Requirement: User-Controlled Ledger Backup
The system SHALL let the user export an encrypted backup of the ledger database to a file location they choose and restore from such a backup. Backup SHALL include ledger data; restoring signing identity remains via recovery phrase or keystore.

#### Scenario: Export backup
- **WHEN the user exports a ledger backup with a passphrase**
- **THEN** a file is written that can restore the ledger on another install

#### Scenario: Restore replaces books
- **WHEN the user restores from a valid backup**
- **THEN** ledger accounts entries and balances match the backup AND the user confirmed overwrite

