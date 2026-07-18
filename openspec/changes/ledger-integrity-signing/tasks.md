> Note: coordinate schema delivery with `core-ledger-single-account` —
> per `design.md`'s Migration Plan, these two changes' Drift schema work
> should land as one schema version, not a retrofit migration after the
> fact.

## 1. Dependencies

- [ ] 1.1 Add a crypto package providing Ed25519 sign/verify and SHA-256 (e.g. `cryptography`)
- [ ] 1.2 Add `flutter_secure_storage` for private-key storage (Keychain/Keystore/DPAPI)
- [ ] 1.3 Add a BIP-39-style mnemonic package (or vendor a wordlist) for recovery-phrase generation/derivation

## 2. Drift Schema Extensions

- [ ] 2.1 Extend `journal_entries` with `device_chain_sequence`, `previous_entry_hash`, `entry_hash`, `signed_by_identity_id`, `signature`, `migrated_from_entry_id` per `design.md`
- [ ] 2.2 Add `signing_identities` table (public key only — never the private key)
- [ ] 2.3 Add `entry_verification_cache` table (derived, rebuildable)
- [ ] 2.4 Add `ledger_chain_state` singleton table (derived, rebuildable)
- [ ] 2.5 Add `integrity_events` append-only table
- [ ] 2.6 Run `build_runner`; verify generated code compiles

## 3. Signing Identity Lifecycle

- [ ] 3.1 Generate Ed25519 key pair on first launch, before any `journal_entries` row (including seeded starter accounts) is created
- [ ] 3.2 Store the private key exclusively in secure storage; write the public key to `signing_identities`
- [ ] 3.3 Implement recovery-phrase generation that deterministically derives the same key pair
- [ ] 3.4 Implement encrypted keystore file export (passphrase-protected) as an alternative/additional backup format
- [ ] 3.5 Implement import: recovery phrase or keystore file → re-derive key pair → compare against an existing `signing_identities.public_key` to confirm a match

## 4. Onboarding UI

- [ ] 4.1 Recovery-phrase display screen with explicit consequences messaging (loss of device + phrase = unrecoverable chain)
- [ ] 4.2 Require confirmation (e.g. re-enter a subset of words) before the ledger becomes usable
- [ ] 4.3 Optional keystore file export screen
- [ ] 4.4 "Restore from recovery phrase / keystore file" entry point for reinstall/new-device setup

## 5. Canonical Hashing and Signing

- [ ] 5.1 Implement canonical serialization of entry content (fields + ordered postings) per the `entry_hash` formula in `design.md`
- [ ] 5.2 Implement genesis handling (well-defined constant previous hash for the first entry, not an arbitrary null)
- [ ] 5.3 Extend `LedgerRepository.recordTransaction` and `reverseEntry` (from `core-ledger-single-account`) to compute `entry_hash`, sign it with the current identity, assign `device_chain_sequence`, and update `ledger_chain_state`

## 6. Startup Verification

- [ ] 6.1 Implement a verification pass: recompute each entry's hash, verify its signature against `signed_by_identity_id`, confirm `previous_entry_hash` matches the prior entry's actual hash
- [ ] 6.2 Rebuild `entry_verification_cache` from the verification pass
- [ ] 6.3 Identify the first failing entry as the break point; mark it and everything chained after it as unverified
- [ ] 6.4 On a newly detected break, write a `CHAIN_BREAK_DETECTED` row to `integrity_events`
- [ ] 6.5 Run verification on every app startup

## 7. Quarantine and Re-anchoring

- [ ] 7.1 Update balance/summary queries to exclude any entry marked unverified in `entry_verification_cache`
- [ ] 7.2 Update register display to show quarantined entries with the design system's error treatment (red left-border + lock icon), never hidden
- [ ] 7.3 Update `ledger_chain_state.trusted_tip_*` to the last verified entry before a break
- [ ] 7.4 Update `recordTransaction`/`reverseEntry` to chain new entries onto `ledger_chain_state.trusted_tip_*`, not onto the raw last-inserted row
- [ ] 7.5 Write a `CHAIN_REANCHORED` row to `integrity_events` when the first post-break entry is recorded

## 8. True Key-Loss Migration

- [ ] 8.1 Build the explicit confirmation flow ("I confirm the current ledger is valid") with plain-language wording that this does not retroactively prove pre-migration integrity
- [ ] 8.2 Generate a new signing identity with `supersedes_identity_id` set
- [ ] 8.3 Re-create every existing entry as a new, signed entry with identical transaction content and `migrated_from_entry_id` set
- [ ] 8.4 Exclude legacy (superseded) entries from active balance/summary calculations while keeping them visible as historical records
- [ ] 8.5 Write a `KEY_MIGRATION_CONFIRMED` row to `integrity_events`

## 9. Recoverable Reinstall Flow

- [ ] 9.1 On setup with an existing database file detected, offer "Restore from recovery phrase/keystore" before offering the migration flow
- [ ] 9.2 On successful import/match, resume normal startup verification — confirm no entry is re-signed or altered in this path

## 10. Testing

- [ ] 10.1 Unit tests (`dart-add-unit-test`): hash determinism, signature acceptance/rejection, chain-linkage break detection, quarantine exclusion logic, migration re-signing preserves original content
- [ ] 10.2 Unit test: tampering with a stored entry (direct DB row edit in test) is detected on next verification pass
- [ ] 10.3 Widget tests (`flutter-add-widget-test`): recovery-phrase screen blocks progress until confirmed; quarantined entry renders with error treatment; migration confirmation dialog shows required wording
- [ ] 10.4 Integration tests (`flutter-add-integration-test`): full tamper-detection flow (mutate a row, restart, confirm break + quarantine + re-anchor); reinstall-with-recovery-phrase flow; true-key-loss migration flow end to end
- [ ] 10.5 Generate coverage report (`dart-collect-coverage`)

## 11. Quality Gates

- [ ] 11.1 `dart analyze` clean, `dart fix --apply` run
- [ ] 11.2 Verify every scenario in `specs/ledger-integrity-signing/spec.md` has a corresponding passing test
- [ ] 11.3 Confirm the private key never appears in any log output, database row, or serialized state (manual/code-searched check)
- [ ] 11.4 Run through the Definition of Done checklist in `smara-tech-guidelines.md`
