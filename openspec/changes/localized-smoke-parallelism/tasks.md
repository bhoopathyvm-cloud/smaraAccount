## 1. Change the workflow

- [x] 1.1 In `.github/workflows/localized-smoke.yml`, change `max-parallel: 3` to `max-parallel: 15` under `strategy`. Leave the `matrix.locale` list unchanged.
- [ ] 1.2 Commit on a dedicated branch (per repo convention, named after this change), push, open a PR, and merge to `main` — the workflow file must be on the default branch for `workflow_dispatch` to pick up the change when triggered.

## 2. Run the experiment

- [ ] 2.1 Trigger the workflow manually (`gh workflow run localized-smoke.yml` or via the Actions UI) after the PR is merged.
- [ ] 2.2 Once complete, pull per-job timing via `gh run view <id> --json jobs` (same method used for the prior 9-locale run).
- [ ] 2.3 Compare against the prior run's timing (`gh run view 34468060073`): did all 9 jobs start within the same short window (ceiling ≥ 9), or did some still queue behind others (ceiling somewhere between 3 and 9)? Note the total wall-clock time either way.

## 3. Record the result

- [ ] 3.1 Report the observed concurrency ceiling and total wall-clock time back to the user, with the job-timing data as evidence.
- [ ] 3.2 Leave `max-parallel` at the value decided as a follow-up (either the observed ceiling, or a value below it) — captured as this change's Open Question, not decided here.
