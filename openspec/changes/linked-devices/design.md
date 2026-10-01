## Context

See proposal.md for the motivation and issue #204 for the full grilling record. This design assumes `books-copy-and-continuation` has landed. That change gives us: a Books Copy holding the books, public identities and books settings; Restore (replace-only); Continuation (a new identity carries on from the last verified record); Device history; and ADR 0004 (the private key never leaves the device).

Constraints from the current code:
- **One database per device.** `getApplicationSupportDirectory()/smara_accounting.sqlite`, and one private key seed in secure storage under a single key name.
- **Device chain sequence.** `journal_entries.device_chain_sequence` is unique across the whole table, and `ledger_chain_state` holds a single tip.
- **What the entry hash covers:** the previous hash, id, sequence, transaction date, recordedAt, description, reversesEntryId, signedByIdentityId and postings (accountId, amountMinor). Account ids are UUID v4. `LedgerChainVerifier` already verifies against `signing_identities` public keys by id.
- **Settings** live in `SharedPreferencesAsync`, outside the database.
- **Starter categories** are stored with English names and localized on display (`system_name_localizer.dart`). They are seeded per device at onboarding with random ids.
- `Specs/architecture/smara-architecture.md` already fixes sync as LAN-only peer-to-peer, with no relay and no server.

## Goals / Non-Goals

**Goals:**
- Append-only replication of signed entries between linked devices, with every received record verified before it is accepted.
- Deterministic convergence for shared master data and for the "two fixes" case.
- A pairing flow that a non-technical person can complete in under a minute.
- Several sets of books per device, without weakening any integrity rule.

**Non-Goals:**
- Sync outside the local network (internet, relay, cloud).
- Partial visibility, where a device sees only part of the books. That arrives with `shared-accounts-and-expense-claims` (#205). This design only keeps the hooks it needs (decision 9).
- Claim, approve and receipt flows.
- Real-time collaboration while two people edit the same screen.

## Decisions

1. **Several sets of books are several database files.**
   - Layout: `books/<booksId>/smara.sqlite`, plus a small `books_index` file listing names and order.
   - Keys: each set's private key lives in secure storage under `signing_seed_<booksId>`.
   - Migration: an existing database becomes the first set unchanged.
   - Why: separate files keep sets truly separate (no cross-set query can leak), make a Books Copy per set trivial, and let the existing single-DB code run per set. Alternative: one database with a `books_id` column on every table. Rejected, because it touches every query and every hash input.

2. **One chain per signing identity.**
   - Uniqueness of `device_chain_sequence` moves from the whole table to (`signed_by_identity_id`, `device_chain_sequence`). `ledger_chain_state` holds one row per identity.
   - The verifier walks each identity's chain separately. A break in one chain quarantines that chain's tail only.
   - Hash inputs don't change, so existing entries keep verifying.
   - Alternative: one shared chain that all devices append to. Rejected, because it needs consensus on order across offline devices, which is exactly what a blockchain consensus layer solves and what households don't need.

3. **Pairing: QR code with a short authentication check.**
   - The QR code carries: the books id and name, the showing device's identity public key, its local address(es) and port, and a one-time pairing secret valid for 2 minutes.
   - The scanner connects and runs a mutually authenticated handshake (Noise XX pattern, with static keys derived from each device's transport keypair, bound to its signing identity by a signature). The handshake proves possession of the pairing secret.
   - Both screens show the same 4-emoji check code before data flows.
   - The showing device then streams the books (the same payload as a Books Copy, unencrypted at file level but inside the encrypted channel). The scanner seeds nothing and creates its own identity. Its identity is announced back as a signed "device added" record.
   - Alternatives: TLS with self-signed certificates pinned via the QR code (heavier certificate handling on mobile), or a PIN-only pairing (weaker against a nearby attacker).

4. **Discovery and transport.**
   - Discovery: mDNS/DNS-SD service `_smara-sync._tcp` on the local network.
   - Fallback: when discovery is blocked (Wi-Fi client isolation), the QR address is used directly, and "Sync now" retries known addresses.
   - Transport: a single TCP connection per sync session, with length-prefixed messages inside the Noise session.
   - Platform needs:
     - iOS: `NSLocalNetworkUsageDescription` and `NSBonjourServices`.
     - Android: `NEARBY_WIFI_DEVICES` on API 33+, otherwise `ACCESS_WIFI_STATE` plus a multicast lock.
     - macOS: the sandbox entitlements `network.client` and `network.server`.
   - Background: iOS syncs in the foreground only. Android uses a WorkManager one-off task when the network becomes available.

5. **Sync protocol: exchange of chain heads.**
   1. Each side sends, per identity, the highest device chain sequence it has.
   2. Each side then sends the entries the other lacks, in sequence order, plus master-data operations newer than the peer's last-seen marker.
   3. The receiver verifies every entry with the existing verifier before inserting, inside one transaction per batch.
   4. A failing entry and everything after it in that chain go to a `rejected_records` table, shown as "Not accepted", and an alert is raised for Owners.
   - Linked-device membership (added, removed, role, erase, claim) is carried as signed control records. These are ordinary chained entries with no postings and a control type, so they get the same integrity protection.
   - Removal is enforced at the receiver: entries signed by a removed identity with a recordedAt after the removal record are refused.

6. **Shared master data: a signed operation log with hybrid logical clocks.**
   - Changes to categories, accounts, groups, payees, rules, templates, limits, translations, merges and books settings are written as `master_ops` rows: entity, field, value, a hybrid-logical-clock timestamp, the device id and a signature.
   - The current state of each field is the value from the operation with the greatest (timestamp, device id). That gives "most recent change wins" with deterministic tie-breaking, regardless of arrival order.
   - Existing master data is converted into initial operations when books are first shared.
   - Alternatives: wall-clock last-writer-wins (clock skew between phones would flip results), or full CRDT libraries (more than these tables need).

7. **The first fix wins, resolved by the loser.**
   - A Fix is a reversal plus a new entry. After sync, if two reversals reference the same entry, the one with the earlier (recordedAt, identity id) is kept.
   - The device whose reversal lost creates a cancelling reversal of its own reversal and of its replacement entry, and posts a notice.
   - Only the losing device acts, so the cancellation is never duplicated, and both devices compute the same winner.
   - The existing `AlreadyReversedException` stays for the local case.

8. **Categories across languages.**
   - New table `category_names(category_id, locale, name)`. The default category language lives in the books settings.
   - Display order: translation for the device locale; else the stored default name; else, for an unchanged starter category, the localized seed label (today's behavior).
   - Merging: a `category_merges(from_id, into_id)` operation. Lists and totals resolve `from_id` to `into_id`, while entries keep their original ids, so hashes are unchanged. Automatic merges compare normalized names (case- and accent-insensitive) of the same type across all locales after each sync. Suggested merges compare a new translation against the other categories' names.
   - "Translate with AI" reuses the research-tool hand-off (ADR 0003 pattern): a URL with only the word and the target language.

9. **A hook for partial visibility (#205).** Every entry and master-data operation gets an optional `visibility_scope` (null means all members). This change always writes null. #205 will define scopes such as one person's account.

10. **Roles and ownership claims** are fields on the identity, changed only by signed control records. A claim record starts a 7-day timer, evaluated identically on every device from the claim's timestamp. An Owner's signed objection within the window cancels it.

## Risks / Trade-offs

- **[Phones on guest or office Wi-Fi with client isolation can't see each other]** → The QR address fallback, a clear "couldn't find your other device" message, and help text in the user guide.
- **[iOS only syncs while the app is open]** → Copy says so plainly ("catch up when both have Smara open"). The "Sync now" button and Home notices make the state visible.
- **[A removed or stolen device keeps its local books]** → Honest erase-on-next-contact, plus a pointer to the phone maker's find-and-erase service. Removal stops any new exchange.
- **[Clock skew on master data]** → Hybrid logical clocks, not wall time. Entries still record wall time for people, and the first-fix rule uses recordedAt only for ordering competing fixes, with the identity id as tie-breaker.
- **[Database growth from operation logs]** → Compact operations older than the last sync with every linked device into a snapshot row.
- **[Schema migration on existing installs]** → The uniqueness change and the new tables are additive, and run in the same Drift migration that moves the database into `books/<id>/`. They're covered by migration tests and an acceptance run on a copied real database.
- **[Merge mistakes]** → Automatic merges only for identical normalized names of the same type. Everything else is suggested, never automatic. Merges are recorded as operations, so a later "unmerge" is possible without touching entries.

## Migration Plan

1. Ship after `books-copy-and-continuation` is archived.
2. On first launch after the update:
   1. move the database into `books/<newId>/`;
   2. rename the key to `signing_seed_<newId>`;
   3. migrate the chain-state and uniqueness schema;
   4. fully verify.
   Sharing stays off until the person opens Linked devices.
3. **Rollback:** an older app version cannot read `books/`. The update keeps the original database file untouched until the first successful verification of the moved copy, then deletes it.
