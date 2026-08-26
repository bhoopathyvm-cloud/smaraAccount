## Context

Chart reader and currency catalog landed in architecture-deepening, but posting/investment still query `accounts` for category activity, and holdings/correction still join groups for currency. Architecture review ranked this Worth exploring: leverage of existing seams is incomplete.

## Goals / Non-Goals

**Goals:**
- Category require-active on the chart seam with explicit exception policy.
- Holdings + correction on `AccountCurrencyCatalog`.
- Remove unused InvestmentRepository Account/Category fields if safe.

**Non-Goals:**
- New catalog features.
- Splitting AccountRepository into financial vs group repositories (out of scope).

## Decisions

### Decision 1 — Exception policy is a parameter, not two copy-pasted methods

Investment currently throws `PendingTransferException` even on buy (documented D1a). Keep that observable behavior via a strategy/enum on the chart method, not a second private copy.

### Decision 2 — Catalog includeArchived true for correction/holdings

Match register: archived accounts still need currency.

## Risks / Trade-offs

- **[Risk]** Wrong exception type changes UI copy → **Mitigation:** keep existing exception types; tests assert type/code.
- **[Trade-off]** Chart reader grows two methods — still one seam.

## Migration Plan

1. Add chart category helpers; switch posting then investment.
2. Migrate holdings and correction to catalog.
3. Drop unused ctor deps if nothing else needs them.

## Open Questions

- Whether `recordCompanionFee` for transfer/buy/sell is in this change or deferred (review mentioned it; default defer).
