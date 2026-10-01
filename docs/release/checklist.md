# Release checklist

A release is ready only after the release owner confirms both required
checks below for the release candidate (a commit on `main`, see the
[store release runbook](store-release-runbook.md)): a Linux
locale-regression run dispatched on that exact commit, and a manual macOS
baseline check. Together these replace the old curated-9-locale manual
macOS sweep (multi-day, by hand) — locale coverage is automatic and
broader (43 locales); the macOS check verifies real macOS platform
behavior, not locale variation.

## Required: Linux locale-regression run on the candidate

[`acceptance-suite-nightly.yml`](../../.github/workflows/acceptance-suite-nightly.yml)
("Acceptance Suite Weekly") runs the full acceptance suite once per
supported locale (all 43, see `kSupportedLocaleTags` in
[`supported_locales.dart`](../../lib/l10n/supported_locales.dart)) against
the Linux desktop target on a GitHub-hosted runner. Its schedule is
weekly (Sundays), so a scheduled run does **not** count for a release —
dispatch one on the candidate. It is not part of the required
pull-request checks.

- [ ] While `main` is the release candidate, dispatch the workflow
  (`workflow_dispatch`, repository-owner only):

  ```sh
  gh workflow run acceptance-suite-nightly.yml --ref main
  gh run list --workflow acceptance-suite-nightly.yml --limit 1 \
    --json databaseId,headSha,status,conclusion,url
  ```

  Confirm the run's `headSha` is the candidate commit; if `main` moved,
  dispatch again.
- [ ] Confirm every one of the 43 locale jobs in that run passed. Record the
  run URL and commit SHA in the release's draft GitHub Release (the
  release record).
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
  immediately after it returns) and record the result, candidate commit,
  and environment details in the release's draft GitHub Release (the
  release record); keep the terminal output.
- [ ] If it fails, hold the release. Investigate and fix the failure, then
  obtain a passing run for the release candidate. If the candidate changes,
  re-run for the candidate that will actually ship.

The CI localized smoke test and a filtered acceptance group do not satisfy
either check above.

## Platform release steps

- [ ] Continue with the [store release runbook](store-release-runbook.md)
  from its tagging step: tag and draft GitHub Release, then Google Play,
  iOS, and the Mac App Store.
- [ ] For first-time Android signing on a machine, follow the [upload
  keystore and signed release instructions](android-upload-keystore.md).
  This checklist establishes the locale and macOS-baseline gates; it does
  not replace platform signing or store submission requirements.
