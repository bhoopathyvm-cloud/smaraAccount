## Context

See proposal.md - Why/What Changes for motivation. Relevant existing pieces this design builds on:

- `SigningKeyService` (`lib/domain/crypto/signing_key_service.dart`) already owns key generation, phrase-based restore, and secure storage of the raw private key seed — unchanged by this proposal.
- `KeystoreFile` (`lib/domain/crypto/keystore_file.dart`) and `LedgerBackupFile` (`lib/domain/backup/ledger_backup_file.dart`) already establish the pattern this design reuses: JSON envelope with a `kind` tag, AES-256-GCM payload encryption, PBKDF2-HMAC-SHA256 (210,000 iterations) key derivation from a passphrase. `LedgerBackupFile` explicitly excludes private key material per the existing `ledger-backup` spec.
- Onboarding currently generates the signing identity automatically (`Device Signing Identity`, unchanged), then guides one account + one transaction, then hard-blocks on the acknowledgment flow this change removes.
- The app is already released to testers/users going through this exact onboarding flow, so in-flight state (an identity already generated, a phrase already pending acknowledgment) needs to resolve cleanly on update, not just for future installs.

## Goals / Non-Goals

**Goals:**
- Onboarding never blocks on any recovery/backup step, before or after this change ships, for existing and new users alike.
- Moving to a new device is a single guided action: export one file, import one file, done.
- Preserve every existing backup option (recovery phrase, keystore file, data-only ledger backup) — this change adds a bundle and removes a block, it does not remove capability.

**Non-Goals:**
- No persistent nudge/reminder (banner, badge, periodic prompt) encouraging users to complete a backup. This change only removes the block; whether to add a non-blocking nudge is a separate future decision.
- No change to the signing/verification algorithm, the hash chain, quarantine, re-anchoring, or `True Key-Loss Migration` — this change only affects what happens before and around backup/restore, not the integrity model itself.
- No change to the existing data-only `ledger-backup` export/restore behavior.

## Decisions

**A single new file format, not an extension of `LedgerBackupFile`.** The bundle is a new class (e.g. `DeviceMigrationBundleFile`) with its own `kind` tag, following the same AES-256-GCM/PBKDF2 pattern as `KeystoreFile` and `LedgerBackupFile`, encrypting a payload containing both the raw database bytes and the private key seed. Considered instead making the private key field on `LedgerBackupFile` optional — rejected because the current `ledger-backup` spec's invariant ("SHALL NOT include any private key material") is easiest to keep auditable by construction when it's simply a different class with no key-bearing code path at all, rather than a conditional field on the same class that every future change to `LedgerBackupFile` must remember not to populate by accident.

**Key material travels as the raw derived seed, not the recovery phrase words.** The bundle stores the same private key seed `SigningKeyService` already stores in secure storage, not a re-encoded BIP-39 phrase. This avoids needing to also carry a language tag and keeps the bundle's restore path a straight "load seed, store seed" operation, identical in effect to `restoreFromRecoveryPhrase` but skipping the phrase round-trip entirely.

**Import rejects a foreign identity, mirroring `ledger-backup`'s existing rule.** Before replacing local data, the bundle's public key is compared against the device's current active identity (if any); a mismatch is rejected with an explanation, exactly as `ledger-backup`'s `Restoring a Backup Replaces the Local Ledger` requirement already does for data-only restores. A device with no active identity yet adopts the bundle's identity outright.

**Startup choice replaces, rather than precedes, automatic key generation.** Today, `Device Signing Identity` generates a key before the first-account screen unconditionally. This design inserts the New Setup / Import From Backup choice before that generation step: New Setup proceeds exactly as today (silent generation, guided first account/entry); Import From Backup generates no new identity at all and instead restores the bundle's identity, skipping guided onboarding entirely since there's already real data to land in.

**Removed onboarding screens are relocated, not rewritten.** `recovery_phrase_view.dart` and `keystore_export_view.dart` move into a new Settings-reachable backup section largely as-is (drop the forced "must continue" framing, add a plain back/done action); `recovery_phrase_confirm_view.dart` and its word-reentry check are dropped entirely, since nothing gates on completing it anymore.

**In-flight users resolve to "already set up."** A user already mid-onboarding at update time (identity generated, first entry possibly posted, phrase not yet acknowledged, `_pendingPhraseWordsStorageKey` populated) is simply released into normal app use on next launch — the acknowledgment requirement that was blocking them no longer exists. No special one-time migration screen is needed.

**The stashed phrase words become the permanent Settings recovery-phrase store, not a transient cache.** BIP-39's seed derivation (PBKDF2 over the words) is one-way: `SigningKeyService`'s stored private key seed cannot be used to reconstruct the original 24 words. Today's `_pendingPhraseWordsStorageKey` cache exists only to survive an app kill between identity commit and acknowledgment, and is deleted the moment acknowledgment completes. Since Settings must be able to display the phrase "at any time" indefinitely (`ledger-integrity-signing`'s `Optional Recovery and Backup Setup` requirement), that cache must instead be kept permanently in secure storage (same storage class and security properties as the private key seed itself, so this introduces no new exposure) and never cleared. `SigningKeyService.clearPendingPhraseWords` is removed as dead code once nothing calls it.

## Risks / Trade-offs

- [Risk] A single compromised bundle file + passphrase grants both full data read access and forging capability, a strictly larger exposure than either existing artifact leaking alone → Mitigation: explicit in-UI disclosure before export (see `device-migration-bundle`'s `Device Migration Bundle Export` requirement), and the data-only `ledger-backup` export remains available as a lower-exposure alternative for users who want it.
- [Risk] Removing the block means some users will never back up anything and only discover the consequences at the worst possible time (device loss) → Mitigation: accepted as a deliberate trade-off per proposal.md - Why; explicitly out of scope to mitigate further in this change (see Non-Goals). A future nudge mechanism is left as an open question, not a requirement here.
- [Risk] Users already stuck on the current acknowledgment screen at update time could theoretically hit an inconsistent state if the update is interrupted mid-migration → Mitigation: releasing them is a pure removal of a gate, not a data migration — no database schema or stored-key format changes, so there is nothing to roll back if interrupted.

## Migration Plan

1. Ship the new `device-migration-bundle` capability (export/import, startup choice) alongside the existing flows, without yet removing the old acknowledgment block — verifiable independently.
2. Remove the blocking acknowledgment flow from the onboarding stack and app-resume checks; relocate its screens into Settings.
3. On first launch after update, any user with a pending (unacknowledged) phrase is treated as already set up; no forced screen shown. No rollback path is needed since no persisted data format changes.
