# key-loss-migration-engine

## Purpose

Leaf data-layer engine that performs true key-loss migration: re-signing
every active Journal Entry under a newly generated Signing Identity on a
fresh genesis hash chain, kept out of `IdentityRepository`.

## Requirements

### Requirement: Key-loss migration lives behind a leaf engine
The system SHALL re-sign every active Journal Entry under a newly generated Signing Identity on a fresh genesis hash chain - superseding the prior identity, continuing the unique `device_chain_sequence` counter, and appending a `KEY_MIGRATION_CONFIRMED` Integrity Event - through a `KeyLossMigrationEngine` that depends only on `AppDatabase`, `LedgerChainStore`, and `SigningKeyService`. `IdentityRepository` MUST NOT own the migration algorithm; it delegates its public `migrateToNewIdentityAfterKeyLoss` to the engine.

#### Scenario: Engine does not depend on Identity or Account repositories
- **WHEN** `KeyLossMigrationEngine` is constructed
- **THEN** its constructor takes only database, chain-store, and signing-key adapters (ADR 0002 leaf)

#### Scenario: The public migration seam is unchanged
- **WHEN** a caller invokes `IdentityRepository.migrateToNewIdentityAfterKeyLoss`
- **THEN** it returns the newly generated identity produced by `KeyLossMigrationEngine.migrate`, with the same supersede / re-sign / genesis-reset / integrity-event outcomes as before

### Requirement: Migration behavior preserved
Extracting the engine SHALL NOT change which entries are re-signed, the monotonic sequence continuation, the genesis hash reset, verification-cache rebuild, or the integrity-event record.

#### Scenario: Existing real-DB migration tests still pass
- **WHEN** the `migrateToNewIdentityAfterKeyLoss` repository tests run after the extraction
- **THEN** they pass without weakening assertions covering re-signing, summary exclusion of legacy entries, and post-migration chain verification
