## REMOVED Requirements

### Requirement: Key-loss migration lives behind a leaf engine
**Reason**: Key-loss migration is no longer offered; books without their key continue under a new identity without re-signing (`device-continuation`).
**Migration**: None needed for users. Verification of entries already superseded by an earlier migration is kept by `ledger-integrity-signing`.

### Requirement: Migration behavior preserved
**Reason**: The engine is removed together with its only entry point.
**Migration**: Tests for legacy migrated books move to chain-verification tests that load a fixture database containing migrated entries.
