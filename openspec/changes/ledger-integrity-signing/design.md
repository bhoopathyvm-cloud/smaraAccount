## Context

`core-ledger-single-account`'s `design.md` deferred tamper-evidence entirely
("immutability is enforced by Repository surface, not database triggers ...
revisit when the LAN-sync change introduces multiple devices"). This change
brings that forward: the schema below adds chaining/signing to
`journal_entries` and introduces the supporting tables needed for key
lifecycle, verification results, and break/migration events — all still
single-device.

A key modeling rule throughout: **verification results are derived data,
never part of the immutable truth.** `smara-architecture.md` already draws
this line for balances/reports; the same line applies here — whether an
entry currently verifies is a projection that can be recomputed and
rebuilt, never a column mutated on `journal_entries` itself (mutating it
would itself violate the immutability rule the whole feature exists to
protect).

## Goals / Non-Goals

**Goals:**
- Schema for chained, signed journal entries with a per-device signing
  identity that can be superseded (key migration) without losing lineage.
- Schema for verification state, chain breaks, and re-anchoring that never
  requires updating an existing `journal_entries`/`postings` row.

**Non-Goals:**
- Multi-device schema (per-device chains, trust-list replication) — see
  `proposal.md`'s deferred section; not designed here.
- Any server/relay component.

## Decisions

### `journal_entries` gains chaining/signing columns

```
journal_entries  (existing table from core-ledger-single-account, extended)
  ...existing columns (id, transaction_date, recorded_at, description,
      reverses_entry_id, created_at)...
  device_chain_sequence   INTEGER NOT NULL UNIQUE  -- gapless, ascending
  previous_entry_hash     BLOB NOT NULL            -- 32 zero bytes for the genesis
                                                    -- entry (a well-defined constant,
                                                    -- never null — see spec.md)
  entry_hash              BLOB NOT NULL
  signed_by_identity_id   TEXT NOT NULL REFERENCES signing_identities(identity_id)
  signature               BLOB NOT NULL
  migrated_from_entry_id  TEXT NULL REFERENCES journal_entries(id)
```

`device_chain_sequence` (not just `sequence`) is named for the per-device
chain this will become once multi-device sync exists — costs nothing now,
avoids a rename later. `migrated_from_entry_id` links a re-signed entry
(created during true-key-loss migration) back to the legacy row whose
content it preserves; the legacy row is left exactly as-is, never edited.

**Canonical hash**, computed the same way the very first architecture
exploration proposed:

```
entry_hash = SHA256(
    previous_entry_hash (32 zero bytes if genesis)
  + id + device_chain_sequence
  + transaction_date + recorded_at
  + description (empty string if null)
  + reverses_entry_id (empty string if null)
  + signed_by_identity_id
  + canonical_postings   -- ordered by line_number: account_id + amount_minor
)
signature = Ed25519_Sign(private_key, entry_hash)
```

Including `signed_by_identity_id` in the hash means swapping which identity
"claims" an entry after the fact breaks the chain, not just an isolated
signature check.

### `signing_identities` — the device's key history, public half only

```
signing_identities
  identity_id             TEXT PRIMARY KEY (uuid)
  public_key              BLOB NOT NULL
  created_at               INTEGER NOT NULL
  supersedes_identity_id   TEXT NULL REFERENCES signing_identities(identity_id)
  superseded_at            INTEGER NULL
```

Only the public key is ever stored in the database. The private key lives
exclusively in OS secure storage (Keychain/Keystore/DPAPI) and is never
written to SQLite. A row is inserted here at first-install key generation,
and again whenever the true-key-loss migration flow creates a new identity
(`supersedes_identity_id` pointing at the old one).

### Verification results are a rebuildable cache, not a column

```
entry_verification_cache        -- derived; safe to drop and rebuild entirely
  entry_id       TEXT PRIMARY KEY REFERENCES journal_entries(id)
  is_verified    INTEGER NOT NULL  -- 0/1
  break_reason   TEXT NULL         -- 'hash_mismatch' | 'signature_invalid' |
                                   -- 'chain_link_broken' | 'excluded_after_break'
  checked_at     INTEGER NOT NULL
```

Recomputed in full on every app startup (chain sizes at this project's
scale make a full walk cheap — see `smara-tech-guidelines.md`'s testing
notes; revisit only if that assumption stops holding). Balance/summary
projections join against this cache and exclude any `is_verified = 0` row,
satisfying "excluded from process" without ever touching
`journal_entries` itself.

### `ledger_chain_state` — a convenience pointer, also derived

```
ledger_chain_state              -- derived; single row, safe to rebuild
  id                        TEXT PRIMARY KEY  -- fixed value 'singleton'
  trusted_tip_entry_id      TEXT NULL REFERENCES journal_entries(id)
  trusted_tip_hash          BLOB NULL
  next_device_chain_sequence INTEGER NOT NULL
```

Exists purely so `recordTransaction`/`reverseEntry` don't have to
re-derive "what's the last verified entry to chain onto" from a full scan
on every write. Value is fully recomputable from `journal_entries` +
`entry_verification_cache`.

### `integrity_events` — append-only audit log for breaks and migrations

```
integrity_events
  event_id            TEXT PRIMARY KEY (uuid)
  event_type           TEXT NOT NULL CHECK (event_type IN
                        ('CHAIN_BREAK_DETECTED','CHAIN_REANCHORED',
                         'KEY_MIGRATION_CONFIRMED'))
  occurred_at          INTEGER NOT NULL
  related_entry_id     TEXT NULL REFERENCES journal_entries(id)
  related_identity_id  TEXT NULL REFERENCES signing_identities(identity_id)
  detail               TEXT NULL
```

Append-only like `journal_entries` (no update/delete), but intentionally
**not** part of the cryptographic chain itself — it's an audit trail of
events about the chain, not financial data. Keeping it a plain immutable
log avoids building a second full signing scheme for a lower-stakes
concern.

### Onboarding ordering dependency

Key generation (first `signing_identities` row) must happen before the
very first `journal_entries` row is written — including the starter
accounts' seed data from `core-ledger-single-account`. This is a real
sequencing dependency between the two changes' `onCreate`/first-run logic,
not just a conceptual one.

As implemented: `AppDatabase.onCreate` creates schema only, no data.
`LedgerRepository.confirmFirstIdentity` inserts the signing identity row
*and* seeds the financial account + starter categories, in the same
transaction, only after the user has confirmed the recovery phrase.
core-ledger-single-account's original design (seeding accounts directly
in `onCreate`) was implemented first and violated this ordering until
caught during this change's spec-conformance audit - noted here so the
dependency direction (accounts wait on identity, not the reverse) is
explicit for anyone touching either change's bootstrap logic again.

## Risks / Trade-offs

- **`entry_verification_cache` recomputed fully on every startup** →
  Acceptable at current expected scale (tens of thousands of entries,
  Ed25519 verification is fast); revisit if startup time becomes
  noticeable.
- **`integrity_events` isn't cryptographically chained** → Accepted
  trade-off to avoid a second signing scheme; it's an audit log, not the
  ledger itself. If this proves insufficient later (e.g. someone could
  delete an `integrity_events` row without detection), it can be folded
  into the same chain mechanism as its own entry type.
- **Two changes' first-run logic must be sequenced correctly** →
  Mitigated by calling it out explicitly here rather than leaving it
  implicit in `tasks.md` for either change.

## Migration Plan

This is additive to `core-ledger-single-account`'s schema (new columns on
`journal_entries`, new tables). Since neither change has been implemented
yet, there is no live data to migrate — the two changes' schema work should
land together as one Drift schema version rather than as a
retrofit-after-the-fact migration.
