## 1. Workflow

- [x] 1.1 Created `.github/workflows/acceptance-suite-spike.yml`: `workflow_dispatch` only, `if: github.actor == github.repository_owner`, `runs-on: ubuntu-slim` (per the user's direction to use the same runner `localized-smoke.yml` already uses), `timeout-minutes: 360`, matrix over all 43 tags in `kSupportedLocaleTags`, `fail-fast: false`. Each job installs the same Linux build dependencies and Xvfb/D-Bus/keyring setup already proven in `linux-desktop.yml`, then runs `tool/run_acceptance_tests.sh -d linux -l ${{ matrix.locale }}`.
- [x] 1.2 Confirmed the workflow YAML parses via `python3 -c "import yaml; yaml.safe_load(...)"`, and that the matrix's 43 tags match `kSupportedLocaleTags` exactly (`sorted(tags) == sorted(workflow)` → `True`, empty set difference).
- [x] 1.3 Fixed `test/l10n/curated_locale_smoke_test.dart`'s `expect(kCuratedAcceptanceLocales, contains(_smokeLocaleTag))` assertion, which would otherwise fail 34 of `localized-smoke.yml`'s newly-added 43-locale matrix jobs (a separate, concurrent edit made directly by the user this same session) — narrowed to the `kSupportedLocaleTags` membership check the test actually needs. Verified every one of the 43 supported tags has a `kLocaleEndonyms` entry (the test's other locale-driven assertion), so no further gap exists.

## 2. Run the spike

- [ ] 2.1 Push to a branch, dispatch the workflow, and record the real per-locale outcome: which jobs completed within 6h (and their actual wall-clock time), which timed out, and how far each timed-out job's log shows it got before being killed. Note whether any locale fails identically at the same group (a single Linux-specific bug, not 43 independent ones).
- [ ] 2.2 Report the results plainly: does any locale complete within 6h? Does the fast Linux timing seen in `add-linux-desktop-support`'s 2-group spot check hold for the full 37-test suite, or does some group behave very differently under Xvfb? If Linux hosted-runner concurrency for this account turned out to matter (jobs queued rather than ran in parallel), note that too.

## 3. Decide and document

- [ ] 3.1 Update design.md's Open Questions (or add a findings section) with the actual outcome and what it implies for `acceptance-test-suite`'s manual-only policy going forward.
- [ ] 3.2 If the spike confirms CI is infeasible (the expected outcome): remove `.github/workflows/acceptance-suite-spike.yml` and the spec exception added by this change in the same change (revert to the original absolute prohibition) rather than leaving a dead, narrowly-scoped exception in the spec permanently. If some locales genuinely complete within 6h: leave the exception and workflow in place, and flag to the user that a follow-up proposal is needed to decide what (if anything) becomes a real CI tier.
