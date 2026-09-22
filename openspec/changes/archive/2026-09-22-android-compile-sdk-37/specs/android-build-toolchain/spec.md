## ADDED Requirements

### Requirement: The Android build satisfies every bundled plugin's compile-SDK floor
The Android application module SHALL compile against an SDK version greater than
or equal to the highest `compileSdk` that any bundled plugin's AAR metadata
requires. The Android Gradle Plugin and the Gradle wrapper SHALL be at versions
that support that `compileSdk` and each other.

#### Scenario: A plugin that requires a newer compile SDK does not break the build
- **WHEN** a dependency publishes AAR metadata requiring `compileSdk` 37
- **THEN** `flutter build apk` and `flutter build appbundle` pass
  `:app:checkDebugAarMetadata` and its release equivalent without failure

#### Scenario: The Android acceptance suite can build
- **WHEN** `tool/run_acceptance_tests.sh -d <android-device>` runs
- **THEN** each acceptance file's `assembleDebug` build succeeds and the app
  launches on the device

### Requirement: The compile-SDK pin is documented and reversible
`android/app/build.gradle.kts` SHALL carry an inline comment stating why
`compileSdk` is pinned ahead of the Flutter SDK's `flutter.compileSdkVersion`
default and the condition under which it reverts to `flutter.compileSdkVersion`.

#### Scenario: A reader can tell the pin is deliberate
- **WHEN** a contributor reads the `compileSdk` assignment in `android/app/build.gradle.kts`
- **THEN** the reason for pinning ahead of the Flutter default, and when to undo
  it, are stated inline
