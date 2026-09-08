## Why

`IdentityRepository` mixes Signing Identity lifecycle with a ~170-line chain walk (`verifyChain`). Callers that only need “is the journal trustworthy?” must learn Identity. Architecture review cycle 9: extract a leaf `LedgerChainVerifier` next to `LedgerChainStore` (ADR 0002-safe).

## What Changes

- Add `lib/data/repositories/ledger_chain_verifier.dart` with `verifyChain` and `ChainVerificationResult`.
- Remove chain walk from `IdentityRepository`.
- Wire `LedgerChainVerifier` in `main.dart`; update router, recovery/restore VMs, and backup verify path.
- Retarget tests from `identityRepository.verifyChain()` to the verifier.

## Capabilities

### New Capabilities
- `ledger-chain-verifier`: leaf module for full-chain hash/signature/link verification and tip/cache rebuild.

### Modified Capabilities
- (none — verification product behavior unchanged)

## Impact

- New verifier module; Identity slimmed
- `main.dart`, `app_router.dart`, recovery/restore VMs, `ledger_backup_repository.dart`
- Tests + mockito
- ADR 0002: Verifier depends only on AppDatabase + SigningKeyService + LedgerChainStore
