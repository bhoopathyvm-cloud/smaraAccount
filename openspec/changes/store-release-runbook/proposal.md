## Why

Updating Google Play, TestFlight/App Store, and the Mac App Store is
already possible, but the steps live scattered across archived OpenSpec
task notes, `docs/release/android-upload-keystore.md`, and ad-hoc memory.
A first-time or repeat release owner needs one easy-to-follow runbook so
version bumps, signing, console clicks, and known pitfalls (especially
reused Apple build numbers and the macOS App Store validator rejections)
are not rediscovered each time.

Around that runbook, several release conventions are undefined today:
there is no version-numbering rule beyond "bump `+N`", no release record
(the checklist asks for one but none exists), no tags, and the store
listing sources live only in a frozen archive folder with a copy-run-delete
screenshot script. The acceptance-suite locale gate also moved from
nightly to weekly (Sundays), so "the latest scheduled run near the
candidate" is no longer a meaningful gate.

## What Changes

- Add `docs/release/store-release-runbook.md`: an ordered checklist with
  every step marked 🤖 (runnable command) or 👤 (store-console only),
  covering shared prep, Google Play (closed testing → production staged
  rollout 20% → 100% after 3 days), iOS (TestFlight → App Review,
  automatic release), and macOS (same App Store Connect record as iOS).
  All three platforms ship every release with the same version/build.
- **Calendar versioning** `YYYY.MM.N` (zero-padded month) with one shared,
  never-reused build number `+N` across all stores (next build = highest
  tag + 1). First release under it: `2026.10.0+4`.
- **Releases only from `main`.** Each release is tagged
  `v<version>+<build>` with a draft GitHub Release (gate evidence +
  English notes) created after the gates pass and before any upload,
  published once the stores accept the build. Backfill `v1.0.0+3` on
  `4156b8b`.
- **Locale gate:** the release owner always dispatches the acceptance
  workflow manually on the candidate commit; the scheduled run is weekly.
  Fix "nightly" wording across docs; workflow display name becomes
  "Acceptance Suite Weekly" (filename unchanged).
- Commit `ios/ExportOptions.plist` and `macos/ExportOptions.plist` for the
  `xcodebuild -exportArchive` upload path (no secrets).
- **Store listing (English only):** move the listing text drafts, Play
  graphics, and screenshots from the archived `store-listing-assembly`
  change into a maintained `docs/release/store-listing/`; promote the
  screenshot capture script to a maintained
  `integration_test/store_screenshots_test.dart` with a
  `tool/capture_store_screenshots.sh` wrapper (analyzed, not run by the
  acceptance suite or CI); add a per-release "does the listing need
  updating?" check. Store "What's new" notes are English only.
- Link the runbook from `docs/release/checklist.md` and `CONTRIBUTING.md`.

## Capabilities

### New Capabilities
- `store-release-runbook`: the release procedure, versioning, tagging and
  release-record conventions, and per-store upload/rollout steps.

### Modified Capabilities
- `contributor-guide`: the Store release section links the runbook.
- `localized-release-verification`: the locale gate is a manually
  dispatched run of the weekly acceptance workflow on the candidate
  commit; the checklist points at the runbook after the gates.
- `acceptance-test-suite`: the scheduled Linux CI tier runs weekly, not
  nightly.
- `store-listing-assembly`: listing sources are maintained under
  `docs/release/store-listing/`, screenshots are regenerated with a
  maintained tool, and each release checks whether the listing changed.

## Impact

- Docs: new runbook and `docs/release/store-listing/`; link and wording
  updates in `docs/release/checklist.md`, `CONTRIBUTING.md`,
  `Specs/architecture/smara-tech-guidelines.md`, `SECURITY.md`, the
  website pages.
- Config: `ios/ExportOptions.plist`, `macos/ExportOptions.plist`;
  workflow display name in `.github/workflows/acceptance-suite-nightly.yml`.
- Code/tooling: `integration_test/store_screenshots_test.dart`,
  `tool/capture_store_screenshots.sh`. No app code changes.
- Git: tag `v1.0.0+3` on `4156b8b`.
- No store automation (no fastlane, no API keys); Play Console and App
  Store Connect steps stay human. Apple binary uploads use `xcodebuild`.
