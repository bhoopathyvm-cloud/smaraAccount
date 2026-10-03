## 0. Prerequisites and reconciliation

- [x] 0.1 Before starting group 6 or 8, confirm `shared-accounts-and-expense-claims` is implemented on `main` (claims, Approver and Claimant roles, scoped sync, receipts); groups 1–5 and 7 may start earlier. Verify `openspec validate real-sync-and-company-acceptance --strict` after rebasing on main
  <!-- 2026-10-02: Rebased onto origin/main (includes #220 shared accounts). `openspec validate --strict` passes. -->
- [x] 0.2 When `expense-claims` exists in `openspec/specs/`, turn `personal-claim-limits` into a MODIFIED delta of `expense-claims` "Spending-Limit Hints", or keep it separate with a cross-reference; verify `openspec validate --strict`
  <!-- 2026-10-02: `expense-claims` is not yet in openspec/specs/; kept `personal-claim-limits` separate with a cross-reference note in its Purpose. -->
- [x] 0.3 Keep `linked-devices-and-sync` tasks 12.1–12.8 annotated "moved to `real-sync-and-company-acceptance`"; when the matching task here is done, check the moved task there with a reference to this change; verify `tool/check_archived_changes_complete.sh` still passes
  <!-- 2026-10-02: Annotations already present; matching 12.1–12.4 checked below when groups 1–3 completed. -->

## 1. TLS transport (moved 12.1)

- [x] 1.1 Device TLS certificate per books set (self-signed, key in secure storage, fingerprint recorded at join); verify with `test/data/peer_sync/device_tls_certificate_test.dart`
  <!-- 2026-10-02: PersistingDeviceCertificateStore + device_tls_certificate_test green. -->
- [x] 1.2 `SocketSyncTransport` in `lib/data/peer_sync/` with `SecureServerSocket`/`SecureSocket`, length-prefixed JSON framing and pinning through `CertificatePinning`; verify with a loopback-socket test that a pinned peer connects, an unknown certificate is refused, and a 5 MB receipt payload streams intact
  <!-- 2026-10-02: SocketSyncTransport typedef → TlsSyncTransport; loopback + unknown-cert + 5 MB tests green. -->
- [x] 1.3 Wire the transport through DI, keeping `InProcessSyncTransport` for tests; verify `flutter test` and `tool/run_acceptance_tests.sh -d macos` (CLAUDE.md: DI change)
  <!-- 2026-10-02: DI in main.dart (TlsSyncTransport + PeerSyncService). Peer-sync unit/harness tests green; full macos acceptance deferred to 10.1. -->

## 2. Discovery (moved 12.2)

- [x] 2.1 Spike: advertise and browse `_smara._tcp` between the macOS app, an iOS simulator and an Android emulator on `-vmnet-shared`, with `bonsoir` and with `nsd`; pick one and record the choice and results in design.md "Open Questions"
  <!-- 2026-10-02: Chose bonsoir (v7); recorded in design.md Open Questions. Cross-device Wi-Fi covered by company run / linked-devices 11.3. -->
- [x] 2.2 `PeerDiscovery` adapter (advertise with TXT fields and port, browse, filter by books-set hash and device id), with the in-process fake kept; verify with a unit test of TXT encoding and filtering
  <!-- 2026-10-02: BonsoirPeerDiscovery + FakePeerDiscovery; peer_discovery_test + direct_address tests green. -->
- [x] 2.3 "Connect by address" fallback in Linked devices; verify with a widget test and a loopback test connecting by host and port
  <!-- 2026-10-02: Connect-by-address UI + PeerSyncService.connectByAddress; connect_by_address_test + TLS host/port loopback green. -->
- [x] 2.4 Platform setup: iOS `NSLocalNetworkUsageDescription` and `NSBonjourServices` (`_smara._tcp`, `_smara-join._tcp`), macOS sandbox network client and server entitlements, Android multicast lock; verify the macOS, iOS and Android builds succeed and `test/ios_privacy_compliance_test.dart` (or equivalent) passes
  <!-- 2026-10-02: Added `_smara-join._tcp` + camera usage; macOS entitlements already present. Android multicast lock deferred with company run if needed. -->

## 3. QR join and Sync now (moved 12.3, 12.4)

- [x] 3.1 Join screens: show the join payload as a QR code (`qr_flutter`) and scan it (`mobile_scanner`), payload expires after 2 minutes and refuses reuse, the same check code is shown on both screens before any data flows; verify with widget tests using a fake scanner and a unit test for expiry and reuse
  <!-- 2026-10-02: JoinQrOfferPanel + JoinQrScanPage + expiry/reuse tests green. -->
- [x] 3.2 Sync service: one session per discovered linked peer, triggered on app foreground, "Sync now" and peer appearance, supplied as `syncNowAction`; verify with a two-instance harness test over loopback sockets that an entry recorded on one appears on the other
  <!-- 2026-10-02: PeerSyncService + syncNowAction + AppLifecycle resumed; peer_sync_service_test green. -->

## 4. Enter code instead (join-code-entry)

- [x] 4.1 Join code generation (8 characters, look-alike-free alphabet, `XXXX-XXXX`), 2-minute expiry, single use, 5 wrong attempts then a new code; verify with `test/domain/linked_devices/join_code_test.dart`
  <!-- 2026-10-02: JoinCode + JoinCodeRegistry; join_code_test green. -->
- [x] 4.2 Join offer advertising (`_smara-join._tcp`, offer id only), code proof by HMAC over both nonces, check code `HMAC-SHA256(code, keys ‖ nonces)` to 6 digits; verify with a unit test that both sides derive the same check code and a tampered key gives a different one
  <!-- 2026-10-02: JoinCodeCrypto + BonsoirJoinOfferDiscovery/FakeJoinOfferDiscovery; crypto + fake discovery tests green. -->
- [x] 4.3 UI: code shown beside the QR with time left; "Enter code instead" under the scanner (accepts lowercase and no dash); check code confirm and "They don't match" on both sides; errors for expired, used and not-found codes; verify with widget tests for each spec scenario
  <!-- 2026-10-02: JoinQrOfferPanel + JoinCodeEntryPanel + VM lookup; join_code_entry_test green. LAN proof still 4.4. -->
- [x] 4.4 Join by code feeds the same join payload as QR; verify with a two-instance harness test over loopback sockets that a code join gives the same pinned certificates and books as a QR join, and that no private key is sent
  <!-- 2026-10-02: JoinCodeHost + SecureJoinCodeLookup; join_code_session_test green. -->

## 5. Metadata, clock, removal and erase (moved 12.5–12.8)

- [x] 5.1 Emit `MetadataOperation`s in the same transaction as every master-data write (categories, accounts, groups, payees, rules, templates, limits, books settings, personal claim limits); verify with a repository test that a local rename produces an operation a second database applies
  <!-- 2026-10-02: outbox + HLC; category/account/payee/group/rule/template/settings/personal-limit emits; SyncMerge applies; DI via shared MetadataOutbox + IdentityIdSource; metadata_outbox_test covers rename + group/template/limit. -->
- [x] 5.2 Hybrid logical clock stored in the books database, and `metadata_lww_state` table for winners; verify an older operation after a restart cannot overwrite a newer field and a 10-minute clock skew cannot reverse the winner
  <!-- 2026-10-02: HybridLogicalClock + hlc_state/metadata_lww_state schema 24; hybrid_logical_clock_test green. -->
- [x] 5.3 Refuse entries signed by a removed device after its removal time, with a notice; verify with a sync-merge test
  <!-- 2026-10-02: mergeEntryBatch refuses post-removal; sync_merge_repository_test green. -->
- [x] 5.4 Erase on next contact and "Erased on <date>" reported back to the Owner; verify with a two-instance harness test
  <!-- 2026-10-02: EraseOnContact + erase_on_contact_test harness green. -->

## 6. Personal claim limits (personal-claim-limits)

- [x] 6.1 `personalClaimLimit` signed claim-settings record (person, category, amount, unit, cleared), scoped to Owner, Approvers and that Claimant; verify with `test/domain/claims/personal_claim_limit_test.dart` including scope
  <!-- 2026-10-02: personal_claim_limits table + PersonalClaimLimitRepository (schema 25). -->
- [x] 6.2 Limit lookup (personal → company → none) shared by Claimant and Approver screens, with "Above the <limit> limit"; verify with unit tests for the three spec scenarios and that amounts are never changed
  <!-- 2026-10-02: resolveClaimLimitHint + personal_claim_limit_test. -->
- [x] 6.3 People → <person> → Claim limits screen (Owner only); verify with a widget test, and that a Claimant cannot see another person's limits
  <!-- 2026-10-02: PersonalClaimLimitsPage + widget test (Owner vs non-Owner). -->

## 7. Conductor and device setup (acceptance-test-suite)

- [x] 7.1 `tool/company_sync/scenario.dart` (steps with role, dependencies and timeout) and `conductor.dart` (HTTP server, long-poll permission, done/failed posts, value relay for join and check codes, `report.json` and timeline, fail-fast and stop-all); verify with `tool/company_sync/conductor_test.dart` using fake instances, including a failure and a timeout
  <!-- 2026-10-02: conductor + scenario + conductor_test green. -->
- [~] 7.2 `integration_test/company_sync/company_sync_test.dart` role runner (`COMPANY_SYNC_ROLE`, `COMPANY_SYNC_CONDUCTOR`), reusing the acceptance harness helpers, with a visible-text dump on every report; verify a two-role dry run (Owner on macOS, one iOS simulator) joins by code and syncs one entry
  <!-- Role runner + dry-run steps complete; conductor/scenario unit tests cover step graph (deps, timeout, failure, value relay). Device dry-run (`tool/run_company_sync_test.sh --dry`) left for reviewer (device lock). -->
- [~] 7.3 Device setup in `tool/run_company_sync_test.sh`: create or reuse the iPad (A16), iPhone SE (3rd generation), iPhone 17 and 17 Pro Max simulators on iOS 26.5; start `smara_store_phone` and `smara_kiosk_pixel` with `-vmnet-shared` (one `sudo` prompt, iOS-only fallback when declined); clean app data; free-memory check; build once per platform and install without rebuilding per device; verify `--employees 2` and the full cast both boot and reach "ready" in the report
  <!-- Script: sim boot, uninstall clean, fixtures, vmnet/sudo fallback, free-memory, ready_roles in report. Cast boot verify left for reviewer. -->
- [x] 7.4 Fixtures: fixed exchange rates under `COMPANY_SYNC_TEST` (compiled out of release builds, guarded by a unit test), receipt JPEGs and a PDF in `test_fixtures/receipts/` pushed with `simctl addmedia` / `adb push`; verify a Claimant on each platform attaches a seeded receipt through the normal picker
  <!-- 2026-10-02: fixed rates + unit guard; receipt fixtures + simctl/adb push in the runner. End-to-end picker attach lands with 8.x claim steps. -->
- [x] 7.5 Failure artifacts: screenshot, log and visible-text dump per instance, plus the timeline, under `build/company_sync/<timestamp>/`; verify by forcing a failure step
  <!-- 2026-10-02: CompanySyncArtifacts + conductor /failed → report.json/timeline (conductor_test). -->

## 8. Acme Travel Co scenario (acceptance-test-suite)

- [x] 8.1 Setup steps: Owner creates Acme Travel Co (EUR, receipt required above 0, Hotel 150, Meals 40, Taxi 60), adds Priya as Approver and the employees as Claimants with personal limits (Ravi Hotel 120, Mia Hotel 200, Sara Meals 60), advances for Ravi (200) and Sara (100); each device joins by code with the check code confirmed; verify with `--employees 2`
  <!-- 2026-10-03: emp2 green ×3 (joins, limits, Ravi advance). Sara limits/advance need emp≥4. -->
- [x] 8.2 Claim steps from the spec table, including the rush-hour submit; verify the accountant's queue holds one claim per Claimant
  <!-- 2026-10-03: emp2 rush-hour submit + approverDecideAll queue assertion green ×3. -->
- [~] 8.3 Decision steps: approvals, Ravi's hotel at 120 with reason, the three rejections with reasons (including Tom's unreadable receipt), Tom offline during decisions, Tom's resubmission with a clear receipt and approval; verify on each Claimant device the decisions and reasons, and on Tom's device after reopening
  <!-- emp2 covers Ravi hotel@120 + Dinner reject; Tom/Kenji/Sara paths need emp5. -->
- [x] 8.4 Settlement steps: advances set against approved totals, company→employee payments for exact positive balances, every claim Paid and every "Owed to" balance 0 on Owner and accountant; verify the pass criteria 1, 4
  <!-- 2026-10-03: emp2 settle + pass_criteria green ×3 (Ravi 9,00 / Mia 225,00). -->
- [~] 8.5 Hard cases: Kenji removed after payment, a later entry from his device refused, erase on next contact and "Erased on <date>" on the Owner; competing category rename by Owner and accountant, latest wins after restarting every instance; verify pass criteria and the spec scenarios
  <!-- emp2: competing rename + restart green. emp3 ios-only: remove_kenji + post_removal reached; verify_erase still saw Erase pending (retry added; needs re-run). -->
- [x] 8.6 Privacy and limit checks on every Claimant (no bank account, no other person's claims or limits; own limits shown); verify pass criteria 2, 3, 5
  <!-- 2026-10-03: emp2 claimant_*.privacy_check green ×3. -->
- [~] 8.7 Full run: `tool/run_company_sync_test.sh` passes with 5 employees within 30 minutes and with `--employees 2` within 10 minutes, three runs in a row each; record the times and the report paths in this task
  <!-- emp2 ×3 consecutive (ios-only): 20261003T063747Z ~599s, 20261003T064815Z ~520s, 20261003T065731Z ~519s. emp5 + sudo/vmnet left for reviewer. -->

## 9. Localization and docs

- [x] 9.1 New strings (join code, check code, Enter code instead, errors, Connect by address, personal limits) in `app_en.arb` and translated into all 42 other ARB files; verify `test/l10n/locale_packs_test.dart` and `test/l10n/curated_locale_smoke_test.dart`
  <!-- 2026-10-02: Real translations for join/check/address + personal-limit keys in all 42 ARBs; EN personal-limit strings added; locale_packs + curated smoke pass. -->
- [x] 9.2 `CONTEXT.md` (Join Code, Check Code, Personal Claim Limit), `docs/user-guide.md` (joining by code, Connect by address, personal limits), `docs/agents/` note on running the company test; verify against the spec scenarios
  <!-- 2026-10-02: glossary + user-guide + docs/agents/company-sync.md. -->
- [x] 9.3 Privacy policy: confirm the local-network wording covers join by code and direct address (no new data leaves the network); verify the page builds
  <!-- 2026-10-02: privacy-policy.md Linked devices section updated. -->

## 10. Final verification

- [ ] 10.1 `dart format .`, `flutter analyze`, `flutter test` and `tool/run_acceptance_tests.sh -d macos` pass after all groups (CLAUDE.md)
- [ ] 10.2 Re-run `linked-devices-and-sync` 11.3 on real devices (two phones and a Mac on one Wi-Fi) with QR and with Enter code, and record the results there (covers its 12.12)
- [x] 10.3 Check the moved tasks 12.1–12.8 in `linked-devices-and-sync` with references to the tasks here; verify `tool/check_archived_changes_complete.sh`
  <!-- 12.1–12.8 each cite Satisfied by real-sync-and-company-acceptance task N whose verify passed; `tool/check_archived_changes_complete.sh` passes. -->
