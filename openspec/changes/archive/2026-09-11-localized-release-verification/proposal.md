## Why

`onboarding-language-selection` and `acceptance-tests-multi-locale` gave this app real, per-locale GUI test coverage, but that coverage has only ever been *run* by hand, once each, for 3 locales (English, Japanese, Arabic) during active development. There is no repeatable, defined moment where "does the app actually work end-to-end in every supported language" gets checked before a release ships — the app's cross-*platform* correctness is exercised (unit/widget tests run on every PR; the acceptance suite covers real-device behavior on demand), but cross-*language* correctness at the same depth is not a standing practice yet, only something that happened once, manually, this session.

This closes that gap: a defined, repeatable "run the full acceptance suite once per language, on one real platform" step, performed before a release — the same kind of assurance a platform-targeted device test gives, applied along the language axis instead.

## What Changes

- Formalizes `tool/run_localized_acceptance_tests.sh -d macos` (already built in `acceptance-tests-multi-locale`, currently covering the 9-locale curated set) as a documented, required **pre-release** step — run manually by a developer/release owner before cutting a release, not automated in CI.
- Keeps the locale set at today's curated 9 for now — growing it is a real, separate decision (each added locale costs another 8-10h per pre-release pass), not a default yes; see design.md for the trade-off and what it would take to grow this without slowing every release down.
- Documents this step in a release checklist (new doc — see design.md for exactly where) so it's a defined, referenceable practice, not tribal knowledge from this session.
- **Explicitly does not** attempt to run this suite in GitHub Actions CI, on any OS. Two things converged on this in discussion: (1) the existing `acceptance-test-suite` spec already requires this tier stay manual-only and never CI-invoked — this proposal doesn't touch that requirement; (2) the full suite's real measured runtime (7h57m-10h03m per locale) exceeds GitHub-hosted runners' fixed 6-hour job timeout, a platform limit that doesn't change with OS or parallelism, so it couldn't run as CI even if the spec allowed it. (Windows, iOS, and Android are already-working platforms for this app — only Linux is a genuine gap, and that's tracked separately in `add-linux-desktop-support`, not a reason for this proposal's scope.)
- **BREAKING** (process, not code): a release is no longer considered ready to ship until this step has been run and passed for the current locale set — this adds a manual gate to the release process that didn't exist before.

## Capabilities

### New Capabilities
- `localized-release-verification`: a defined, repeatable pre-release requirement that the full real-device acceptance suite runs, and passes, once per locale in the covered set, on macOS, before a release ships.

### Modified Capabilities

(none — `acceptance-test-suite`'s existing "manual-only, never invoked by CI" requirement is unchanged and unaffected by this proposal)

## Impact

- A new release-checklist doc (see design.md for exact location).
- No changes to `tool/run_acceptance_tests.sh` or `tool/run_localized_acceptance_tests.sh` themselves — both already exist and work as needed.
- No CI workflow changes.
- No application code changes.
- Real cost: each full pass over the curated set takes multiple days of real macOS wall-clock time today (9 locales × 8-10h ≈ 3-4 days sequentially on one machine) — a genuine, ongoing cost this proposal makes explicit and asks the team to accept as the price of this assurance, rather than something to solve by throwing free CI parallelism at it (design.md covers why that doesn't work here, and what would).
