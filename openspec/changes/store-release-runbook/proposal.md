## Why

Updating Google Play closed testing and uploading an iOS build to TestFlight
is already possible, but the steps live scattered across archived OpenSpec
task notes, `docs/release/android-upload-keystore.md`, and ad-hoc memory.
A first-time or repeat release owner needs one easy-to-follow runbook so
version bumps, signing, console clicks, and known pitfalls (especially
reused Apple build numbers) are not rediscovered each time.

## What Changes

- Add a step-by-step store release runbook under `docs/release/` covering:
  shared prep (version bump, release gates), Google Play closed-testing
  update, and iOS TestFlight upload (Xcode and CLI paths this project has
  already used).
- Link that runbook from `docs/release/checklist.md` and
  `CONTRIBUTING.md`'s existing Store release section so it is discoverable.
- Keep existing signing docs (`android-upload-keystore.md`) as the deep
  reference for keystore setup; the runbook points at them rather than
  duplicating enrollment history.

## Capabilities

### New Capabilities
- `store-release-runbook`: A discoverable, checklist-style procedure for
  bumping the app version, verifying release gates, uploading a signed AAB
  to Play closed testing, and uploading an iOS build to TestFlight.

### Modified Capabilities
- `contributor-guide`: The Store release section of `CONTRIBUTING.md` SHALL
  link to the new runbook (not only the keystore doc and checklist gates).
- `localized-release-verification`: The release checklist's platform steps
  SHALL point at the runbook for Play closed testing and TestFlight upload
  after the required locale/macOS gates.

## Impact

- Documentation only under `docs/release/`, plus short link updates in
  `CONTRIBUTING.md` and `docs/release/checklist.md`.
- No app code, signing config, or store listing asset changes.
- Human console steps (Play Console / App Store Connect) remain external;
  the runbook documents them, it does not automate them.
