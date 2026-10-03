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

- [x] 4.1 Implement membership repository: Owner/Member roles, add/remove, erase-pending/erased timestamps, can-add policy, sole-Owner claim with 7-day effective time and Owner objection cancel, second-Owner suggestion flag — verify unit tests for role gates, claim timing, and objection cancel
- [x] 4.2 Build Settings "Linked devices" section and "Add a device" entry with catch-up copy and first-open local-network permission sentence — verify widget tests for labels, copy, and that the permission explanation precedes the OS prompt hook
- [x] 4.3 Implement QR join payload (signing public key, device cert, books-set id, role offer, join nonce) with no private key bytes; reject join when peers are not on the local network — verify unit tests for payload round-trip and that private key material is absent
- [x] 4.4 Implement Books-Copy-then-join-request + one-tap approve/refuse on an already-linked device — verify unit/widget tests for approve links the requester and refuse leaves membership unchanged
- [x] 4.5 Membership notices (added/removed/erase status) stored for Home and Device history display at next sync — verify unit tests that notices are created on membership ops and surfaced to the notice feed

## 5. Peer discovery and TLS transfer

- [x] 5.1 Advertise/browse mDNS service `_smara._tcp` with TXT books-set id hash, device display name, protocol version; gate on local-network permission — verify unit/integration tests with a fake discovery adapter that two peers filter to the same books set and ignore others
- [x] 5.2 Implement TLS sync transport with pinned device certificates from join; refuse unknown certs; payloads are EntryBatch / MetadataOps / NoticeOps without private keys — verify unit tests for pin accept/reject and payload serialization
- [x] 5.3 Sync session: when both apps open on same LAN and on "Sync now"; Android brief background sync where OS allows; never use internet relay — verify tests with the in-process transport that Sync now exchanges missing entries and that a "remote network" fake does not connect

## 6. Sync merge and conflicts

- [x] 6.1 Entry merge inserts peer-signed rows never editing existing ones; skip duplicates by identity + `deviceChainSequence` — verify merge tests that A's entry appears on B unchanged on A
- [x] 6.2 Reject entries that fail verification; record "Not accepted: couldn't be verified (from \<device\>)" and Owner alert notice — verify tests with a tampered signature
- [x] 6.3 Competing Fixes: first Fix wins by `(recordedAt, signedByIdentityId, entryId)`; loser cancelled by a new signed cancel record; both sides get a check notice — verify deterministic winner tests
- [x] 6.4 Metadata last-write-wins per field for category/account ops with identity tie-break — verify field-independent merge tests
- [x] 6.5 Apply MetadataOps for shared books settings only; device settings never overwrite from peer — verify settings allowlist tests aligned with Books Copy split

## 7. Shared categories

- [x] 7.1 Category default language (books setting) + `category_translations` CRUD; display prefers app-locale translation then default — verify unit and widget tests for fallback and translation sync via MetadataOps
- [x] 7.2 "Translate with AI" handoff passes only the category name through the Research Tool path — verify unit test that the prompt/clipboard payload contains only that text
- [x] 7.3 Automatic merge on same name+type across languages, suggested merge when a translation matches, manual "Merge categories"; UI/totals use merge map; postings keep original ids — verify merge tests and that entry hashes still verify
- [x] 7.4 Joining device skips starter categories (`seedStarterCategories: false`) and uses received catalog — verify join/onboarding test that starters are not inserted on successful link into existing books

## 8. Platform permissions, privacy, sandbox

- [x] 8.1 iOS/macOS Info.plist local-network usage strings and Bonjour entitlements; Android local-network/nearby permissions as required — verify plist/entitlements/manifest contain the declarations and match the in-app sentence
- [x] 8.2 Update privacy policy page for LAN discovery/sync (nothing leaves the LAN; no server) and keep ios-privacy-compliance declarations consistent — verify a doc review checklist / grep that policy mentions Linked devices LAN sync
- [x] 8.3 macOS sandbox entitlements include minimum Bonjour/local-network client rights; confirm sandboxed build still saves Books Copies — verify entitlements file and existing sandbox file-export scenarios still apply

## 9. Dual-device harness and acceptance

- [x] 9.1 Build two-in-memory-device harness (isolated DB, identity, test certs, in-process or loopback transport) reusable by unit/integration tests — verify harness smoke test creates A/B, links, and syncs one entry
- [x] 9.2 Add acceptance/integration group for linked devices covering join, sync, reject bad signature, competing Fix, metadata LWW, erase-pending using the harness — verify the group runs in CI without physical devices
- [x] 9.3 Flag physical two-device acceptance as manual (`linked_devices_physical` or equivalent), document Wi-Fi prerequisites, and ensure default `tool/run_acceptance_tests.sh` skips it — verify script help/docs and that default invocation does not require two devices
- [x] 9.4 Extend acceptance coverage listing in suite docs/specs wiring so Linked devices, shared categories, and books switcher groups are independently runnable — verify `tool/run_acceptance_tests.sh -d macos <group>` for each new group that is GUI-based, and harness group for sync

## 10. Localization, docs, glossary

- [x] 10.1 Add English ARB strings for Linked devices, Add a device, Sync now, catch-up copy, permission sentence, roles, notices, erase pending, category merge/translate, books switcher; run `flutter gen-l10n` — verify gen-l10n succeeds and widget tests use the new keys
- [x] 10.2 Update `docs/user-guide.md` for Linked devices, sync, roles, erase, shared categories, books switcher — verify guide sections exist and do not claim a cloud sync service
- [x] 10.3 Apply `CONTEXT.md` glossary updates when landing (Linked Device, Peer Sync, Owner, Member, Books Set; widen opening beyond single-device); update `Specs/architecture/smara-architecture.md` optional LAN peer-sync note — verify glossary terms match household tone and avoid banned synonyms from the grilling (_Avoid_ lines)

## 11. Integration check

- [x] 11.1 Run `flutter analyze` and the unit/widget suites touched by this change; fix regressions — verify clean analyze and test pass for books-switcher, membership, verifier, merge, categories, harness
- [x] 11.2 Run acceptance on macOS for non-manual groups including any new GUI groups; run dual-device harness group in CI configuration — verify `tool/run_acceptance_tests.sh -d macos` (or documented subset) passes
  <!-- 2026-10-01: `tool/run_acceptance_tests.sh -d macos` (incl. books_switcher, shared_categories) — 45 passed, 1 skipped (manual linked_devices_physical); harness group `linked_devices` — 6 passed. -->
- [ ] 11.3 Manual spot-check on two real devices/simulators on one Wi-Fi: Add a device via QR, Sync now, confirm entry appears, confirm erase pending copy — record result in this task (manual flag satisfied even if CI skips it)
  <!-- Cloud agent cannot satisfy physical two-device spot-check; group `linked_devices_physical` remains manual/skipped by default. -->

## 12. Gaps found in review (2026-10-01)

A comparison with the duplicate proposal `linked-devices` (#209), and a check of the code on `main`, found that several boxes above were ticked against test seams, not working device-to-device behavior. These tasks keep the change open until two real devices can share books.

- [x] 12.1 Real TLS transport: implement the `SecureSocket`/`SecureServerSocket` adapter behind `SyncTransport` with certificate pinning (only `InProcessSyncTransport` exists; `sync_transport.dart` says "Real SecureSocket adapters land later"); verify with a loopback-socket test that a pinned peer connects and an unknown certificate is refused
  <!-- Satisfied by real-sync-and-company-acceptance task 1.2 (loopback pin/refuse/5 MB verify passed). -->
- [x] 12.2 Real mDNS discovery: a Bonjour/NSD adapter for `_smara._tcp` (advertise and browse) plus a direct-address fallback when discovery is blocked; verify on macOS ↔ iOS and macOS ↔ Android on one Wi-Fi
  <!-- Satisfied by real-sync-and-company-acceptance tasks 2.2–2.3 (unit + connect-by-address verify passed). Cross-device Wi-Fi remains under 11.3 / real-sync 10.2. -->
- [x] 12.3 QR join screens: show the join payload as a QR code and scan it with the camera (no QR rendering or scanning exists in `lib/`); make the join payload expire after 2 minutes and refuse reuse; show the same short check code on both screens before any data flows; verify with widget tests using a fake scanner and a unit test for expiry and reuse
  <!-- Satisfied by real-sync-and-company-acceptance task 3.1 (widget + expiry/reuse verify passed). -->
- [x] 12.4 Wire "Sync now" and automatic sync on app foreground to the real transport (`syncNowAction` is never supplied, so the button does nothing in the app); verify on two devices that an entry recorded on one appears on the other
  <!-- Satisfied by real-sync-and-company-acceptance task 3.2 (two-instance harness verify passed). -->
- [x] 12.5 Emit `MetadataOperation`s from every local master-data write (categories, accounts, groups, payees, rules, templates, limits, books settings); nothing emits them today; verify with a repository test that a local rename produces an operation that a second database applies
  <!-- Satisfied by real-sync-and-company-acceptance task 5.1 (repository rename→apply verify passed). -->
- [x] 12.6 Persist last-write-wins state (`SyncMergeRepository.metadataState` is in memory only, so a restart forgets which change won) and order operations by a hybrid logical clock instead of the device's wall clock; verify that an older operation arriving after a restart cannot overwrite a newer field, and that clock skew between devices cannot reverse the winner
  <!-- Satisfied by real-sync-and-company-acceptance task 5.2 (HLC + metadata_lww_state verify passed). -->
- [x] 12.7 Removal enforcement: refuse entries signed by a removed device after its removal (no check exists in the merge path); verify with a sync-merge test
  <!-- Satisfied by real-sync-and-company-acceptance task 5.3 (sync-merge refuse verify passed). -->
- [x] 12.8 Erase on next contact: when a removed device with a pending erase meets a linked device, erase its copy of the books and report "Erased on <date>" back (only the pending/erased timestamps exist); verify with a two-instance harness test
  <!-- Satisfied by real-sync-and-company-acceptance task 5.4 (erase-on-contact harness verify passed). -->
- [x] 12.9 Android background sync where the system allows it (no WorkManager or equivalent exists); verify an Android-only scheduling test, or record a decision to drop it from the spec
  <!-- Decision (2026-10-03): drop from peer-sync. Sync needs both apps open on the same Wi-Fi for mDNS + pinned TLS; WorkManager would mostly wake for no peer and contradicts the "both open" copy. See design.md Decision 11; peer-sync / proposal updated. -->
- [x] 12.10 Show the books set's name in the switcher instead of its raw id (noted in PR #216); verify with a widget test
- [x] 12.11 Translate this change's 46 new strings (Linked devices, notices, books switcher, category translation and merge) into all 42 non-English ARB files and clear them from `lib/l10n/untranslated.json`; verify `test/l10n/locale_packs_test.dart` and the localized smoke workflow
  <!-- 2026-10-03: 103 untranslated keys (claims + linked devices + books switcher + category translation/merge, incl. settingsBooksSwitcherFallbackName) translated into all 42 locales; placeholders checked; untranslated.json empty; locale_packs/curated smoke/acceptance fixtures + full flutter test green. Lower-resource locales (brx, doi, kok, ks, mai, mni, sa, sat) are best-effort and would benefit from native review, as for the original i18n / books-copy passes. -->
- [ ] 12.12 After 12.1–12.8, re-run 11.3 on real devices (two phones and a Mac on one Wi-Fi) and record the results
