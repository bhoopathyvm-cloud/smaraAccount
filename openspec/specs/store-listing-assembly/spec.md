# store-listing-assembly

## Purpose

Defines what "the store listings are ready" actually means for Smara
Account, so App Store Connect and Google Play Console submissions aren't
blocked by missing or inconsistent listing content at the last minute.

## Requirements

### Requirement: App description, keywords, category, and support URL
Both stores SHALL have a finished app description, keyword list, category,
and support URL before submission. Content SHALL be adapted from the
project's existing public description of the app (`pages/open-source/
smara-account/`) rather than written independently, so the store listing
and the public project description don't drift apart or contradict each
other.

#### Scenario: Description drafted from existing project copy
- **WHEN** the app description is drafted for either store
- **THEN** it is derived from `pages/open-source/smara-account/index.md`'s
  existing "what it is / the problem / the solution" framing, adapted to
  each store's length and format constraints

#### Scenario: Category matches the app's actual nature
- **WHEN** a store category is chosen
- **THEN** it reflects that Smara Account is a personal finance / ledger
  app (matching the `LSApplicationCategoryType` of
  `public.app-category.finance` already set for the macOS build)

### Requirement: Screenshots at each store's required sizes
Both stores SHALL have screenshots captured from a real running build
(Simulator or device), organized into each store's required device/size
classes, before submission. Placeholder, mocked-up, or marketing-only
imagery SHALL NOT substitute for a real captured screen.

#### Scenario: Screenshots come from a real build
- **WHEN** a screenshot is captured for either store's listing
- **THEN** it is taken from an actual running build of the app (iOS
  Simulator, a real device, or the signed macOS build), not a mockup

#### Scenario: Screenshot sizes match store requirements
- **WHEN** screenshots are organized for submission
- **THEN** each is sized/cropped to the specific device class App Store
  Connect or Play Console requires for that image, not a single
  one-size-fits-all export

### Requirement: Privacy declarations cross-checked against the real policy
Google Play's Data Safety form and App Store Connect's App Privacy
section SHALL each be completed by cross-checking every declared data
practice against `pages/open-source/smara-account/privacy-policy.md`,
line by line, rather than filled in from memory or assumption. A
declaration SHALL NOT claim a data practice (collection, sharing,
tracking) that the actual privacy policy doesn't also describe, and
SHALL NOT omit one the privacy policy does describe.

#### Scenario: Data Safety form matches the privacy policy
- **WHEN** Google Play's Data Safety form is completed
- **THEN** every data type and purpose declared there has a corresponding,
  consistent statement in `privacy-policy.md`

#### Scenario: App Privacy section matches the privacy policy
- **WHEN** App Store Connect's App Privacy ("nutrition label") section is
  completed
- **THEN** every data type and purpose declared there has a corresponding,
  consistent statement in `privacy-policy.md`

### Requirement: Google Play content rating questionnaire completed
Google Play's content rating questionnaire SHALL be completed accurately
based on the app's actual content and functionality before submission.

#### Scenario: Content rating reflects actual app behavior
- **WHEN** the content rating questionnaire is answered
- **THEN** answers reflect what the app actually does (a personal finance
  ledger with no user-generated social content, no ads, no gambling
  mechanics) rather than defaults or guesses

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
