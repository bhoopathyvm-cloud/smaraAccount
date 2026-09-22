## Why

Onboarding currently hard-blocks every first-time user with a 3-screen mandatory recovery ritual (display a 24-word phrase, optional keystore export, re-type 3 words) immediately after their first guided transaction — including blocking reopening the app after backgrounding or a kill. Testers are complaining about this wall. Key generation itself already happens silently with no user interaction, so the block isn't protecting key creation — it's forcing backup setup before the user has any data worth backing up. Meanwhile, moving to a new device already requires juggling two separate artifacts (the recovery phrase to restore the signing key, plus a separate `ledger-backup` export to restore the data) with no single guided path.

## What Changes

- **BREAKING**: Remove the mandatory, blocking recovery-phrase acknowledgment flow from onboarding. Recording a second transaction, navigating elsewhere, or reopening the app no longer requires completing any recovery/backup step first.
- The signing identity continues to be generated automatically and silently on first launch, unchanged.
- Onboarding becomes a single uninterrupted flow: name first account → record first transaction → land in the app normally. No acknowledgment screen follows.
- Add a new **device migration bundle**: a single passphrase-protected export containing both the ledger database and the private key material together, so restoring from it on a new device yields a fully working, immediately verified, immediately record-capable identity in one step — no separate key-restore step required.
- At startup/first-launch, present an explicit choice: **New setup** (today's silent key generation + guided onboarding) or **Import from backup** (select a device migration bundle, enter its passphrase, restore data and key together).
- Move recovery-phrase display, keystore export, and the new bundle export to Settings, fully optional and reachable at any time, never blocking.
- The 24-word recovery phrase remains available as an optional, non-blocking, paper-only fallback in Settings for users who don't want a file-based backup — demoted from mandatory to one of several optional backup choices.
- The existing data-only `ledger-backup` export/restore (explicitly excludes private key material) remains available unchanged, for users who want a pure data backup without carrying key material. The bundle is an additional option, not a replacement.
- The bundle is a deliberate trade-off: a single compromised bundle file + passphrase yields both full data read access and forging capability, where today's split artifacts each leak less on their own. This is accepted and left to the user's judgment rather than forced apart; the design and the export UI must say so explicitly.
- `deferred-onboarding`'s guided-first-entry-before-acknowledgment behavior is superseded: there is no longer an acknowledgment screen to defer into, so the guided first account/entry simply happens as ordinary onboarding with nothing gating it afterward.

## Capabilities

### New Capabilities
- `device-migration-bundle`: passphrase-protected export/import bundling the ledger database and private key material together for one-step device migration, plus the startup "New setup" / "Import from backup" choice.

### Modified Capabilities
- `ledger-integrity-signing`: the "Mandatory Recovery Phrase Acknowledgment" requirement is replaced — recovery/backup setup becomes optional and non-blocking, reachable from Settings, instead of a mandatory gate after the first transaction.
- `deferred-onboarding`: the guided-first-entry-before-acknowledgment requirement is superseded — there is no acknowledgment flow left to defer into, so first-launch onboarding no longer gates a second transaction, navigation, or app resume on anything.
- `user-guide`: the onboarding section, the signing-key-tradeoff section, and the backup/restore section must be rewritten to describe the non-blocking Settings-based backup flow and the new device migration bundle, instead of the mandatory recovery-phrase-during-onboarding flow they currently document.

## Impact

- `lib/ui/features/onboarding/views/recovery_phrase_view.dart`, `recovery_phrase_confirm_view.dart`, `keystore_export_view.dart` — removed from the onboarding flow; their content is repurposed as Settings screens.
- `lib/ui/features/onboarding/view_models/recovery_phrase_setup_view_model.dart` — no longer drives a blocking onboarding step.
- `lib/ui/app_router.dart` — `recoveryPhrase`/`keystoreExport`/`confirm` routes move out of the onboarding stack; new routes for Settings-based backup and the startup New setup/Import from backup choice.
- `lib/domain/crypto/signing_key_service.dart`, `lib/domain/crypto/keystore_file.dart` — reused by the new bundle export/import, no change to key generation itself.
- `lib/domain/backup/ledger_backup_file.dart` — existing data-only backup format unchanged; new bundle format added alongside it (likely a new class following the same encrypted-payload pattern, carrying both DB bytes and key seed).
- `lib/ui/features/restore/views/restore_identity_view.dart` — extended or joined by a new bundle-import view for the startup choice.
- `openspec/specs/ledger-integrity-signing/spec.md`, `openspec/specs/deferred-onboarding/spec.md`, `openspec/specs/user-guide/spec.md` — requirement deltas per Capabilities above.
- `docs/user-guide.md` — onboarding, signing-key-tradeoff, and backup/restore sections rewritten to match.
