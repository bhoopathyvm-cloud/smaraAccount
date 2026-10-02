## 0. Prerequisites and reconciliation

- [ ] 0.1 Before starting group 6 or 8, confirm `shared-accounts-and-expense-claims` is implemented on `main` (claims, Approver and Claimant roles, scoped sync, receipts); groups 1–5 and 7 may start earlier. Verify `openspec validate real-sync-and-company-acceptance --strict` after rebasing on main
- [ ] 0.2 When `expense-claims` exists in `openspec/specs/`, turn `personal-claim-limits` into a MODIFIED delta of `expense-claims` "Spending-Limit Hints", or keep it separate with a cross-reference; verify `openspec validate --strict`
- [ ] 0.3 Keep `linked-devices-and-sync` tasks 12.1–12.8 annotated "moved to `real-sync-and-company-acceptance`"; when the matching task here is done, check the moved task there with a reference to this change; verify `tool/check_archived_changes_complete.sh` still passes

## 1. TLS transport (moved 12.1)

- [ ] 1.1 Device TLS certificate per books set (self-signed, key in secure storage, fingerprint recorded at join); verify with `test/data/peer_sync/device_tls_certificate_test.dart`
- [ ] 1.2 `SocketSyncTransport` in `lib/data/peer_sync/` with `SecureServerSocket`/`SecureSocket`, length-prefixed JSON framing and pinning through `CertificatePinning`; verify with a loopback-socket test that a pinned peer connects, an unknown certificate is refused, and a 5 MB receipt payload streams intact
- [ ] 1.3 Wire the transport through DI, keeping `InProcessSyncTransport` for tests; verify `flutter test` and `tool/run_acceptance_tests.sh -d macos` (CLAUDE.md: DI change)

## 2. Discovery (moved 12.2)

- [ ] 2.1 Spike: advertise and browse `_smara._tcp` between the macOS app, an iOS simulator and an Android emulator on `-vmnet-shared`, with `bonsoir` and with `nsd`; pick one and record the choice and results in design.md "Open Questions"
- [ ] 2.2 `PeerDiscovery` adapter (advertise with TXT fields and port, browse, filter by books-set hash and device id), with the in-process fake kept; verify with a unit test of TXT encoding and filtering
- [ ] 2.3 "Connect by address" fallback in Linked devices; verify with a widget test and a loopback test connecting by host and port
- [ ] 2.4 Platform setup: iOS `NSLocalNetworkUsageDescription` and `NSBonjourServices` (`_smara._tcp`, `_smara-join._tcp`), macOS sandbox network client and server entitlements, Android multicast lock; verify the macOS, iOS and Android builds succeed and `test/ios_privacy_compliance_test.dart` (or equivalent) passes

## 3. QR join and Sync now (moved 12.3, 12.4)

- [ ] 3.1 Join screens: show the join payload as a QR code (`qr_flutter`) and scan it (`mobile_scanner`), payload expires after 2 minutes and refuses reuse, the same check code is shown on both screens before any data flows; verify with widget tests using a fake scanner and a unit test for expiry and reuse
- [ ] 3.2 Sync service: one session per discovered linked peer, triggered on app foreground, "Sync now" and peer appearance, supplied as `syncNowAction`; verify with a two-instance harness test over loopback sockets that an entry recorded on one appears on the other

## 4. Enter code instead (join-code-entry)

- [ ] 4.1 Join code generation (8 characters, look-alike-free alphabet, `XXXX-XXXX`), 2-minute expiry, single use, 5 wrong attempts then a new code; verify with `test/domain/linked_devices/join_code_test.dart`
- [ ] 4.2 Join offer advertising (`_smara-join._tcp`, offer id only), code proof by HMAC over both nonces, check code `HMAC-SHA256(code, keys ‖ nonces)` to 6 digits; verify with a unit test that both sides derive the same check code and a tampered key gives a different one
- [ ] 4.3 UI: code shown beside the QR with time left; "Enter code instead" under the scanner (accepts lowercase and no dash); check code confirm and "They don't match" on both sides; errors for expired, used and not-found codes; verify with widget tests for each spec scenario
- [ ] 4.4 Join by code feeds the same join payload as QR; verify with a two-instance harness test over loopback sockets that a code join gives the same pinned certificates and books as a QR join, and that no private key is sent

## 5. Metadata, clock, removal and erase (moved 12.5–12.8)

- [ ] 5.1 Emit `MetadataOperation`s in the same transaction as every master-data write (categories, accounts, groups, payees, rules, templates, limits, books settings, personal claim limits); verify with a repository test that a local rename produces an operation a second database applies
- [ ] 5.2 Hybrid logical clock stored in the books database, and `metadata_lww_state` table for winners; verify an older operation after a restart cannot overwrite a newer field and a 10-minute clock skew cannot reverse the winner
- [ ] 5.3 Refuse entries signed by a removed device after its removal time, with a notice; verify with a sync-merge test
- [ ] 5.4 Erase on next contact and "Erased on <date>" reported back to the Owner; verify with a two-instance harness test

## 6. Personal claim limits (personal-claim-limits)

- [ ] 6.1 `personalClaimLimit` signed claim-settings record (person, category, amount, unit, cleared), scoped to Owner, Approvers and that Claimant; verify with `test/domain/claims/personal_claim_limit_test.dart` including scope
- [ ] 6.2 Limit lookup (personal → company → none) shared by Claimant and Approver screens, with "Above the <limit> limit"; verify with unit tests for the three spec scenarios and that amounts are never changed
- [ ] 6.3 People → <person> → Claim limits screen (Owner only); verify with a widget test, and that a Claimant cannot see another person's limits

## 7. Conductor and device setup (acceptance-test-suite)

- [ ] 7.1 `tool/company_sync/scenario.dart` (steps with role, dependencies and timeout) and `conductor.dart` (HTTP server, long-poll permission, done/failed posts, value relay for join and check codes, `report.json` and timeline, fail-fast and stop-all); verify with `tool/company_sync/conductor_test.dart` using fake instances, including a failure and a timeout
- [ ] 7.2 `integration_test/company_sync/company_sync_test.dart` role runner (`COMPANY_SYNC_ROLE`, `COMPANY_SYNC_CONDUCTOR`), reusing the acceptance harness helpers, with a visible-text dump on every report; verify a two-role dry run (Owner on macOS, one iOS simulator) joins by code and syncs one entry
- [ ] 7.3 Device setup in `tool/run_company_sync_test.sh`: create or reuse the iPad (A16), iPhone SE (3rd generation), iPhone 17 and 17 Pro Max simulators on iOS 26.5; start `smara_store_phone` and `smara_kiosk_pixel` with `-vmnet-shared` (one `sudo` prompt, iOS-only fallback when declined); clean app data; free-memory check; build once per platform and install without rebuilding per device; verify `--employees 2` and the full cast both boot and reach "ready" in the report
- [ ] 7.4 Fixtures: fixed exchange rates under `COMPANY_SYNC_TEST` (compiled out of release builds, guarded by a unit test), receipt JPEGs and a PDF in `test_fixtures/receipts/` pushed with `simctl addmedia` / `adb push`; verify a Claimant on each platform attaches a seeded receipt through the normal picker
- [ ] 7.5 Failure artifacts: screenshot, log and visible-text dump per instance, plus the timeline, under `build/company_sync/<timestamp>/`; verify by forcing a failure step

## 8. Acme Travel Co scenario (acceptance-test-suite)

- [ ] 8.1 Setup steps: Owner creates Acme Travel Co (EUR, receipt required above 0, Hotel 150, Meals 40, Taxi 60), adds Priya as Approver and the employees as Claimants with personal limits (Ravi Hotel 120, Mia Hotel 200, Sara Meals 60), advances for Ravi (200) and Sara (100); each device joins by code with the check code confirmed; verify with `--employees 2`
- [ ] 8.2 Claim steps from the spec table, including the rush-hour submit; verify the accountant's queue holds one claim per Claimant
- [ ] 8.3 Decision steps: approvals, Ravi's hotel at 120 with reason, the three rejections with reasons, Tom offline during decisions, Tom's resubmission with a receipt and approval; verify on each Claimant device the decisions and reasons, and on Tom's device after reopening
- [ ] 8.4 Settlement steps: advances set against approved totals, payments in both directions, every claim Paid and every "Owed to" balance 0 on Owner and accountant; verify the pass criteria 1, 4
- [ ] 8.5 Hard cases: Kenji removed after payment, a later entry from his device refused, erase on next contact and "Erased on <date>" on the Owner; competing category rename by Owner and accountant, latest wins after restarting every instance; verify pass criteria and the spec scenarios
- [ ] 8.6 Privacy and limit checks on every Claimant (no bank account, no other person's claims or limits; own limits shown); verify pass criteria 2, 3, 5
- [ ] 8.7 Full run: `tool/run_company_sync_test.sh` passes with 5 employees within 30 minutes and with `--employees 2` within 10 minutes, three runs in a row each; record the times and the report paths in this task

## 9. Localization and docs

- [ ] 9.1 New strings (join code, check code, Enter code instead, errors, Connect by address, personal limits) in `app_en.arb` and translated into all 42 other ARB files; verify `test/l10n/locale_packs_test.dart` and `test/l10n/curated_locale_smoke_test.dart`
- [ ] 9.2 `CONTEXT.md` (Join Code, Check Code, Personal Claim Limit), `docs/user-guide.md` (joining by code, Connect by address, personal limits), `docs/agents/` note on running the company test; verify against the spec scenarios
- [ ] 9.3 Privacy policy: confirm the local-network wording covers join by code and direct address (no new data leaves the network); verify the page builds

## 10. Final verification

- [ ] 10.1 `dart format .`, `flutter analyze`, `flutter test` and `tool/run_acceptance_tests.sh -d macos` pass after all groups (CLAUDE.md)
- [ ] 10.2 Re-run `linked-devices-and-sync` 11.3 on real devices (two phones and a Mac on one Wi-Fi) with QR and with Enter code, and record the results there (covers its 12.12)
- [ ] 10.3 Check the moved tasks 12.1–12.8 in `linked-devices-and-sync` with references to the tasks here; verify `tool/check_archived_changes_complete.sh`
