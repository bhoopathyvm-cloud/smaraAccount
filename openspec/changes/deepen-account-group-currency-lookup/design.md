## Context

Five feature view models duplicate `currencyFor(accountId)` by joining `watchFinancialAccounts` and `watchAccountGroups`. Statement import uses `groupCurrencyFor` via `.first` on a stream. Cross-currency transfer and register checks depend on that join staying consistent.

## Goals / Non-Goals

**Goals:**
- One reactive lookup on `AccountRepository` (or catalog read model): account id → group currency.
- All listed call sites use that seam.
- Fewer duplicate stream subscriptions in view models.

**Non-Goals:**
- Changing multi-currency product rules.
- Solving posting extraction or Drift enum lift.
- Caching policy beyond what AccountRepository already does for watches.

## Decisions

### Decision 1 — Deepen AccountRepository rather than a new top-level package

**Options:** (A) New `AccountCatalog` type; (B) Methods on `AccountRepository`; (C) Inherited widget / Riverpod-only helper.

**Decision: B** unless AccountRepository already feels overloaded — then A as a thin read model owned by the account package. Prefer one seam injectable in ViewModel constructors.

### Decision 2 — Reactive API shape

Prefer `Stream<String?>` or a combined catalog snapshot watch so UI can rebuild when group currency changes; keep a sync lookup only if existing code requires it after snapshot load.

### Decision 3 — Statement import uses the same seam

Replace `groupCurrencyFor` with the shared lookup to eliminate the third variant.

## Risks / Trade-offs

- **[Risk]** Extra stream churn → **Mitigation:** derive currency from existing account+group watches inside the repository once, not once per ViewModel.
- **[Trade-off]** ViewModels lose local join control — acceptable for leverage.

## Migration Plan

1. Add repository method + unit tests.
2. Migrate view models one by one.
3. Delete local `currencyFor` copies.

## Open Questions

- Sync vs stream-only API for settle-pending flows.
