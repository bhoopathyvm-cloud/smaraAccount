## Why

`acceptance-suite-github-runner-spike` proved the full 37-test acceptance suite runs cleanly against the Linux desktop target in CI: all 43 supported locales pass in ~11 minutes each on a GitHub-hosted `ubuntu-latest` runner — roughly 40-50x faster than the suite's measured 8-10h-per-locale macOS runtime, with enormous headroom under the 6-hour hosted-runner cap. `localized-release-verification`'s existing manual macOS pre-release gate (9 curated locales, ~72-90h by hand) exists because, at the time, no CI-based alternative was known to work. Now one does. This proposal makes the automated Linux nightly run the standing locale-regression gate, replacing the expensive manual multi-locale sweep, while keeping a lighter macOS-specific check so real macOS platform behavior (window/rendering quirks, Keychain behavior) doesn't go unverified before release.

## What Changes

- Converts `.github/workflows/acceptance-suite-spike.yml` into a permanent, scheduled workflow (`acceptance-suite-nightly.yml`): `on: schedule` (nightly cron) plus `workflow_dispatch` for on-demand runs, `runs-on: ubuntu-latest`, the same Xvfb/D-Bus/keyring setup and `tool/run_acceptance_tests.sh -d linux -l <locale>` matrix across all 43 supported locales, `fail-fast: false`.
- Adds a permanent "Nightly Linux CI Tier" requirement to `acceptance-test-suite`, replacing the narrow, temporary feasibility-spike exception. Still not part of `flutter-ci.yml`'s required pull-request gate — a nightly cadence, not a per-PR one.
- **Retires** `localized-release-verification`'s curated-9-locale, ~72-90h manual macOS multi-locale sweep (`tool/run_localized_acceptance_tests.sh -d macos`) as the pre-release locale gate — the nightly Linux tier now covers that role, at 43 locales instead of 9, automatically instead of by hand.
- **Keeps a lighter macOS check**: a single, English-only `tool/run_acceptance_tests.sh -d macos` run (no locale flag — the suite's original, ~8-10h baseline behavior, already required and already exercised on every real acceptance-suite run) remains a required pre-release step, so real macOS platform behavior is still verified by hand before a release, just without the multi-day multi-locale sweep on top of it.
- Updates `docs/release/checklist.md` to reflect the new shape: the nightly Linux CI tier (automatic, all locales, informational/regression-detection) plus the retained single-locale macOS pre-release check (manual, English only, required), replacing the old 9-locale macOS table and its ~72-90h cost estimate.

## Capabilities

### Modified Capabilities
- `acceptance-test-suite`: "One-Command, Manual-Only Developer Entry Point" changes from a narrow, temporary `workflow_dispatch`-only feasibility-spike exception to a permanent nightly-schedule allowance; adds a new "Nightly Linux CI Tier" requirement.
- `localized-release-verification`: "Full Acceptance Suite Runs Per Curated Locale Before Release" changes from a manual, curated-9-locale, macOS multi-locale sweep to pointing at the nightly Linux CI tier as the locale-regression gate, plus a retained single-locale (English) macOS pre-release check.

## Impact

- `.github/workflows/acceptance-suite-spike.yml` renamed/rewritten to `.github/workflows/acceptance-suite-nightly.yml`, gaining a `schedule` trigger.
- `docs/release/checklist.md`: the 9-locale macOS table and ~72-90h cost estimate are removed; replaced with a note pointing at the nightly Linux CI tier plus the retained single-locale macOS check.
- `tool/run_localized_acceptance_tests.sh` becomes unused as a pre-release step (not deleted here — a separate decision, since it may still be useful for ad hoc local debugging).
- No changes to `tool/run_acceptance_tests.sh`, `flutter-ci.yml`, or the acceptance suite's own test files.
- Real cost: ~43 `ubuntu-latest` job-minutes worth of Actions usage every night (free for this public repo); ~8-10h of macOS wall-clock time per release (down from ~80-98h combined today), plus whatever attention a failed nightly run requires from the repository owner.
