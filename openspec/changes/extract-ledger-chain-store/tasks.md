## 1. Map

- [x] 1.1 Inventory `_chainState`, `_updateChainState`, `_upsertVerificationCache`, and identity lookup in posting vs identity; list callers
- [x] 1.2 Choose module path and interface (read tip, update tip, upsert cache; optional identity lookup)

## 2. Implement

- [x] 2.1 Add `LedgerChainStore` (or chosen name); construct from `AppDatabase`
- [x] 2.2 Switch `LedgerPosting` and `IdentityRepository` to the store; delete private copies
- [x] 2.3 Wire DI in `main.dart` if the store is shared; keep construction acyclic

## 3. Verify

- [x] 3.1 `dart analyze` clean; verify-chain / re-anchor / key-loss unit tests green
- [ ] 3.2 Spot-check integrity acceptance on macOS if chain writes moved
