## Why

`android/app/build.gradle.kts`'s `release` build type sets `signingConfig = signingConfigs.getByName("debug")` — every release APK/AAB is currently signed with Flutter's shared debug keystore, not an app-specific release key. Google Play rejects any upload signed with a debug certificate outright; even setting that aside, the debug keystore is a low-security, tooling-shared key never meant to identify a real published app.

## What Changes

- Add a real `release` `signingConfig` that reads keystore path, store password, key alias, and key password from a git-ignored `android/key.properties` file (the standard Flutter pattern), rather than hard-coding secrets in a tracked build file.
- `key.properties` and any `*.jks`/`*.keystore` file are added to `.gitignore` so a real signing key is never committed.
- The release build fails loudly (a clear Gradle error) if `key.properties` is missing, instead of silently falling back to debug signing — signing with the wrong key by accident is worse than a build that refuses to proceed.
- Document, briefly, how to generate the upload keystore (`keytool -genkeypair`) and populate `key.properties` — the keystore itself is generated and safeguarded by the user; it is not something this repository can create on their behalf.

## Capabilities

### New Capabilities
- `android-release-signing`: release Android builds are signed with a real, app-specific upload key, never the shared debug keystore, and the build fails clearly rather than silently mis-signing when that key is unavailable.

### Modified Capabilities
- (none — no product behavior changes; this is a build-configuration change only)

## Impact

- `android/app/build.gradle.kts`
- `.gitignore`
- A new, user-generated (not repo-generated) `android/key.properties` and keystore file, kept outside version control
- Google Play Console enrollment in Play App Signing is a separate, external step (see `design.md`) — not itself a code change, but the release signingConfig here is what produces the upload artifact Play App Signing then re-signs for distribution
