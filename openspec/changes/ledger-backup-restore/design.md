## Context

An earlier draft left "SQLite export or logical JSON+entries" as an
open either/or, and didn't address what happens to signature
verification across a restore. Checked the actual schema before
resolving both:

- `signing_identities` is its own table; every `journal_entries` row
  references `signedByIdentityId`, and the true-key-loss migration flow
  already relies on a ledger holding **more than one** historical
  identity's entries side by side, each verified against its own stored
  public key. Verification never needs the private key — only signing a
  *new* entry does. This means a full-database backup that includes
  `signing_identities` carries everything `verifyChain()` needs, and the
  existing multi-identity verification path is exactly the mechanism a
  restored backup exercises — nothing new to build there.
- A raw encrypted SQLite file is strictly simpler than a logical/JSON
  export: no schema-to-JSON mapping to design or keep in sync with future
  migrations, no partial-field-loss risk, and restore is "decrypt, drop
  in as the app's database file" rather than "replay a logical import."
  Logical export is deferred to `ledger-data-export` (CSV, a different,
  already-separate change) for the "give this to my CA" use case; this
  change is specifically about a *restorable* backup.

## Goals / Non-Goals

**Goals:** User controls an off-device, encrypted copy of the books;
restoring it reproduces the exact ledger state; restore composes with
the existing multi-identity verification model instead of assuming one
identity per ledger.

**Non-Goals:** Merging two ledgers (out of scope — replace only).
Logical/CSV export (that's `ledger-data-export`). Automatic/scheduled
backup (v1 is user-initiated only).

## Decisions

### 1. Backup is the encrypted raw SQLite file, not a logical export
Resolves the earlier either/or. `Save backup` encrypts the current
database file with a user-supplied passphrase (same primitive family as
the existing keystore-file encryption) and writes it via the platform
file saver to a location the user chooses. `Restore backup` decrypts and
replaces the local database file after explicit confirmation.

### 2. Restore is replace-only
Proposal.md's original "replace/merge" language is resolved to replace
only. Merging two independently hash-chained histories is a
substantially harder problem (chain-sequence renumbering, duplicate-entry
detection, conflicting `signedByIdentityId` provenance) than the stated
product need ("I want my books back after losing my phone"). Replace
covers that need directly; merge is not attempted in this change or
implied as a future extension without its own design.

### 3. Restore composes with the existing multi-identity verification model
The backup includes `signing_identities` (public keys + metadata; never
a private key — the private key never leaves OS secure storage and is
never part of a database export). Immediately after restore,
`verifyChain()` runs exactly as it does on every app start and fully
verifies the restored chain using only what's in the backup. The
restored ledger is readable and verifiable right away. Recording a *new*
entry still requires the matching private key on-device (recovery phrase
or keystore restore) — unchanged, and orthogonal to this change.

### 4. Restoring a foreign identity's backup onto an already-set-up device is rejected
If the device already has an active signing identity and the backup's
active identity doesn't match it, restore is rejected with an
explanation (the alternative — silently merging in a stranger identity's
history — is confusing and not the stated use case, which is "get my
own books back," not "combine two people's ledgers"). Restoring onto a
**fresh, not-yet-onboarded** device is the supported path: the backup's
identity becomes the device's identity, and the user still separately
restores the matching private key via recovery phrase or keystore to
resume recording.

## Risks / Trade-offs

- [Risk] User loses the backup passphrase. → Mitigation: same accepted
  trade-off as the keystore export passphrase already has; no recovery
  path, stated plainly in the UI.
- [Risk] Restore-replace destroys unsynced local data if the user
  restores by mistake. → Mitigation: explicit confirmation naming what
  will be replaced, matching this app's existing destructive-action
  confirmation pattern.
- [Risk] Scope creep toward merge. → Mitigation: replace-only is a
  stated decision here, not an oversight to "fix" later without its own
  design.
- [Risk, found during implementation] The app wires `AppDatabase` once at
  startup (`main.dart`'s `Provider<AppDatabase>`), so replacing the file
  on disk doesn't retarget the live connection every already-constructed
  ViewModel is holding onto. → Mitigation: `restoreLedgerBackup` closes
  its own connection before replacing the file and is documented as
  unusable afterward; the Settings UI shows a "close the app to continue"
  screen rather than attempting an in-place hot-swap, which would need a
  much larger DI restructuring than this change's stated scope.

## Migration Plan

No schema change. Backup/restore operate on the database file as a
whole, so they're schema-version-agnostic by construction (a backup made
under one schema version restores and then runs the app's existing
migration path on next launch, same as upgrading the app itself would).

## Open Questions

None that block apply.
