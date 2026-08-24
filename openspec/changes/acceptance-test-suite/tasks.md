## 1. Real-build harness (shared by every capability group)

- [x] 1.1 Create `integration_test/acceptance/support/acceptance_harness.dart`: a helper that pumps the real `SmaraAccountingApp` (imported from `lib/main.dart`) directly — not a hand-rebuilt provider tree — so this tier can never silently diverge from what `main()` actually builds.
- [x] 1.2 Add a helper that locates the app's real database path (`getApplicationSupportDirectory()`, matching `app_database.dart`'s `_openConnection`) and deletes it.
- [x] 1.3 Add a helper that clears the real secure-storage implementation's known keys (not `deleteAll()` — see design.md's risk note on `errSecMissingEntitlement`).
- [x] 1.4 Add a `resetToFreshDevice()` helper combining 1.2 and 1.3, used both for pre-run cleanup and for the storage/keychain reset between the two phases of the restore scenario (Decision 2's single-device, two-phase model).
- [x] 1.5 Wire `resetToFreshDevice()` to run once at the start of every acceptance test file's `main()` (pre-run cleanup) and inside every `testWidgets`' `addTearDown` (post-run cleanup), per design.md Decision 3.

## 2. Device targeting

- [~] 2.1 Confirm each capability group's test files run correctly via `flutter test integration_test/acceptance/<file>.dart -d <device-id>` against a macOS build, an iOS simulator, and an Android emulator — no platform-specific test code should be needed given 1.1–1.3 already abstract over the target via `path_provider`/secure storage. **macOS confirmed: `core_ledger_test.dart` passes cleanly and reproducibly (2 consecutive green runs, ~11s each). iOS/Android untested — no reason to expect the harness itself to differ (it's already platform-abstracted), but device-specific window/timing quirks (design.md Risks) haven't been observed there yet.**
- [ ] 2.2 Document, in the script from Task 8, how to discover device ids for each platform (`flutter devices` output for a running macOS session, a booted iOS Simulator, and a running Android emulator).

## 3. Capability group: core ledger journeys

- [~] 3.1 Port the existing INTEGRATION-tier journeys — record transaction, reverse a posted entry, archive a category, tamper detection and re-anchoring, user-created group archive lifecycle (`core-ledger-single-account`, `multi-account-ledger`, `ledger-integrity-signing`) — onto the real-build harness in `integration_test/acceptance/core_ledger_test.dart`. **Record-transaction, hide-category, and tamper-detection-on-restart scenarios DONE, all three passing reliably and reproducibly against a real macOS build (3/3 clean runs). Reverse-entry has no GUI affordance in the app at all (ViewModel/Repository-only — see design.md note) so it's excluded from this GUI-only tier, not deferred. `completeOnboardingWithGuidedEntry` extracted into the shared harness so every remaining scenario (here and in other groups) reuses it instead of duplicating the onboarding walk. Two follow-ups intentionally scoped out rather than silently dropped: (1) re-anchoring - recording a second, clean entry after quarantine and confirming only the tampered one keeps the lock badge - hit a still-unexplained "no FAB found" failure distinct from every other issue in this change; (2) group-archive-lifecycle not yet started.**

## 4. Capability group: currency and transfers

- [x] 4.1 Port the cross-currency transfer lifecycle and bounced-transfer settlement journeys (`foreign-currency-settlement`, `credit-card-household-flow`) onto the real-build harness. Both scenarios live in `currency_transfers_test.dart`, sharing a `_setUpCrossCurrencyTransfer` helper; 2/2 clean runs each.
- [x] 4.2 Add a scenario asserting amounts render through `localized-money-formatting` and a live rate through `reference-exchange-rate-lookup` on the real build. Covered by 4.1's own assertions (EUR `92,00`/USD `990.00` real-GUI formatted output, plus the live reference-rate row driving the shortfall/fee flow) rather than a separate file - money_formatter_test.dart already covers JPY's zero-decimal case at the unit level.
- [x] 4.3 Add a scenario changing an account/group's currency (`account-currency`) through the real GUI. `account_currency_test.dart`: changes the seeded Investments group from USD to JPY via the real "Edit group" dialog; 2/2 clean runs.

## 5. Capability group: identity and backup

- [ ] 5.1 Write the record → capture phrase → reset → restore scenario (proposal's original flow), using `resetToFreshDevice()` from Task 1.
- [ ] 5.2 Write the wrong-recovery-phrase negative scenario.
- [ ] 5.3 Add a scenario exporting an encrypted `ledger-backup` file through the real GUI, resetting to a fresh device, and restoring from that file, asserting entries match.
- [ ] 5.4 Add a scenario restoring a foreign identity's backup onto a device that already has an active identity, asserting the real UI rejects it with an explanation (per `ledger-backup` spec).

## 6. Capability group: onboarding

- [ ] 6.1 Add a scenario walking first-run setup end to end through the real GUI (`first-week-setup`).
- [ ] 6.2 Add a scenario exercising the deferred-setup path (`deferred-onboarding`).

## 7. Capability group: data import

- [x] 7.1 Add a scenario importing a real CSV file through the platform file picker and asserting entries land correctly (`csv-transaction-import`). `csv_import_test.dart`: discovered `FilePickerPlatform.instance` is a swappable singleton exactly like `UrlLauncherPlatform` (change `acceptance-investment-research`'s pattern), so the native picker is faked with a canned `PlatformFile` rather than left infeasible per design.md's original deferral. Maps columns, categorizes both rows, confirms import, and asserts them in Register; 2/2 clean runs.
- [ ] 7.2 Add a scenario importing a real OFX file the same way (`ofx-transaction-import`).

## 8. Capability group: organization features

- [ ] 8.1 Add scenarios for `payees`, `recurring-templates`, `import-category-rules`, `monthly-category-limits`, `split-transactions`, `correction-wizard`, and `register-search` — one representative real-GUI journey per capability, at minimum covering that capability's primary spec scenario.

## 9. Capability group: home, accounts overview, and App Lock (PIN path)

- [ ] 9.1 Add a scenario asserting the home/accounts overview renders correctly against real recorded data (`accounts-home-overview`, `home-hub`, `account-management-ui`).
- [ ] 9.2 Add a scenario locking and unlocking via PIN through the real GUI (`app-lock`, PIN path only — biometric path stays out of scope per design.md Non-Goals).

## 10. Developer entry point

- [ ] 10.1 Add `tool/run_acceptance_tests.sh`, requiring a `-d <device-id>` argument (failing fast with a clear message if omitted, per spec.md's "No device specified" scenario) and an optional group argument to run a single capability group's file instead of the full suite.
- [ ] 10.2 The script runs pre-run cleanup, then `flutter test` against the chosen file(s) and device, and reports pass/fail clearly.
- [ ] 10.3 Make the script executable and document its usage (including the per-platform device-id discovery from Task 2.2) at the top of the script itself.
- [ ] 10.4 Confirm no `.github/workflows/*.yml` file invokes this script or any `integration_test/acceptance/` file.

## 11. Docs

- [ ] 11.1 Add an ACCEPTANCE tier to `Specs/architecture/smara-tech-guidelines.md`'s Testing Rules section: scope (real build via the real root widget, real storage/keychain, self-cleaning, device-selectable, manual-only), and its capability groups.
- [ ] 11.2 Add a short section in `CONTRIBUTING.md` pointing to `tool/run_acceptance_tests.sh`, when to run it (after finishing a large change, before opening a PR), and that it must be run once per target platform the developer wants confidence on.

## 12. Verification

- [ ] 12.1 Run the full suite locally against `-d macos` and confirm every capability group passes.
- [ ] 12.2 Repeat against an iOS simulator and an Android emulator, confirming the same test code passes unmodified on each.
- [ ] 12.3 Inspect each target's real storage location and keychain/keystore afterward and confirm no acceptance-test artifacts remain.
- [ ] 12.4 Force-kill a run mid-test, then run again, and confirm pre-run cleanup removes the leftover state before the second run's assertions execute.
- [ ] 12.5 Confirm `flutter-ci.yml` and every other workflow are unchanged.
