## Tasks

- [x] 2.1 `RegisterRowTile`'s dead `onReverse` field replaced with a real `onTap` wired through an `InkWell`; `RegisterView` exposes `onFixEntry`, wired in `app_router.dart` to a new pushed `/fix` route (`CorrectionView`). Only rows `RegisterViewModel.isRowFixable` accepts (ordinary, verified, non-reversal category transactions - not transfers or opening balances) get a tap target at all.
- [x] 2.2 `CorrectionViewModel` (lib/ui/features/correction_wizard/): prefilled from the original entry's fields, `fix()` calls `reverseEntry` then `recordTransaction` (not wrapped in a single atomic repository call, per this change's own design.md decision - if the second call fails, the reversal already posted safely and the user re-enters the replacement by hand).
- [x] 2.3 `CorrectionView`'s intro banner explains the old line stays and a correction is added, in household voice (no "reversal"/"journal entry").
- [x] 2.4 Added `RegisterViewModel.isRowFixable` unit tests, `CorrectionViewModel` unit tests (prefill, direction-changes-clear-category, fix() success and failure), and `RegisterView` widget tests (tapping a fixable row invokes `onFixEntry`; a transfer row has no tap target at all).
- [x] 2.5 User guide Register section rewritten to describe the actual Fix flow (prefilled form, not a bare instant reversal).
