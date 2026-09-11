## Context

`.github/workflows/localized-smoke.yml` runs `test/l10n/curated_locale_smoke_test.dart` + `test/acceptance_locale_fixtures_test.dart` once per locale in `kCuratedAcceptanceLocales` (currently 9 locales), via a matrix strategy with `max-parallel: 3`. A real run (`gh run view 34468060073`) showed 9 jobs completing in 3 waves of 3, ~2.6 minutes average per job, ~10 minutes total wall-clock. Each job's own test content is a handful of Dart assertions plus one widget pump — cheap — so the wave count, driven by `max-parallel`, is the dominant factor in total time, not the per-locale work itself.

The repository is a personal (not organization) GitHub account on an unknown plan tier, so the actual concurrent-job ceiling isn't visible via any settings page and can't be confirmed from documentation alone with confidence.

## Goals / Non-Goals

**Goals:**
- Determine, empirically, whether this account's real concurrency ceiling is at or above 9 (the current matrix size) by raising `max-parallel` and observing actual job start times.
- Keep the matrix size unchanged (9 locales) so this run isolates the concurrency question — any change in total wall-clock time is attributable to concurrency alone, not to more work being added.

**Non-Goals:**
- Deciding whether to extend the matrix to more locales (a separate, follow-up decision that depends on this experiment's result).
- Reducing per-job setup overhead (Flutter SDK restore, `flutter pub get`) — a real, separate lever, out of scope here.
- Redesigning the workflow to batch multiple locales per job — also a separate, follow-up option.

## Decisions

1. **Raise `max-parallel` to 15, not "unlimited" (removing the key entirely).** 15 is comfortably above the current 9-locale matrix size, so if the account's ceiling is at least 9, all 9 jobs should start together — enough to answer the question. Removing `max-parallel` entirely would default GitHub's matrix strategy to its own maximum (256 for matrix size, unrelated to account concurrency), which doesn't add information here and makes the experiment's intent less explicit to a future reader of the workflow file.

2. **Don't change the matrix's locale list.** Keeping it at today's 9 keeps this a single-variable experiment. If the ceiling turns out to be lower than 9, that's still directly actionable information (it tells us the real number without guessing), obtained without touching the locale list at all.

3. **Observe via the same method already used, not new tooling.** `gh run view <id> --json jobs` (start/end timestamps per job) already gave a clear picture of the previous run's wave structure. Reusing it keeps this a pure "change one number, observe with existing tools" exercise.

## Risks / Trade-offs

- **[The ceiling might be exactly 9 or a number in between]** → Not a risk exactly, but worth naming: a ceiling of, say, 12 would show partial concurrency (some jobs queue briefly) rather than a clean "all together" or "still 3 at a time" result. The job-timing data will still show this clearly (a queued job's start time lags behind when a runner should have been free).
- **[A transient GitHub Actions scheduling delay could be misread as a concurrency-ceiling signal]** → Mitigation: look at the overall pattern across all 9 jobs' start times, not any single job in isolation, before concluding what the ceiling is.

## Migration Plan

N/A — a one-line config change with no rollback complexity. If the result doesn't inform anything useful, `max-parallel` can simply be set back to `3` (or whatever value is decided as a follow-up) in a later commit.

## Open Questions

- Once the real ceiling is known, should `max-parallel` be set to that ceiling permanently, or to some value below it (leaving headroom for other Actions usage on the account)? Decide after seeing this experiment's result.
