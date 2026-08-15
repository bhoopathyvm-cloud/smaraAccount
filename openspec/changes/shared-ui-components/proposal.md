## Why

The claim checks out: several UI patterns are copy-pasted rather than
shared. Concretely (file:line evidence gathered directly from the
codebase, not assumed):

- **Confirm-destructive-action dialog**: `account_management_view.dart`'s
  `_confirmArchiveGroup` (line 356) and `_confirmArchive` (line 453) are
  byte-for-byte identical in structure — title, message, Cancel button,
  and an `OutlinedButton.styleFrom(foregroundColor: AppColors.signal,
  side: BorderSide(color: AppColors.signal))`-styled destructive button —
  differing only in the title/message text and which repository call
  fires. The same `OutlinedButton.styleFrom` block is copy-pasted a third
  time in `category_management_view.dart` (line 147), whose own comment
  already calls this "the design system's destructive-button pattern"
  without it actually being one reusable widget.
- **Money amount input field**: the exact shape (`TextField` +
  `TextInputType.numberWithOptions(decimal: true)` + a currency
  `suffixText` + `double.tryParse` → `(amount * 100).round()` minor-unit
  conversion in `onChanged`) is repeated at 7+ call sites across
  `transfer_view.dart` (3x: amount, destination amount, fee),
  `record_transaction_view.dart` (2x), `settle_pending_transfer_view.dart`,
  and `account_management_view.dart`. The minor-unit parsing logic itself
  — not just the widget markup — is duplicated inline in each callback.
- **Entity-picker dropdown**: `DropdownButtonFormField<String>` built from
  `for (final x in list) DropdownMenuItem(value: x.id, child: Text(x.name))`
  appears at 10+ call sites across `register_view.dart`,
  `summary_view.dart`, `transfer_view.dart` (3x), `account_management_view.dart`
  (2x), `record_transaction_view.dart` (2x), and
  `settle_pending_transfer_view.dart` — picking an account or a category by
  id, styled identically each time.
- **Error/status banner**: `MaterialBanner` showing a `viewModel.errorMessage`
  (or similar) is repeated in `account_management_view.dart` and
  `statement_import_view.dart`.

Beyond the current duplication, there is currently no stated rule against
adding a fifth copy of any of these the next time a screen needs one —
`Specs/architecture/smara-tech-guidelines.md`'s Golden Rules cover
dependency duplication (#8) but not UI component duplication.

## What Changes

- Add four shared widgets under `lib/ui/core/` (flat, matching the
  existing `app_colors.dart`/`app_spacing.dart`/`money_formatter.dart`
  convention — no new subfolder): a destructive-confirmation dialog
  helper, a money-amount input field, an entity-picker dropdown, and an
  error/status banner.
- Replace every identified duplicated call site (listed above) with the
  new shared widget in this same change — per Golden Rule #9, a
  replacement doesn't leave the old copies behind.
- Add unit/widget tests for each new shared widget, and keep each
  migrated view's existing tests passing unchanged (behavior doesn't
  change, only where the markup lives).
- Add a new Golden Rule to `Specs/architecture/smara-tech-guidelines.md`:
  before writing a new dialog/input/picker/banner, check
  `lib/ui/core/widgets/` for an existing one to reuse or extend first.

## Capabilities

### New Capabilities
- `shared-ui-components`: a small set of reusable widgets for
  destructive-action confirmation, money amount entry, entity picking,
  and status banners, used consistently everywhere that shape of UI
  appears, instead of being reimplemented per screen.

### Modified Capabilities

(none — this is a UI-layer refactor; no screen's user-facing behavior
changes, only where its markup is implemented)

## Impact

- New: `lib/ui/core/confirm_destructive_dialog.dart`,
  `money_amount_field.dart`, `entity_picker_field.dart`,
  `status_banner.dart` (final names decided in design.md)
- Modified: `account_management_view.dart`, `category_management_view.dart`,
  `transfer_view.dart`, `record_transaction_view.dart`,
  `settle_pending_transfer_view.dart`, `register_view.dart`,
  `summary_view.dart`, `statement_import_view.dart`
- Modified: `Specs/architecture/smara-tech-guidelines.md` (new Golden Rule)
- New widget tests under `test/ui/core/widgets/`; existing view tests
  should continue to pass without behavioral changes
