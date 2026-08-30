## Why

`flutter_secure_storage` 11.0.0 (a direct dependency) compiles its Android
library against `compileSdk = 37` and publishes AAR metadata that forces every
consumer to compile against API 37 or higher. `android/app/build.gradle.kts`
sets `compileSdk = flutter.compileSdkVersion`, which is 36 in Flutter 3.47.

Every Android build — `flutter run`, `flutter test -d <android>`,
`flutter build apk`/`appbundle`, and the whole
`tool/run_acceptance_tests.sh -d <android-device>` suite — fails at
`:app:checkDebugAarMetadata` with:

> Dependency ':flutter_secure_storage' requires libraries and applications that
> depend on it to compile against version 37 or later of the Android APIs.
> :app is currently compiled against android-36.

The Android target is unbuildable until the toolchain is raised.

## What Changes

- Pin `compileSdk = 37` explicitly in `android/app/build.gradle.kts`, overriding
  the Flutter SDK default of 36, until a future Flutter release raises its own
  default.
- Bump the Android Gradle Plugin from `9.0.1` to `9.1.1` — AGP 9.0.x officially
  supports a maximum `compileSdk` of 36.
- Bump the Gradle wrapper from `9.1.0` to `9.3.1` — the minimum AGP 9.1.1
  accepts (its version-check plugin fails the build otherwise, naming the
  version).
- No change to `minSdk` or `targetSdk`. Device reach and runtime behaviour are
  unchanged; this is a compile-time-only bump.

## Capabilities

### New Capabilities

- `android-build-toolchain`: the Android build targets an AGP / Gradle /
  compile-SDK combination new enough to satisfy the AAR metadata of every
  bundled plugin, so the Android target builds and its acceptance suite can run.

### Modified Capabilities

- (none — no product behaviour changes; this is a build-configuration change
  only)

## Impact

- `android/app/build.gradle.kts`
- `android/settings.gradle.kts`
- `android/gradle/wrapper/gradle-wrapper.properties`
- Requires Android SDK Platform 37 to be installed locally and in CI
  (`sdkmanager "platforms;android-37"`).
