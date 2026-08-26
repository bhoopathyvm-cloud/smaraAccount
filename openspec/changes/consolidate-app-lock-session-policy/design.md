## Context

`AppLockService` owns PIN hash (PBKDF2 on isolate per ADR 0001). Session policy — enabled flag, timeout, snapshot hiding, unlocked session — is spread across `AppLockController`, `SettingsRepository`, router redirects, and `LockViewModel`. Acceptance unlock is green on macOS/iOS; locality for timeout/relock unit tests remains poor.

## Goals / Non-Goals

**Goals:**
- One `AppLockPolicy` (or deepened `AppLockService`) owning session decisions.
- Controller forwards lifecycle; exposes sync policy state after init.
- Unit-test timeout/relock without WidgetsBinding where feasible.
- Preserve ADR 0001 Keychain path and isolate PBKDF2.

**Non-Goals:**
- Biometric path product expansion beyond existing wiring.
- Acceptance-only in-memory PIN store.
- Redesigning lock screen UI.

## Decisions

### Decision 1 — Policy module vs extending AppLockService

**Options:** (A) New `AppLockPolicy` composing settings + service; (B) Fold timeout into `AppLockService`; (C) Keep controller as source of truth.

**Decision: A preferred** — crypto/storage stay in `AppLockService`; session rules stay in policy. B acceptable if types stay small. Reject C.

### Decision 2 — Settings read once into policy cache

Avoid racing async settings reads on every lifecycle event; policy refreshes on settings change notifications.

### Decision 3 — Align with ADR 0001

Do not introduce a second storage path for PIN for tests; use fakes at the secure-storage seam already used by unit tests.

## Risks / Trade-offs

- **[Risk]** Router timing regressions → **Mitigation:** keep acceptance `home_and_lock` green on macOS; add policy unit tests for timeout edge cases.
- **[Trade-off]** More types in domain/lock — clearer locality.

## Migration Plan

1. Introduce policy; delegate from controller.
2. Point router/LockViewModel at policy.
3. Delete duplicated timeout logic.

## Open Questions

- Exact timeout clock source (injectable `DateTime` for tests).
