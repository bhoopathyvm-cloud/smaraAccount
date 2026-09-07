## Context

Cycle 3. Domain drafts already depend on pure helpers that live under `data/repositories/`, violating the domain→data direction. ADR 0002 still applies: Drift loaders stay as `AppDatabase` leaves shared by InvestmentRepository and LedgerRepository.

## Goals / Non-Goals

**Goals:**
- Pure investment holdings logic in `lib/domain/investment/` with no Drift import.
- Domain drafts import only domain.
- Data file is a thin adapter: load rows → domain events → replay/valuation.

**Non-Goals:**
- Changing replay algorithm or valuation rules.
- Extracting home-overview engine (later cycle).

## Decisions

### Decision 1 — One domain file `investment_holdings.dart`
Keeps related pure types together (same as today's data file cohesion) rather than splitting into many tiny files.

### Decision 2 — `toInstrumentHolding` stays in data
It maps Drift `InstrumentRow` → domain `Instrument`. Callers that already have `Instrument` can construct `InstrumentHolding` directly.

### Decision 3 — Data file re-exports domain symbols temporarily?
**No.** Update imports at all call sites in the same change (finish the seam). Data file imports domain; callers of pure symbols import domain; callers of loaders import data.

## Risks / Trade-offs

- **[Risk]** Missed import leaves a compile error → Mitigation: analyze + existing investment_holdings_test.
- **[Trade-off]** More import path churn in tests — acceptable.

## Migration Plan

1. Add domain module + unit tests for multiply/replay/valuation.
2. Slim data file; update imports.
3. Acceptance; archive; merge.

## Open Questions

- None.
