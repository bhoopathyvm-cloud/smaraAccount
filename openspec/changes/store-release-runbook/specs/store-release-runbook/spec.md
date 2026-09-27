## Purpose

A discoverable, checklist-style procedure that a release owner can follow
end-to-end to bump the app version, satisfy existing release gates, update
Google Play closed testing with a signed AAB, and upload an iOS build to
TestFlight without rediscovering console steps or known pitfalls.

## ADDED Requirements

### Requirement: Store Release Runbook Exists
The repository SHALL contain a store release runbook at
`docs/release/store-release-runbook.md` that a release owner can follow
step by step to ship an update to Google Play closed testing and to Apple
TestFlight. The runbook SHALL be written as an ordered checklist (not an
essay), use this project's real identifiers and commands where they
matter, and SHALL NOT require reading archived OpenSpec task notes to
complete a routine update.

#### Scenario: Runbook is discoverable under docs/release
- **WHEN** a release owner looks under `docs/release/` for how to push a
  store update
- **THEN** `store-release-runbook.md` is present and named so its purpose
  is obvious

#### Scenario: Runbook is checklist-shaped
- **WHEN** a release owner opens the runbook to perform a release
- **THEN** the primary content is numbered or checkbox steps in release
  order, not a narrative that must be reverse-engineered into actions

### Requirement: Shared Prep Before Either Store
The runbook SHALL start with shared preparation that applies before either
store upload: work from the commit intended to ship, bump
`pubspec.yaml`'s version so the build number after `+` is strictly greater
than any build already uploaded to Play Console or App Store Connect for
this app, and complete the release gates required by
`localized-release-verification` (nightly locale tier check and macOS
baseline acceptance) before treating the candidate as shippable.

#### Scenario: Version bump is mandatory and explained
- **WHEN** a release owner follows the shared-prep section
- **THEN** they are told to raise the `+` build number above every
  previously uploaded build, and warned that reusing an Apple build number
  can report upload success while the build never appears in App Store
  Connect

#### Scenario: Release gates are referenced, not reinvented
- **WHEN** a release owner reaches the verification step in shared prep
- **THEN** the runbook points at `docs/release/checklist.md` /
  `localized-release-verification` rather than restating the full locale
  and macOS procedures inline

### Requirement: Google Play Closed Testing Update Steps
The runbook SHALL document how to build a release-signed Android App
Bundle from this repository, where the artifact is written, how to confirm
it is not debug-signed, and the Play Console clicks to create a new
release on the existing closed testing track and roll it out to current
testers. Deep keystore setup SHALL remain in
`docs/release/android-upload-keystore.md`; the runbook SHALL link to it
for first-time keystore work rather than duplicating enrollment history.

#### Scenario: AAB build and upload path are explicit
- **WHEN** a release owner follows the Play section
- **THEN** they can run the documented `flutter build appbundle` (or
  equivalent), locate
  `build/app/outputs/bundle/release/app-release.aab`, and upload it to the
  closed testing track without inventing console navigation

#### Scenario: Closed testing, not production, is the default path
- **WHEN** a release owner follows the Play section for a routine update
- **THEN** the steps target the existing closed testing track, not a
  direct production release

### Requirement: iOS TestFlight Upload Steps
The runbook SHALL document uploading a Team-signed iOS build to App Store
Connect for TestFlight, including both the Xcode Organizer path and the
CLI archive/export path this project has already used successfully. It
SHALL name the App Store Connect app / bundle id used by this repository,
require waiting for processing before assigning testers, and cover
enabling the build for Internal and/or External TestFlight groups.

#### Scenario: Xcode path is sufficient for a routine upload
- **WHEN** a release owner prefers the GUI
- **THEN** the runbook lists Archive → Distribute → App Store Connect →
  Upload, then TestFlight assignment after processing

#### Scenario: CLI path matches prior successful uploads
- **WHEN** a release owner prefers the command line
- **THEN** the runbook documents archiving for generic iOS and exporting
  with App Store Connect upload destination, consistent with prior
  successful uploads for this app

#### Scenario: TestFlight assignment is after processing
- **WHEN** upload reports success
- **THEN** the runbook tells the owner to wait until the build appears in
  TestFlight (and clear export-compliance prompts if shown) before adding
  it to a tester group
