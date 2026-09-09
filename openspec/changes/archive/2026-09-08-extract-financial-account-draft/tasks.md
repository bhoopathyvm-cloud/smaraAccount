## 1. Draft module

- [x] 1.1 Add `lib/domain/account/financial_account_draft.dart` (type/group/flags, `selectedGroupCurrency`, `ensureValidGroupSelection`, `setType`); type-filtering stays on the ViewModel seam
- [x] 1.2 Domain unit tests (`test/domain/account/financial_account_draft_test.dart`): auto-select, currency, type-switch clears flags

## 2. Wire the create dialog

- [x] 2.1 `AccountManagementView` create dialog owns one draft, deletes the five scattered locals
- [x] 2.2 Preserve submit gating (group selected; name checked in handler) and posting call

## 3. Verify

- [x] 3.1 `dart analyze` clean; new domain tests green
- [x] 3.2 Existing account-management widget + ViewModel tests green
- [x] 3.3 Linux acceptance `organization` group green
