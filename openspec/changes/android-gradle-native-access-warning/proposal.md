## Why

Every Gradle invocation for the Android build — `flutter run`,
`flutter build`, `flutter test -d <android>`, the acceptance suite — prints:

```
WARNING: A restricted method in java.lang.System has been called
WARNING: java.lang.System::load has been called by
  net.rubygrapefruit.platform.internal.NativeLibraryLoader in an unnamed
  module (.../gradle-9.3.1/lib/native-platform-0.22-milestone-29.jar)
WARNING: Use --enable-native-access=ALL-UNNAMED to avoid a warning for
  callers in this module
WARNING: Restricted methods will be blocked in a future release unless
  native access is enabled
```

This is a JDK "restricted native access" notice (the daemon here runs on
JDK 25). Gradle's own `native-platform` library calls `System.load` from the
unnamed module without declaring native access, so the JVM warns and says a
future JDK will make it an error. It is noise today — no build step fails —
but it clutters every Android build log and buries real warnings, and the
"blocked in a future release" line is a standing latent break.

## What Changes

- Add `--enable-native-access=ALL-UNNAMED` to `org.gradle.jvmargs` in
  `android/gradle.properties`, granting the Gradle daemon JVM the native
  access its bundled `native-platform` needs. This is exactly the flag the
  warning itself recommends.
- A short comment records that this is a workaround for Gradle's
  `native-platform` and can be dropped once a Gradle release ships a
  `native-platform` that declares native access itself.
- No change to Gradle, AGP, the JDK, heap sizes, or any build behaviour —
  only the one JVM arg is added to the existing list.

## Capabilities

### Modified Capabilities

- `android-build-toolchain`: the Android build's Gradle invocation starts
  without JVM restricted-native-access warnings, so build logs show only
  warnings that matter.

## Impact

- `android/gradle.properties` (one entry appended to `org.gradle.jvmargs`).
- Silences the warning for the Gradle daemon JVM only; the Kotlin compile
  daemon and other sub-processes do not emit it.
- Revisit when the Gradle wrapper is next bumped — a newer `native-platform`
  may remove the need for the flag.
