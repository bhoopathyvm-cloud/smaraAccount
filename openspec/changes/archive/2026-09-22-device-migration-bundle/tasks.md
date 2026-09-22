## 1. Device migration bundle file format

- [x] 1.1 Add a `DeviceMigrationBundleFile` class (own `kind` tag, AES-256-GCM + PBKDF2-HMAC-SHA256 matching `KeystoreFile`/`LedgerBackupFile`) that encrypts/decrypts a payload containing both raw database bytes and the private key seed, and verify unit tests cover round-trip encrypt/decrypt, wrong-passphrase rejection, and rejection of a mismatched `kind` (e.g. a `KeystoreFile` or `LedgerBackupFile` selected by mistake)
- [x] 1.2 Add an orchestration method (e.g. on `SigningKeyService` or a new adjoining service) that produces a `DeviceMigrationBundleFile` from the current stored key seed plus the live database bytes, and verify a unit test confirms the exported bundle decrypts to the same seed currently in secure storage

## 2. Bundle import and foreign-identity rejection

- [x] 2.1 Add an import method that decrypts a bundle, compares its public key against the device's current active identity (if any), rejects on mismatch with an explanation, and otherwise replaces the local database and stores the private key seed, and verify unit/integration tests cover: successful import on a fresh device, foreign-identity rejection, and wrong-passphrase rejection
- [x] 2.2 Verify (integration test) that after a successful import, `verifyChain` reports the restored chain fully verified and a new transaction can be recorded immediately with no further setup

## 3. Startup Setup Choice screen

- [x] 3.1 Add a startup screen presenting "New Setup" and "Import From Backup", shown before any signing identity is generated, and wire `lib/ui/app_router.dart` so it is the first screen on a device with no existing identity
- [x] 3.2 Wire "New Setup" to today's unmodified flow (silent key generation, guided first account, guided first transaction) and verify a widget test confirms no acknowledgment screen follows the first transaction
- [x] 3.3 Add a bundle-import view (file picker + passphrase field, reusing patterns from `lib/ui/features/restore/views/restore_identity_view.dart`) wired to "Import From Backup", landing the user directly in the restored ledger on success, and verify a widget test covers the success path and a wrong-passphrase error state

## 4. Remove the mandatory acknowledgment block

- [x] 4.1 Delete `recovery_phrase_confirm_view.dart` and its word-reentry check, and remove the `confirm` route and any navigation-guard/app-resume check that currently blocks on it; verify a widget test confirms recording a second transaction, navigating elsewhere, and killing/reopening the app all work immediately after the first transaction with no blocking screen
- [x] 4.2 Handle in-flight pending state: on launch, if a phrase is pending acknowledgment (`_pendingPhraseWordsStorageKey` populated) from a prior app version, treat the user as already set up and show no screen; keep (do not clear) the stashed words, since they now serve as the permanent Settings recovery-phrase store (BIP-39 seed derivation is one-way, so the words can't be reconstructed from the stored key seed later); verify a unit test covers this migration path

## 5. Settings-based backup section

- [x] 5.1 Relocate `recovery_phrase_view.dart` and `keystore_export_view.dart` into a new Settings backup section (drop forced-continue framing, add a plain back/done action), reachable at any time, and add the device migration bundle export screen (passphrase entry, the combined-artifact disclosure required by `device-migration-bundle`'s `Device Migration Bundle Export` requirement, then file save) alongside them
- [x] 5.2 Verify a widget test confirms all three Settings backup screens (recovery phrase, keystore export, bundle export) are reachable and none of them block any other app action when left incomplete

## 6. Spec-required documentation

- [x] 6.1 Rewrite the onboarding, signing-key-tradeoff, and backup/restore sections of `docs/user-guide.md` per the `user-guide` spec delta, and verify `openspec show user-guide --type spec` scenarios are each satisfied by the rewritten text

## 7. Full verification

- [x] 7.1 Run `flutter analyze` and `flutter test`, verify both pass
- [x] 7.2 Run `tool/run_acceptance_tests.sh -d macos` (required per this repo's working conventions after DI/routing/onboarding-flow changes) and verify it passes, since onboarding routing and app-resume gating changed in ways unit/widget test mocks would not catch
- [x] 7.3 Run `openspec validate device-migration-bundle --strict` and verify it reports the change valid before archiving
