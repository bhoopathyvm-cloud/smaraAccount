## Context

Architecture review (round 2, 2026-08-26) flagged this "Strong": it's not just duplication, it's a direct contradiction of the codebase's own documented View convention ("Views are lean. No business logic, no Repository calls" — `smara-tech-guidelines.md` Responsibility Boundaries § Views), and the codebase already has a structured-failure mechanism (`AppErrorCode` + `localizeError`) that these four checks bypass.

## Goals / Non-Goals

**Goals:**
- One definition each for "is this PIN valid/matching" and "is this passphrase non-blank", reachable from a unit test.
- Route both through the existing `AppErrorCode`/`localizeError` pattern rather than inventing a second validation-result shape.
- Restore the View's own documented convention for these four dialogs specifically.

**Non-Goals:**
- Changing the PIN minimum length (4) or any other threshold.
- Touching `AppLockService.setPin`/`verifyPin` or the biometric/timeout/snapshot-hiding settings — unrelated to this change.
- A general-purpose form-validation framework — two small methods are enough for four call sites.

## Decisions

### Decision 1 — Validators return `AppErrorCode?`, not a bespoke result type

**Options:** (A) A new `ValidationResult` sealed class; (B) Reuse `AppErrorCode?` (null = valid), matching the codebase's existing `AppFailure(AppErrorCode, ...)` pattern.

**Decision: B.** `AppErrorCode` already exists specifically so "repositories must not emit display English as the only signal" (`app_error.dart:1-3`); a validator returning a code is consistent with every other failure path in the app, and the View already has `localizeError(l10n, code)` wired up to render it. Introducing a second result shape for validation only would be a shallow module of its own.

### Decision 2 — Validators are synchronous methods on `SettingsViewModel`, not a separate domain module

Both rules are pure, single-expression-scale checks (`length`, `==`, `trim().isEmpty`) — there is no session or multi-field draft state like the holdings trade-order module. Precedent: keep them where `enableAppLock`/`changePin`/`exportBackup`/`restoreBackup` already live, since they gate those same calls.

### Decision 3 — Add `validationPinTooShort` rather than reusing `validationPinsDoNotMatch` for both cases

The View currently shows a different message for "too short" vs. "don't match" (`l10n.validationPinMinLength` vs. `l10n.validationPinsDoNotMatch`) — the existing `l10n.validationPinMinLength` string stays, just gets an `AppErrorCode` so it can flow through `localizeError` like its sibling `validationPinsDoNotMatch` already does.

## Risks / Trade-offs

- **[Risk]** `pinValidationError`/`passphraseValidationError` get called from a fifth site in the future and someone re-inlines the check instead of reusing them → **Mitigation:** none beyond code review; low risk given only four call sites exist today and all four are migrated in this change.
- **[Trade-off]** Two new small public methods on `SettingsViewModel` — offset by deleting four inline duplicate checks.

## Migration Plan

1. Add `AppErrorCode.validationPinTooShort`; wire it through `localizeError` to the existing `l10n.validationPinMinLength` string.
2. Add `SettingsViewModel.pinValidationError`/`passphraseValidationError` with unit tests.
3. Migrate all four dialogs to call the validators and render `localizeError`.
4. Delete the four inline `if` checks.
5. Rollback = revert; no data migration.

## Open Questions

- None outstanding.
