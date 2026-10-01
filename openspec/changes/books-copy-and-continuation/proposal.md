## Why

Keeping your books safe today asks too much of an ordinary person. Moving
to a new phone means understanding three separate things: a 24-word
recovery phrase, a keystore file, and a device migration bundle. On top of
that, a books backup only restores if the matching key is restored
separately. Worse, anyone who taps **New setup** cannot bring their old
books in afterwards. That includes people whose phone arrived with the app
already installed after an Apple or Google phone transfer, and people who
simply tapped Start. Bundle import exists only on the first-launch screen,
and a backup is rejected on a device whose key differs. Android phone
transfers in particular move the books database but never the key, so
those users land on a restore screen that only a recovery phrase can
satisfy.

The fix is to stop asking people to manage a key at all. Checking a
record's signature only needs the stored *public* key, so a new device can
verify the old books and simply carry on under its own key. This change
does that. It is project A of three agreed in the 2026-10 grilling session.
Project B (linked devices and sync) and project C (shared accounts and
expense claims) build on it and are tracked separately.

## What Changes

- **BREAKING:** The private key never leaves the device. Removed:
  - **Recovery phrase:** viewing it in Settings, and restoring from it.
  - **Keystore file:** exporting it, and restoring from it.
  - **Key-loss Migration:** its screens and its engine.

  Books that already contain records superseded by a past migration still
  verify, and those records keep their historical mark.
- On iOS and macOS the key is stored "this device only", so it never
  travels in iCloud, Finder or Quick Start transfers. Existing installs
  re-save their key with that setting on first launch after the update.
  Android already behaves this way.
- **BREAKING:** One file type replaces both the Ledger Backup and the
  Device Migration Bundle. It is called a **Books Copy** and holds:
  - the books;
  - the public signing identities needed to verify them;
  - the app settings, except App Lock.

  It never holds a private key. Older backup and bundle files are still
  accepted when restoring, and any key inside them is ignored.
- **Making a copy:** in Settings, labelled "Save a copy of my books".
- **Restoring a copy:** labelled "Restore from a copy", on the first-launch
  screen *and* in Settings.
  - It always **replaces** this device's books; it never merges them.
  - On a device that already has books, a warning first lists what will be
    replaced: counts of entries, categories, accounts, payees, rules,
    recurring templates, instruments and so on, and the settings. It also
    offers "Save a copy first".
  - A copy that fails verification is refused completely, and the device is
    left untouched.
- **Continuation.** When a device has books but no matching key (after a
  phone transfer or a reinstall), or right after restoring a copy, the
  device continues the books:
  - It creates its own new Signing Identity. The screen labels this
    "Continue my books on this phone".
  - The new key continues the chain from the last verified record. Nothing
    is re-recorded or copied.
  - Records signed by earlier keys stay active and verified.
  - On a device with books but no key, a damaged tail is quarantined, as
    after any break.
- **The old device is not blocked.** The restore success screen explains
  that entries made later on the other device won't appear here.
- **Backup reminder.** A Home banner, "Save a copy of your books", appears
  after 30 days or 500 new entries with no copy saved. "Later" hides it for
  7 days or 500 entries. Both limits can be changed in Settings, and the
  reminder can be turned off.
- **Device history.** Settings shows when the books continued on this
  phone and from which copy. Each Continuation is also recorded as an
  integrity event.
- **ADR 0004** records the decision: the private key never leaves the
  device, and new devices continue by Continuation.

## Capabilities

### New Capabilities
- `books-copy`: covers the following.
  - The Books Copy file: its contents and the legacy files it accepts.
  - Saving a copy from Settings.
  - Restoring from a copy on the first-launch screen and in Settings: the
    replace-only rule, the counted warning with "Save a copy first", the
    all-or-nothing verification, and the success screen that explains the
    old device.
- `device-continuation`: covers continuing the books under this device's
  new Signing Identity when books exist without a matching key, the
  quarantine of damaged records, the integrity event, and Device history
  in Settings.
- `backup-reminder`: covers the Home banner's thresholds, the "Later"
  snooze, the configurable limits, and turning the reminder off.

### Modified Capabilities
- `ledger-integrity-signing`: changes four requirements and removes two.
  - **Device Signing Identity:** the key is never exported and is stored
    this-device-only.
  - **Optional Recovery and Backup Setup:** becomes the Books Copy only.
  - **Migration-Superseded Entries Are Visibly Marked:** narrowed to books
    that already contain migrated records.
  - **Re-anchoring After a Break:** a Continuation also continues from the
    trusted tip.
  - **Removed:** Recoverable Reinstall or Device Migration, and True
    Key-Loss Migration.
- `device-migration-bundle`: Export and Import are removed. Startup Setup
  Choice now offers New setup or Restore from a copy.
- `ledger-backup`: both requirements are removed; `books-copy` supersedes
  them.
- `key-loss-migration-engine`: both requirements are removed, because the
  engine and its entry points are removed.
- `acceptance-test-suite`: the real-build restore flow uses Save a copy,
  device reset, and Restore from a copy with Continuation, instead of the
  recovery phrase.
- `app-localization`: the recovery-phrase wordlist requirement is removed.
- `onboarding-language-selection`: the English-wordlist notice for the
  recovery phrase is removed.
- `user-guide`: the onboarding and Settings coverage and the signing-key
  explanation describe Books Copy and Continuation instead of the phrase,
  keystore and bundle.
- `macos-app-store-sandbox`: saving a Books Copy works under the sandbox
  (it replaces "ledger backup").
- `settings-validation`: the passphrase validator serves the "Save a copy"
  and "Restore from a copy" dialogs.

## Impact

- **Code removed:**
  - `lib/domain/crypto/recovery_phrase.dart`, `keystore_file.dart` and
    `bip39_language_for_locale.dart`
  - `lib/data/repositories/key_loss_migration_engine.dart`
  - the `lib/ui/features/restore/`, `lib/ui/features/migration/` and
    onboarding `recovery_phrase_setup` view models and views
  - in Settings: `recovery_phrase_view.dart`, `keystore_export_view.dart`
    and `device_migration_bundle_export_view.dart`
  - the matching routes in `lib/ui/app_router.dart`
- **Code changed:**
  - `lib/domain/backup/`: the Books Copy format, with a reader for the
    legacy formats.
  - `lib/data/repositories/ledger_backup_repository.dart` and
    `device_migration_bundle_repository.dart`, which become one Books Copy
    repository.
  - `identity_repository.dart`: Continuation.
  - `ledger_chain_verifier.dart`: chains that span several identities.
  - `secure_key_storage.dart`: this-device-only, plus the one-time re-save.
  - `settings_repository.dart`: export and import of settings, and the
    reminder preferences.
  - `app_navigation_policy.dart`: books without a key now route to
    Continuation, not `/restore`.
  - Setup Choice, Settings, Home (the banner), and DI wiring in `main.dart`.
- **Localization:** 43 ARB files plus `lib/l10n/untranslated.json`. The
  phrase, keystore and migration strings are removed, and new copy is added
  for save, restore, warning, Continuation, reminder and Device history.
- **Tests:**
  - unit and widget tests under `test/`;
  - `integration_test/app_test.dart`;
  - the acceptance suite (`integration_test/acceptance/`, the harness, and
    the locale fixtures);
  - the localized acceptance runner;
  - CI workflows;
  - the store screenshot and preview tests if PR #198 lands first.
- **Docs:** `docs/user-guide.md`, `README.md`, `CONTEXT.md` (applied when
  the change lands), `Specs/architecture/*`,
  `pages/open-source/smara-account/*` (what's built, privacy policy,
  architecture) and `docs/adr/0004-*`.
- **Dependencies:** the BIP39 wordlist dependency can be dropped if nothing
  else uses it.
- **Users:** two testers hold a recovery phrase. The owner informs them
  directly; no in-app migration is needed for them, because their books
  continue by Continuation.
