# localized-smoke-workflow

## Purpose

The `localized-smoke.yml` GitHub Actions workflow's concurrency settings are empirically tuned against the account's real observed capacity, not assumed from documentation or left at an arbitrarily conservative default.

## Requirements

### Requirement: Locale Smoke Matrix Concurrency Is Empirically Tuned
The `localized-smoke.yml` workflow's `max-parallel` setting SHALL be set based on the account's actual observed concurrent-job capacity, determined by inspecting real run data (per-job start/end times), rather than assumed from documentation or left at an arbitrarily low default.

#### Scenario: Raising max-parallel and observing the result
- **WHEN** `max-parallel` is raised above the current locale-matrix size and the workflow is run manually
- **THEN** the per-job start/end timestamps from that run show whether jobs beyond the old limit started concurrently or still queued, revealing the account's real concurrency ceiling

#### Scenario: The matrix size stays fixed during the experiment
- **WHEN** the concurrency experiment run is triggered
- **THEN** the locale matrix list is unchanged from the prior run, so any difference in total wall-clock time is attributable to the concurrency setting alone
