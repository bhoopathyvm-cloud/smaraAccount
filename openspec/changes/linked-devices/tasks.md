## 0. Prerequisites

- [ ] 0.1 Confirm `books-copy-and-continuation` is implemented and archived (`openspec list` no longer shows it and `openspec/specs/books-copy/spec.md` exists); verify by running `openspec validate linked-devices --strict` after rebasing on main

## 1. Several sets of books (multiple-books)

- [ ] 1.1 Add the books index and per-set database location `books/<booksId>/smara.sqlite`, with the per-set key name `signing_seed_<booksId>`; verify with `test/data/books/books_index_test.dart`
- [ ] 1.2 Migrate an existing install into the first set (move the database, rename the key, keep the original until verified, then delete); verify with `test/data/books/first_set_migration_test.dart` covering success, failed verification (original kept) and an interrupted move
- [ ] 1.3 Make DI build repositories per open set and switch cleanly (close the database, rebuild providers); verify with `test/main_wiring_test.dart` and run `tool/run_acceptance_tests.sh -d macos` (DI change per CLAUDE.md)
- [ ] 1.4 Books switcher UI (open, create "New books", name) with App Lock applying app-wide; verify with `test/ui/features/books_switcher/` widget tests

## 2. One chain per identity (ledger-integrity-signing)

- [ ] 2.1 Drift migration: uniqueness of `device_chain_sequence` per `signed_by_identity_id`; `ledger_chain_state` one row per identity; identity fields `deviceName`, `role`, `removedAt`, `visibilityScope` (nullable); verify with `test/data/database/app_database_migration_test.dart`
- [ ] 2.2 Update `LedgerPosting` and the chain store to chain per identity, and `LedgerChainVerifier` to verify each chain separately and quarantine per chain; verify with `test/data/repositories/ledger_chain_verifier_test.dart` cases: two intact chains, a break in one chain leaving the other verified, and existing single-chain books unchanged
- [ ] 2.3 Control records (device added, removed, role changed, erase requested, ownership claim/objection) as signed chained entries without postings; verify the verifier accepts them and balances ignore them in `test/domain/linked_devices/control_record_test.dart`

## 3. Pairing and transport (linked-devices, local-network-sync)

- [ ] 3.1 Transport keypair bound to the signing identity, Noise XX session and length-prefixed framing; verify with `test/data/sync/secure_channel_test.dart` (handshake, tampered frame rejected, unknown static key rejected)
- [ ] 3.2 mDNS/DNS-SD discovery `_smara-sync._tcp` plus direct-address fallback; verify with `test/data/sync/discovery_test.dart` using a fake resolver
- [ ] 3.3 QR payload (books id and name, public key, addresses, port, 2-minute one-time secret) and 4-emoji check code; verify with `test/domain/linked_devices/pairing_payload_test.dart` (expiry, reuse refused)
- [ ] 3.4 Platform permissions and entitlements: iOS `NSLocalNetworkUsageDescription` and `NSBonjourServices`, Android `NEARBY_WIFI_DEVICES` / `ACCESS_WIFI_STATE` / multicast lock, macOS `network.client` and `network.server`, and camera for scanning; verify with `flutter build ios --no-codesign`, `flutter build apk` and `flutter build macos`, plus `test/platform/manifest_entries_test.dart`

## 4. Sync engine (local-network-sync)

- [ ] 4.1 Head exchange and missing-entry transfer, with verification before insert and one transaction per batch; verify with `test/data/sync/sync_engine_test.dart` over an in-memory loopback between two real databases
- [ ] 4.2 Rejected records: `rejected_records` table, "Not accepted" listing, Owner alert; verify with a tampered-entry case in `sync_engine_test.dart`
- [ ] 4.3 Removal enforcement (refuse entries signed by a removed identity after its removal record); verify in `sync_engine_test.dart`
- [ ] 4.4 Sync triggers: app foreground on both, "Sync now", Android WorkManager one-off when the network becomes available; verify with `test/ui/features/linked_devices/sync_now_test.dart` and an Android-only unit test of the worker scheduling

## 5. Shared master data and conflicts

- [ ] 5.1 `master_ops` signed operation log with hybrid logical clocks; materialized state per field; initial operations created when books are first shared; verify with `test/data/sync/master_ops_test.dart` (out-of-order arrival converges, tie-break by device id)
- [ ] 5.2 Route every master-data write (categories, accounts, groups, payees, rules, templates, limits, books settings) through operations; verify the existing repository tests still pass and new convergence tests in `master_ops_test.dart`
- [ ] 5.3 Split settings into books settings (shared via operations) and device settings (local only); verify with `test/data/repositories/settings_repository_test.dart` that app language, display, research tool, App Lock and reminder never sync
- [ ] 5.4 First-fix-wins: detect competing reversals after sync, let the losing device post the cancelling reversal and notice; verify with `test/data/sync/first_fix_wins_test.dart` (both devices compute the same winner; only one cancellation is posted)

## 6. Categories across languages (category-translations, core-ledger-single-account, app-localization)

- [ ] 6.1 `category_names` translations, a default category language in books settings, and display resolution order; verify with `test/l10n/category_name_resolution_test.dart`
- [ ] 6.2 Automatic merges for identical normalized names of the same type, suggested merges on matching translations, manual "Merge categories"; lists and totals resolve merges while entries keep their ids; verify with `test/data/repositories/category_merge_test.dart` including full chain verification after a merge
- [ ] 6.3 "Translate with AI" hand-off with only the word and target language; verify with `test/domain/category_translation_prompt_test.dart` (no other books data in the URL)
- [ ] 6.4 Joining or restoring devices skip starter-category seeding; verify with `test/data/repositories/account_repository_test.dart`

## 7. Roles, notices, remove and erase, ownership claims (linked-devices)

- [ ] 7.1 Owner and Member roles, "Members can add devices" setting, making Owners; verify with `test/domain/linked_devices/roles_test.dart`
- [ ] 7.2 Notices on Home and in Device history for added, removed, role-change and erase events; verify with `test/ui/features/home/linked_device_notice_test.dart`
- [ ] 7.3 Remove and erase with "Erase pending" and "Erased on <date>", erase executed on the removed device at next contact, and the find-my-device pointer; verify with `test/data/sync/erase_test.dart` over loopback
- [ ] 7.4 Ownership claim with the 7-day timer and objection; verify with `test/domain/linked_devices/ownership_claim_test.dart` using an injected clock
- [ ] 7.5 Join by restored copy: join request, one-tap approval, nothing exchanged before approval; verify with `test/data/sync/join_request_test.dart`

## 8. UI

- [ ] 8.1 Settings → Linked devices (list, roles, Add a device, Sync now, Remove, Remove and erase, Not accepted list); verify with widget tests under `test/ui/features/linked_devices/`
- [ ] 8.2 Add a device: show QR, scan QR (camera permission), check-code confirmation, progress, success; verify with widget tests using a fake scanner
- [ ] 8.3 Local-network explanation before the system prompt, shown only on first opening of Linked devices; verify with a widget test that no prompt occurs elsewhere
- [ ] 8.4 Category translation and merge screens; verify with widget tests

## 9. Localization (43 languages)

- [ ] 9.1 Add all new strings to `lib/l10n/app_en.arb` in household wording ("Linked devices", "Add a device", "Sync now", notices, erase states, join request, books switcher, translation and merge); verify `flutter gen-l10n` succeeds
- [ ] 9.2 Translate into all 43 ARB files and update `lib/l10n/untranslated.json`; verify `test/l10n/locale_packs_test.dart` and `test/l10n/language_picker_test.dart` pass
- [ ] 9.3 Run the localized smoke suite (`tool/run_localized_acceptance_tests.sh`) and confirm `.github/workflows/localized-smoke.yml` covers the Linked devices screens

## 10. Integration and acceptance tests (all suites)

- [ ] 10.1 Acceptance harness: a loopback transport so two app instances with separate databases can link and sync inside one test process; verify with a smoke test in `integration_test/acceptance/support/`
- [ ] 10.2 New acceptance group `linked_devices`: add a device by QR (fake scanner), record on each side and see both entries, first-fix-wins notice, rename-versus-archive convergence, tampered record "Not accepted", remove then a refused later entry, erase pending then erased, join by restored copy with approval; verify `tool/run_acceptance_tests.sh -d macos linked_devices` passes
- [ ] 10.3 New acceptance group `multiple_books`: create a second set, switch, and confirm entries and keys are separate and that an existing install migrates into the first set; verify `tool/run_acceptance_tests.sh -d macos multiple_books` passes
- [ ] 10.4 Update existing acceptance groups that assume a single database or a single chain (`core_ledger` tamper detection, `identity_restore`/`books_copy`, `onboarding`, `home_and_lock`, `organization` categories); verify each group passes on macOS
- [ ] 10.5 Update `integration_test/app_test.dart` scenarios that assume one database path or one chain; verify `flutter test integration_test/app_test.dart -d macos` passes
- [ ] 10.6 Check `integration_test/instrument_identifier_resolve_test.dart`, `instrument_identifier_live_yahoo_android_test.dart` and `market_quote_currency_test.dart` still pass with per-set databases
- [ ] 10.7 If store screenshot or preview tests exist (PR #198), add a Linked devices screen and keep the others passing; verify `tool/capture_store_screenshots.sh`
- [ ] 10.8 CI: confirm `.github/workflows/flutter-ci.yml`, `acceptance-suite-nightly.yml`, `localized-smoke.yml` and `linux-desktop.yml` run the new tests (Linux uses the loopback transport only); verify a green CI run on the PR
- [ ] 10.9 Full suite after the refactor per CLAUDE.md: `tool/run_acceptance_tests.sh -d macos` green
- [ ] 10.10 Real-device runs: link iPhone ↔ Android phone ↔ Mac on the same Wi-Fi; record, fix twice, remove and erase; record the results in this task with dates and devices

## 11. Docs and glossary

- [ ] 11.1 `CONTEXT.md`: replace "Household books on one device"; add Linked Device, Owner, Member, Books (set of books), Default Category Language, Category Translation, Category Merge, Control Record, Not Accepted; mark sync as designed; verify `openspec validate --specs` and a glossary review
- [ ] 11.2 `Specs/architecture/smara-architecture.md` and `smara-tech-guidelines.md`: sync is designed (LAN-only, Noise channel, one chain per identity, operation log); verify the doc no longer says "not designed"
- [ ] 11.3 Privacy policy (`pages/open-source/smara-account/privacy-policy.md`), user guide (`docs/user-guide.md`), `whats-built.md`, and README: Linked devices, what crosses the local network, erase limits; verify `mkdocs build --strict`
- [ ] 11.4 Update `docs/household-term-map.md` with the new screen words; verify the term map test or review
