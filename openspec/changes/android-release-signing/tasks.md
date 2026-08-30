## 1. Build configuration

- [x] 1.1 Add a `key.properties`-reading `signingConfig` to `android/app/build.gradle.kts`
- [x] 1.2 Wire the `release` build type to the new `signingConfig` instead of `debug`
- [x] 1.3 Fail the build with a clear error when `key.properties` is missing, instead of falling back to debug signing
- [x] 1.4 Add `key.properties` and `*.jks`/`*.keystore` to `.gitignore`

## 2. Keystore (human, not code)

- [ ] 2.1 Generate an upload keystore (`keytool -genkeypair ...`)
- [ ] 2.2 Store the keystore file and its passwords somewhere durable and private (outside the repo)
- [ ] 2.3 Populate local `android/key.properties` from that keystore

See `docs/release/android-upload-keystore.md` and `android/key.properties.example`.

## 3. Verify

- [ ] 3.1 `flutter build appbundle` (or `apk`) succeeds and produces a release-signed artifact (not debug-signed — verify with `keytool -printcert` or `apksigner verify --print-certs`) — blocked on task 2 (upload keystore is human-generated)
- [x] 3.2 Confirm neither the keystore nor `key.properties` shows up in `git status`

## 4. Play Console (human, not code)

- [ ] 4.1 First upload to Google Play Console; enroll in Play App Signing
