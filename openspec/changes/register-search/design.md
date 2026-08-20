## Context

An earlier draft claimed `core-ledger-single-account` as a modified
capability with no delta. Checked before resolving: search and its
optional filters only narrow which of the register's already-posted,
already-ordered rows are visible — they don't change posting behavior or
the `Transaction Register` requirement's ordering guarantee, so no delta
is needed there.

## Goals / Non-Goals

**Goals:** Find a row in seconds, by text or by narrowing to a date
range/direction.

**Non-Goals:** Searching across multiple accounts at once (scoped to the
selected account's register, matching how the register itself is
already account-scoped).

## Decisions

`RegisterViewModel` filters client-side over the already-loaded rows for
v1 (no new repository query) — the register's row count for a single
account is small enough that this is simpler and sufficient; a
repository-level `watchRegisterRows(query)` is a later optimization if
ever needed, not required for this change to be useful.

## Risks / Trade-offs

- [Risk] Interaction with other child changes. → See
  household-product-repositioning waves.

## Open Questions

None for v1.
