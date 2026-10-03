## 1. Apple export options

- [x] 1.1 Add `ios/ExportOptions.plist` (method `app-store-connect`, destination `upload`, team `PLUT6R5W2W`, automatic signing) and verify it parses with `plutil -lint`
- [x] 1.2 Add `macos/ExportOptions.plist` with the same settings and verify it parses with `plutil -lint`

## 2. Store listing sources and screenshot tool

- [x] 2.1 Move the listing text drafts, Play icon/feature graphic, and all screenshot folders from `openspec/changes/archive/2026-09-22-store-listing-assembly/` into `docs/release/store-listing/` (screenshots under `screenshots/<size-class>/`) by copying, leaving the archive untouched; add a short `docs/release/store-listing/README.md` index, and verify the archive diff is empty
- [x] 2.2 Promote `capture-screenshots.dart.reference` to `integration_test/store_screenshots_test.dart`, driven by a host controller that captures each screenshot into `docs/release/store-listing/screenshots/<size-class>` (see 6.2; Mac stays manual), and verify `flutter analyze` is clean
- [x] 2.3 Add `tool/capture_store_screenshots.sh -d <device-id> -c <size-class> [-o <dir>]` wrapping the capture, and verify `--help`/missing-arg handling and that `tool/run_acceptance_tests.sh` and no CI workflow reference the screenshot test

## 3. Runbook

- [x] 3.1 Create `docs/release/store-release-runbook.md` shared prep: `main`-only candidate, `YYYY.MM.N` version and shared never-reused `+N` from the highest tag (with the Apple reuse warning and the first zero-padded-month check), release gates via `checklist.md`, tag + draft GitHub Release with evidence and English notes, every step marked 🤖/👤
- [x] 3.2 Add the store listing check (screens/description changed → recapture all size classes and update text; privacy policy changed since the last tag → re-cross-check App Privacy and Data Safety)
- [x] 3.3 Add the Google Play section: `flutter build appbundle`, artifact path, `keytool -printcert` check, closed testing upload/rollout, production staged rollout 20% → 100% after 3 days, English "What's new", link to `android-upload-keystore.md`
- [x] 3.4 Add the iOS section: CLI (`flutter build ipa` / `xcodebuild -exportArchive` with `ios/ExportOptions.plist`) and Xcode Organizer paths, bundle id, processing wait, TestFlight groups, App Review with automatic release and no phased release
- [x] 3.5 Add the macOS section: CLI and Organizer paths with `macos/ExportOptions.plist`, the known validator rejections (90285, 90242, encryption declaration) and fixes, TestFlight/App Review as iOS
- [x] 3.6 Add the finish section: publish the GitHub Release after all stores accept; store rejection → fix on `main`, new build number

## 4. Weekly gate and links

- [x] 4.1 Rename the acceptance workflow's display name to "Acceptance Suite Weekly" (filename unchanged) and update its header comment to the weekly schedule
- [x] 4.2 Update `docs/release/checklist.md`: manual dispatch on the candidate commit as the locale gate, runbook link in platform steps (keep keystore link), verify both gates are still named
- [x] 4.3 Update `CONTRIBUTING.md` Store release and acceptance sections (runbook link, weekly wording) and verify its links resolve
- [x] 4.4 Replace remaining "nightly" wording for the acceptance tier in `Specs/architecture/smara-tech-guidelines.md`, `SECURITY.md`, `docs/release/android-upload-keystore.md`, `tool/run_acceptance_tests.sh` header, and `pages/open-source/smara-account/whats-built.md`, and verify with `grep -ri nightly`

## 6. Expanded screenshots and preview videos

- [x] 6.1 Add an optional `onScreen` hook to `completeOnboardingWithGuidedEntry` (acceptance behavior unchanged) and shared GUI flows in `integration_test/store_media/store_media_flows.dart`, and verify `flutter analyze` is clean
- [x] 6.2 Replace the driver-based capture with `tool/store_media.py` (log-marker controller: `simctl io`/`adb` screenshots and recordings, clean status bar) behind `tool/capture_store_screenshots.sh` and `tool/record_store_previews.sh`; remove `test_driver/`
- [x] 6.3 Expand `store_screenshots_test.dart` to at least 15 flows in store-priority order, and verify a real capture on the 6.9" iPhone Simulator produces ≥15 correct screenshots
- [x] 6.4 Add `store_previews_test.dart` (11 chapter clips) and composition: three App Store previews (15–30 s, exact resolution, 30 fps, audio track) and a captioned 1920×1080 tour; verify on the 6.9" iPhone Simulator with `ffprobe`
- [x] 6.5 Capture screenshots for every automatable size class available here (6.9", 6.5", 13" iPad Simulators; Android phone emulator) and record Apple previews for the iOS classes and the tour on the Android phone emulator
- [x] 6.7 Fix two app UI bugs visible in every store screenshot: the 5-item `BottomNavigationBar` defaulted to the shifting type (white bar, invisible selected tab) → `type: BottomNavigationBarType.fixed`; `AppTypography.headerTitle` rendered near-black on the navy app bar → white; add regression tests in `test/ui/core/app_shell_test.dart` and verify they fail on the old code
- [x] 6.6 Update the runbook, listing README and `listing.md` (tour pointer via the website, no YouTube/Android mention in App Store text)

## 5. Tag and validation

- [x] 5.1 Create annotated tag `v1.0.0+3` on `4156b8b` and push it
- [x] 5.2 Run `openspec validate store-release-runbook --strict`, `flutter analyze`, and `flutter test`, and verify all pass
