## Context

See proposal.md for motivation. Constraints that shape this design:

- **No server / no cloud / no relay** (`Specs/architecture/smara-architecture.md`).
  Sync is LAN-only device-to-device.
- **ADR 0004:** the private key never leaves the device. Linked devices
  exchange public keys and signed records only. Builds on project A
  (`books-copy-and-continuation`): Books Copy, Continuation, and the
  shared-vs-device settings split.
- **Verification today** already checks each entry against
  `signing_identities[signedByIdentityId].publicKey`
  (`LedgerChainVerifier`). Continuation marks a prior identity
  `continuedAt` on *one* device's key lifecycle; linked peers are
  different — several identities stay active signers of the same books.
- **Settings** live in `SharedPreferencesAsync` today; project A already
  splits books settings (travel in a Books Copy) from device settings.
  Linked sync must reuse that split: books settings sync; device
  settings do not.
- **One SQLite database file** per install today. Several books sets
  require one file per set plus an active-books pointer.
- **Issue #204** left four items open for this proposal: discovery,
  multi-chain verification, books-switcher on disk, and two-device
  acceptance. Decisions below close them.

## Goals / Non-Goals

**Goals:**
- Concrete LAN discovery and TLS transfer that need no internet service.
- Multi-chain verification that extends Continuation's public-key model
  without re-signing or editing entries.
- On-disk books switcher that keeps keys and databases fully separate.
- CI-testable sync via two in-memory devices; physical two-device runs
  stay manual.
- Membership, roles, conflict rules, shared categories, and notices as
  specified — implemented behind ADR 0002-style seams.

**Non-Goals:**
- Project C (shared accounts, expense claims between people).
- Push notifications, accounts, or any hosted relay.
- Encrypting the live SQLite file at rest (unchanged stance).
- Automatic sync while both devices are off or on different networks.
- OS-scheduled background sync (WorkManager / BGTaskScheduler, etc.) —
  see Decision 11.
- Rewriting or re-signing history to "unify" chains.

## Decisions

1. **Discovery: mDNS/Bonjour service type `_smara._tcp`.**
   After local-network permission (asked on first open of Linked
   devices), each open app advertises and browses `_smara._tcp` on the
   local link. TXT records carry a non-secret books-set id hash, a
   short device display name, and a protocol version — enough to filter
   peers for the active books, not enough to impersonate without the
   certificates exchanged at join.
   - **Why not a custom UDP beacon:** mDNS is the platform-supported
     path on iOS/macOS (Bonjour), Android, and Linux (Avahi), and matches
     App Store local-network entitlement patterns.
   - **Why not Bluetooth:** issue #204 fixed same-Wi-Fi; QR already
     covers the in-person bootstrap.

2. **Transfer: TLS with pinned device certificates exchanged via QR.**
   At join, each device generates (or reuses) a device TLS certificate
   whose public key is bound to that device's Signing Identity id. The
   QR payload (and the Books-Copy join-request approval) exchanges:
   Signing Identity public key, device cert, books-set id, role offer,
   and a short-lived join nonce. Sync sessions are TLS 1.3 (or platform
   equivalent) with **certificate pinning** to the exchanged certs —
   no CA, no public internet PKI.
   - Sync payloads are length-prefixed messages:
     - `EntryBatch`: ordered journal entries (full signed rows +
       postings) the peer is missing, keyed by identity +
       `deviceChainSequence`.
     - `MetadataOps`: category/account/payee/template/membership/
       translation/settings ops with per-field timestamps.
     - `NoticeOps`: membership, reject, conflict, erase-status notices.
   - Private keys never appear in QR or payloads (ADR 0004).
   - **Alternative rejected:** Noise protocol without TLS — harder to
     reuse OS stack and store entitlements; TLS pinning is enough on a
     trusted LAN after QR exchange.

3. **Multi-chain verification: verify each entry against its
   `signedByIdentityId`; linked identities stay active.**
   Extends the Continuation model:
   - Every linked device's Signing Identity row stays **active** (not
     `continuedAt`) for as long as that device is a member.
   - Each device keeps its own chain tip / `deviceChainSequence` counter
     for entries *it* signs. Sync **inserts** peer entries; it never
     re-chains them under the local key.
   - `LedgerChainVerifier` walks entries grouped by
     `signedByIdentityId` (or equivalent per-identity previous-hash
     links). A break quarantines that identity's damaged tail only.
   - Balances count every verified entry from every active linked
     identity.
   - **Continuation vs link:** Continuation is one device replacing its
     own key after restore/key loss. Linking adds a *peer* identity.
     Do not set `continuedAt` on peer identities when someone joins.
   - **Trusted tip per identity:** `ledger_chain_state` gains
     per-identity tip columns (or a tip table keyed by identity id);
     the local device records new entries onto *its* tip only.

4. **Books switcher on disk: one SQLite file per books set; active id
   in SharedPreferences.**
   - Path pattern under the app support directory:
     `books/<booksSetId>/ledger.sqlite` (plus WAL/SHM sidecars).
   - Each set's Signing Identity private key is stored in secure storage
     under a key namespaced by `booksSetId`.
   - `activeBooksSetId` lives in SharedPreferences (device setting — does
     not sync, does not travel in a Books Copy of another set).
   - Opening the app opens only the active set's database. Switching
     closes the current Drift connection and opens the other file;
     UI state resets to that set's Home.
   - Creating a set runs New setup (or Restore from a copy) into a new
     id. Removing a set deletes that directory and its namespaced key
     material after confirmation.
   - **Alternative rejected:** multiple schemas in one SQLite file —
     couples wipe/backup/sync and risks cross-set queries.

5. **Acceptance: two in-memory devices in one process for CI; real
   two-device flagged manual.**
   - Harness builds two isolated stacks (database, identity, sync
     transport faked over in-process channels or loopback sockets with
     test certs) sharing no mutable state except the test-controlled
     network.
   - CI runs: join, sync entry batch, reject bad signature, competing
     Fix, metadata last-write-wins, erase-pending.
   - `tool/run_acceptance_tests.sh` gains an optional manual group
     `linked_devices_physical` that is skipped unless explicitly
     selected; docs state two phones/simulators on one Wi-Fi are
     required.

6. **Membership and roles storage.** Stored in the books database
   (shared): device id, display name, signing identity id, device cert
   fingerprint, role (Owner/Member), can-add flag, removed/erase
   pending timestamps. First device to create books is Owner. Sole-Owner
   claim is a membership op with `claimedAt` + 7-day effective time,
   cancelled by an Owner objection op that syncs like any other.

7. **Conflict rules (concrete).**
   - **Competing Fixes:** identify Fixes that reverse the same
     `reversesEntryId` (or the same original entry). Winner = lowest
     `(recordedAt, signedByIdentityId, entryId)` among the correcting
     entries. Loser is cancelled by a new system-authored reversal
     signed by the device that *detects* the conflict during merge
     (an ordinary journal entry, not an edit), plus a notice on both
     sides.
   - **Metadata fields:** last-write-wins per field using the op's
     `updatedAt` (device clock) with identity id as tie-break. Clocks
     are not trusted for security — only for merge preference among
     already-verified membership ops.

8. **Shared categories.** Category rows gain `defaultLocale` at books
   level plus a `category_translations` table `(categoryId, locale,
   name)`. Display picks app locale translation else default name.
   Merge creates a `category_merge` mapping from absorbed ids → survivor
   id for UI/totals; posting rows keep original `accountId` so hashes
   stay valid. Join path sets a flag `seedStarterCategories: false`.

9. **Settings sync.** Reuse project A's allowlists: books settings sync
   via MetadataOps; device settings stay local. Default category
   language is a books setting.

10. **Permissions copy.** First Linked devices open shows the fixed
    sentence from the issue, then the OS local-network prompt. Android
    may use nearby/Wi-Fi permissions as required by API level; same
    user-facing sentence first.

11. **No Android background sync / WorkManager.** Dropped the earlier
    "MAY sync briefly while backgrounded" idea. Sync already requires
    both devices open on the same Wi-Fi so mDNS discovery and the
    pinned TLS session can run; a periodic WorkManager job cannot find
    a peer that is not advertising, so it would mostly wake the device
    for no catch-up and fight the honest "both open" screen copy.
    Catch-up while both are foregrounded, plus Sync now, is enough.
    Spec updated accordingly (peer-sync "Sync When Both Open Plus Sync
    Now"; task 12.9).

## Risks / Trade-offs

- **[LAN only means no catch-up away from home]** → Accepted in #204;
  Books Copy remains the offline carry path; Sync now copy sets
  expectations.
- **[Device clock skew can flip last-write-wins]** → Tie-break by
  identity id; notices let people check; security still rests on
  signatures, not clocks.
- **[Competing Fix auto-cancel surprises users]** → Explicit notice to
  check; first-Fix-wins is deterministic.
- **[mDNS blocked on guest Wi-Fi / AP isolation]** → Join and sync fail
  closed with a plain "same Wi-Fi" message; no internet fallback.
- **[Multiple DB files increase backup complexity]** → Books Copy is
  always of the *active* set; switcher UI makes the active set obvious;
  reminder stays per-device but keyed by active set counters.
- **[Erase pending forever if device never returns]** → Honest status
  plus OS Find-my-device pointer; no pretend remote wipe.
- **[Dependency on project A]** → Do not ship Linked devices before
  Books Copy / Continuation / ADR 0004 land; tasks call that out.

## Migration Plan

1. Schema bump: membership tables, per-identity chain tips, category
   translations / merge map, books-set id. Existing single-DB installs
   become books set `default` (or a generated id) moved into
   `books/<id>/`; active id set in preferences; existing secure-storage
   key re-namespaced once.
2. Ship books switcher storage + multi-chain verifier before enabling
   discovery UI, so single-device users keep working.
3. Enable Linked devices UI, then peer sync, then shared-category
   translations.
4. **Rollback:** previous app versions cannot read multi-set paths or
   membership tables. Keep migrations additive/nullable where possible;
   a downgrade opens only the legacy single file if we keep a
   compatibility copy during one release, otherwise document
   "update required" for linked books. Prefer additive columns and a
   one-release dual-read of old path → new path.
5. Before archive: apply `CONTEXT.md` glossary terms (Linked Device,
   Peer Sync, Owner, Member, Books Set), update architecture "no
   networking" diagrams to show optional LAN peer sync, update privacy
   policy.

## Open Questions

None that block specs or tasks. Package choice for mDNS/TLS on Flutter
(e.g. which Bonjour plugin vs. Dart `multicast_dns` + `SecureSocket`)
is an implementation detail left to the apply phase, as long as the
service type, pinning, and payload shapes above hold.
