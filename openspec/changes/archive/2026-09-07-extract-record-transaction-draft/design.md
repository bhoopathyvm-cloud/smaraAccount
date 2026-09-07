## Context

Architecture review cycle 1 (2026-09-07) flagged `RecordTransactionViewModel` as the strongest deepening candidate among recent hot files: split remainder, foreign-currency visibility, paid-from-card/bank picker filters, and payee-matching live in a ~480-line ChangeNotifier whose interface is nearly as wide as the implementation. Precedent already exists: `BuyOrderDraft` / `SellOrderDraft` / `DividendOrderDraft` (`extract-holdings-trade-order`) and `CsvMappingDraft` / `StatementImportSession` (`extract-statement-import-session`).

This is a locality change only — product behavior for record / split / credit-card shortcuts / multi-currency stays the same.

## Goals / Non-Goals

**Goals:**
- One deep, Flutter-free module owning record-transaction draft state and its visibility/readiness rules, testable with `package:test`.
- `RecordTransactionViewModel` stays the seam between the draft and repositories (streams + submit + payee usage); the draft never touches Drift or a Repository.
- Byte-for-byte preservation of current field visibility, validation error codes, and posting behavior.

**Non-Goals:**
- Extracting correction / recurring-template / transfer drafts (separate deepenings).
- Unifying direction→category filtering across ViewModels as a standalone change (bundle later if drafts land).
- Changing `LedgerRepository.recordTransaction` / `recordSplitTransaction` interfaces.
- Introducing form-framework machinery.

## Decisions

### Decision 1 — One `RecordTransactionDraft` + `SplitLine`, not separate single/split classes

**Options:** (A) `SingleTransactionDraft` and `SplitTransactionDraft`; (B) one mutable draft that expands in place via `startSplitting` / collapse on last-line remove.

**Decision: B.** Today's form is already an in-place expansion (split-transactions spec); splitting into two classes would duplicate amount/account/date/description and fight the existing UX. Matches how the ViewModel works today.

### Decision 2 — Draft lives in `lib/domain/record_transaction/`

Matches `lib/domain/investment/`, `lib/domain/statement_import/`, `lib/domain/register/`. ViewModel is the only non-test importer.

### Decision 3 — Catalog lists are inputs to getters, not owned by the draft forever

`financialAccounts`, `categories`, `payees`, and `accountCurrency` (resolved from catalog) are supplied by the ViewModel from streams. The draft either:
- (preferred) holds the latest snapshots via `updateCatalog(...)` / field setters the VM calls when streams fire, or
- accepts lists as method parameters for `financialAccountOptions` / `categoriesForDirection` / `payeeSuggestions`.

**Decision:** Draft holds mutable catalog snapshots updated by the VM on each stream event (same pattern as holding `amountMinor` etc.). Keeps getter shapes identical to today's ViewModel API so the view keeps calling `viewModel.financialAccountOptions` without signature churn. Methods that need catalogs read from the draft's snapshots.

### Decision 4 — ViewModel still owns submit and failure surfacing

Draft answers readiness (`canSubmitSingle` / `canSubmitSplit` / incomplete-line / remainder-zero checks as pure bools or structured validation). ViewModel maps those into existing `AppFailure` codes and calls the repository — so LocalizedErrorMixin and existing widget tests stay stable.

### Decision 5 — `SplitLine` moves with the draft; ViewModel re-exports if needed

`record_transaction_view.dart` imports `SplitLine` via the ViewModel file today. Move `SplitLine` to the draft file; ViewModel file exports it (`export '...record_transaction_draft.dart' show SplitLine;`) so the view import path can stay unchanged, or update the view import in the same change. Prefer updating the view import to the domain module (cleaner).

## Risks / Trade-offs

- **[Risk]** Catalog snapshot lag if a getter is read before the VM updates the draft → **Mitigation:** update draft in the same listen callback before `notifyListeners()`, identical timing to today.
- **[Risk]** Subtle behavior drift in collapse-to-single or direction-change category clearing → **Mitigation:** port logic literally; keep existing ViewModel tests for those behaviors; add domain unit tests for remainder / FX / shortcuts.
- **[Trade-off]** Draft holds Account/Payee lists (domain models already known to domain) — fine; still no Drift.

## Migration Plan

1. Add `record_transaction_draft.dart` + unit tests for remainder, FX, shortcuts, split expand/collapse, direction clears.
2. Wire ViewModel to own a draft; forward public getters/setters; delete inlined implementations.
3. Update view import for `SplitLine` if needed.
4. Thin ViewModel tests that only re-assert draft math; keep submit/orchestration tests.
5. Rollback = revert; no schema change.

## Open Questions

- None blocking. Correction ViewModel twin filtering left for a later cycle.
