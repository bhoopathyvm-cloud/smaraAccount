## Why

Acceptance proves **locking** via PIN (Lock screen appears after relaunch) but never **unlocking**: on the ad-hoc signed macOS build, `AppLockService.verifyPin` (real secure storage) hangs indefinitely — the same class of Keychain pathology already noted for cleanup entitlements. Users on developer / ad-hoc macOS builds can hit the same hang. The fix must be **production-correct** (real Keychain/entitlements/signing path), not a test-only bypass, and unlock must then pass acceptance on **macOS, iOS, and Android**.

## What Changes

- Fix macOS (and any shared) secure-storage / entitlements / signing configuration so PIN hash read/verify completes reliably for real users — same path acceptance uses.
- Extend `home_and_lock_test.dart` (or equivalent) to enter the PIN on the Lock screen and assert the app unlocks to Home/Accounts.
- Verify that unlock scenario on macOS, iOS (simulator or wipeable physical device), and Android (`smara_kiosk_pixel` or equivalent emulator).
- Biometric unlock remains out of scope (existing `acceptance-test-suite` / `app-lock` non-goal).

## Capabilities

### New Capabilities
- `acceptance-app-lock-unlock`: real-build acceptance coverage for PIN unlock after lock, on every ship platform the acceptance tier targets.

### Modified Capabilities
- `app-lock`: PIN unlock via the app's secure-storage-backed verifier SHALL complete (succeed or fail with a normal false) without hanging on every supported platform, including local/ad-hoc signed macOS developer runs that the project supports for day-to-day development.

## Impact

- `lib/domain/lock/app_lock_service.dart`, `lib/domain/crypto/secure_key_storage.dart`
- macOS entitlements / signing docs or project settings under `macos/`
- `integration_test/acceptance/home_and_lock_test.dart` and possibly `acceptance_harness.dart` cleanup if Keychain key set changes
- Manual multi-platform acceptance runs; no CI gate
