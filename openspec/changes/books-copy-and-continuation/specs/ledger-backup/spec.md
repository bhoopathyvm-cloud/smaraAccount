## REMOVED Requirements

### Requirement: User-Controlled Ledger Backup
**Reason**: Ledger Backup and Device Migration Bundle merge into one Books Copy, which also carries settings.
**Migration**: Use "Save a copy of my books" (`books-copy`); existing ledger backup files remain restorable.

### Requirement: Restoring a Backup Replaces the Local Ledger
**Reason**: Superseded by `books-copy` restore, which no longer rejects a different identity and no longer requires a separately restored key.
**Migration**: Use "Restore from a copy" (`books-copy`), which replaces this device's books and continues them via `device-continuation`.
