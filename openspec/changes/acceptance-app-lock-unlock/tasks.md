## 1. Diagnose and fix production secure storage / PIN verify

- [x] 1.1 Reproduce the `verifyPin` hang on ad-hoc signed macOS with a minimal secure-storage read after `setPin` + simulated relaunch; compare with signing-key reads — **hang correlated with sync PBKDF2 on the UI/method-channel isolate (see ADR).**
- [x] 1.2 Implement the production-correct fix (secure-storage options, macOS entitlements/signing, and/or AppLockService usage) so PIN verify completes without hanging — **`AppLockService._deriveHash` moved to `Isolate.run`.**
- [x] 1.3 Add a focused unit or platform test where feasible; document any required signing/Team ID steps for contributors — **`test/domain/lock/app_lock_service_test.dart` (6/6); `docs/adr/0001-production-keychain-pin-unlock.md`.**
- [x] 1.4 Re-run identity/backup acceptance smoke (`identity_restore` / `ledger_backup` group) on macOS after the storage change — **both groups green via `tool/run_acceptance_tests.sh -d macos`.**

## 2. Acceptance unlock scenario

- [x] 2.1 Extend `home_and_lock_test.dart` to enter the correct PIN on the Lock screen and assert the main shell is reachable
- [x] 2.2 Confirm 2 consecutive green runs on macOS — **2/2 green in isolation (`home_and_lock_test.dart`).**

## 3. Multi-platform DoD

- [x] 3.1 Run the unlock scenario on iOS (simulator or wipeable physical device — not a daily-ledger install) — **iPhone 17 Simulator (`home_and_lock_test.dart` 2/2 green).**
- [ ] 3.2 Run the unlock scenario on Android (`flutter emulators --launch smara_kiosk_pixel` or equivalent) — **emulator launch attempted; device not online in this session.**
- [~] 3.3 Confirm the same test code passes on all three without platform-specific scenario branches — **macOS + iOS sim green; Android pending.**
