## Why

The "Localized Smoke" workflow (`.github/workflows/localized-smoke.yml`) runs a lightweight per-locale smoke test across a matrix of 9 locales, but caps concurrency at `max-parallel: 3`. A recent run showed the 9-locale matrix taking ~10 minutes in 3 sequential waves of 3 concurrent jobs. Since each job's own work (a handful of Dart assertions plus one widget pump) is cheap, the wave count — not the per-locale test logic — is the main driver of total wall-clock time. Before deciding whether to extend this matrix to more locales, we need real data on how much higher concurrency this GitHub account can actually sustain, since that ceiling (not the matrix size) determines whether "more locales" costs more wall-clock time or not.

## What Changes

- Raise `max-parallel` in `.github/workflows/localized-smoke.yml` from `3` to `15` (matrix size stays at the current 9 locales — this change isolates the concurrency question from the "how many locales" question).
- Manually trigger the workflow once with the new setting and capture the same per-job start/end timing data pulled previously (`gh run view <id> --json jobs`), to observe whether jobs now start together (concurrency ceiling ≥ 9) or some still queue (ceiling lower than 15, revealing the true number).

## Capabilities

### New Capabilities
- `localized-smoke-workflow`: the locale-smoke CI workflow's concurrency setting is tuned from real, observed account capacity rather than an arbitrary default.

### Modified Capabilities

(none)

## Impact

- `.github/workflows/localized-smoke.yml`: one line changed (`max-parallel: 3` → `max-parallel: 15`).
- No application code, no `lib/`/`test/` changes.
- One manual `workflow_dispatch` run triggered to observe the result.
