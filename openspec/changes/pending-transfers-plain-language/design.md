## Context

An earlier draft claimed `foreign-currency-settlement` as a modified
capability with no delta, and left a local-notification reminder as a
loose "optional v2" bullet. Resolved both: the settlement mechanism and
its requirement text are unaffected by a copy change (same principle
`household-language-voice` already uses — internal spec vocabulary
stays, UI copy changes), and the reminder is explicitly deferred rather
than left ambiguous about whether it's in scope.

## Goals / Non-Goals

**Goals:** Remittance-friendly words on Home and the settle screen.

**Non-Goals:** Any change to settlement behavior, pending-transfer data,
or `foreign-currency-settlement`'s own requirements. A scheduled/local
notification reminder — deferred, its own future change if wanted.

## Decisions

Copy and layout only. `accounts-home-overview`'s pending-line rendering
is where the human-sentence wording lives (see spec.md); the settle
screen's intro text changes in the UI layer with no corresponding spec
delta needed, since it's the same pattern — wording, not behavior.

## Risks / Trade-offs

- [Risk] Interaction with other child changes. → See
  household-product-repositioning waves.

## Open Questions

None for v1.
