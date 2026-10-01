## Context

See proposal.md for the motivation. The current state that shapes this
design:

- **Two file formats today.** Both are AES-256-GCM, with the key derived by
  PBKDF2-HMAC-SHA256 at 210,000 iterations. Both are restored by replacing
  the whole database file, never row by row.
  - The Ledger Backup (`lib/domain/backup/ledger_backup_file.dart`, kind
    `smara-ledger-backup`) is the raw SQLite file.
  - The Device Migration Bundle (`device_migration_bundle_file.dart`, kind
    `smara-device-migration-bundle`) is JSON:
    `{db: base64, key: base64 seed}`.
- **What a signature covers.** An entry's hash covers `previousEntryHash`,
  `id`, `deviceChainSequence`, `transactionDate`, `recordedAt`,
  `description`, `reversesEntryId`, `signedByIdentityId` and its postings
  (`accountId`, `amountMinor`).
  - `LedgerChainVerifier` verifies each signature against
    `signing_identities[signedByIdentityId].publicKey`. Verification
    therefore already works across several identities, using only public
    keys.
  - Entries created by a migration must have the genesis previous hash.
- **Settings live outside the database.** They are in
  `SharedPreferencesAsync` (`SettingsRepository`), so no backup carries
  them today.
- **The private key** sits in `flutter_secure_storage` with plugin
  defaults:
  - iOS: `unlocked`, not this-device-only, not synchronizable.
  - macOS: the legacy keychain (`usesDataProtectionKeychain: false`, see
    ADR 0001).
  - Android: Keystore-wrapped, and never leaves the device.
- **Navigation.** `AppNavigationPolicy` sends "identity and entries exist,
  but no matching stored key" to `/restore`, which offers only the
  recovery phrase or keystore file, then `/migrate`.

## Goals / Non-Goals

**Goals:**
- Use one file format, read by one repository. Legacy formats are
  readable; nothing writes them.
- Continuation reuses the existing verifier and chain rules. It adds an
  identity link, not a new chain model.
- No entry is ever rewritten, re-signed or copied.
- Keep the current replace-the-whole-file restore mechanics, which are
  already tested.

**Non-Goals:**
- Sync, linked devices, roles, and merging two sets of books (projects B
  and C).
- Automatic or cloud backup. Only the reminder is in scope.
- Translating category names, which belongs to project B.

## Decisions

1. **Books Copy format: a new kind, `smara-books-copy` v1.** It is an
   encrypted JSON payload,
   `{db: base64(sqlite after wal_checkpoint), settings: {key: value, …}}`,
   using the same cipher and KDF as today.
   - **Why not reuse the raw-DB ledger-backup format:** settings must
     travel (Q14), and a typed envelope leaves room for project B.
   - **Legacy formats** are detected by their `kind` tag. A
     `smara-ledger-backup` restores the database and keeps the device's
     current settings. A `smara-device-migration-bundle` restores the
     database and discards `key` without ever writing it to secure storage.
2. **Which settings travel.** Every `SettingsRepository` preference is
   exported, except:
   - the App Lock keys (enabled, PIN hash location, biometric, timeout,
     snapshot hiding);
   - the device-local reminder state (last copy saved, entry count at that
     save, snooze-until).

   The exported preferences include language, reference rates, quote
   provider, research tool, default exchange and first-week-setup
   completion. Settings are applied only after the database replace
   succeeds.
   - Alternative considered: also keep language device-local. Rejected,
     because the grilling chose "settings travel except App Lock"; the user
     can change the language right after a restore.
3. **One `BooksCopyRepository`** replaces `LedgerBackupRepository` and
   `DeviceMigrationBundleRepository`.
   - **Restore pipeline:**
     1. Decrypt the file to a temp file.
     2. Open it as a throwaway database.
     3. Require a signing identity.
     4. Run `verifyChain`, which must fully verify. Otherwise refuse, and
        nothing changes.
     5. Close it, swap the file in, and delete the WAL/SHM/journal
        sidecars.
     6. Apply the settings.
     7. Delete any orphaned private key in secure storage.
     8. Restart the app.
   - The "different identity is rejected" rule is dropped, because restore
     is replace-only.
   - **Replacement warning:** counts are taken from the *current* device
     database before the swap: entries, financial accounts, categories,
     user account groups, payees, category rules, CSV import profiles,
     recurring templates and instruments. Zero counts are hidden.
4. **Continuation.** It is a method on `IdentityRepository` (or a small
   leaf engine, following ADR 0002) that runs in one transaction:
   1. Generate a new Ed25519 key, stored this-device-only.
   2. Insert a `signing_identities` row with a new nullable column,
      `continuesIdentityId`, set to the previous active identity. The
      previous identity is marked not-current through a new nullable
      `continuedAt` column. The existing `supersededAt` is not used,
      because that would exclude its entries from balances.
   3. Set `ledger_chain_state`'s tip to the last verified entry (the
      trusted tip when there is a break), so the next entry chains there.
   4. Append an integrity event,
      `IDENTITY_CONTINUED {newId, previousId, continuationEntryHash, copySavedAt?}`.

   The schema version is bumped, with a Drift migration adding the two
   nullable columns.
   - **Alternative rejected: re-sign everything (the existing Migration).**
     It doubles visible history, rewrites `recordedAt` and breaks the
     links between reversals and the entries they reverse.
   - **Edge case:** if a restored copy's active identity matches a key
     already in this device's secure storage (a copy restored onto the
     phone that saved it), there is no Continuation. The device keeps that
     identity.
5. **Navigation.** "Books exist, no matching key" routes to a new
   `/continue` screen with two actions: "Continue my books on this phone"
   and "Restore from a copy". The routes `/restore` and `/migrate` and
   their views and view models are deleted. The first-launch screen offers
   New setup or Restore from a copy. Settings gets a section with:
   - "Save a copy of my books"
   - "Restore from a copy"
   - "Device history"
   - the reminder settings
6. **Verifying old migrations.** `KeyLossMigrationEngine` and
   `IdentityRepository.migrateToNewIdentityAfterKeyLoss` are deleted.
   `LedgerChainVerifier` keeps its genesis rule for entries with
   `migratedFromEntryId`, and the register keeps its superseded marking.
   A fixture database with migrated entries protects this in the tests.
7. **Key storage.**
   - **The new options:** `IOSOptions(accessibility: unlocked_this_device, synchronizable: false)`.
     On macOS, the same accessibility is set on top of the existing
     ADR 0001 configuration.
   - **The one-time re-save:** at startup, read the seed, write it back
     with the new options, read it again, and compare. Only then is the
     preference flag `keyAccessibilityMigrated` set. If anything fails,
     the old item is kept and the re-save is retried on the next launch.
     The key must never be lost.
8. **Reminder state.** The reminder stores device-local preferences:
   `lastCopySavedAt`, `entryCountAtLastCopy`, `snoozeUntil` and
   `entryCountAtSnooze`, plus the user-configurable limits (days and
   entries for the reminder and for the snooze) and an on/off switch, with
   the defaults 30/500 and 7/500.
   - The Home view model works out visibility from these values and the
     active entry count.
   - When no copy has ever been saved, the start point is the first
     entry's date and an entry count of zero.
9. **Removed dependency.** `bip39_mnemonic` is removed, together with
   `recovery_phrase.dart`, `bip39_language_for_locale.dart` and
   `keystore_file.dart`.

## Risks / Trade-offs

- **[A lost phone with no saved copy means the books are gone]** → The
  reminder, with defaults on and a usage-based trigger. The user guide
  states it plainly. This was accepted in the grilling (Q4).
- **[A stolen copy plus its passphrase exposes the books]** → It is
  encrypted with the same strong KDF. Unlike today's bundle, it can no
  longer be used to sign as the user.
- **[The macOS legacy keychain may still travel with Migration Assistant]**
  → This is harmless. If the same key arrives, it matches and there is no
  Continuation. If not, Continuation runs.
- **[Two devices keep recording after a restore and their books diverge]**
  → The success screen explains it. Sync is project B.
- **[A restored language overrides the one chosen at first launch]** →
  The user can change it immediately. The Settings warning names the
  settings as being replaced.
- **[Schema migration on existing installs]** → Only nullable columns are
  added. `app_database_migration_test` covers upgrading from the current
  schema version.
- **[The two testers with a recovery phrase]** → The owner informs them
  directly. Their books continue by Continuation.

## Migration Plan

1. Ship the schema migration, the key re-save, the Books Copy and
   Continuation together in one release.
2. Before archiving the change, apply the `CONTEXT.md` glossary edits.
   Then move `openspec/specs/ledger-backup/spec.md`'s Background References
   into the `books-copy` main spec. Archive retires `ledger-backup`,
   `device-migration-bundle` and `key-loss-migration-engine` (the change
   sets `retire_capabilities: true`). It refuses to retire `ledger-backup`
   while that section is still there.
3. **Rollback:** a previous app version can still open the database,
   because the new columns are nullable. It cannot read a Books Copy file,
   since the kind is new. A downgrade therefore keeps the on-device books
   but cannot restore new copies.
