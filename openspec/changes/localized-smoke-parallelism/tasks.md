## 1. Change the workflow

- [x] 1.1 In `.github/workflows/localized-smoke.yml`, change `max-parallel: 3` to `max-parallel: 15` under `strategy`. Leave the `matrix.locale` list unchanged.
- [x] 1.2 Committed on branch `localized-smoke-parallelism`, pushed, opened PR #136, all checks passed, squash-merged to `main` (commit 9feca72).

## 2. Run the experiment

- [x] 2.1 Triggered via `gh workflow run localized-smoke.yml` — run 34480006115.
- [x] 2.2 Pulled per-job timing from run 34480006115 via `gh run view --json jobs`. All 9 jobs started between 13:00:53 and 13:01:02 (a 9-second window) — no waves, no queueing.
- [x] 2.3 Compared against run 34468060073 (the prior `max-parallel: 3` run): that run showed a clean 3-wave pattern (3 jobs starting together, 3 more once slots freed, 3 more after that) over ~10 minutes. This run shows all 9 starting together — ceiling is **at least 9** (the exact number is unresolved, since the experiment deliberately kept the matrix at 9 locales rather than testing higher). Total wall-clock time: first start (13:00:53) to last completion (13:05:21) = 4m28s, vs. ~10 minutes before — about a 2.2x speedup from collapsing 3 waves into 1.

## 3. Record the result

- [x] 3.1 Reported to the user: concurrency ceiling ≥ 9, total wall-clock 4m28s vs. ~10 minutes before, with the job-timing data as evidence.
- [x] 3.2 Left `max-parallel: 15` as merged (already gives headroom above the confirmed ≥9 ceiling and above the current 9-locale matrix). Open question (unresolved, captured in design.md): whether to test a higher matrix size to find the exact ceiling, or whether 15 is good enough for any locale-matrix size under consideration.
