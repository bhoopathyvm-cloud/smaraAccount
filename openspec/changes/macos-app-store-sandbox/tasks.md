## 1. Prerequisite (human, not code)

- [x] 1.1 Configure a real Apple Developer Team in Xcode's Signing & Capabilities for the `Runner` target (blocks verification of every task below) — done (2026-09-13): added `DEVELOPMENT_TEAM = PLUT6R5W2W` to the Runner target's Debug/Release/Profile configs in `macos/Runner.xcodeproj/project.pbxproj` (matching what was already present for iOS), and removed a project-level `CODE_SIGN_IDENTITY = "-"` override on the **Release** config only that was forcing ad-hoc signing regardless of Team (Debug/Profile keep it, per Decision 3 below — local `flutter run` stays unsandboxed/ad-hoc). Verified via a real `xcodebuild archive`: `codesign -dvv` on the archived `.app` shows `TeamIdentifier=PLUT6R5W2W` with the Apple Development authority chain, not ad-hoc

## 2. Entitlements

- [x] 2.1 Set `com.apple.security.app-sandbox` to `true` in `macos/Runner/Release.entitlements`
- [x] 2.2 ~~Add `com.apple.security.keychain-access-groups` as an empty array~~ — reversed (2026-09-13): Apple's real App Store Connect validator rejected this outright — `Invalid Code Signing Entitlements ... key 'com.apple.security.keychain-access-groups' ... is not supported` (error 90285) — on an actual Validate attempt. The empty-array assumption in design.md was wrong. Removed the key entirely from `Release.entitlements`; `flutter_secure_storage`'s own Keychain items don't need it since there's no App Group/companion app to share with
- [x] 2.3 Change `com.apple.security.files.user-selected.read-only` to `com.apple.security.files.user-selected.read-write`
- [x] 2.4 New, found via the same Validate attempt (2026-09-13): App Store Connect also rejected the archive with `The Info.plist must contain a LSApplicationCategoryType key` (error 90242). Added `LSApplicationCategoryType = public.app-category.finance` to `macos/Runner/Info.plist`. Both fixes verified directly on a rebuilt archive: `codesign -d --entitlements -` no longer lists `keychain-access-groups`, and `PlistBuddy -c "Print :LSApplicationCategoryType"` returns `public.app-category.finance`; `TeamIdentifier=PLUT6R5W2W` unchanged
- [x] 2.5 New, found while uploading via App Store Connect (2026-09-14): the app record's "App Encryption Documentation" flow demanded a manual documentation upload — the macOS `Info.plist` was missing `ITSAppUsesNonExemptEncryption` entirely (present and `false` on iOS's `Info.plist` since the `ios-privacy-compliance` change, never carried over to macOS). Added the same key/value and the same justifying comment (crypto used only for local ledger signing/verification and PIN hashing, no proprietary algorithms, not used to encrypt communications — Apple's standard authentication/integrity exemption) to `macos/Runner/Info.plist`. Requires a fresh archive+upload to take effect, since the key is baked in at build time — the already-uploaded build still lacks it

## 3. Verify on a real sandboxed build

- [x] 3.1 OFX import and CSV import (open dialog) still work — manually click-tested by the user (2026-09-14) against the actual sandboxed Release archive
- [x] 3.2 CSV export and "Save backup" (save dialog) still work — same manual pass
- [x] 3.3 Signing key read/write (`flutter_secure_storage`) still works — onboarding, restore, and normal posting all still sign correctly — same manual pass
- [x] 3.4 App-lock Face ID/Touch ID unlock still works — same manual pass; this one specifically needed a human, since Touch ID can't be scripted
- [ ] 3.5 `tool/run_acceptance_tests.sh -d macos` green

No longer blocked on task 1.1. Tasks 3.1-3.4 are done via a manual click-through of the real sandboxed `.xcarchive` by the user directly, confirmed 2026-09-14 (a fresh archive was rebuilt after the `ios-launch-screen-image` and `store-listing-assembly-macos-screenshots` changes; those touch launch-image assets and demo-data screenshots only, nothing sandbox/entitlement-related, so the earlier click-through result still holds — re-verified anyway since a new archive was on hand). Task 3.5 stays open: `tool/run_acceptance_tests.sh -d macos` runs `flutter test -d macos`, which always builds **Debug**, and `DebugProfile.entitlements` is intentionally unsandboxed (Decision 3) — a green run of that command still wouldn't exercise the sandbox at all. Given 3.1-3.4 already cover the sandboxed behavior directly, 3.5 is now a lower-value automated regression check rather than a blocker for submission.

## 4. Decide on DebugProfile.entitlements

- [x] 4.1 Resolve the Open Question in `design.md` once real signing is routine for local dev — keep DebugProfile unsandboxed until a real Team is routine for `flutter run -d macos` (Decision 3)
