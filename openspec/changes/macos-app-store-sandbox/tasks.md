## 1. Prerequisite (human, not code)

- [x] 1.1 Configure a real Apple Developer Team in Xcode's Signing & Capabilities for the `Runner` target (blocks verification of every task below) — done (2026-09-13): added `DEVELOPMENT_TEAM = PLUT6R5W2W` to the Runner target's Debug/Release/Profile configs in `macos/Runner.xcodeproj/project.pbxproj` (matching what was already present for iOS), and removed a project-level `CODE_SIGN_IDENTITY = "-"` override on the **Release** config only that was forcing ad-hoc signing regardless of Team (Debug/Profile keep it, per Decision 3 below — local `flutter run` stays unsandboxed/ad-hoc). Verified via a real `xcodebuild archive`: `codesign -dvv` on the archived `.app` shows `TeamIdentifier=PLUT6R5W2W` with the Apple Development authority chain, not ad-hoc

## 2. Entitlements

- [x] 2.1 Set `com.apple.security.app-sandbox` to `true` in `macos/Runner/Release.entitlements`
- [x] 2.2 Add `com.apple.security.keychain-access-groups` as an empty array
- [x] 2.3 Change `com.apple.security.files.user-selected.read-only` to `com.apple.security.files.user-selected.read-write`

## 3. Verify on a real sandboxed build

- [ ] 3.1 OFX import and CSV import (open dialog) still work
- [ ] 3.2 CSV export and "Save backup" (save dialog) still work
- [ ] 3.3 Signing key read/write (`flutter_secure_storage`) still works — onboarding, restore, and normal posting all still sign correctly
- [ ] 3.4 App-lock Face ID/Touch ID unlock still works
- [ ] 3.5 `tool/run_acceptance_tests.sh -d macos` green

No longer blocked on task 1.1 — but a real gap surfaced while unblocking it: `tool/run_acceptance_tests.sh -d macos` runs `flutter test -d macos`, which always builds **Debug**, and `DebugProfile.entitlements` is intentionally unsandboxed (Decision 3). So a green run of that command does not exercise the sandbox at all — it never has, and still doesn't. The actual `.xcarchive` now builds Release-signed with the real entitlements applied and confirmed present (`codesign -d --entitlements -` shows `app-sandbox`, `network.client`, `keychain-access-groups`, `user-selected.read-write` all correctly set) at `build/macos/Build/Products/smara_accounting.xcarchive`. Tasks 3.1-3.4 need a manual click-through of that archived `.app` specifically (or a real answer to whether `flutter test`/`flutter drive` can target a Release-configured build) — not just a green 3.5.

## 4. Decide on DebugProfile.entitlements

- [x] 4.1 Resolve the Open Question in `design.md` once real signing is routine for local dev — keep DebugProfile unsandboxed until a real Team is routine for `flutter run -d macos` (Decision 3)
