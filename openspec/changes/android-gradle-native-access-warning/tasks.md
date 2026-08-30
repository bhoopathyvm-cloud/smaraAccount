## 1. Configure the Gradle daemon JVM

- [x] 1.1 Append `--enable-native-access=ALL-UNNAMED` to the `org.gradle.jvmargs` line in `android/gradle.properties`
- [x] 1.2 Add a one-line comment above/beside it: workaround for Gradle's bundled `native-platform` `System.load` call; drop when a future Gradle wrapper bump ships a `native-platform` that declares native access

## 2. Verify

Blocked in this Linux Cloud Agent: the restricted-native-access warning is a
JDK 24+ behaviour and the agent only has JDK 21 (which never emits it), and no
Android SDK is installed, so a real before/after Android build can't be run
here. The flag itself was confirmed accepted by the JVM
(`java --enable-native-access=ALL-UNNAMED -version` exits 0), so it will not
break builds on JDK 21+. Tasks below require an Android build environment on
JDK 24/25.

- [ ] 2.1 Stop any running Gradle daemon (`cd android && ./gradlew --stop`) so the new JVM args take effect
- [ ] 2.2 Run an Android build (`flutter run -d <android-device>` or `flutter build apk --debug`) and confirm the four `WARNING:` lines about `java.lang.System::load` / restricted native access no longer appear
- [ ] 2.3 Confirm the build still succeeds and the app launches
- [ ] 2.4 `tool/run_acceptance_tests.sh -d <android-device>` shows a clean build log for at least the first file
