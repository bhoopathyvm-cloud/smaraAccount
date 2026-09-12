## MODIFIED Requirements

### Requirement: One-Command, Manual-Only Developer Entry Point
The system SHALL provide a single script under `tool/` that runs the acceptance suite for a developer-chosen capability group and device, so a developer can invoke it manually after finishing a change. This tier SHALL NOT be part of the required `flutter-ci.yml` pull request gate. Automated invocation of this suite by any GitHub Actions workflow is permitted only as described by the "Nightly Linux CI Tier" requirement below — no other scheduled or automatically-triggered workflow may invoke it.

#### Scenario: Developer runs the suite after finishing a change
- **WHEN** a developer runs the acceptance test script from the repository root with a device argument
- **THEN** the acceptance flow runs against a real build on that device and reports pass/fail without requiring any additional manual setup beyond the target device/simulator being available

#### Scenario: The suite is never invoked by a scheduled or automatic workflow
- **WHEN** any GitHub Actions workflow in this repository runs on a trigger other than a repository-owner's manual `workflow_dispatch` or the nightly Linux CI tier's own schedule
- **THEN** it does not invoke the acceptance test script or its test files

#### Scenario: A manual, owner-gated feasibility spike is permitted
- **WHEN** the repository owner manually dispatches the `acceptance-suite-nightly.yml` workflow
- **THEN** it may invoke the acceptance test script against GitHub-hosted runners on demand, independent of the nightly schedule, the same way `acceptance-suite-spike.yml` did before this requirement made the nightly schedule permanent

## ADDED Requirements

### Requirement: Nightly Linux CI Tier
The full acceptance suite SHALL run automatically once nightly, on a schedule, against the Linux desktop target, across every supported locale, on a GitHub-hosted runner. This is the standing locale-regression gate for the app (see `localized-release-verification`'s corresponding requirement for how this relates to release readiness). This tier SHALL NOT be part of the required `flutter-ci.yml` pull request gate — a failing or flaky locale on a given night SHALL NOT block any pull request from merging.

#### Scenario: The nightly run covers every supported locale on Linux
- **WHEN** the nightly scheduled workflow runs
- **THEN** the full acceptance suite runs once per supported locale against the Linux target, and a per-locale pass/fail result is available for each

#### Scenario: A failing nightly run does not block pull requests
- **WHEN** the nightly run fails for one or more locales
- **THEN** no open or future pull request is blocked from merging as a result, since this tier is not part of `flutter-ci.yml`'s required checks
