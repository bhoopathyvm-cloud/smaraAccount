## Context

See proposal.md.

## Goals / Non-Goals

**Goals:** One user action; two journal entries; no in-place edit.

**Non-Goals:** Out of scope items in proposal.

## Decisions

`LedgerRepository.fixPostedTransaction` posts the reversal and the
replacement in one Drift transaction. The Fix view-model calls that
single method. `reverseEntry` still exists for independent reversals
and refuses a second reverse of the same original.

## Risks / Trade-offs

- [Risk] Scope creep. → Mitigation: child change stays focused.

## Open Questions

None for v1.
