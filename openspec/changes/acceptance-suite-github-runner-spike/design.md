## Context

`acceptance-test-suite`'s manual-only requirement was written from reasoning, not measurement: GitHub-hosted runners cap every job at 6 hours regardless of OS, and the suite's own measured per-locale runtime (7h57m-10h03m on this session's Mac) exceeds that, so CI seemed ruled out by definition. That reasoning has never been checked against a real GitHub-hosted `macos-latest` runner, which may have different hardware (faster or slower than the developer's own Mac) and a real GUI session (unlike Linux's `ubuntu-latest`, which needed Xvfb for `add-linux-desktop-support` — macOS runners are real VMs with a window server, so no headless-launch workaround is expected to be needed here).

The user asked, after weighing the alternative (a self-hosted runner plus a permanent spec revision), to instead just try the GitHub-hosted path directly and see what actually happens, accepting that it will likely fail outright but treating that as a valid answer rather than an assumption.

## Goals / Non-Goals

**Goals:**
- Get real data: does `tool/run_acceptance_tests.sh -d macos -l <locale>` complete within 6 hours on a GitHub-hosted `macos-latest` runner, for any locale?
- If it does complete for some locales, learn which ones and how close to the 6h boundary they land.
- Keep the exception this requires as narrow and reversible as possible, so a negative result is trivial to close out (delete the workflow, revert the spec exception).

**Non-Goals:**
- Making this a permanent CI tier, however the experiment turns out. A positive result here would be its own follow-up decision (which locales, what cadence, whether it replaces or supplements the manual macOS-only process), not an automatic outcome of this change.
- A self-hosted runner. Explicitly the alternative path the user chose not to take for now.
- Fixing anything the spike finds. If the suite fails on GitHub's runner for reasons unrelated to the 6h cap (e.g., a display/rendering difference from the developer's own Mac), that is itself a useful, reportable finding — not a debugging obligation this change takes on.

## Decisions

1. **All 43 locales in one matrix, `fail-fast: false`, rather than one locale first.** The user explicitly asked to try all languages now rather than a single pilot locale. `fail-fast: false` ensures one locale's timeout doesn't cancel the others mid-flight, so the run produces a complete picture (which locales, if any, finish) rather than stopping at the first failure.
2. **`timeout-minutes: 360` set explicitly, matching GitHub's own hard ceiling for hosted runners.** This is already the platform maximum and cannot be raised, but setting it explicitly documents the intent in the workflow file rather than relying on an implicit default (GitHub's default is 360 minutes for public-repo hosted jobs already, so this is a no-op in practice, kept for clarity).
3. **No new group filter — full 37-test suite per locale, matching the developer-invoked script's existing behavior.** Running a smaller subset (e.g., just `onboarding`) would answer a different, easier question ("does a fast subset fit in 6h") than the one actually asked ("can the real pre-release gate move to CI").

## Risks / Trade-offs

- **[Near-certain timeout on most or all locales]** → Expected and explicitly treated as a valid result per Non-Goals, not something to work around by shrinking scope after the fact.
- **[macOS GitHub-hosted runner concurrency is typically lower than Linux's]** → Unverified for this account specifically (the same caution `localized-smoke-parallelism` applied to Linux runner concurrency applies here); the run itself will reveal the real number rather than this document assuming one.
- **[A timed-out job leaves no artifact/log evidence of partial progress by default]** → Mitigation: the workflow step's own `flutter test` output streams to the job log regardless of whether the job is later killed by the timeout, so however far it got before the 6h cutoff is still visible in the log.
- **[This is a genuine, if narrow, loosening of a previously firm prohibition]** → Mitigation: the spec exception's own scenario names the specific workflow file and ties the exception to that one purpose, so it reads clearly as bounded rather than as a quiet general reversal.

## Migration Plan

If the spike confirms CI is infeasible (expected): delete `.github/workflows/acceptance-suite-spike.yml` and revert the spec exception in a follow-up change, restoring the original absolute prohibition. If some locales genuinely complete within 6h: that becomes its own future proposal (which locales, on what cadence, whether it changes the manual pre-release process) — this change does not commit to that outcome.
