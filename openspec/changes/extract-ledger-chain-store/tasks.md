## 1. Map

- [ ] 1.1 Inventory `_chainState`, `_updateChainState`, `_upsertVerificationCache`, and identity lookup in posting vs identity; list callers
- [ ] 1.2 Choose module path and interface (read tip, update tip, upsert cache; optional identity lookup)

## 2. Implement

- [ ] 2.1 Add `LedgerChainStore` (or chosen name); construct from `AppDatabase`
- [ ] 2.2 Switch `LedgerPosting` and `IdentityRepository` to the store; delete private copies
- [ ] 2.3 Wire DI in `main.dart` if the store is shared; keep construction acyclic

## 3. Verify

- [ ] 3.1 `dart analyze` clean; verify-chain / re-anchor / key-loss unit tests green
- [ ] 3.2 Spot-check integrity acceptance on macOS if chain writes moved
