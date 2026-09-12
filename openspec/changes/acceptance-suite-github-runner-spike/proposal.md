## Why

`acceptance-test-suite`'s existing spec forbids any GitHub Actions invocation of the full acceptance suite, reasoned from GitHub-hosted runners' fixed 6-hour job timeout versus the suite's real 8-10h-per-locale runtime measured on macOS — a limit that seemed to rule out CI entirely. That reasoning was never actually tested against a real GitHub-hosted runner, and it was specific to the macOS target: the same suite has never been run at full scale (all 37 tests, not just the 2 groups spot-checked in `add-linux-desktop-support`) against the Linux desktop target, where widget-driven interaction under Xvfb may behave very differently timing-wise. The user wants to try it directly on the `ubuntu-slim` runner already used by `localized-smoke.yml`, against the Linux target, across every supported locale, and see empirically what actually happens before deciding whether CI has any role here at all.

## What Changes

- Adds a `workflow_dispatch`-triggered, repository-owner-gated GitHub Actions job (`acceptance-suite-spike.yml`) on `ubuntu-slim` that runs `tool/run_acceptance_tests.sh -d linux -l <locale>` (the Linux desktop target added by `add-linux-desktop-support`, with the same Xvfb/D-Bus/keyring setup already proven in `linux-desktop.yml`) as a matrix across all 43 supported locale tags, one job per locale, `fail-fast: false`, no `flutter-ci.yml` gate involvement.
- Carves a narrow, explicit exception into `acceptance-test-suite`'s "One-Command, Manual-Only Developer Entry Point" requirement: a `workflow_dispatch`-only, repository-owner-gated GitHub Actions invocation is permitted **for this bounded feasibility experiment**, still never scheduled, never part of any required PR gate, and never triggered by anything but the owner's manual dispatch.
- **Does not** change the underlying manual-only policy's intent otherwise — this is an explicit, narrow, reviewable spike to gather real data, not a reversal of "the acceptance suite doesn't run in CI." If the experiment confirms the 6-hour cap makes this unworkable (the likely outcome, given the suite's own measured 8-10h-per-locale runtime), a follow-up change removes the exception and this workflow entirely.
- **BREAKING** (spec, not code): loosens an existing hard prohibition, even if only temporarily and narrowly, which is why it needs its own change rather than an ad hoc workflow edit.

## Capabilities

### Modified Capabilities
- `acceptance-test-suite`: "One-Command, Manual-Only Developer Entry Point" gains a narrow, explicitly-scoped exception permitting a `workflow_dispatch`-only, repository-owner-gated GitHub Actions invocation for this feasibility spike.

## Impact

- New `.github/workflows/acceptance-suite-spike.yml`.
- `test/l10n/curated_locale_smoke_test.dart`: dropped its `expect(kCuratedAcceptanceLocales, contains(_smokeLocaleTag))` assertion, which would otherwise fail for every one of `localized-smoke.yml`'s newly-added, not-yet-curated locales (see that workflow's own matrix, separately grown to all 43 locales). The smoke test's purpose — basic ARB/localization structural sanity — only ever needed `kSupportedLocaleTags` membership; the stricter curated-only check was never load-bearing for what this test actually verifies.
- No changes to `tool/run_acceptance_tests.sh`, `tool/run_localized_acceptance_tests.sh`, `flutter-ci.yml`, or `linux-desktop.yml`.
- Real cost: up to 43 `ubuntu-slim` jobs, each capped at GitHub's 6-hour hosted-runner maximum. Linux runner concurrency on hosted GitHub Actions is typically much higher than macOS's, so most/all jobs are expected to start close together rather than queue significantly — this run itself will confirm the real number for this account.
- Expected outcome is genuinely open, unlike a macOS-target version of this experiment would have been: the only Linux data that exists so far (`add-linux-desktop-support` tasks 4.1/4.2) is 2 of 13 groups completing in well under a minute combined — dramatically faster than the same groups' macOS runtime. Whether that generalizes to the full 37-test suite, or whether some later group (CSV/OFX import, investment holdings, etc.) behaves very differently on Linux, is exactly what this spike is for.
