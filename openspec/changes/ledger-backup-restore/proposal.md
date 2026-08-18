## Why

Restore phrase restores key, not books. Local-first without user-chosen backup is hostage-taking.

## What Changes

- Settings: Save backup → encrypted file (passphrase) user picks path via platform file saver.
- Restore backup → replace/merge ledger DB with confirmation.
- Separate from keystore (identity) and recovery phrase.
- Document in user guide.

## Capabilities

### New Capabilities

- `ledger-backup`

### Modified Capabilities

- `ledger-integrity-signing`
- `user-guide`

## Impact

- UI, repository or settings as described.
- Tests and user guide.
