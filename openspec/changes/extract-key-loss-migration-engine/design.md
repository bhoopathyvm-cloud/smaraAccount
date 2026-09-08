## Decisions
1. Structure, not behavior. The algorithm moves verbatim: same identity
   supersede/insert, same monotonic `device_chain_sequence` continuation
   with a genesis hash reset, same per-entry re-canonicalize/re-sign,
   verification-cache upsert, chain-state update, and
   `KEY_MIGRATION_CONFIRMED` Integrity Event.
2. The engine is an internal collaborator of `IdentityRepository`,
   constructed inline (lazy `late final`) like `LedgerRepository` builds
   `LedgerPosting` - not an app-wide provider, so no second DI mechanism.
3. `IdentityRepository.migrateToNewIdentityAfterKeyLoss` stays the public
   seam every caller (and every test) already uses; it now delegates to
   `KeyLossMigrationEngine.migrate()`. Existing real-DB migration tests
   verify the extraction through that seam unchanged.
4. ADR 0002: the engine takes only `AppDatabase`, `LedgerChainStore`, and
   `SigningKeyService` (all leaves), so it sits below `IdentityRepository`
   and re-closes no construction cycle.
