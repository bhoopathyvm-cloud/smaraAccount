## 1. Workflow

- [x] 1.1 Created `.github/workflows/acceptance-suite-spike.yml`: `workflow_dispatch` only, `if: github.actor == github.repository_owner`, `runs-on: macos-latest`, `timeout-minutes: 360`, matrix over all 43 tags in `kSupportedLocaleTags`, `fail-fast: false`. Each job runs `flutter pub get --enforce-lockfile` then `tool/run_acceptance_tests.sh -d macos -l ${{ matrix.locale }}` — the script's own header confirms `-l en` is a valid, ordinary invocation (defaults to `en` when omitted; passing it explicitly is equivalent), so no special-casing was needed for English.
- [x] 1.2 Confirmed the workflow YAML parses via `python3 -c "import yaml; yaml.safe_load(...)"`, and that the matrix's 43 tags match `kSupportedLocaleTags` exactly (`sorted(tags) == sorted(workflow)` → `True`, empty set difference).

## 2. Run the spike

- [ ] 2.1 Push to a branch, dispatch the workflow, and record the real per-locale outcome: which jobs completed within 6h (and their actual wall-clock time), which timed out, and how far each timed-out job's log shows it got before being killed.
- [ ] 2.2 Report the results plainly: does any locale complete within 6h? If the account's real macOS concurrency ceiling turned out to matter (jobs queued rather than ran in parallel), note that too.

## 3. Decide and document

- [ ] 3.1 Update design.md's Open Questions (or add a findings section) with the actual outcome and what it implies for `acceptance-test-suite`'s manual-only policy going forward.
- [ ] 3.2 If the spike confirms CI is infeasible (the expected outcome): remove `.github/workflows/acceptance-suite-spike.yml` and the spec exception added by this change in the same change (revert to the original absolute prohibition) rather than leaving a dead, narrowly-scoped exception in the spec permanently. If some locales genuinely complete within 6h: leave the exception and workflow in place, and flag to the user that a follow-up proposal is needed to decide what (if anything) becomes a real CI tier.
