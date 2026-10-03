## RENAMED Requirements

- FROM: `### Requirement: Nightly Linux CI Tier`
- TO: `### Requirement: Scheduled Linux CI Tier`

## MODIFIED Requirements

### Requirement: Scheduled Linux CI Tier
The full acceptance suite SHALL run automatically once weekly, on a schedule, against the Linux desktop target, across every supported locale, on a GitHub-hosted runner, and SHALL also be dispatchable manually (`workflow_dispatch`) against a chosen commit. This is the standing locale-regression tier for the app; a release candidate is gated by a manually dispatched run on its own commit (see `localized-release-verification`). This tier SHALL NOT be part of the required `flutter-ci.yml` pull request gate — a failing or flaky locale on a given run SHALL NOT block any pull request from merging.

#### Scenario: The nightly run covers every supported locale on Linux
- **WHEN** the weekly scheduled workflow runs
- **THEN** the full acceptance suite runs once per supported locale against the Linux target, and a per-locale pass/fail result is available for each

#### Scenario: A manual dispatch targets the release candidate
- **WHEN** a release owner dispatches the workflow on a candidate commit
- **THEN** the full acceptance suite runs once per supported locale against that commit

#### Scenario: A failing nightly run does not block pull requests
- **WHEN** a run fails for one or more locales
- **THEN** no open or future pull request is blocked from merging as a result, since this tier is not part of `flutter-ci.yml`'s required checks
