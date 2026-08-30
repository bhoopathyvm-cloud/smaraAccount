## Context

The Gradle daemon here runs on JDK 25 (Azul Zulu 25 LTS / Android Studio's
bundled JBR 25). Since JDK 24, calling a "restricted" method such as
`System.load`/`System.loadLibrary` from code in the unnamed module without
`--enable-native-access` produces a runtime warning, and the JDK has
announced these calls will become hard errors in a future release. Gradle
9.x still bundles `native-platform 0.22-milestone-29`, which loads its
native library exactly that way, so the warning fires once per Gradle
start on every Android build path.

`android/gradle.properties` already sets `org.gradle.jvmargs` (heap,
metaspace, code cache). Nothing there addresses native access.

## Goals / Non-Goals

**Goals:**
- No restricted-native-access warning in Android build output.
- The smallest possible change: one JVM arg, no version bumps.

**Non-Goals:**
- Upgrading Gradle/AGP/JDK to chase a `native-platform` that declares
  native access — worth doing when the wrapper is next bumped, not now.
- Silencing warnings from any other JVM (Kotlin compile daemon, test JVM) —
  they do not emit this one.
- Suppressing JVM warnings globally (e.g. `-Xlog:...:off`) — that would hide
  future genuine warnings too.

## Decisions

### 1. `--enable-native-access=ALL-UNNAMED` in `org.gradle.jvmargs`

**Alternatives considered:**
- *Pin `org.gradle.java.home` to a JDK 21 that does not warn.* Rejected — a
  downgrade of the whole Android build toolchain to hide one cosmetic line,
  and JDK 21 support has its own horizon.
- *Wait for a Gradle release whose `native-platform` declares native
  access.* That is the real long-term fix, captured as the "revisit on next
  wrapper bump" note, but it is not actionable now and leaves the noise in
  place indefinitely.
- *`-XX:+IgnoreUnrecognizedVMOptions` / log suppression.* Rejected — hides
  the class of warning, not just this instance.

**Decision:** append `--enable-native-access=ALL-UNNAMED` — a standard
`java` launcher option since JDK 22, valid in `org.gradle.jvmargs`, and the
exact remedy the warning text names. `ALL-UNNAMED` (not a specific module)
because `native-platform` loads from the unnamed module.

### 2. Keep it in `android/gradle.properties`, not a global `~/.gradle`

The fix must travel with the repo so every contributor and CI sees a clean
log, not just this machine.

## Risks / Trade-offs

- **[Risk]** A future JDK removes or renames `--enable-native-access`. →
  **Mitigation:** it is a documented, stable flag through JDK 25; the "next
  wrapper bump" note is the checkpoint to re-evaluate.
- **[Risk]** Granting `ALL-UNNAMED` native access is broader than strictly
  needed. → **Mitigation:** it applies only to the Gradle daemon JVM
  building this app, and only removes a warning the JDK already lets these
  calls make; it does not enable anything that is not already happening.
- **[Trade-off]** Silencing the warning removes the reminder that Gradle's
  native-platform is not future-JDK-clean. The proposal's revisit note
  carries that reminder instead.

## Migration Plan

1. Append the arg to `org.gradle.jvmargs` in `android/gradle.properties`
   with a one-line comment.
2. `flutter run -d <android>` (or any Android build) — confirm the four
   WARNING lines are gone and the build still succeeds.
3. Rollback = remove the arg.

## Open Questions

- None.
