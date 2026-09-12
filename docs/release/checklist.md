# Release checklist

A release is ready only after the release owner confirms both required
checks below for the release candidate: the automated nightly Linux
locale-regression tier, and a manual macOS baseline check. Together these
replace the old curated-9-locale manual macOS sweep (multi-day, by hand) —
locale coverage is now automatic and broader (43 locales, nightly); the
macOS check verifies real macOS platform behavior, not locale variation.

## Required: nightly Linux locale-regression check

[`acceptance-suite-nightly.yml`](../../.github/workflows/acceptance-suite-nightly.yml)
runs the full acceptance suite once per night, once per supported locale
(all 43, see `kSupportedLocaleTags` in
[`supported_locales.dart`](../../lib/l10n/supported_locales.dart)), against
the Linux desktop target on a GitHub-hosted runner. It is not part of the
required pull-request checks — a failing locale on a given night does not
block merges — but it is required reading before a release ships.

- [ ] Open the workflow's run history and find the most recent run at or
  near the release candidate's commit. If the last run predates changes
  that could plausibly affect localization or the acceptance suite itself,
  dispatch it manually (`workflow_dispatch`, repository-owner only) against
  the candidate commit rather than relying on a stale result.
- [ ] Confirm every one of the 43 locale jobs in that run passed. Record the
  run URL and commit SHA it covered in the release record.
- [ ] If any locale failed, hold the release. Investigate and fix the
  failure (or obtain a fresh passing run for the candidate), or document a
  deliberate, explicit exception (excluded locale, reason, release owner's
  decision) in the release record. Never silently ignore a failed locale or
  describe a partial result as a full pass.

## Required: macOS baseline check

This verifies real macOS platform behavior (window/rendering behavior, OS
Keychain integration) independent of locale — it is **English only**, not a
multi-locale sweep.

- [ ] Use a Mac configured for this project's Flutter desktop development.
  From the repository root, run `flutter doctor -v`, resolve any macOS/Xcode
  setup problems, then run `flutter pub get` and `flutter devices`. The latter
  must list the `macos` target. The existing CI workflows pin Flutter 3.47.1.
- [ ] Use a dedicated test macOS user account with no production Smara data.
  The acceptance harness resets the app's real database, preferences, and
  signing/recovery keychain entries. Do not run this against your personal ledger.
- [ ] Reserve approximately **8–10 hours** for this single run (one locale,
  English) — this estimate comes from previous macOS runs; allow time for
  failures and reruns. Keep the Mac powered, awake, and available for the
  GUI run throughout.
- [ ] From the repository root, run exactly:

  ```sh
  tool/run_acceptance_tests.sh -d macos
  ```

  No locale flag: this runs the full acceptance suite once, in English,
  using a real macOS app, database, and OS keychain.
- [ ] Confirm the run passes (37/37 tests, exit status 0 — `echo $?`
  immediately after it returns) and save the terminal output with the
  release record, alongside the candidate commit and environment details.
- [ ] If it fails, hold the release. Investigate and fix the failure, then
  obtain a passing run for the release candidate. If the candidate changes,
  re-run for the candidate that will actually ship.

The CI localized smoke test and a filtered acceptance group do not satisfy
either check above.

## Platform release steps

- [ ] For Android, complete the [upload keystore and signed release
  instructions](android-upload-keystore.md), including the Play Console steps.
- [ ] Follow the project's [contribution and store release
  guidance](../../CONTRIBUTING.md#store-release-human-steps) for the target
  platform. This checklist establishes the localized and macOS-baseline
  gates; it does not replace platform signing or store submission requirements.
