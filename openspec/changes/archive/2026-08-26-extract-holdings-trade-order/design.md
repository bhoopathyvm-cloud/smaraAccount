## Context

Architecture review (main `1d8c22e` .. round 2, 2026-08-26) flagged `HoldingsView`'s three trade dialogs as the strongest deepening candidate in the holdings/settings/account-management sweep: the funding-source and gain/loss-sign branching that decides which fields appear is real domain logic with zero test coverage, direct or indirect, and it duplicates rules `InvestmentRepository` already enforces at write time.

This is deliberately scoped separately from the in-flight `finish-chart-catalog-seams`/`extract-active-balance-engine` work — those touch `InvestmentRepository`'s *write-side* validation and balance rules; this change touches only the *view-side* draft state that decides what the dialog shows before submission.

## Goals / Non-Goals

**Goals:**
- One deep, Flutter-free module owning trade-draft state and its visibility/readiness rules, testable with `package:test`.
- `HoldingsViewModel` stays the seam between the draft and `InvestmentRepository`; the draft itself never touches Drift or `InvestmentRepository`.
- Byte-for-byte preservation of current field visibility and submit behavior.

**Non-Goals:**
- Changing `InvestmentRepository`'s validation rules or exception types (covered separately by `finish-investment-income-category-seam` for one leftover case).
- Introducing form-framework machinery (e.g. `flutter_form_builder`) — the draft is a plain Dart class, not a new dependency.
- Touching `_showBuyDialog`'s inline instrument-creation UI beyond wiring it through the draft.

## Decisions

### Decision 1 — Three small drafts, not one polymorphic `TradeOrderDraft`

**Options:** (A) One `TradeOrderDraft` class with nullable fields for every trade kind; (B) `BuyOrderDraft` / `SellOrderDraft` / `DividendOrderDraft`, each with only the fields its dialog uses.

**Decision: B.** Buy, sell, and dividend share almost no fields (buy has funding source + optional new-instrument fields; sell has a held-instrument selector + gain/loss; dividend has neither). A shared class would be nullable-field soup — the same shallowness this change is meant to remove. Precedent: `statement_import_session.dart` already keeps `CsvMappingDraft` separate from the step/session state it sits inside.

### Decision 2 — Draft lives in `lib/domain/investment/`, not `lib/ui/features/holdings/`

Matches the existing `lib/domain/statement_import/`, `lib/domain/register/` precedent: view-agnostic session/draft state lives in `lib/domain/`, not next to the widgets that use it. `HoldingsViewModel` is the only importer outside tests.

### Decision 3 — `HoldingsViewModel` still owns the submit call, not the draft

The draft answers "is this submittable and what should be visible"; it does not call `InvestmentRepository`. `HoldingsViewModel.submitBuy(BuyOrderDraft draft)` reads the draft's fields and calls `_investmentRepository.recordBuy(...)` exactly as `recordBuy(...)` does today, so the existing `_run`/`InvestmentException` error handling is untouched.

### Decision 4 — Behavior-preserving migration, dialog by dialog

Migrate `_showBuyDialog` first (largest, most branching), verify widget tests still pass, then `_showSellDialog`, then `_showDividendDialog`. Each dialog's local `var`s are deleted only once its widgets read from the draft.

## Risks / Trade-offs

- **[Risk]** A draft field default drifts from the dialog's current default (e.g. `holding = viewModel.holdings.first` for sell) during migration → **Mitigation:** port each default literally in the same commit as its dialog, verified by the existing widget tests before deleting the local var.
- **[Trade-off]** One more constructed object per dialog open (a `BuyOrderDraft`/`SellOrderDraft`/`DividendOrderDraft`), scoped to the dialog's lifetime — negligible.

## Migration Plan

1. Add `trade_order_draft.dart` with unit tests for `requiresIncomeCategory`, `requiresBrokerageCategory`, `gainLossMinor`, `canSubmit` covering both funding sources and all three gain/loss signs.
2. Add `HoldingsViewModel.newBuyDraft()` / `submitBuy(draft)`; migrate `_showBuyDialog` to bind to it.
3. Repeat for sell, then dividend.
4. Delete the now-dead local `var`s and inline branching in each dialog.
5. Rollback = revert; no data migration, no schema change.

## Open Questions

- Whether `DividendOrderDraft` is worth a dedicated class given it has almost no branching (only "instrument required, amount required, income category required") — keep it for symmetry with the other two, or fold it into a plain validation function. Default to the class for now; simplify during grilling if it proves to be a pure pass-through.

## Post-implementation note

The implementation did not achieve byte-for-byte behavior preservation (Goals, above) in one spot, discovered during architecture review of the merged diff: in `_showBuyDialog`'s submit handler, `BuyOrderDraft.canSubmit` requires `quantityScaled`/`unitPriceMinor` to be set *before* the "create new instrument" side effect runs (`if (draft.creatingNew) { if (!draft.canSubmit) return; ... createInstrument(...); }`). The pre-draft dialog only checked the new-instrument name before calling `createInstrument`, then checked quantity/price *after* — so a user who filled in a new-instrument name but left quantity or price blank would have the instrument created (a real write) and then silently abort the buy, leaving an orphaned instrument behind.

This is a latent-bug fix, not a regression, and is the more correct behavior — kept as-is rather than reverted. Neither the old nor the new behavior at this specific edge had a test either direction; added `holdings_view_test.dart`'s `'buy dialog does not create the new instrument until quantity and price are set'` to cover it going forward (asserts `InvestmentRepository.createInstrument` is never called while quantity/price are unset, then that it is called once both are filled).
