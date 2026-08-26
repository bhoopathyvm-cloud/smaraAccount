# acceptance-test-suite

## Purpose

TBD

## Requirements

### Requirement: Real-Build Acceptance Flow for Recording and Restoring Entries
The system SHALL provide an acceptance test that drives a real, launched build of the app — by reusing the app's actual root widget from `main.dart`, not a hand-rebuilt widget tree — through its GUI to: complete onboarding, record at least one transaction, capture the recovery phrase, simulate a fresh device by resetting the app's real on-disk database and real OS keychain, and restore through the real Restore UI. The test SHALL assert, after restore, that the recorded entries and their running balances are present and unchanged.

#### Scenario: Entries recorded on the first device reappear after restore on a simulated second device
- **WHEN** the acceptance test records a transaction through the GUI, resets local app storage and keychain to simulate a new device, and restores using the captured recovery phrase through the GUI
- **THEN** the restored app's register shows the same entry with the same amount and running balance as before the reset

#### Scenario: Restore fails obviously if the wrong phrase is used
- **WHEN** the acceptance test attempts to restore with an incorrect recovery phrase after the same storage/keychain reset
- **THEN** the real Restore UI shows an error and no entries are restored

#### Scenario: The acceptance harness cannot silently diverge from the real app
- **WHEN** the acceptance test builds the app under test
- **THEN** it does so by launching the same root widget `main.dart` launches, so a change to how the app's own widget tree is assembled is automatically exercised by this tier without the test needing a matching update

### Requirement: Acceptance Coverage Spans the App's Shipped Capabilities
The system SHALL organize the acceptance suite into capability groups covering, at minimum: core ledger journeys (recording, reversing, archiving, tamper detection), currency and transfers, identity and backup, onboarding, data import, day-to-day organization features (payees, recurring templates, category rules, category limits, split transactions, corrections, register search), the home/accounts overview, and App Lock's PIN path. Each group SHALL be independently runnable and share the same real-build harness and cleanup helpers.

#### Scenario: A capability group runs independently
- **WHEN** a developer runs only one capability group's acceptance test file
- **THEN** it runs to completion using the same real-build harness and cleanup as the full suite, without requiring any other group to run first

#### Scenario: New capabilities extend the suite without changing its shape
- **WHEN** a new shipped capability needs acceptance coverage
- **THEN** it is added as a new capability group reusing the existing harness and cleanup helpers, not a bespoke test setup

### Requirement: Target Device Is Selectable Per Run
The system SHALL require the developer to specify which real target device to run the acceptance suite against (a macOS build, an iOS simulator, or an Android emulator/device) for every manual invocation. The system SHALL NOT silently default to one platform, and SHALL NOT run against more than one target automatically within a single invocation.

#### Scenario: Running against a specific platform
- **WHEN** a developer runs the acceptance suite with a device argument identifying a macOS, iOS, or Android target
- **THEN** the suite launches the real build on that target and runs entirely against it

#### Scenario: No device specified
- **WHEN** a developer runs the acceptance suite without specifying a device
- **THEN** the run fails fast with a message asking the developer to choose a target, rather than guessing one

### Requirement: Acceptance Runs Leave No Residual Host State
The system SHALL clean up every artifact an acceptance test run creates on the host — the app's real database directory and every real OS keychain entry it wrote — both before a run starts (in case a prior run crashed without cleaning up) and after it ends, regardless of whether the run passed or failed. The cleanup SHALL work identically across macOS, iOS, and Android targets without platform-specific branching.

#### Scenario: A run that crashes mid-test does not contaminate the next run
- **WHEN** an acceptance test run is interrupted before its own teardown executes
- **THEN** the next acceptance test run's pre-run cleanup removes the leftover database file and keychain entries before proceeding

#### Scenario: A passing run leaves the host clean
- **WHEN** an acceptance test run completes successfully
- **THEN** no acceptance-test database file or keychain entry remains on the host afterward

#### Scenario: Cleanup behaves the same on every supported target
- **WHEN** the acceptance suite runs against a macOS, an iOS, or an Android target
- **THEN** the same cleanup code removes that target's database file and keychain/keystore entries without any per-platform special-casing

### Requirement: One-Command, Manual-Only Developer Entry Point
The system SHALL provide a single script under `tool/` that runs the acceptance suite for a developer-chosen capability group and device, so a developer can invoke it manually after finishing a change. This tier SHALL NOT be invoked by any GitHub Actions workflow, scheduled or otherwise, and SHALL NOT be part of the required `flutter-ci.yml` pull request gate.

#### Scenario: Developer runs the suite after finishing a change
- **WHEN** a developer runs the acceptance test script from the repository root with a device argument
- **THEN** the acceptance flow runs against a real build on that device and reports pass/fail without requiring any additional manual setup beyond the target device/simulator being available

#### Scenario: The suite is never invoked by CI
- **WHEN** any GitHub Actions workflow in this repository runs
- **THEN** none of them invoke the acceptance test script or its test files
