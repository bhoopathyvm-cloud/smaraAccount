## Context

`createAppRouter` hosts a long async `redirect` that sequences identity, ledger, account, settings, and `AppLockPolicy`. Session-local `hasVerifiedThisSession` lives in the closure. Architecture review (main `ae41a9f`) ranked this Strong for AI-navigability: the interface is the whole router.

## Goals / Non-Goals

**Goals:**
- Deep `AppNavigationPolicy` with a small interface (`resolve` location → redirect path?).
- Router registers routes and forwards; lock/biometric adapters come from DI, not `new` in builders.
- Unit tests cover gate order without Flutter navigation.

**Non-Goals:**
- Changing product onboarding or lock rules.
- Replacing go_router.
- Re-opening ADR 0001 PIN storage.

## Decisions

### Decision 1 — Policy is app-layer, not a repository

**Options:** (A) Method on IdentityRepository; (B) Domain/app module taking ports; (C) Keep in router.

**Decision: B.** Gates span identity, ledger, accounts, settings, lock — not one repository's job.

### Decision 2 — Session verify-once stays with the policy

`hasVerifiedThisSession` moves into the policy instance (same lifetime as today's router), not a global.

### Decision 3 — Behavior-preserving

Same path constants and allowlists; only the seam moves.

## Risks / Trade-offs

- **[Risk]** Async redirect vs sync tests → **Mitigation:** policy `resolve` stays async; tests `await`.
- **[Trade-off]** Policy constructor takes several ports (same as today's redirect dependencies).

## Migration Plan

1. Extract policy with tests mirroring current redirect cases.
2. Point `GoRouter.redirect` at it.
3. Deduplicate lock/biometric construction into Provider.

## Open Questions

- Package path (`lib/ui/` vs `lib/domain/navigation/`).
