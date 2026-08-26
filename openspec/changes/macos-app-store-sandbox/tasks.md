## 1. Prerequisite (human, not code)

- [ ] 1.1 Configure a real Apple Developer Team in Xcode's Signing & Capabilities for the `Runner` target (blocks verification of every task below)

## 2. Entitlements

- [ ] 2.1 Set `com.apple.security.app-sandbox` to `true` in `macos/Runner/Release.entitlements`
- [ ] 2.2 Add `com.apple.security.keychain-access-groups` as an empty array
- [ ] 2.3 Change `com.apple.security.files.user-selected.read-only` to `com.apple.security.files.user-selected.read-write`

## 3. Verify on a real sandboxed build

- [ ] 3.1 OFX import and CSV import (open dialog) still work
- [ ] 3.2 CSV export and "Save backup" (save dialog) still work
- [ ] 3.3 Signing key read/write (`flutter_secure_storage`) still works — onboarding, restore, and normal posting all still sign correctly
- [ ] 3.4 App-lock Face ID/Touch ID unlock still works
- [ ] 3.5 `tool/run_acceptance_tests.sh -d macos` green

## 4. Decide on DebugProfile.entitlements

- [ ] 4.1 Resolve the Open Question in `design.md` once real signing is routine for local dev
