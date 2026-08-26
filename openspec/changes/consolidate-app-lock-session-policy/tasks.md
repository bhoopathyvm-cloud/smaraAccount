## 1. Policy module

- [ ] 1.1 Inventory lock/timeout/snapshot/unlock decisions across controller, settings, router, LockViewModel
- [ ] 1.2 Introduce `AppLockPolicy` (or deepen `AppLockService`) with injectable clock for timeout tests
- [ ] 1.3 Keep PIN verify on ADR 0001 path (`AppLockService` + isolate PBKDF2 + secure storage)

## 2. Wire UI and router

- [ ] 2.1 `AppLockController` forwards lifecycle into policy; exposes sync locked/enabled state after init
- [ ] 2.2 Router and LockViewModel read policy; mark unlocked only after successful verify
- [ ] 2.3 Remove duplicated timeout/settings branching from the controller

## 3. Verify

- [ ] 3.1 Unit tests for timeout relock and unlock without full widget tree
- [ ] 3.2 Existing `app_lock_service` unit tests still green
- [ ] 3.3 `tool/run_acceptance_tests.sh -d macos home_and_lock` green (lock + unlock)
