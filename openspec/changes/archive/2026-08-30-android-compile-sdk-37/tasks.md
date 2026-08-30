## 1. Toolchain bump

- [x] 1.1 `android/app/build.gradle.kts`: set `compileSdk = 37` explicitly, with a note to revert to `flutter.compileSdkVersion` once that reaches 37
- [x] 1.2 `android/settings.gradle.kts`: AGP `9.0.1` → `9.1.1`
- [x] 1.3 `android/gradle/wrapper/gradle-wrapper.properties`: Gradle `9.1.0` → `9.3.1`

## 2. Environment (not code)

- [ ] 2.1 Ensure Android SDK Platform 37 is installed on dev machines and CI (`sdkmanager "platforms;android-37"`)

## 3. Verify

- [x] 3.1 `flutter build apk --debug` succeeds (was failing at `:app:checkDebugAarMetadata`)
- [x] 3.2 `flutter analyze` clean; `flutter test` green
- [x] 3.3 One acceptance file runs green on a real Android device — `onboarding_test.dart` on SM X230 / Android 16
- [~] 3.4 Full `tool/run_acceptance_tests.sh -d <android-device>` — 10/13 files pass on SM X230 / Android 16. The 3 that fail are pre-existing acceptance-suite issues on Android/large-screen, unrelated to this toolchain bump (never surfaced before because the Android build was broken by `flutter_secure_storage` 11): `core_ledger` (flaky late async `Bad state: No element` in `RegisterViewModel._onAccounts`, passes on retry), `home_and_lock` (flaky; also a missing `await tester.pump()` at `home_and_lock_test.dart:125`), `currency_transfers` (`_setUpCrossCurrencyTransfer` assumes "Euro Group" renders once, but on a tablet the Accounts list stays visible behind the Create-account dialog so it renders twice). Tracked separately from this change.

## 4. Follow-up

- [ ] 4.1 When a Flutter release raises `flutter.compileSdkVersion` to ≥ 37, drop the literal `compileSdk = 37` pin and go back to `flutter.compileSdkVersion`
