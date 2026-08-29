# Android upload keystore

Release APK/AAB builds read `android/key.properties` (git-ignored) and
sign with a dedicated upload keystore — never Flutter's shared debug
key. Generate and safeguard that keystore yourself; it is not created
by the repository.

## Generate the keystore

From the repo root, with a JDK `keytool` on `PATH`:

```bash
keytool -genkeypair -v \
  -keystore android/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

Store the `.jks` file and both passwords in a password manager or other
durable private backup **before** the first Play upload. Losing the
upload key after Play App Signing enrollment is recoverable only through
Google's support process.

## Local `key.properties`

```bash
cp android/key.properties.example android/key.properties
```

Fill in `storePassword`, `keyPassword`, `keyAlias`, and `storeFile`
(`storeFile` is resolved relative to `android/app/`). Neither
`android/key.properties` nor `*.jks`/`*.keystore` should appear in
`git status`.

## Verify a signed release

```bash
flutter build appbundle
```

Then confirm the artifact is not debug-signed, for example:

```bash
keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab
```

A missing `android/key.properties` fails the release Gradle build with
an error that names that file, rather than silently signing with debug.

## Play Console

First upload of the AAB to Google Play Console should enroll the app in
Play App Signing. That enrollment is an account-level console step, not
a code change.
