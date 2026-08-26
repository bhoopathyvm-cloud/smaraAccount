## Context

`acceptance-test-suite` landed tamper detection on the real build: mutate a journal row outside the app, simulate restart, assert the Register lock badge. The follow-on — record a second clean entry through the GUI and show the chain has re-anchored — failed because `find.byIcon(TablerIcons.plus)` found zero elements after that restart. INTEGRATION covers re-anchoring via direct `LedgerRepository.recordTransaction` after the same quarantine setup; acceptance must do it through the FAB like a user.

## Goals / Non-Goals

**Goals:**
- Explain and fix the missing FAB (product and/or harness).
- Ship a green acceptance scenario for post-quarantine re-anchoring on at least macOS (same bar as the parent suite's proven core-ledger file); prefer the same code path works unmodified on iOS/Android.
- Keep using `SmaraAccountingApp` + `resetToFreshDevice` / existing helpers.

**Non-Goals:**
- Changing integrity/signing algorithms or quarantine semantics.
- Porting reverse-entry (still no GUI).
- Group-archive or PIN unlock (separate changes).

## Decisions

### Decision 1 — Investigate before rewriting the scenario

**Options:** (A) Assume finder wrong and switch to another locator; (B) Assume UI bug and fix Register shell; (C) Reproduce first with dumps (`tapReliably` visible-text dump, widget tree, route) then fix the actual cause.

**Decision: C.** The parent design already notes the failure is distinct from scroll/bounds/stale-check issues; guessing A or B wastes a cycle.

### Decision 2 — Prefer GUI recording over Repository backdoor

Acceptance is GUI-only for user-visible journeys. Recording the post-quarantine entry MUST go through Register FAB → record flow, not `LedgerRepository.recordTransaction`, even though INTEGRATION uses the repository for that half.

### Decision 3 — Keep the scenario in `core_ledger_test.dart`

Same file already owns tamper detection; extending it preserves group filtering (`core_ledger`) and shared onboarding helpers.

## Risks / Trade-offs

- **[Risk]** FAB absence is intermittent flakiness → **Mitigation:** require 2 consecutive green runs; use `pumpUntilFound` with specific success widgets, not generic `TextField`.
- **[Risk]** Fixing a real post-quarantine navigation bug changes product behavior → **Mitigation:** acceptable — that's a product bug the acceptance tier exists to catch; cover with widget/unit if logic moves.
- **[Trade-off]** Time-box investigation; if blocked on platform-only flake, document evidence in tasks and stop rather than inventing a Repository backdoor that would violate the tier.

## Migration Plan

N/A — test + optional UI fix only; no data migration.

## Open Questions

- Exact root cause of the FAB miss (unknown until investigation).
