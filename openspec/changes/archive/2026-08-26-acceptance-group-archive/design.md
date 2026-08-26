## Context

INTEGRATION already walks user-created group archive: create Business group + account (via repository), reject Hide while active, archive member account (repository), Hide group via UI, assert visibility and reassignment picker behavior. Acceptance never did. Product rules live in `multi-account-ledger`.

## Goals / Non-Goals

**Goals:**
- Port that lifecycle onto the real-build harness with the same assertions that matter for users (error when not empty, success when empty, historical names remain, archived group not a reassignment target).
- Independently runnable under the existing acceptance script/group filter.

**Non-Goals:**
- Testing the Create Group dialog itself (INTEGRATION also skips that).
- System-group archive attempts (already rejected by product; optional later).
- Unarchive flows (out of this change unless needed for cleanup between scenarios).

## Decisions

### Decision 1 — Match INTEGRATION's setup/GUI split

**Decision:** Create group + member account and empty the group via repository (or equivalent non-dialog setup already used in acceptance helpers if present); drive Hide / confirmation / reassign-group through the real Accounts UI. This keeps the scenario focused on archive rules, not create-dialog chrome.

### Decision 2 — File placement

**Decision:** Prefer adding the scenario to `core_ledger_test.dart` (core ledger / multi-account group) unless file size makes a sibling `group_archive_test.dart` clearer — either is fine if the script's group substring still finds it (`core_ledger` or `group_archive`).

### Decision 3 — Platform-stable popup finding

**Decision:** Use tooltip `"Show menu"` (or localized equivalent via `AppLocalizations` if the acceptance locale isn't English) rather than `byIcon` for `PopupMenuButton`, matching INTEGRATION's macOS-vs-other icon lesson.

## Risks / Trade-offs

- **[Risk]** Popup index order differs with acceptance's seeded groups (Investments, etc.) → **Mitigation:** locate by group name context / stable ordering documented in the test, not hardcoded magic indices from INTEGRATION's thinner seed.
- **[Risk]** Below-the-fold groups on small windows → **Mitigation:** `ensureVisible` / existing `tapReliably` helpers.
- **[Trade-off]** Repository setup is slightly less "pure GUI" but matches the reference journey and avoids inventing create-dialog coverage here.

## Migration Plan

N/A.

## Open Questions

- None blocking design; confirm popup ordering against current seed during implementation.
