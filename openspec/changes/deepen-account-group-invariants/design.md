## Context

Architecture review (round 2, 2026-08-26) ranked this "Worth exploring": real duplication (the currency-lock rule is checked twice in one dialog method) and a genuine cross-feature invariant (reassignment currency-matching, sourced from `multi-currency-support`'s design doc), but a smaller blast radius than the holdings trade-order draft — each rule is a short, self-contained predicate, not a multi-step session.

## Goals / Non-Goals

**Goals:**
- One definition each for the three inline rules, callable from a unit test without opening a dialog.
- `AccountManagementViewModel` stays a thin orchestration layer plus these three predicates — not a place to grow unrelated logic.

**Non-Goals:**
- Changing which groups/currencies are valid — behavior-preserving only.
- Moving account/group creation or reassignment writes themselves (`AccountRepository.createFinancialAccount` etc.) — those are untouched.
- Touching `finish-chart-catalog-seams`' already-completed currency-catalog work in holdings/correction.

## Decisions

### Decision 1 — Predicates on the ViewModel, not a new domain module

**Options:** (A) A new `lib/domain/account_management/` module; (B) Plain methods on `AccountManagementViewModel`.

**Decision: B.** Each predicate is a short, pure function over `Account`/`AccountGroup` domain models already available on the ViewModel (`accounts`, `groups`) — there's no session/step state like `StatementImportSession` or branching complexity like the holdings trade-order draft that would justify a separate Flutter-free module. Precedent: `AccountRepository`'s own predicates (e.g. `hasActiveAccounts`-shaped checks) already live at the repository/view-model layer elsewhere in this codebase, not in a dedicated domain package.

### Decision 2 — Keep the exception-based guard in `AccountRepository`, add the UI-facing predicate on top

`AccountRepository.changeAccountGroupCurrency` may still reject a currency change server-side (defense in depth). `canChangeGroupCurrency` on the ViewModel is what the View calls to decide what to *show*; it does not replace the repository-side check.

## Risks / Trade-offs

- **[Risk]** `canChangeGroupCurrency`'s definition of "active accounts" drifts from the repository's own guard if the two are edited independently in the future → **Mitigation:** the predicate reads `viewModel.accounts` the same way `hasActiveAccounts` does today (`account.groupId == group.id && !account.archived`); note in the method doc comment that this must match `AccountRepository.changeAccountGroupCurrency`'s guard.
- **[Trade-off]** Three small public methods added to an already-public ViewModel surface — acceptable; each removes a corresponding block of inline widget logic.

## Migration Plan

1. Add the three predicates to `AccountManagementViewModel` with unit tests, ported literally from the current inline logic.
2. Point `_showCreateDialog`, `_showRenameGroupDialog`, `_showReassignDialog` at them; delete the inline `.where()`/`hasActiveAccounts` duplication.
3. Rollback = revert; no data migration.

## Open Questions

- None outstanding.
