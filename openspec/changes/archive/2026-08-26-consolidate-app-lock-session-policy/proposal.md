## Why

PIN hashing correctly lives in `AppLockService`, but timeout / relock / snapshot-hiding policy is split across `AppLockController`, async `SettingsRepository` reads, `LockViewModel`, and `app_router`. Answering “when is the app locked?” requires reading four places — poor locality for unit tests and for acceptance (`home_and_lock_test.dart`).

## What Changes

- Deepen a domain `AppLockPolicy` (or extend `AppLockService`) to own enabled / timeout / biometric-available / snapshot-hide / unlock-session decisions.
- Keep `AppLockController` as a thin lifecycle forwarder exposing synchronous policy state after init.
- Keep PIN derive-on-isolate and Keychain storage path per ADR 0001 — no acceptance-only in-memory bypass.
- Router and lock UI read policy through one seam.

## Capabilities

### New Capabilities
- `app-lock-session-policy`: single module for session lock/unlock policy distinct from PIN crypto and Keychain storage.

### Modified Capabilities
- (none required if product `app-lock` scenarios are preserved; only list `app-lock` if a requirement wording must change)

## Impact

- `lib/domain/lock/app_lock_service.dart`, `biometric_authenticator.dart`
- `lib/ui/core/app_lock_controller.dart`, `lib/ui/features/lock/view_models/lock_view_model.dart`
- `lib/data/repositories/settings_repository.dart`, `lib/ui/app_router.dart`
- Unit tests for timeout/relock without WidgetsBinding; acceptance unlock remains GUI
- **Aligns with ADR 0001** — deepen policy around the same secure-storage path
