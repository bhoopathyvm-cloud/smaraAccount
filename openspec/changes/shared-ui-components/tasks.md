## 1. Build the shared widgets

- [x] 1.1 Add `lib/ui/core/destructive_confirmation.dart`: `Future<bool> confirmDestructiveAction({required BuildContext context, required String title, required String message, String confirmLabel = 'Archive'})` and a shared `destructiveButtonStyle` `ButtonStyle` constant per the design system's "Destructive" pattern (1.5px red border, red text, transparent background)
- [x] 1.2 Add `lib/ui/core/money_amount_field.dart`: `MoneyAmountField` widget (controller, labelText, suffixText, helperText, onChangedMinor) that owns the `double.tryParse` → minor-units conversion internally
- [x] 1.3 Add `lib/ui/core/entity_picker_field.dart`: generic `EntityPickerField<T>` widget (labelText, items, idOf, labelOf, value, onChanged, optional key)
- [x] 1.4 Add `lib/ui/core/status_banner.dart`: `StatusBanner` widget (message, onDismiss, isError)

## 2. Migrate destructive-confirmation call sites

- [x] 2.1 `account_management_view.dart`: replace `_confirmArchiveGroup`'s inline `AlertDialog` with `confirmDestructiveAction`
- [x] 2.2 `account_management_view.dart`: replace `_confirmArchive`'s inline `AlertDialog` with `confirmDestructiveAction`
- [x] 2.3 `category_management_view.dart`: replace its inline `OutlinedButton.styleFrom` block with the shared `destructiveButtonStyle`

## 3. Migrate money-amount-field call sites

- [x] 3.1 `transfer_view.dart`: amount, destination amount, and fee amount fields
- [x] 3.2 `record_transaction_view.dart`: amount and account-currency-amount fields
- [x] 3.3 `settle_pending_transfer_view.dart`: its amount field
- [x] 3.4 `account_management_view.dart`: the opening-balance field in the create-account dialog

## 4. Migrate entity-picker call sites

- [x] 4.1 `register_view.dart`: account picker
- [x] 4.2 `summary_view.dart`: account picker
- [x] 4.3 `transfer_view.dart`: from-account, to-account, and fee-category pickers
- [x] 4.4 `account_management_view.dart`: group pickers (create-account dialog and reassign dialog)
- [x] 4.5 `record_transaction_view.dart`: account and category pickers
- [x] 4.6 `settle_pending_transfer_view.dart`: fee/loss category picker

## 5. Migrate status-banner call sites

- [x] 5.1 `account_management_view.dart`: error banner (with Dismiss)
- [x] 5.2 `statement_import_view.dart`: currency-mismatch banner (no Dismiss, error-styled)

## 6. Architectural rule

- [x] 6.1 Add a new numbered Golden Rule to `Specs/architecture/smara-tech-guidelines.md` (after #9): check `lib/ui/core/` for an existing shared widget before implementing a new dialog/input/picker/banner

## 7. Tests

- [x] 7.1 Widget tests for `confirmDestructiveAction` (confirm and cancel paths)
- [x] 7.2 Widget tests for `MoneyAmountField` (valid amount, cleared, unparseable)
- [x] 7.3 Widget tests for `EntityPickerField<T>` (selection reports id, caller-side filtering respected)
- [x] 7.4 Widget tests for `StatusBanner` (with and without dismiss, error vs. default styling)
- [x] 7.5 Re-run every migrated view's existing test file and confirm it still passes unchanged (no behavior regression)

## 8. Verify

- [x] 8.1 `flutter analyze` passes with no new warnings
- [x] 8.2 Full test suite passes
- [x] 8.3 Confirm no leftover copy of any of the four patterns remains outside the shared widgets (grep for `OutlinedButton.styleFrom(\s*foregroundColor: AppColors.signal`, `TextInputType.numberWithOptions(decimal: true)` outside `money_amount_field.dart`, etc.)
