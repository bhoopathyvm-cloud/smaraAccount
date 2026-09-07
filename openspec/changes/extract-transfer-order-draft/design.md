## Context

Cycle 2 of the architecture-improvement loop. `TransferViewModel` still inlines fee/rate form rules after cycle 1 extracted `RecordTransactionDraft`. Reference-rate network fetch and two-step submit stay on the ViewModel.

## Goals / Non-Goals

**Goals:**
- Deep Flutter-free draft for transfer form math and readiness.
- ViewModel remains the seam for streams, `ExchangeRateService`, and partial-failure fee posting.
- Behavior-preserving migration.

**Non-Goals:**
- Collapsing transfer+fee into one `LedgerRepository` posting method (separate deepening if still needed).
- Moving reference-rate fetch into the draft.

## Decisions

### Decision 1 — Draft owns currencies as snapshots, not AccountCurrencyCatalog
VM updates `fromCurrency` / `toCurrency` (or a small map) when catalogs/accounts change. Keeps domain free of the catalog type if unnecessary; either is fine — prefer `fromCurrency`/`toCurrency` strings resolved by the VM for a smaller interface.

### Decision 2 — Submit validation returns structured checks the VM maps to AppErrorCode
Draft exposes `hasRequiredAccountsAndAmount`, `feeRequiresCategory`, `feeExceedsAmountWhenDeducted`, and `transferAmountMinor` so the VM keeps existing error codes without the draft depending on `AppErrorCode`.

### Decision 3 — `impliedRate` uses `minorUnitDigitsForCurrency` from `lib/domain/money/`
Already a domain leaf; no UI import.

## Risks / Trade-offs

- **[Risk]** Fee-deducted implied-rate edge cases drift → **Mitigation:** port literally + domain unit tests covering deducted and non-deducted cases.
- **[Trade-off]** Two-step submit remains UI-orchestrated — accepted for this cycle.

## Migration Plan

1. Add draft + unit tests.
2. Wire ViewModel; delete inlined math.
3. Keep ViewModel tests for submit/fee failure.
4. macOS acceptance; archive; merge.

## Open Questions

- None blocking.
