## ADDED Requirements

### Requirement: Store Listing Sources Are Maintained In The Repository
The English store listing sources — listing text, App Privacy draft,
content rating / Data Safety draft, Play icon and feature graphic, and
the screenshots for every required size class — SHALL live in the
maintained directory `docs/release/store-listing/`, with screenshots
under `docs/release/store-listing/screenshots/<size-class>/`. The copies
inside the archived `store-listing-assembly` change SHALL remain frozen
and SHALL NOT be edited. Store listings SHALL be English only.

#### Scenario: Listing edits happen in the maintained directory
- **WHEN** a release changes the store listing
- **THEN** the text or screenshot changes are committed under
  `docs/release/store-listing/`, not in the archive

### Requirement: Screenshots Are Regenerated With A Maintained Tool
Store screenshots SHALL be captured by a maintained
`integration_test/store_screenshots_test.dart`, run through
`tool/capture_store_screenshots.sh -d <device-id> -c <size-class>`, from a
real running build on an iOS Simulator or Android emulator, with a clean
status bar. Each automated size class SHALL get at least 15 screenshots
covering different flows, named in store-priority order so the first 10
(App Store) or 8 (Google Play) are the ones uploaded. The test SHALL be
checked by `flutter analyze` and SHALL NOT be run by
`tool/run_acceptance_tests.sh` or any CI workflow.

#### Scenario: Wrapper captures into the maintained directory
- **WHEN** a release owner runs `tool/capture_store_screenshots.sh -d <device-id> -c <size-class>`
- **THEN** at least 15 screenshots of distinct flows from that device are
  written under `docs/release/store-listing/screenshots/<size-class>/`

#### Scenario: Helper drift fails loudly
- **WHEN** an acceptance helper the screenshot test uses changes signature
- **THEN** `flutter analyze` reports the screenshot test as broken

### Requirement: Preview Videos Are Recorded With A Maintained Tool
`tool/record_store_previews.sh -d <device-id> -c <size-class>` SHALL record
the app's flows from a real running build (driven by
`integration_test/store_previews_test.dart`) and compose: for each App
Store size class, three app previews of 15–30 seconds at that class's
exact preview resolution and at most 30 fps, with an audio track; and one
captioned, platform-neutral landscape tour video covering every chapter,
for the Google Play promo video (YouTube) and the project website.
App Store metadata SHALL NOT mention YouTube, Android, or Google Play; it
points to the tour through the project website instead.

#### Scenario: Apple previews meet the format limits
- **WHEN** previews are recorded for an App Store size class
- **THEN** three MP4 files are produced, each 15–30 seconds long, at the
  class's preview resolution and 30 fps

#### Scenario: One tour for Play and the website
- **WHEN** previews are recorded
- **THEN** one captioned 1920×1080 tour video covering every chapter is
  produced, with status and navigation bars cropped out

### Requirement: Each Release Checks Whether The Listing Changed
The store release runbook SHALL include a per-release listing check: if
Home, Register, Accounts, or Settings changed visually, or a feature named
in the listing description changed, every screenshot size class SHALL be
recaptured and the listing text updated; if the privacy policy changed,
the App Privacy and Data Safety answers SHALL be re-cross-checked against
it before submission.

#### Scenario: Privacy policy change triggers declaration review
- **WHEN** `pages/open-source/smara-account/privacy-policy.md` changed since
  the previous release tag
- **THEN** the runbook requires re-checking App Store Connect's App Privacy
  and Play's Data Safety answers before submitting the release
