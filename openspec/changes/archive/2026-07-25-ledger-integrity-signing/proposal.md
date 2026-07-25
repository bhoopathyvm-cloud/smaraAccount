## Why

`core-ledger-single-account` enforces immutability only through code discipline — no `updateEntry`/`deleteEntry` method exists on the Repository, but nothing stops someone with direct access to the SQLite file from editing a "posted" row. For a small-business accounting tool, that gap matters: an owner or employee with device access could alter historical records and nothing would notice. This change makes tampering **detectable and provably not-quiet**, using a chained, signed ledger — deliberately choosing an all-or-nothing trust model (see Decisions) over a softer, per-row-only check.

## What Changes

- Every posted journal entry is hashed and **signed** with a device-local Ed25519 key (hash alone is not enough — a determined tamperer can simply recompute a hash; only a signature backed by a key outside the SQLite file resists that).
- Entries form a **hash chain** (each entry's hash includes the previous entry's hash). This is a deliberate choice: tampering with one entry invalidates cryptographic trust for every entry chained after it, not just that one row. The reasoning: any unauthorized edit outside the application already invalidates the accounting as a whole, and making that failure maximally visible is the point, not a side effect to soften.
- The signing key is generated on first install and stored in OS secure storage (Keychain/Keystore/DPAPI) — never inside the SQLite file, or the trust anchor could be forged alongside the data.
- **Backup/export**: onboarding generates a human-readable recovery phrase (BIP-39-style) deriving the signing key, shown once with unskippable messaging, plus an optional encrypted keystore file export. The user is responsible for storing it externally (their own password manager, printed copy, etc.) — the app does not integrate with or depend on any specific storage provider, and never depends on a server-side escrow.
- **Recoverable reinstall/migration** (user still has the recovery phrase): import re-derives the identical key, the app re-attaches to the existing database, and the full chain re-verifies normally. No re-signing occurs — this is the expected common path for a lost/reset/replaced device.
- **True key loss** (no recovery phrase available): a distinct, explicit disaster-recovery flow. The user reviews current ledger state and explicitly confirms it as valid; the app then re-signs every entry under a newly generated key, preserving original content while marking entries as migrated (original entry ID, migration date, reason). The old, no-longer-verifiable-under-current-key data is retained as read-only historical reference, never deleted. This does not retroactively prove pre-migration entries were untampered — it only re-establishes trust going forward from the point of explicit human confirmation, and the confirmation dialog must say so.
- **Verification on startup**: the app walks the chain, recomputes hashes, checks signatures, and confirms chain linkage. The first entry that fails becomes the break point.
- **On a detected break**: the break-point entry and everything chained after it are marked unverifiable and excluded from balances/reports — visible for forensic review, never deleted or hidden. New activity re-anchors onto the last verified entry before the break (with a recorded event describing the break and re-anchor point), not onto the compromised tip. Any legitimate transactions caught in the quarantined tail are not auto-recovered; the user reviews them and manually re-enters whichever were real, as new entries chained onto the fresh trusted tip.

## Capabilities

### New Capabilities
- `ledger-integrity-signing`: device signing key lifecycle (generation, secure storage, export/import), chained+signed journal entries, startup verification, break detection and quarantine/re-anchor behavior, and the recoverable-reinstall vs. true-key-loss migration flows.

### Modified Capabilities
- `core-ledger-single-account`: supersedes design.md's current "immutability is enforced by Repository surface, not database triggers" decision — immutability becomes cryptographically verifiable, not just a code-discipline guarantee. (Requirement-level impact to be reflected in that capability's spec once this change's specs are written.)

## Impact

- Every write path in `core-ledger-single-account`'s Repository (`recordTransaction`, `reverseEntry`) now also computes a hash and signature and updates chain state — this change cannot ship independently of that one.
- Introduces onboarding steps (key generation, mandatory recovery-phrase acknowledgment) ahead of first ledger use.
- Introduces new UI surfaces: recovery-phrase display/confirmation, key import during setup, the "migrate under new key" disaster-recovery flow, and quarantined-entry review.

## Deferred to Future Multi-Device Work (do not lose this)

This change is scoped to a **single device**. The following was explored in conversation but deliberately left undecided — flagged here so `lan-device-discovery-pairing` / `lan-sync` revisit it rather than re-deriving it from scratch:

- **One signing key per device, not shared across devices.** Sharing a private key across devices would require transmitting private key material during pairing (a real attack-surface increase) and reintroduces an unresolvable fork: two offline devices appending with the *same* identity can both validly extend the same previous hash, with no way to determine order from the chain alone. A separate key per device avoids this — each device's own chain is inherently serial.
- **Only the trust list (public keys, authorization/revocation state) should sync between devices — never private key material.** Each device keeps generating and holding its own private key, backed up via its own recovery phrase.
- **No hub/server needed for canonical ordering across devices.** With per-device chains, a single global chain isn't required: every device can independently compute the same *display* merge order from replicated data (e.g. sort by transaction date with a deterministic tie-breaker such as device ID), while cryptographic trust stays local to each device's own chain, verified against that device's own registered public key. This preserves the no-server constraint.
- **Device pairing/authorization can likely reuse this change's signing primitive** — an already-trusted device signing off on a new device's public key, rather than inventing a separate trust mechanism.

None of the above is designed yet. It is intentionally provisional.
