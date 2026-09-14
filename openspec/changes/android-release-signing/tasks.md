## 1. Build configuration

- [x] 1.1 Add a `key.properties`-reading `signingConfig` to `android/app/build.gradle.kts`
- [x] 1.2 Wire the `release` build type to the new `signingConfig` instead of `debug`
- [x] 1.3 Fail the build with a clear error when `key.properties` is missing, instead of falling back to debug signing
- [x] 1.4 Add `key.properties` and `*.jks`/`*.keystore` to `.gitignore`

## 2. Keystore (human, not code)

- [x] 2.1 Generate an upload keystore (`keytool -genkeypair ...`) — regenerated (2026-09-14): the original 2026-09-08 keystore's passwords were never actually saved anywhere retrievable (`key.properties` still had placeholder text). Since the app has never been uploaded to Google Play (task 4.1 still open — no Play App Signing enrollment to lose), regenerating was safe. New `android/upload-keystore.jks`, alias `upload`, RSA 2048, valid until 2054-01-30, correctly untracked
- [ ] 2.2 Store the keystore file and its passwords somewhere durable and private (outside the repo) — **still needs the user to actually do this**: passwords were generated and written to `android/key.properties` (gitignored) this session, but not shown in chat/logs to avoid leaking them there. Back up the `.jks` file and the two passwords in `android/key.properties` to a password manager now, before this happens again
- [x] 2.3 Populate local `android/key.properties` from that keystore — done (2026-09-14): real values written, confirmed working by a real `flutter build appbundle` + `jarsigner -verify` (see 3.1). Note for next time: current `keytool` defaults to PKCS12, which doesn't support distinct store/key passwords — it silently ignores `-keypass` and uses the store password for both, so `key.properties`' `keyPassword` must equal `storePassword` or the build fails with a wrong-password error

See `docs/release/android-upload-keystore.md` and `android/key.properties.example`.

## 3. Verify

- [x] 3.1 `flutter build appbundle` (or `apk`) succeeds and produces a release-signed artifact (not debug-signed — verify with `keytool -printcert` or `apksigner verify --print-certs`) — done (2026-09-14): `flutter build appbundle --release` succeeded (`app-release.aab`, 78.0MB). `jarsigner -verify -verbose -certs` confirms every entry signed with `CN=Smara Accounting, OU=Smara Accounting, O=Smara Accounting, L=Zurich, ST=Zurich, C=CH` (the new upload cert, signer file `META-INF/UPLOAD.SF`), not a debug identity; `jarsigner -verify` reports `jar verified` with exit code 0
- [x] 3.2 Confirm neither the keystore nor `key.properties` shows up in `git status`

## 4. Play Console (human, not code)

- [ ] 4.1 First upload to Google Play Console; enroll in Play App Signing
