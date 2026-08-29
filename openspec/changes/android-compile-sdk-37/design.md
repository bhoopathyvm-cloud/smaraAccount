## Context

Found 2026-08-29 when `tool/run_acceptance_tests.sh -d <android-tablet>` failed
on every acceptance file at `:app:checkDebugAarMetadata`. Root cause:
`flutter_secure_storage` is at 11.0.0, whose release notes say it "Raised
`minSdk` to 24 and `compileSdk` to 37." AAR metadata propagates that
`compileSdk` floor to every consumer, and the app compiled against 36.

## Goals / Non-Goals

**Goals:**
- The Android target builds again (debug and release), on device and in the
  acceptance suite.
- The smallest toolchain bump that clears the AAR-metadata floor.

**Non-Goals:**
- Chasing the newest AGP / Gradle for its own sake — bump only as far as
  `flutter_secure_storage`'s floor and AGP/Gradle's own mutual minimums force.
- Raising `targetSdk` or `minSdk`. Those are runtime-behaviour and device-reach
  decisions, out of scope. `flutter_secure_storage` 11 also raised its own
  `minSdk` to 24, but the app's effective `minSdk` (`flutter.minSdkVersion` in
  Flutter 3.47) is already ≥ 24, so nothing is needed there.
- Keeping `compileSdk = flutter.compileSdkVersion` forever — see the follow-up
  task to drop the literal pin once Flutter's default reaches 37.

## Decisions

### 1. Pin `compileSdk = 37` literally, not via a helper

**Options:** (A) `compileSdk = 37`; (B)
`compileSdk = maxOf(flutter.compileSdkVersion, 37)`.

**Decision: A.** It matches what Flutter's own Android docs show for an
override, it is greppable, and (B) hides that the project is deliberately ahead
of the Flutter default. A one-line comment records why and when to revert.

### 2. AGP 9.1.1 + Gradle 9.3.1 — the mutual minimum

AGP 9.0.1's maximum supported `compileSdk` is 36; 9.1.x raises it. AGP 9.1.1 in
turn requires Gradle ≥ 9.3.1 — its `com.android.internal.version-check` plugin
fails the build otherwise and names the exact version. `9.1.1` + `9.3.1` is the
lowest pair that builds. Kotlin (`2.3.20`) is unaffected.

### 3. SDK Platform 37 is an environment prerequisite, not vendored

`compileSdk = 37` needs `platforms;android-37` present. It was already installed
on the machine used here; CI and other contributors install it with a one-line
`sdkmanager` command. Tracked as a task, not a code change.

## Risks / Trade-offs

- **[Risk]** AGP 9.1 tightens some lint / DSL behaviour → **Mitigation:**
  `flutter analyze` and `flutter test` were run green, plus one on-device
  acceptance file, after the bump.
- **[Risk]** A contributor without SDK 37 hits a build error → **Mitigation:**
  the error is self-explanatory and the `sdkmanager` fix is one line; noted in
  tasks.
- **[Trade-off]** The app now compiles one API level ahead of Flutter's blessed
  default. `compileSdk` only affects which APIs are visible at compile time, not
  runtime, and the pin reverts cleanly once Flutter catches up.

## Migration Plan

1. Bump `compileSdk`, AGP, and the Gradle wrapper.
2. `flutter build apk --debug` to confirm `:app:checkDebugAarMetadata` passes.
3. Run one acceptance file on an Android device, then the full suite.
4. Rollback = revert the three files. The cached Gradle 9.3.1 distribution is
   harmless if left on disk.

## Open Questions

- None. Dropping the literal pin once `flutter.compileSdkVersion` ≥ 37 is a
  follow-up task, not an open design decision.
