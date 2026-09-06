## Why

Smara Accounting's build configuration is close to store-ready — Android
signing is wired, the iOS privacy manifest and export-compliance flag are in
place, and real app icons are generated — but no one has yet walked the app
through an actual store submission. An `/opsx:explore` session surfaced that
the two accounts required to submit anywhere (Apple Developer Program, Google
Play Console) don't exist yet, and that Google's mandatory 14-day/12-tester
closed-testing gate for new Play accounts means production release timing is
bounded by that clock, not by engineering effort. This change exists to track
the remaining path to submission across both stores in one place, instead of
leaving it scattered across `android-release-signing`,
`ios-privacy-compliance`, `app-icon-branding`, and `macos-app-store-sandbox`.

## What Changes

- Track Apple Developer Program enrollment and Google Play Console
  registration as the critical-path items (their approval/verification
  timing is external and unpredictable, so they should start first).
- Add the one code/config step no existing change owns: configuring a real
  Apple Developer Team in Xcode's Signing & Capabilities for the `Runner`
  target for **iOS** distribution (only the macOS analogue is currently
  tracked, in `macos-app-store-sandbox` task 1.1).
- Track closing out the remaining human steps in `android-release-signing`
  (generate upload keystore, populate `key.properties`, verify a
  release-signed build) by reference rather than duplicating them.
- Track landing the `smara-ai.ch` DNS cutover (`project-website-smara-rebrand`
  tasks 6.1/6.2) as a submission prerequisite, since both stores require a
  live, public privacy-policy URL at submission time.
- Track assembling each store's listing (screenshots, description, content
  rating / Data Safety form, App Privacy labels) using assets that are
  already prepared.
- Track the actual submission mechanics for both stores: App Store Connect
  record + archive/upload + App Review for iOS; Play Console app record +
  signed AAB + Play App Signing + mandatory closed-testing track for
  Android.
- Track a final acceptance-suite verification pass before either submission,
  per this repo's convention of running the full suite after
  release-configuration changes.

## Capabilities

### New Capabilities
- `app-store-launch-readiness`: the app has everything required — developer
  accounts, signing identities, a live privacy policy, complete store
  listings, and a verified release build — to be submitted to the Apple App
  Store and Google Play Store, and has actually been submitted through each
  store's required release track.

### Modified Capabilities
- (none — no product behavior changes; this is a release/administrative
  readiness change only)

## Impact

- `ios/Runner.xcodeproj` (Signing & Capabilities — Team selection, human step
  in Xcode, not a text diff)
- `android/key.properties` (new, user-generated, outside version control)
- `pages/` / DNS configuration for `smara-ai.ch` (external, cross-referenced
  from `project-website-smara-rebrand`)
- App Store Connect and Google Play Console (external systems — account
  creation, app records, listings, review submission)
- No application code changes are expected; this change is administrative
  and cross-references existing in-repo changes rather than re-doing their
  work.
