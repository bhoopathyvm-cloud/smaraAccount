## Tasks

- [ ] 1.1 Repository/service: encrypt the raw SQLite database file with a user-supplied passphrase (reuse the existing keystore-file encryption primitive); write via the platform file saver to a user-chosen location. Never include private key material.
- [ ] 1.2 Confirm the export includes `signing_identities` (public keys + metadata) alongside the ledger tables.
- [ ] 1.3 Restore: decrypt with the supplied passphrase; if the device already has an active identity different from the backup's, reject with an explanation; otherwise replace the local database file after an explicit confirmation naming what will be replaced.
- [ ] 1.4 Confirm `verifyChain` runs on next app start after a restore and fully verifies the restored chain using only what's in the backup (no private key needed for verification).
- [ ] 1.5 Settings UI: Save backup / Restore backup actions, passphrase prompts, confirmation dialog for restore (reuse `confirmDestructiveAction` shape).
- [ ] 1.6 Tests: export/restore round-trip reproduces identical ledger state; restore rejected when identities mismatch; restore onto a fresh device succeeds and the ledger is read/verify-only until the private key is separately restored; wrong passphrase on restore fails cleanly with no partial replacement.
- [ ] 1.7 User guide: what backup covers (books) vs. recovery phrase/keystore (identity), and that restore replaces rather than merges.
