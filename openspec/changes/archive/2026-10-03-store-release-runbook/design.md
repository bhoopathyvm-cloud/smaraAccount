## Context

See proposal.md for why. Decisions below were settled in a grilling
session (Q1–Q32) on 2026-09-27. Facts they rest on:

- iOS and macOS share one App Store Connect record and bundle id
  `com.smaraaccounting.smaraAccounting` (team `PLUT6R5W2W`); Android is
  `com.smaraaccounting.smara_accounting`.
- `pubspec.yaml`'s `+N` drives iOS `CFBundleVersion`, macOS, and Android
  `versionCode` together. Current: `1.0.0+3`, set in `4156b8b` (#178),
  which produced the iOS build submitted for review and the Play upload.
- A reused Apple build number can report `Upload succeeded` while no
  build ever appears in App Store Connect (seen with iOS build 2).
- Prior macOS App Store validator rejections, already fixed: error 90285
  (`keychain-access-groups` entitlement), 90242 (missing
  `LSApplicationCategoryType`), and the encryption-documentation prompt
  (missing `ITSAppUsesNonExemptEncryption`).
- `pub` accepts a zero-padded version such as `2026.09.0+4`.
- `acceptance-suite-nightly.yml` now schedules weekly (`0 3 * * 0`).

## Goals / Non-Goals

**Goals:**
- One ordered runbook covering Play, iOS, and macOS end to end, with each
  step marked 🤖 (command) or 👤 (console-only).
- Defined versioning, tagging, and release-record conventions.
- Maintained, reproducible English store-listing sources and screenshots.

**Non-Goals:**
- Store automation (fastlane, App Store Connect / Play Developer APIs,
  service-account keys). Apple uploads via `xcodebuild` are the only
  scripted uploads.
- Localized store listings or localized "What's new" (English only).
- Changing signing configs, entitlements, or app code.

## Decisions

### 1. Single runbook, all three platforms, every release
`docs/release/store-release-runbook.md`. Every release ships iOS, macOS,
and Android with the same version and build (one codebase, one build
number). The checklist stays the gate document; the keystore doc stays
the Android signing deep-dive.

### 2. Calendar versioning `YYYY.MM.N`, shared monotonic build number
Version is year, zero-padded month, and a per-month release counter
starting at 0 (`2026.10.0`, `2026.10.1`, `2026.11.0`). The build number
`+N` is shared by all stores and only ever increases across versions:
next build = highest `v*` tag's build + 1; a number is never reused even
if one store did not receive it. `2026.x` sorts above `1.0.0`, so
Apple/Play ordering holds.
- **Risk:** App Store Connect acceptance of a leading zero (`09`) is not
  yet verified; the first release is `2026.10.0` (two-digit month), and
  the runbook flags the first single-digit month release for checking.

### 3. Releases only from `main`; tags + GitHub Release as release record
After both release gates pass on a `main` commit: 🤖 create annotated tag
`v<version>+<build>` and a **draft** GitHub Release whose notes hold the
gate evidence (workflow run URL, commit, macOS run result) and English
release notes (from PRs merged since the previous tag). Upload only from
that tagged commit. Publish the Release once all stores accept the build.
A store rejection is fixed on `main` and shipped as a new build number.
Backfill `v1.0.0+3` on `4156b8b`.

### 4. Locale gate: manual dispatch on the candidate
The scheduled acceptance run is weekly, so the release owner always
dispatches `acceptance-suite-nightly.yml` (`workflow_dispatch`, owner-only)
on the candidate commit and requires all locale jobs green. macOS English
baseline stays unchanged. Workflow display name becomes "Acceptance Suite
Weekly"; filename unchanged to keep run-history and doc links.

### 5. Apple: both CLI and Organizer paths, committed ExportOptions
`ios/ExportOptions.plist` and `macos/ExportOptions.plist` (method
`app-store-connect`, destination `upload`, team `PLUT6R5W2W`, automatic
signing). CLI path: `flutter build ipa`/`xcodebuild archive` then
`xcodebuild -exportArchive -exportOptionsPlist …`. Organizer path:
Archive → Distribute App → App Store Connect → Upload. Wait for
processing, then TestFlight groups, then submit for review.
**Automatic release** after approval, **no phased release**.

### 6. Play: closed testing, then staged production 20% → 100%
Build the AAB, 👤 upload to the closed testing track and roll out to
testers; then promote to production at 20%, and to 100% after 3 days.
Stores are submitted independently (no cross-store sequencing).

### 7. Store listing: maintained English sources and screenshot tool
Move `store-listing-draft.md`, `app-privacy-draft.md`,
`content-rating-and-data-safety-draft.md`, the Play icon/feature graphic,
and all screenshot folders from the archived change into
`docs/release/store-listing/` (screenshots under `screenshots/<class>/`,
committed so listing changes are reviewable). The archive copy stays
frozen. Promote `capture-screenshots.dart.reference` to
`integration_test/store_screenshots_test.dart` (analyzed by
`flutter analyze`; not invoked by `run_acceptance_tests.sh` or CI) with a
`tool/capture_store_screenshots.sh -d <device> [-o <dir>]` wrapper.
Each release runs a listing check: if Home, Register, Accounts, or
Settings changed visually, or a feature named in the description
changed, recapture every size class and update the text; if the privacy
policy changed, re-cross-check the App Privacy / Data Safety answers.

### 8. Store media: 19 screenshots, 3 Apple previews, one captioned tour
Screenshots and previews are driven by shared GUI flows
(`integration_test/store_media/`) and a host controller
(`tool/store_media.py`) that reacts to `STORE_MEDIA` markers the test
prints: `xcrun simctl io` / `adb` capture real device pixels with a clean
status bar. Integration-test screenshots were rejected because on mobile
they reach the host only when the test ends, so they cannot time a screen
recording. Each automated class gets 19 screenshots in store-priority
order (App Store max 10, Play max 8). iOS classes get three App Store
previews (record, fix, invest; 15–30 s, exact preview resolution, 30 fps,
silent AAC). One captioned 1920×1080 tour (11 chapters, status and nav
bars cropped so it is platform-neutral) serves as the Play promo video
via YouTube and is embedded on the website; the App Store text points to
the website, never to YouTube/Android/Play (guideline 2.3.10). Captions
are rendered with Pillow because Homebrew ffmpeg lacks `drawtext`.
Videos are generated under `build/store_media/`, not committed.

## Risks / Trade-offs

- **[Risk]** Console UI labels drift. → Describe intent plus stable
  artifact paths; fix the runbook when a renamed screen is hit.
- **[Risk]** Screenshot test drifts from acceptance helpers. → It is
  analyzed in CI, so helper API changes break it loudly.
- **[Trade-off]** No phased Apple release: a regression reaches all Apple
  users on approval; TestFlight is the only pre-release exposure.
- **[Trade-off]** Screenshots are binary files in the repo (~28 small
  PNGs); accepted for reviewable listing diffs.

## Migration Plan

1. Add runbook, ExportOptions files, listing directory, screenshot tool.
2. Update checklist, CONTRIBUTING, docs wording, workflow display name.
3. Tag `v1.0.0+3`. Rollback = revert the commits and delete the tag.
