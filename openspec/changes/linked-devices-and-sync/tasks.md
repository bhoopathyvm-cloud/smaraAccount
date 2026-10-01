# Tasks

## 1. Prerequisites and schema foundations

- [x] 1.1 Confirm `books-copy-and-continuation` (project A / ADR 0004) is merged or available on the implementation branch; if not, land or rebase onto it first — verify Books Copy, Continuation, and the shared-vs-device settings split compile and their unit tests pass
- [x] 1.2 Add Drift schema for linked-device membership (device id, display name, signing identity id, device cert fingerprint, role, can-add, removed/erase-pending timestamps), per-identity chain tips, category translations, category-merge map, and books-set metadata; bump schema version with a migration that moves the existing single DB into `books/<id>/` and namespaces the existing secure-storage key — verify `app_database_migration_test` upgrades from the prior schema version
- [x] 1.3 Implement books-set path helpers (app support `books/<booksSetId>/ledger.sqlite`, `activeBooksSetId` in SharedPreferences, namespaced secure-storage keys) and verify unit tests cover create/open/switch/remove path selection without touching unrelated sets

## 2. Books switcher

- [x] 2.1 Implement books-set repository: create set (New setup into a new id), list sets, rename, remove set (delete directory + namespaced key after confirm), switch active set (close Drift connection, open other file) — verify `test/data/repositories/books_set_repository_test.dart` covers independence of two sets' entries and keys
- [x] 2.2 Wire books switcher UI (list by user-visible name, switch active set, create/remove) in Settings or shell; after switch, Home/Register/Linked devices refer to the new set — verify widget tests for switcher list and that Home rebuilds against the newly opened database
- [x] 2.3 Ensure Books Copy save/restore and backup reminder operate on the active set only — verify unit/widget tests that a copy from set A does not include set B's entries

## 3. Multi-chain verification

- [x] 3.1 Extend `LedgerChainVerifier` to verify each entry against `signedByIdentityId`'s public key and walk per-identity hash chains; quarantine only the damaged identity's tail — verify repository/verifier tests with two active identities, a break on one chain, and a missing public key failing closed
- [x] 3.2 Update identity/chain-state so linked peer identities remain active (not `continuedAt`) when joining; local device still signs only onto its own tip — verify tests that Continuation still sets `continuedAt` on key loss/restore, while linking does not
- [x] 3.3 Startup verification uses the multi-chain walk and balances include all verified linked identities' entries — verify existing integrity tests still pass and new multi-identity fixture balances are correct

## 4. Linked devices membership and roles

- [ ] 4.1 Implement membership repository: Owner/Member roles, add/remove, erase-pending/erased timestamps, can-add policy, sole-Owner claim with 7-day effective time and Owner objection cancel, second-Owner suggestion flag — verify unit tests for role gates, claim timing, and objection cancel
- [ ] 4.2 Build Settings "Linked devices" section and "Add a device" entry with catch-up copy and first-open local-network permission sentence — verify widget tests for labels, copy, and that the permission explanation precedes the OS prompt hook
- [ ] 4.3 Implement QR join payload (signing public key, device cert, books-set id, role offer, join nonce) with no private key bytes; reject join when peers are not on the local network — verify unit tests for payload round-trip and that private key material is absent
- [ ] 4.4 Implement Books-Copy-then-join-request + one-tap approve/refuse on an already-linked device — verify unit/widget tests for approve links the requester and refuse leaves membership unchanged
- [ ] 4.5 Membership notices (added/removed/erase status) stored for Home and Device history display at next sync — verify unit tests that notices are created on membership ops and surfaced to the notice feed

## 5. Peer discovery and TLS transfer

- [ ] 5.1 Advertise/browse mDNS service `_smara._tcp` with TXT books-set id hash, device display name, protocol version; gate on local-network permission — verify unit/integration tests with a fake discovery adapter that two peers filter to the same books set and ignore others
- [ ] 5.2 Implement TLS sync transport with pinned device certificates from join; refuse unknown certs; payloads are EntryBatch / MetadataOps / NoticeOps without private keys — verify unit tests for pin accept/reject and payload serialization
- [ ] 5.3 Sync session: when both apps open on same LAN and on "Sync now"; Android brief background sync where OS allows; never use internet relay — verify tests with the in-process transport that Sync now exchanges missing entries and that a "remote network" fake does not connect

## 6. Sync merge and conflicts

- [ ] 6.1 Entry merge inserts peer-signed rows never editing existing ones; skip duplicates by identity + `deviceChainSequence` — verify merge tests that A's entry appears on B unchanged on A
- [ ] 6.2 Reject entries that fail verification; record "Not accepted: couldn't be verified (from \<device\>)" and Owner alert notice — verify tests with a tampered signature
- [ ] 6.3 Competing Fixes: first Fix wins by `(recordedAt, signedByIdentityId, entryId)`; loser cancelled by a new signed cancel record; both sides get a check notice — verify deterministic winner tests
- [ ] 6.4 Metadata last-write-wins per field for category/account ops with identity tie-break — verify field-independent merge tests
- [ ] 6.5 Apply MetadataOps for shared books settings only; device settings never overwrite from peer — verify settings allowlist tests aligned with Books Copy split

## 7. Shared categories

- [ ] 7.1 Category default language (books setting) + `category_translations` CRUD; display prefers app-locale translation then default — verify unit and widget tests for fallback and translation sync via MetadataOps
- [ ] 7.2 "Translate with AI" handoff passes only the category name through the Research Tool path — verify unit test that the prompt/clipboard payload contains only that text
- [ ] 7.3 Automatic merge on same name+type across languages, suggested merge when a translation matches, manual "Merge categories"; UI/totals use merge map; postings keep original ids — verify merge tests and that entry hashes still verify
- [ ] 7.4 Joining device skips starter categories (`seedStarterCategories: false`) and uses received catalog — verify join/onboarding test that starters are not inserted on successful link into existing books

## 8. Platform permissions, privacy, sandbox

- [ ] 8.1 iOS/macOS Info.plist local-network usage strings and Bonjour entitlements; Android local-network/nearby permissions as required — verify plist/entitlements/manifest contain the declarations and match the in-app sentence
- [ ] 8.2 Update privacy policy page for LAN discovery/sync (nothing leaves the LAN; no server) and keep ios-privacy-compliance declarations consistent — verify a doc review checklist / grep that policy mentions Linked devices LAN sync
- [ ] 8.3 macOS sandbox entitlements include minimum Bonjour/local-network client rights; confirm sandboxed build still saves Books Copies — verify entitlements file and existing sandbox file-export scenarios still apply

## 9. Dual-device harness and acceptance

- [ ] 9.1 Build two-in-memory-device harness (isolated DB, identity, test certs, in-process or loopback transport) reusable by unit/integration tests — verify harness smoke test creates A/B, links, and syncs one entry
- [ ] 9.2 Add acceptance/integration group for linked devices covering join, sync, reject bad signature, competing Fix, metadata LWW, erase-pending using the harness — verify the group runs in CI without physical devices
- [ ] 9.3 Flag physical two-device acceptance as manual (`linked_devices_physical` or equivalent), document Wi-Fi prerequisites, and ensure default `tool/run_acceptance_tests.sh` skips it — verify script help/docs and that default invocation does not require two devices
- [ ] 9.4 Extend acceptance coverage listing in suite docs/specs wiring so Linked devices, shared categories, and books switcher groups are independently runnable — verify `tool/run_acceptance_tests.sh -d macos <group>` for each new group that is GUI-based, and harness group for sync

## 10. Localization, docs, glossary

- [ ] 10.1 Add English ARB strings for Linked devices, Add a device, Sync now, catch-up copy, permission sentence, roles, notices, erase pending, category merge/translate, books switcher; run `flutter gen-l10n` — verify gen-l10n succeeds and widget tests use the new keys
- [ ] 10.2 Update `docs/user-guide.md` for Linked devices, sync, roles, erase, shared categories, books switcher — verify guide sections exist and do not claim a cloud sync service
- [ ] 10.3 Apply `CONTEXT.md` glossary updates when landing (Linked Device, Peer Sync, Owner, Member, Books Set; widen opening beyond single-device); update `Specs/architecture/smara-architecture.md` optional LAN peer-sync note — verify glossary terms match household tone and avoid banned synonyms from the grilling (_Avoid_ lines)

## 11. Integration check

- [ ] 11.1 Run `flutter analyze` and the unit/widget suites touched by this change; fix regressions — verify clean analyze and test pass for books-switcher, membership, verifier, merge, categories, harness
- [ ] 11.2 Run acceptance on macOS for non-manual groups including any new GUI groups; run dual-device harness group in CI configuration — verify `tool/run_acceptance_tests.sh -d macos` (or documented subset) passes
- [ ] 11.3 Manual spot-check on two real devices/simulators on one Wi-Fi: Add a device via QR, Sync now, confirm entry appears, confirm erase pending copy — record result in this task (manual flag satisfied even if CI skips it)
