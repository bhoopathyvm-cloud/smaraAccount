## Why

`IdentityRepository` mixes Signing Identity lifecycle with a ~130-line true-key-loss migration algorithm (`migrateToNewIdentityAfterKeyLoss` + `_activeEntriesForMigration`) that supersedes the old identity, re-canonicalizes/re-signs every active Journal Entry onto a fresh genesis chain, and appends a `KEY_MIGRATION_CONFIRMED` Integrity Event. Architecture review cycle 18: extract a leaf `KeyLossMigrationEngine` next to `LedgerChainStore` / `LedgerChainVerifier` (ADR 0002-safe).

## What Changes

- Add `lib/data/repositories/key_loss_migration_engine.dart` with `KeyLossMigrationEngine.migrate()` and the private active-entries selection.
- Remove the migration algorithm from `IdentityRepository`; it constructs one engine and delegates its public `migrateToNewIdentityAfterKeyLoss`.
- Pure structural move: no behavior change, no new call sites, no DI change (engine is an internal collaborator like `LedgerPosting`).

## Capabilities

### New Capabilities
- `key-loss-migration-engine`: leaf module for re-signing active entries under a new identity on a fresh genesis chain after confirmed key loss.

### Modified Capabilities
- (none — migration product behavior unchanged)

## Impact

- New engine module; `IdentityRepository` slimmed and delegating.
- No `main.dart` change (constructed internally, optional `SigningKeyService` injection for tests).
- ADR 0002: engine depends only on `AppDatabase`, `LedgerChainStore`, `SigningKeyService` — a leaf below `IdentityRepository`, closes no cycle.
