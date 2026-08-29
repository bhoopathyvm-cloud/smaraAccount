## 1. Configure the Gradle daemon JVM

- [ ] 1.1 Append `--enable-native-access=ALL-UNNAMED` to the `org.gradle.jvmargs` line in `android/gradle.properties`
- [ ] 1.2 Add a one-line comment above/beside it: workaround for Gradle's bundled `native-platform` `System.load` call; drop when a future Gradle wrapper bump ships a `native-platform` that declares native access

## 2. Verify

- [ ] 2.1 Stop any running Gradle daemon (`cd android && ./gradlew --stop`) so the new JVM args take effect
- [ ] 2.2 Run an Android build (`flutter run -d <android-device>` or `flutter build apk --debug`) and confirm the four `WARNING:` lines about `java.lang.System::load` / restricted native access no longer appear
- [ ] 2.3 Confirm the build still succeeds and the app launches
- [ ] 2.4 `tool/run_acceptance_tests.sh -d <android-device>` shows a clean build log for at least the first file
