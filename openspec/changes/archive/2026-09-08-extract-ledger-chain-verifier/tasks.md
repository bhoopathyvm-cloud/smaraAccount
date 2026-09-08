## 1. Extract module

- [x] 1.1 Add `ledger_chain_verifier.dart` with `verifyChain` + `ChainVerificationResult`
- [x] 1.2 Remove walk from `IdentityRepository`

## 2. Wire callers

- [x] 2.1 Register Verifier in `main.dart`; update router + recovery/restore VMs + backup
- [x] 2.2 Retarget tests; regenerate mocks

## 3. Verify

- [x] 3.1 analyze + focused tests green
- [x] 3.2 Full macOS acceptance
