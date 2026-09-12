## MODIFIED Requirements

### Requirement: One-Command, Manual-Only Developer Entry Point
The system SHALL provide a single script under `tool/` that runs the acceptance suite for a developer-chosen capability group and device, so a developer can invoke it manually after finishing a change. This tier SHALL NOT be part of the required `flutter-ci.yml` pull request gate, and SHALL NOT be invoked by any scheduled or automatically-triggered GitHub Actions workflow. As a narrow, explicitly-scoped exception, a `workflow_dispatch`-only, repository-owner-gated GitHub Actions workflow MAY invoke the suite solely to empirically measure whether it can complete within GitHub-hosted runners' fixed job-timeout limit; this exception exists only for that feasibility experiment and SHALL NOT be treated as general permission for CI automation of this tier.

#### Scenario: Developer runs the suite after finishing a change
- **WHEN** a developer runs the acceptance test script from the repository root with a device argument
- **THEN** the acceptance flow runs against a real build on that device and reports pass/fail without requiring any additional manual setup beyond the target device/simulator being available

#### Scenario: The suite is never invoked by CI
- **WHEN** any GitHub Actions workflow in this repository runs on a trigger other than a repository-owner's manual `workflow_dispatch`
- **THEN** it does not invoke the acceptance test script or its test files

#### Scenario: A manual, owner-gated feasibility spike is permitted
- **WHEN** the repository owner manually dispatches the `acceptance-suite-spike.yml` workflow
- **THEN** it may invoke the acceptance test script against GitHub-hosted runners to measure real completion behavior, distinct from and not expanding the general CI prohibition above
