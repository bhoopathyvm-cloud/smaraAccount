## Context

See proposal.md.

## Goals / Non-Goals

**Goals:** Take data with you.

**Non-Goals:** See proposal.

## Decisions

CSV v1; PDF later.

## Risks / Trade-offs

- [Risk] Interaction with other child changes. → See household-product-repositioning waves.

## Open Questions

None for v1.

## Filled in during implementation

This design.md predated any concrete decisions - the following resolves
what "CSV v1" alone left open:

### Scope: one account, one date range, no repository-level "all accounts"
Matches the spec's own scenario ("exports January for one account") and
mirrors how Register itself is already account-scoped - the currently
viewed account is the export's account, with no separate account picker
needed in the UI.

### Columns: `Date,Description,Category,Direction,Amount,Currency,Verified`
`Category` doubles as the counterparty label for a transfer
("Transfer: {account}") or an opening balance ("Opening balance"), the
same resolution `RegisterViewModel`'s own row-label logic already does
independently (data layer, not a UI-layer dependency). `Verified` was
added beyond the proposal's literal "account category date amount
description" list: a quarantined (tamper-flagged) entry is still
exported, matching the Register's own "still shown, never hidden"
treatment - silently dropping it from an accountant's export would be
actively misleading, not just incomplete.

### One row per category leg (split-transactions interop)
An ordinary transaction has exactly one category leg, so this reduces to
one row per entry in the common case. A split entry exports one row per
category line, each with that line's own amount - not the entry's total
repeated per line - so the exported rows sum correctly per entry and the
breakdown isn't lost the way a single summarized row would lose it.

### Correction, found during implementation: amount formatting
The first implementation used `ui/core/money_formatter.dart`'s
`formatAmountMinor` for the Amount column display - wrong for two
independent reasons, found before landing: (1) `LedgerRepository` is the
data layer and must not import from `ui/core`
(smara-tech-guidelines.md's Repository/View separation); (2)
`formatAmountMinor`'s locale-grouped output is actively wrong *inside a
comma-delimited CSV* for a currency like EUR, whose own decimal
separator is a comma - it would silently misalign every EUR row's
columns. Resolved by extracting the currency-accurate minor-unit-digit
lookup (`minorUnitDigitsForCurrency`, previously private to
`ui/core/money_formatter.dart`) into a new domain-layer file,
`lib/domain/money/currency_minor_units.dart`, usable from both layers;
`ui/core/money_formatter.dart` now re-exports it unchanged for every
existing UI call site. The CSV's own Amount column uses a plain,
locale-independent period-decimal string (`_csvAmount`) built from that
digit count directly - accurate per currency (0 digits for JPY, 2 for
most others), never locale-grouped, so it can never collide with the
file's own comma delimiter.
