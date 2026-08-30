# android-release-signing

## Purpose

TBD

## Requirements

### Requirement: Release builds are signed with a real, app-specific key
The Android `release` build type SHALL be signed with a dedicated upload keystore configured via a git-ignored `key.properties` file, not the shared Flutter debug keystore.

#### Scenario: Release build uses the real signing config
- **WHEN** a release APK or AAB is built
- **THEN** it is signed with the certificate from the keystore named in `key.properties`, not the debug certificate

### Requirement: Signing secrets never enter version control
The keystore file and `key.properties` SHALL be excluded from version control.

#### Scenario: Signing material is git-ignored
- **WHEN** the keystore and `key.properties` exist on a developer's machine at the paths this change configures
- **THEN** `git status` does not list either as trackable or staged

### Requirement: A missing signing key fails the build, not the signature
If `key.properties` is absent, the release build SHALL fail with a clear, explicit error rather than silently signing with the debug key.

#### Scenario: Missing key.properties stops the build
- **WHEN** a release build is attempted without `android/key.properties` present
- **THEN** the Gradle build fails with an error naming the missing file, and no release artifact is produced
