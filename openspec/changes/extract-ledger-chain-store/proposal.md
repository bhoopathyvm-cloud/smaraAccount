## Why

`LedgerPosting` extracted signing writes, but `IdentityRepository` still owns a private clone of `_chainState` / `_updateChainState` / `_upsertVerificationCache` (and posting still privately looks up the current signing identity). Chain re-anchor and key-loss migration can drift — the leftover D1a tax sits on the integrity path.

## What Changes

- Extract an in-process `LedgerChainStore` module: read/update trusted tip, upsert verification cache.
- Give posting and identity a shared `SigningIdentityLookup` (or equivalent) so posting does not query `signing_identities` with a private copy of `currentIdentity`.
- Keep Identity → Account → Ledger acyclic: the store has no posting logic.
- Preserve existing verify-chain, re-anchor, and key-loss migration outcomes.

## Capabilities

### New Capabilities
- `ledger-chain-store`: shared chain-tip and verification-cache persistence used by posting and identity, without an Identity → Ledger cycle.

### Modified Capabilities
- (none — product integrity/re-anchoring/key-loss requirements unchanged)

## Impact

- `lib/data/repositories/ledger_posting.dart`, `identity_repository.dart`
- `lib/main.dart` DI if the store is constructed once
- Unit/INTEGRATION tests for verify-chain, re-anchor, and key-loss migration
- No Drift schema change; no ADR 0001 conflict
