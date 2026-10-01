# Release notes draft — Books Copy and Continuation

For testers of the build that lands `books-copy-and-continuation`.

## What changed

- **Recovery phrases and keystore files are gone.** The signing key never
  leaves the device. There is nothing to write down or export for the key.
- **Books Copy** replaces ledger backup and the device migration bundle.
  Settings → **Save a copy of my books** / **Restore from a copy**. The
  copy holds books and books settings only — never the private key, and
  never language or App Lock settings.
- **Restoring always replaces** this phone's books (with counts and
  "Save a copy first"). It does not merge. After restore, this phone
  continues under its own new key. Later entries on the other device do
  not appear here.
- **Continuation**: if books are present without a matching key (keychain
  reset, or after restore), choose **Continue my books on this phone**.
  Existing entries stay; new ones use the new key. See **Device history**.
- **Copy reminder** on Home and in Settings gently nudges you to save a
  copy after time or many new entries.
- Older `.smarabackup` / migration-bundle files can still be restored; any
  key inside a legacy bundle is discarded.

## What to try

1. New setup → record entries → save a copy → restore on a fresh install.
2. Reset keychain only → Continue my books → same register → Device history.
3. Confirm App Lock / language survive a restore from another device's copy.
