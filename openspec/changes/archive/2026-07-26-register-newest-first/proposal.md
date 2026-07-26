## Why

The account register currently lists entries oldest-first: `LedgerRepository.watchEntries()` orders ascending by transaction date, and `RegisterViewModel` accumulates the running balance in that same order and exposes it unreversed. The visible effect is that a newly recorded entry - and the current balance, which only appears on the last row - lands at the bottom of the list, off-screen until the user scrolls. Users expect the newest activity and the current balance to be immediately visible at the top, without scrolling, matching how bank and card statements are normally read.

## What Changes

- Reverse the display order of the register's rows so the most recently recorded entry appears first (top of the list), and the oldest appears last.
- The topmost row's running balance is therefore the account's current balance - visible without scrolling.
- The running balance math itself is unchanged (still accumulated oldest-to-newest internally, so each row's balance is correct); only the order the computed rows are exposed/rendered in changes.
- No change to how entries are recorded, reversed, or to any other screen's ordering (e.g. Home, Accounts) - scoped to the account register list only.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `core-ledger-single-account`: the register's entry list display order changes from oldest-first to newest-first.

## Impact

- `lib/ui/features/register/view_models/register_view_model.dart`: `_recompute` continues to accumulate the running balance oldest-to-newest, then exposes `_rows` reversed (newest first).
- `lib/ui/features/register/views/register_view.dart`: no change expected - it already just renders `viewModel.rows` in order via `ListView.builder`.
- Existing tests asserting on `rows[0]`/`rows[1]` order in `test/ui/features/register/view_models/register_view_model_test.dart` need updating to the new newest-first order.
