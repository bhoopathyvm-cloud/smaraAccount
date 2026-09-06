## ADDED Requirements

### Requirement: iOS and macOS builds are signed by a real Apple Developer Team
Archive builds of the `Runner` target SHALL be signed with a Team from an
active Apple Developer Program membership, not an automatically-managed
personal team or no team at all.

#### Scenario: Archiving Runner for distribution
- **WHEN** the `Runner` target is archived in Xcode for App Store or
  notarized distribution
- **THEN** the archive is signed with a Team tied to an active Apple
  Developer Program membership

### Requirement: The app is submitted for Apple App Store Review
An App Store Connect record for the app SHALL exist, carry the prepared
listing assets and the live privacy-policy URL, and have a build submitted
for App Review.

#### Scenario: First iOS submission
- **WHEN** an archived, Team-signed build is uploaded to App Store Connect
- **THEN** the app's App Store Connect record has the listing assets and
  privacy-policy URL attached, and the build has been submitted for review

### Requirement: The app is pushed to a Google Play closed testing track
Because the Google Play Console account is newly registered, the app SHALL
be released to a **closed testing** track with the tester count and duration
Google requires before requesting production access — not directly to
production.

#### Scenario: First Android release
- **WHEN** a release-signed AAB is uploaded to a newly registered Play
  Console account
- **THEN** it is released via a closed testing track with at least the
  number of testers Google's current policy requires, not via the
  production track

#### Scenario: Requesting production access
- **WHEN** the closed testing track has run for the number of consecutive
  days Google's current policy requires
- **THEN** production access may be requested for the app

### Requirement: The privacy policy is live at the URL referenced by both store listings
Both store listings SHALL reference a privacy-policy URL that is publicly
reachable (not blocked by DNS not yet being cut over) at the time of
submission.

#### Scenario: Privacy policy reachable before submission
- **WHEN** either store's listing is submitted with a privacy-policy URL
- **THEN** that URL resolves publicly and serves the current privacy-policy
  content

### Requirement: Store data-practice disclosures match the privacy policy
Google Play's Data Safety form and App Store Connect's App Privacy labels
SHALL describe the same data flows as the app's published privacy policy —
neither over- nor under-declaring what the app actually does with data.

#### Scenario: Disclosures cross-checked before submission
- **WHEN** the Data Safety form or App Privacy labels are filled in
- **THEN** each declared data flow matches a corresponding statement in
  `pages/open-source/smara-account/privacy-policy.md`
