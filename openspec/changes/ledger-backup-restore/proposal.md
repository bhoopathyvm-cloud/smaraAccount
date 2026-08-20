## Why

Restore phrase restores key, not books. Local-first without user-chosen backup is hostage-taking.

## What Changes

- Settings: Save backup → an encrypted copy of the local SQLite database
  file (passphrase-protected), written to a location the user picks via
  the platform file saver. Not a logical/JSON export — the raw database,
  encrypted, so restore reproduces the exact state with no schema-mapping
  risk.
- Restore backup → **replaces** the local ledger database after an
  explicit confirmation (not merge — merging two independently-signed
  hash chains is a much harder, higher-risk problem than this change
  takes on; replace is the only mode).
- The backup includes the `signing_identities` table (public keys and
  metadata only — never a private key), so `verifyChain()` can fully
  verify every restored entry's signature immediately after restore,
  using only what travels in the backup. Recording *new* entries after
  restore still requires the matching private key via recovery phrase or
  keystore, exactly as today — a restored ledger with no matching private
  key on-device is fully readable and verifiable, just not writable until
  the identity is separately restored.
- Restoring a backup whose identity doesn't match the device's current
  identity is rejected with a clear explanation, rather than silently
  producing a ledger with entries the device can never sign new work
  under. (See design.md for the exact condition.)
- Separate from keystore (identity) and recovery phrase — this change
  backs up the *books*; identity restoration is unchanged.
- Document in user guide.

## Capabilities

### New Capabilities

- `ledger-backup`

### Modified Capabilities

- `user-guide`

`ledger-integrity-signing` itself needs no delta: restore replaces the
database file, and the existing startup `verifyChain` behavior runs
unchanged afterward — it already supports multiple historical identities
(true-key-loss migration relies on the same mechanism), so a restored
backup's signatures verify with no new code path. `ledger-backup`'s own
requirements state the restore-time guarantees this relies on.

## Impact

- UI, repository or settings as described.
- Tests and user guide.
