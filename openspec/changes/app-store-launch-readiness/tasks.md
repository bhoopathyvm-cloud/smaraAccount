## 1. Account enrollment (human, not code — start first, longest lead time)

- [x] 1.1 Start Apple Developer Program enrollment ($99/yr) — subscription created (2026-09-05); a real Team is now signed into Xcode, resolving the free/personal-team signing churn (new certificate needing re-trust on every build) and the device-provisioning gate that blocked tasks 3.1-3.4 and 9.2
- [x] 1.2 Start Google Play Console registration ($25 one-time) and complete identity verification — verification cleared (2026-09-08)
- [x] 1.3 Confirm whether this Play Console account is subject to Google's mandatory closed-testing requirement for new accounts (it will be, per Google's current policy for accounts with no prior production app) and note the earliest possible production-eligible date once the account activates — confirmed in Console (2026-09-08); specific tester-count/day requirement and the resulting earliest production-eligible date not yet recorded here — worth adding once a closed test is actually live and Console shows the countdown

## 2. Close out Android signing (cross-references `android-release-signing`)

- [ ] 2.1 `android-release-signing` task 2.1: generate an upload keystore (`keytool -genkeypair ...`)
- [ ] 2.2 `android-release-signing` task 2.2: store the keystore file and passwords somewhere durable and private, outside the repo
- [ ] 2.3 `android-release-signing` task 2.3: populate local `android/key.properties` from that keystore
- [ ] 2.4 `android-release-signing` task 3.1: run `flutter build appbundle` and verify the artifact is release-signed, not debug-signed (`apksigner verify --print-certs`)

## 3. iOS/macOS Team signing

- [ ] 3.1 Once Apple Developer Program enrollment is active, configure the real Team in Xcode's Signing & Capabilities for the `Runner` target's **iOS** build configuration (new — not tracked elsewhere)
- [ ] 3.2 `macos-app-store-sandbox` task 1.1: configure the same real Team for the **macOS** build configuration, if macOS App Store distribution is also wanted in this pass
- [ ] 3.3 Verify an iOS archive build succeeds and is Team-signed
- [ ] 3.4 `ios-privacy-compliance` task 4.1: verify the Xcode archive build succeeds with `PrivacyInfo.xcprivacy` present (blocked on Xcode/Team access, not previously verifiable on the Linux agent that did the original change)
- [x] 3.5 `app-icon-branding` tasks 3.1-3.3: spot-check the generated app icon on a real iOS Simulator, macOS build, and Android emulator/device home screen — done; see that change's `tasks.md` for verification detail and the noted (non-blocking) iOS Simulator home-screen-label display quirk

## 4. Privacy policy hosting

- [x] 4.1 `project-website-smara-rebrand` task 6.1: point `smara-ai.ch` DNS at GitHub Pages — verified: `dig smara-ai.ch` resolves to GitHub Pages IPs (185.199.108-111.153)
- [x] 4.2 `project-website-smara-rebrand` task 6.2: set the repository's GitHub Pages custom domain to `smara-ai.ch` and re-enable HTTPS — verified via `gh api repos/:owner/:repo/pages`: `cname: smara-ai.ch`, certificate state `approved`. Note: `https_enforced` is still `false` (HTTPS works but isn't force-redirected) — worth flipping on in repo Settings → Pages, not blocking since the store-submitted URL will be given as `https://` explicitly.
- [x] 4.3 Confirm the privacy policy page is publicly reachable at its final URL before either store submission — verified: `https://smara-ai.ch/open-source/smara-account/privacy-policy/` returns HTTP 200 with correct content

## 5. Store listing assembly

- [ ] 5.1 Organize existing screenshots into each store's required size sets (App Store Connect and Play Console have different requirements per device class)
- [ ] 5.2 Finalize app description, keywords, category, and support URL for both stores
- [ ] 5.3 Complete Google Play's content rating questionnaire
- [ ] 5.4 Complete Google Play's Data Safety form, cross-checked line-by-line against `pages/open-source/smara-account/privacy-policy.md`
- [ ] 5.5 Complete App Store Connect's App Privacy ("nutrition label") section, cross-checked the same way

## 6. iOS submission

- [ ] 6.1 Create the app record in App Store Connect
- [ ] 6.2 Archive and upload the Team-signed build via Xcode Organizer
- [ ] 6.3 Attach listing assets and the live privacy-policy URL to the App Store Connect record
- [ ] 6.4 Submit for App Review

## 7. Android submission

- [ ] 7.1 Create the app record in Google Play Console
- [ ] 7.2 Upload the release-signed AAB and enroll in Play App Signing
- [ ] 7.3 Attach listing assets and the live privacy-policy URL
- [ ] 7.4 Release to a closed testing track with the number of testers Google's current policy requires (not production)
- [ ] 7.5 Once the closed-testing clock completes and passes, request production access

## 8. Final verification

- [x] 8.1 `tool/run_acceptance_tests.sh -d macos` green before iOS/macOS submission — verified (2026-09-05): 13/13 files pass. Found and fixed a real bug along the way: `organization_test.dart`'s `_openCapture` tapped `find.text(l10n.captureSpent)`, which matched both the capture-sheet's own "Spent" action and Home's "THIS MONTH" summary label (same localized string, sheet doesn't unmount Home) — fixed by scoping to `find.widgetWithText(ListTile, ...)` (`integration_test/acceptance/organization_test.dart`). An `inBottomSheet`/`find.byType(BottomSheet)` scoping attempt was tried first and caused an 8-minute hang (the ancestor assumption was wrong) — reverted before landing the working fix.
- [x] 8.2 `tool/run_acceptance_tests.sh -d <android-device>` green before Android submission — verified (2026-09-05) on a real Samsung SM X230 (Android 16): 13/13 files pass. Found and fixed two real-device timing races: `openHoldingsFor` returned as soon as the "Cash" label appeared, before the numeric total (a separate, slightly later rebuild) had rendered, breaking two `investment_holdings_test.dart` assertions; and `onboarding_test.dart` asserted on "Pocket Cash" immediately after the Accounts screen's FAB tooltip appeared, before the account list had streamed in. Both fixed with a bounded settle/`pumpUntilFound` rather than an unbounded wait (`integration_test/acceptance/support/acceptance_harness.dart`, `integration_test/acceptance/onboarding_test.dart`). The previously-tracked tablet flakes (`core_ledger`, `home_and_lock`, `currency_transfers`) did not reproduce this run — already resolved by `acceptance-suite-tablet-green`.

## 9. iPhone (real device) verification — new, discovered this session

- [x] 9.1 Wireless-only iOS devices can't run `flutter test`/integration tests (`Cannot start app on wirelessly tethered iOS device`, needs `--publish-port` mDNS + a Local Network permission prompt that can't be answered headlessly) — connect via USB cable instead. Resolved by connecting via cable.
- [x] 9.2 Xcode needed a one-time interactive step to provision this iPhone: sign a real Apple ID into Xcode's Accounts settings, select the Team in Signing & Capabilities for `Runner`, and Run once. Also needed along the way: granting Xcode Automation access to the terminal app (System Settings → Privacy & Security → Automation) and re-enabling Developer Mode on the device after a reboot reset it (Settings → Privacy & Security → Developer Mode) — without Developer Mode on, dev-signed apps don't even appear on the Home Screen.
- [x] 9.3 Verified green on the real iPhone (Bhoopathy Murugaswamy's iPhone, iOS 26.6.1): `tool/run_acceptance_tests.sh -d <iphone-device-id>` — 37/37 tests pass, one install, 7:44 total (2026-09-05). Getting there took several retries; real, non-flaky causes found and fixed along the way (see 10.6/10.7) plus environment gremlins that weren't code bugs: the app disappearing from the Home Screen after a reboot (Developer Mode reset, not a build problem), and the phone's screen being locked mid-run killing the GUI-automation driver (needs the screen left on and untouched for the ~2 minutes a full run takes).

## 10. Acceptance suite: merge 13 files into one (reduces real-device install count)

- [x] 10.1 Merged all 13 `integration_test/acceptance/*_test.dart` files into a single `integration_test/acceptance/acceptance_test.dart` (one `group('name', () { ... })` per former file, same name minus `_test.dart`), so a full run needs one app install instead of 13. Motivation: on a real iOS device, `flutter test <file> -d <device>` rebuilds/reinstalls/relaunches per invocation, and empirically this doesn't change even when multiple files are passed to one `flutter test` invocation (verified: the second file in a 4-file batch still re-ran the full "Automatically signing → Running Xcode build → Installing and launching" cycle) — only a single shared `main()`/binding avoids that, which also means only one chance to hit Xcode's real-device automation-launch flakiness per run instead of 13.
- [x] 10.2 Resolved naming collisions from the merge: two pairs of former files defined identically-named helpers with different per-file values (`_brokerage`/`_instrument` constants in `investment_holdings_test.dart` vs `investment_research_test.dart`) — these and every other former top-level private helper/constant became local to their own group's closure (Dart scopes local declarations per-closure, so no collision regardless of value). Only classes can't be declared locally (a Dart limitation) — the handful of per-file fake FilePicker/UrlLauncher platform classes were kept as independent per-group copies with group-prefixed names (`_CsvImportFakePlatformFile`, `_OfxImportFakePlatformFile`, etc.), matching this suite's own prior documented preference for independent copies over a shared abstraction (`ofx_import_test.dart`'s original comment: "kept as a separate copy rather than shared... the class is a handful of lines").
- [x] 10.3 Fixed one real ambiguous-import error the merge surfaced: `flutter_secure_storage` and `file_picker` both export `AndroidOptions`/`WindowsOptions`/`LinuxOptions`/`WebOptions`, harmless while those two packages were never imported by the same original file — merging put them in the same library, so the `flutter_secure_storage` import now hides those four names.
- [x] 10.4 Updated `tool/run_acceptance_tests.sh` to run the single merged file; the `[group]` argument now filters via `flutter test --plain-name <group>` against group/test names instead of matching file names.
- [x] 10.5 Verified green end-to-end on macOS: `tool/run_acceptance_tests.sh -d macos` — 37/37 tests across all 13 groups pass, one install, 7:17 total (2026-09-05).
- [x] 10.6 Re-verified green on the Android tablet with the merged file: `tool/run_acceptance_tests.sh -d <android-device>` — 37/37 (one confirmed flake on the `onboarding` group, retested green in isolation; the previously-tracked tablet flakes did not reproduce). Confirms the merge itself didn't regress Android.
- [x] 10.7 Re-verified green on the real iPhone with the merged file: 37/37, see task 9.3.
- [x] 10.8 Fixed two real, previously-undiscovered production layout bugs surfaced only by running on an actual iPhone screen width (neither the macOS window, iOS Simulator, nor Android tablet ever hit these): `lib/ui/core/entity_picker_field.dart`'s `DropdownButtonFormField` overflowed 9.7px on the right (fixed with `isExpanded: true` + `TextOverflow.ellipsis` on the item text); `lib/ui/core/monthly_limit_progress.dart`'s Row overflowed 13px (fixed by wrapping the "spent of limit" text in `Flexible` with `TextOverflow.ellipsis`).
- [x] 10.9 Fixed two acceptance-test scroll helpers that assumed a fixed screen coordinate tuned against the desktop/simulator window (`tester.dragFrom(Offset(400, 300), ...)`), which on this iPhone's actual screen dimensions landed outside the scrollable region and did nothing: the `home_and_lock` PIN-lock test's Settings scroll, and the `organization` group's local `scrollUntilVisible` helper. Both switched to `tester.drag(find.byType(ListView).first, ...)` — the same pattern already used reliably elsewhere in this suite — in a bounded loop that stops as soon as the target is visible.
