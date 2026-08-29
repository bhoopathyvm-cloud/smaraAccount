## ADDED Requirements

### Requirement: Gradle starts without JVM restricted-native-access warnings
The Android build's Gradle daemon JVM SHALL be configured so that Gradle's
own native libraries load without producing JDK restricted-native-access
warnings. `android/gradle.properties` SHALL carry the JVM argument that
grants this (and a comment noting it is a workaround for Gradle's bundled
`native-platform` that can be removed once a Gradle release declares native
access itself).

#### Scenario: An Android build log has no restricted-native-access warnings
- **WHEN** any Android build runs (`flutter run`, `flutter build apk`,
  `flutter build appbundle`, `flutter test -d <android-device>`, or the
  acceptance suite) on a JDK that enforces restricted native access
- **THEN** its output contains no `WARNING: A restricted method in
  java.lang.System has been called` / `java.lang.System::load ... in an
  unnamed module` lines
- **AND** the build otherwise succeeds unchanged

#### Scenario: The workaround is self-documenting
- **WHEN** a contributor reads `org.gradle.jvmargs` in
  `android/gradle.properties`
- **THEN** the native-access argument is accompanied by a comment stating
  why it is there and when it can be dropped
