## Why

`acceptance-test-suite`'s existing spec forbids any GitHub Actions invocation of the full acceptance suite, reasoned from GitHub-hosted runners' fixed 6-hour job timeout versus the suite's real 8-10h-per-locale runtime — a limit that seemed to rule out CI entirely. That reasoning was never actually tested against a real GitHub-hosted macOS runner; it was inferred from the runtime numbers. The user wants to try it directly rather than continue assuming: dispatch the suite on GitHub-hosted `macos-latest` runners, across every supported locale, and see empirically what actually happens (full pass within 6h, partial-but-useful progress before timeout, or immediate failure) before deciding whether CI has any role here at all.

## What Changes

- Adds a `workflow_dispatch`-triggered, repository-owner-gated GitHub Actions job (`acceptance-suite-spike.yml`) on `macos-latest` that runs `tool/run_acceptance_tests.sh -d macos -l <locale>` as a matrix across all 43 supported locale tags, one job per locale, `fail-fast: false`, no `flutter-ci.yml` gate involvement.
- Carves a narrow, explicit exception into `acceptance-test-suite`'s "One-Command, Manual-Only Developer Entry Point" requirement: a `workflow_dispatch`-only, repository-owner-gated GitHub Actions invocation is permitted **for this bounded feasibility experiment**, still never scheduled, never part of any required PR gate, and never triggered by anything but the owner's manual dispatch.
- **Does not** change the underlying manual-only policy's intent otherwise — this is an explicit, narrow, reviewable spike to gather real data, not a reversal of "the acceptance suite doesn't run in CI." If the experiment confirms the 6-hour cap makes this unworkable (the likely outcome, given the suite's own measured 8-10h-per-locale runtime), a follow-up change removes the exception and this workflow entirely.
- **BREAKING** (spec, not code): loosens an existing hard prohibition, even if only temporarily and narrowly, which is why it needs its own change rather than an ad hoc workflow edit.

## Capabilities

### Modified Capabilities
- `acceptance-test-suite`: "One-Command, Manual-Only Developer Entry Point" gains a narrow, explicitly-scoped exception permitting a `workflow_dispatch`-only, repository-owner-gated GitHub Actions invocation for this feasibility spike.

## Impact

- New `.github/workflows/acceptance-suite-spike.yml`.
- No changes to `tool/run_acceptance_tests.sh`, `tool/run_localized_acceptance_tests.sh`, `flutter-ci.yml`, or any other existing workflow.
- Real cost: up to 43 macOS-runner jobs, each capped at GitHub's 6-hour hosted-runner maximum, run in parallel up to whatever this account's actual macOS concurrency ceiling turns out to be (documented default for non-Enterprise accounts is lower for macOS than Linux; this run itself will reveal the real number, consistent with how `localized-smoke-parallelism` empirically found the real concurrency ceiling rather than assuming one).
- Expected outcome, stated plainly: most or all locale jobs are expected to hit the 6-hour timeout without finishing, since the suite's own measured runtime already exceeds it per locale. This is treated as a valid, useful experimental result, not a failure to fix.
