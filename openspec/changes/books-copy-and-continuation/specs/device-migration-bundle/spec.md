## REMOVED Requirements

### Requirement: Startup Setup Choice
**Reason**: The startup choice now offers "Restore from a copy" instead of importing a device migration bundle, and moves to `books-copy`.
**Migration**: See `books-copy` requirement `Startup Choice Between New Setup and Restore From a Copy`.

### Requirement: Device Migration Bundle Export
**Reason**: A file combining books and the private key is replaced by the Books Copy, which never contains a private key.
**Migration**: Use "Save a copy of my books" (`books-copy`).

### Requirement: Device Migration Bundle Import Restores a Working Identity Immediately
**Reason**: Importing a private key is removed; restored books continue under the device's own new identity.
**Migration**: "Restore from a copy" (`books-copy`) accepts existing bundle files, ignores their key, and continues via `device-continuation`.
