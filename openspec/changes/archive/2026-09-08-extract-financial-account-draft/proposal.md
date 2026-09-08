# Proposal: extract-financial-account-draft

## Why
The create-financial-account dialog is the last account/money form still holding its in-progress state as scattered `StatefulBuilder` locals (`type`, `groupId`, `openingBalanceMinor`, `isCreditCard`, `holdsInvestments`) with the type→group→flags coupling rules inline in the View. Architecture cycle 16 continues the draft pattern (`RecordTransactionDraft`, `TransferOrderDraft`, `CorrectionDraft`, `RecurringTemplateDraft`).

## What Changes
- Add Flutter-free `lib/domain/account/financial_account_draft.dart` with mutable `FinancialAccountDraft`: type, group, opening balance, the two create-time-only flags, plus `hasSelectedGroup`, `selectedGroupCurrency(groupsForType)`, `ensureValidGroupSelection(groupsForType)`, and `setType()`.
- `AccountManagementView`'s create dialog owns one draft instead of five locals; it still reads the type-filtered group list from the ViewModel's existing `groupsAvailableForType` seam and passes it into the draft, so the type-filter rule keeps its one home.
- The ViewModel keeps `createAccount` orchestration.
- Structure-only: field visibility, submit gating, and posting behavior unchanged.

## Impact
- Spec: new `financial-account-draft` capability.
- Callers: create-account dialog only; product behavior unchanged. No Drift schema change; no ADR 0002 conflict (leaf domain module).
