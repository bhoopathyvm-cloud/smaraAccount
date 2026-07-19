> Note: coordinate schema delivery with `core-ledger-single-account` —
> per `design.md`'s Migration Plan, these two changes' Drift schema work
> should land as one schema version, not a retrofit migration after the
> fact.

## 1. Dependencies

- [x] 1.1 Add a crypto package providing Ed25519 sign/verify and SHA-256 (e.g. `cryptography`)
- [x] 1.2 Add `flutter_secure_storage` for private-key storage (Keychain/Keystore/DPAPI) — already present from `core-ledger-single-account`
- [x] 1.3 Add a BIP-39-style mnemonic package (or vendor a wordlist) for recovery-phrase generation/derivation — used `bip39_mnemonic` (actively maintained, published 2025-08-18) instead of `bip39` (unmaintained since 2021, fails Golden Rule #8)

## 2. Drift Schema Extensions

- [x] 2.1 Extend `journal_entries` with `device_chain_sequence`, `previous_entry_hash`, `entry_hash`, `signed_by_identity_id`, `signature`, `migrated_from_entry_id` per `design.md`
- [x] 2.2 Add `signing_identities` table (public key only — never the private key)
- [x] 2.3 Add `entry_verification_cache` table (derived, rebuildable)
- [x] 2.4 Add `ledger_chain_state` singleton table (derived, rebuildable)
- [x] 2.5 Add `integrity_events` append-only table
- [x] 2.6 Run `build_runner`; verify generated code compiles — schemaVersion bumped 1→2 with a real `onUpgrade`, guarded to reject upgrading a database with existing `journal_entries` rows (none has ever shipped per design.md's Migration Plan)

## 3. Signing Identity Lifecycle

- [x] 3.1 Generate Ed25519 key pair on first launch, before any `journal_entries` row (including seeded starter accounts) is created — `LedgerRepository.generateFirstIdentity`/`confirmFirstIdentity`; `recordTransaction`/`reverseEntry` throw `StateError` with no confirmed identity; `app_router.dart`'s redirect now enforces onboarding before any other route is reachable
- [x] 3.2 Store the private key exclusively in secure storage; write the public key to `signing_identities` — `SigningKeyService` (secure storage) + `LedgerRepository.confirmFirstIdentity` (DB)
- [x] 3.3 Implement recovery-phrase generation that deterministically derives the same key pair — `RecoveryPhrase` (`bip39_mnemonic`) + `Ed25519Signing.keyPairFromSeed`
- [x] 3.4 Implement encrypted keystore file export (passphrase-protected) as an alternative/additional backup format — `KeystoreFile` (PBKDF2-HMAC-SHA256 + AES-256-GCM)
- [x] 3.5 Implement import: recovery phrase or keystore file → re-derive key pair → compare against an existing `signing_identities.public_key` to confirm a match — `LedgerRepository.restoreIdentity`

## 4. Onboarding UI

- [x] 4.1 Recovery-phrase display screen with explicit consequences messaging (loss of device + phrase = unrecoverable chain) — `RecoveryPhraseView`
- [x] 4.2 Require confirmation (e.g. re-enter a subset of words) before the ledger becomes usable — `RecoveryPhraseConfirmView`, asks back 3 fixed word indices; `LedgerRepository.confirmFirstIdentity` only runs after a correct match
- [x] 4.3 Optional keystore file export screen — `KeystoreExportView`; writes to the app's Documents directory via `path_provider`, Skip always available
- [x] 4.4 "Restore from recovery phrase / keystore file" entry point for reinstall/new-device setup — `RestoreIdentityView`

`app_router.dart`'s `redirect` now gates every route on identity state:
no identity → onboarding; identity exists but no matching stored key →
restore; otherwise → `verifyChain()` once per session, then through.
`main.dart` provides the two new ViewModels
(`RecoveryPhraseSetupViewModel`, `RestoreIdentityViewModel`).

**Real-device fix found while testing this on macOS**: `flutter_secure_storage`'s
`SecItemAdd` hung indefinitely under the default `kSecUseDataProtectionKeychain`
- it requires real Apple Developer code signing + a matching
`keychain-access-groups` entitlement, not available for local/ad-hoc
signed runs. Fixed via `MacOsOptions(usesDataProtectionKeychain: false)`
in `FlutterSecureKeyStorage` (legacy file-based Keychain API instead).
Also had to disable App Sandbox in both `.entitlements` files - adding
`keychain-access-groups` without real signing broke the build outright.
Flagged in both files' comments to revisit before any App Store
submission, where sandboxing is required and real signing would replace
this workaround.

## 5. Canonical Hashing and Signing

- [x] 5.1 Implement canonical serialization of entry content (fields + ordered postings) per the `entry_hash` formula in `design.md` — `canonicalEntryBytes`
- [x] 5.2 Implement genesis handling (well-defined constant previous hash for the first entry, not an arbitrary null) — `genesisPreviousEntryHash`
- [x] 5.3 Extend `LedgerRepository.recordTransaction` and `reverseEntry` (from `core-ledger-single-account`) to compute `entry_hash`, sign it with the current identity, assign `device_chain_sequence`, and update `ledger_chain_state` — shared `_appendSignedEntry`

## 6. Startup Verification

- [x] 6.1 Implement a verification pass: recompute each entry's hash, verify its signature against `signed_by_identity_id`, confirm `previous_entry_hash` matches the prior entry's actual hash — `LedgerRepository.verifyChain`
- [x] 6.2 Rebuild `entry_verification_cache` from the verification pass
- [x] 6.3 Identify the first failing entry as the break point; mark it and everything chained after it as unverified
- [x] 6.4 On a newly detected break, write a `CHAIN_BREAK_DETECTED` row to `integrity_events`
- [x] 6.5 Run verification on every app startup — `app_router.dart`'s redirect calls `verifyChain()` once per app session before any route past identity-check is reachable

## 7. Quarantine and Re-anchoring

- [x] 7.1 Update balance/summary queries to exclude any entry marked unverified in `entry_verification_cache` — `watchSummary`, `RegisterViewModel._recompute`
- [x] 7.2 Update register display to show quarantined entries with the design system's error treatment (red left-border + lock icon), never hidden — `RegisterRowTile`
- [x] 7.3 Update `ledger_chain_state.trusted_tip_*` to the last verified entry before a break — `verifyChain`
- [x] 7.4 Update `recordTransaction`/`reverseEntry` to chain new entries onto `ledger_chain_state.trusted_tip_*`, not onto the raw last-inserted row — `_appendSignedEntry`
- [x] 7.5 Write a `CHAIN_REANCHORED` row to `integrity_events` when the first post-break entry is recorded — `_appendSignedEntry`'s `isReanchor` check

## 8. True Key-Loss Migration

- [ ] 8.1 Build the explicit confirmation flow ("I confirm the current ledger is valid") with plain-language wording that this does not retroactively prove pre-migration integrity — UI only; `LedgerRepository.migrateToNewIdentityAfterKeyLoss` assumes this has already happened before it's called
- [x] 8.2 Generate a new signing identity with `supersedes_identity_id` set
- [x] 8.3 Re-create every existing entry as a new, signed entry with identical transaction content and `migrated_from_entry_id` set
- [x] 8.4 Exclude legacy (superseded) entries from active balance/summary calculations while keeping them visible as historical records — `JournalEntry.isSupersededByMigration`, excluded in `watchSummary` and the register's running balance
- [x] 8.5 Write a `KEY_MIGRATION_CONFIRMED` row to `integrity_events`

## 9. Recoverable Reinstall Flow

- [x] 9.1 On setup with an existing database file detected, offer "Restore from recovery phrase/keystore" before offering the migration flow — `RestoreIdentityView`, routed to automatically by `app_router.dart` when an identity exists but no matching key is stored. (The true-key-loss migration flow itself - section 8.1's confirmation UI - still doesn't exist, so there's no "before offering X" choice screen yet; restore is simply the only path offered today.)
- [x] 9.2 On successful import/match, resume normal startup verification — confirm no entry is re-signed or altered in this path — `restoreIdentity` re-derives and matches only, never writes/re-signs; covered by test

## 10. Testing

- [x] 10.1 Unit tests (`dart-add-unit-test`): hash determinism, signature acceptance/rejection, chain-linkage break detection, quarantine exclusion logic, migration re-signing preserves original content — `test/domain/crypto/*`, `test/data/repositories/ledger_repository_test.dart`
- [x] 10.2 Unit test: tampering with a stored entry (direct DB row edit in test) is detected on next verification pass — `verifyChain` group
- [ ] 10.3 Widget tests (`flutter-add-widget-test`): recovery-phrase screen blocks progress until confirmed; quarantined entry renders with error treatment; migration confirmation dialog shows required wording — quarantined-entry render test done (`register_view_test.dart`); `RecoveryPhraseSetupViewModel`/`RestoreIdentityViewModel` have full unit test coverage (`test/ui/features/onboarding`, `test/ui/features/restore`), but no `WidgetTester`-level test yet drives the actual onboarding/restore Views; migration confirmation dialog still doesn't exist (8.1)
- [ ] 10.4 Integration tests (`flutter-add-integration-test`): full tamper-detection flow (mutate a row, restart, confirm break + quarantine + re-anchor); reinstall-with-recovery-phrase flow; true-key-loss migration flow end to end — onboarding UI now exists to drive these through `integration_test`, but none are written yet
- [ ] 10.5 Generate coverage report (`dart-collect-coverage`) — defer until the above land, so the report reflects the finished change

## 11. Quality Gates

- [x] 11.1 `dart analyze` clean, `dart fix --apply` run
- [ ] 11.2 Verify every scenario in `specs/ledger-integrity-signing/spec.md` has a corresponding passing test — blocked on the onboarding/migration-UI scenarios (section 4, 8.1, 9.1)
- [x] 11.3 Confirm the private key never appears in any log output, database row, or serialized state (manual/code-searched check) — `grep`ed for `privateKeySeed`/`private_key` outside `SigningKeyService`/secure-storage/tests; only ever passed to `Ed25519Signing`/`SecureKeyStorage`, never logged or written to a Drift column
- [ ] 11.4 Run through the Definition of Done checklist in `smara-tech-guidelines.md` — blocked on remaining sections above
