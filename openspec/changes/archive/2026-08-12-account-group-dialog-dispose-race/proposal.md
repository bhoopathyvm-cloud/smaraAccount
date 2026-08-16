## Why

Creating an account group (and, less reliably, creating/renaming accounts) on a
physical device crashes to Flutter's red error screen with `A
TextEditingController was used after being disposed.` Reproduced live via
`flutter run` on an iPhone. The app is otherwise unusable for this flow until
this is fixed.

## What Changes

- Remove the premature manual `.dispose()` calls on locally-scoped
  `TextEditingController`s in `AccountManagementView`'s dialog methods
  (`_showCreateDialog`, `_showRenameAccountDialog`, `_showRenameGroupDialog`,
  `_showCreateGroupDialog`).
- No user-visible behavior changes; this only removes a crash.

## Capabilities

### New Capabilities
- `account-management-ui`: Account/group management dialogs (create account,
  create group, rename account, rename group) must not crash when dismissed.

### Modified Capabilities

(none)

## Impact

- `lib/ui/features/account_management/views/account_management_view.dart`
- No API, schema, or dependency changes.
