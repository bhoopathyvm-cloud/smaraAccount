## ADDED Requirements

### Requirement: Store Release Runbook Exists
The repository SHALL contain a store release runbook at
`docs/release/store-release-runbook.md` that a release owner can follow
step by step to ship an update to Google Play, Apple iOS (TestFlight and
App Store), and the Mac App Store. The runbook SHALL be an ordered
checklist, SHALL mark every step as either runnable from the command line
(🤖) or store-console-only (👤), SHALL use this project's real identifiers
and commands, and SHALL NOT require reading archived OpenSpec notes to
complete a routine release.

#### Scenario: Runbook is discoverable and checklist-shaped
- **WHEN** a release owner opens `docs/release/store-release-runbook.md`
- **THEN** its primary content is numbered or checkbox steps in release
  order, each marked 🤖 or 👤

#### Scenario: Every release ships all three platforms
- **WHEN** a release owner follows the runbook for a release
- **THEN** it ships iOS, macOS, and Android with the same version and
  build number

### Requirement: Calendar Versioning With A Shared Monotonic Build Number
Releases SHALL use the version format `YYYY.MM.N` (four-digit year,
zero-padded two-digit month, and a release counter within that month
starting at 0) in `pubspec.yaml`. The build number after `+` SHALL be
shared by all stores, SHALL be strictly greater than every previously
tagged build, and SHALL never be reused, even if a store did not receive
that build.

#### Scenario: Next version and build are derived from tags
- **WHEN** a release owner prepares the first release of October 2026 and
  the highest release tag is `v1.0.0+3`
- **THEN** the runbook leads them to set `version: 2026.10.0+4`

#### Scenario: Build-number reuse is warned against
- **WHEN** a release owner reaches the version-bump step
- **THEN** the runbook warns that reusing an Apple build number can report
  upload success while the build never appears in App Store Connect

### Requirement: Releases Come From Tagged Commits On Main
A release SHALL be built only from a commit on `main`. After the release
gates pass, the commit SHALL be tagged `v<version>+<build>` and a draft
GitHub Release SHALL be created holding the gate evidence and English
release notes, before any store upload. The GitHub Release SHALL be
published once all stores accept the build. A store rejection SHALL be
fixed through `main` and shipped under a new build number.

#### Scenario: Tag and draft release precede uploads
- **WHEN** both release gates pass for a `main` commit
- **THEN** the runbook's next steps create the tag and the draft GitHub
  Release, and only then build and upload from that tagged commit

#### Scenario: Previously shipped build is tagged
- **WHEN** this change is implemented
- **THEN** a tag `v1.0.0+3` exists on commit `4156b8b`

### Requirement: Release Gates Run On The Candidate
Before tagging, the runbook SHALL require the release gates defined by
`localized-release-verification`: a manually dispatched run of the
acceptance workflow on the candidate commit with every locale passing,
and the macOS English baseline. The runbook SHALL point at
`docs/release/checklist.md` rather than restating the gate procedures.

#### Scenario: Gates are referenced, not reinvented
- **WHEN** a release owner reaches the verification step
- **THEN** the runbook links `docs/release/checklist.md` for the gate
  procedures

### Requirement: Google Play Release Steps
The runbook SHALL document building the release-signed AAB
(`flutter build appbundle`, artifact
`build/app/outputs/bundle/release/app-release.aab`), confirming it is not
debug-signed, uploading it to the existing closed testing track, and then
promoting it to production as a staged rollout at 20%, raised to 100%
after 3 days. First-time keystore work SHALL be linked to
`docs/release/android-upload-keystore.md`, not duplicated.

#### Scenario: Closed testing precedes staged production
- **WHEN** a release owner follows the Play section
- **THEN** the build goes to closed testing first, then production at 20%,
  then 100% after 3 days

### Requirement: Apple iOS And macOS Release Steps
The runbook SHALL document uploading iOS and macOS builds to the shared
App Store Connect record (`com.smaraaccounting.smaraAccounting`) through
both the Xcode Organizer path and the command-line path using the
committed `ios/ExportOptions.plist` and `macos/ExportOptions.plist`. It
SHALL require waiting for processing before TestFlight assignment, cover
submitting for App Review with automatic release after approval and no
phased release, and list the previously hit macOS App Store validator
rejections with their fixes.

#### Scenario: Command-line upload uses committed export options
- **WHEN** a release owner uses the command-line path
- **THEN** the runbook's `xcodebuild -exportArchive` commands reference the
  committed `ExportOptions.plist` for that platform

#### Scenario: Known macOS rejections are listed
- **WHEN** a macOS upload is rejected by App Store Connect validation
- **THEN** the runbook lists the previously seen errors (90285, 90242,
  missing encryption declaration) and their fixes

### Requirement: English Release Notes
Store "What's new" text SHALL be English only, derived from the GitHub
Release notes for that tag.

#### Scenario: Notes have one source
- **WHEN** a release owner fills in a store's "What's new"
- **THEN** the runbook directs them to summarize that release's GitHub
  Release notes in English
