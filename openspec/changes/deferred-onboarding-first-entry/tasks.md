## Tasks

- [ ] 1.1 `app_router.dart`: change the redirect guard so a first-run session (identity exists, unacknowledged) reaches the first-account-naming and first-entry screens before the recovery-phrase redirect fires; the redirect still fires unconditionally once that first entry has posted, or on any relaunch before acknowledgment (matching today's `_onboardingPaths` guard for every path afterward).
- [ ] 1.2 First-account-naming screen (currency + name) and a minimal guided first-entry screen (existing record-transaction flow, or a thin wrapper around it) reachable only in this pre-acknowledgment window.
- [ ] 1.3 Confirm the guided first entry calls the same `recordTransaction` path as every other entry — no new posting method, no bypass of the existing "identity must exist" guard (it's already satisfied, since identity generation is unchanged).
- [ ] 1.4 After the first entry posts, force the existing recovery-phrase acknowledgment route; verify it blocks navigation to anything else, including app resume after backgrounding/kill.
- [ ] 1.5 Migrate existing onboarding tests for the new route order; add a test that a killed-and-relaunched app between first entry and acknowledgment still redirects to acknowledgment, and that the first entry is present and correctly signed/chained on relaunch.
- [ ] 1.6 Update user guide onboarding order.
