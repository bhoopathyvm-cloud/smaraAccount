## MODIFIED Requirements

### Requirement: Target Device Is Selectable Per Run
The system SHALL require the developer to specify which real target device to run the acceptance suite against (a macOS build, an iOS simulator, or an Android emulator/device) for every manual invocation. The system SHALL NOT silently default to one platform, and SHALL NOT run against more than one target automatically within a single invocation. The suite SHALL pass on every supported target regardless of its screen size or device class, including tablets; acceptance tests SHALL NOT assume a dialog, sheet, or menu occludes the rest of the screen.

#### Scenario: Running against a specific platform
- **WHEN** a developer runs the acceptance suite with a device argument identifying a macOS, iOS, or Android target
- **THEN** the suite launches the real build on that target and runs entirely against it

#### Scenario: No device specified
- **WHEN** a developer runs the acceptance suite without specifying a device
- **THEN** the run fails fast with a message asking the developer to choose a target, rather than guessing one

#### Scenario: A tablet-sized screen does not break dialog interactions
- **WHEN** an acceptance test opens a dialog or sheet on a target whose screen is large enough that content behind it stays visible
- **THEN** the test's checks for elements inside that dialog are scoped to the dialog, so unrelated matching text elsewhere on screen does not change the outcome

#### Scenario: Relaunch simulation does not race in-flight navigation
- **WHEN** an acceptance test simulates an app relaunch by swapping the root widget
- **THEN** pending microtasks and router redirects are drained around the swap so a platform-channel call is not cancelled mid-flight, and the step is not flaky
