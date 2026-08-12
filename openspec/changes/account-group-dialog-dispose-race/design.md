## Context

`AccountManagementView` (`lib/ui/features/account_management/views/account_management_view.dart`)
is a `StatelessWidget`. Its four dialog methods (`_showCreateDialog`,
`_showRenameAccountDialog`, `_showRenameGroupDialog`,
`_showCreateGroupDialog`) each follow the same pattern:

```dart
final controller = TextEditingController();
await showDialog<void>(
  context: context,
  builder: (dialogContext) => AlertDialog(/* TextField(controller: controller) */),
);
controller.dispose();
```

`showDialog`'s returned `Future` resolves as soon as `Navigator.pop()` is
called inside the dialog, but the `AlertDialog`'s exit transition (a fade,
~150ms by default) keeps the dialog's widget subtree mounted and rebuilding
for several more animation frames after that. Reproduced live on a physical
iPhone via `flutter run`: creating an account group threw `A
TextEditingController was used after being disposed.` from
`EditableText`/`RawGestureDetector`'s `didUpdateWidget`, with the app falling
back to Flutter's red error screen.

Sequence that triggers it:
1. User taps "Create" in `_showCreateGroupDialog`.
2. The button's `onPressed` awaits `viewModel.createGroup(...)`, then calls
   `Navigator.of(dialogContext).pop()`.
3. `await showDialog(...)` in `_showCreateGroupDialog` resolves immediately.
4. `nameController.dispose(); currencyController.dispose();` run synchronously
   next line.
5. The dialog is still fading out (and/or the keyboard is still animating
   closed, per the `TUIKeyboardContentView` autolayout warnings seen right
   before the crash in the logs) — another frame rebuilds the still-mounted
   `TextField`, which calls `addListener` on the now-disposed controller.

## Goals / Non-Goals

**Goals:**
- Eliminate the crash without changing any user-visible behavior of the
  create/rename dialogs.
- Keep the fix minimal and localized to the four affected methods.

**Non-Goals:**
- Refactoring these dialogs into `StatefulWidget`s with framework-managed
  controller lifecycles. That would also fix the race (Flutter only calls
  `State.dispose()` after the widget is actually unmounted, post-animation),
  but it's a larger structural change than this crash-only fix warrants.

## Decisions

- **Remove the manual `.dispose()` calls** on these dialog-local controllers
  rather than deferring them (e.g. via `addPostFrameCallback` or a fixed
  delay).
  - These controllers are local variables, not held by any `State` object,
    and the app never registers listeners on them directly (only the
    `TextField` itself does, and it detaches its own listener when its
    `Element` is actually disposed). Once the dialog route and its closures
    are discarded, the controller becomes unreachable and is reclaimed by
    the garbage collector like any other object.
  - A `postFrameCallback` delay was considered and rejected: the exit
    transition can span more than one frame, so a single deferred callback
    doesn't reliably close the race — it would just narrow the window
    without eliminating it.

## Risks / Trade-offs

- [Skipping `dispose()` looks like it violates the "always dispose
  controllers" convention used elsewhere in the codebase (e.g.
  `record_transaction_view.dart`, `transfer_view.dart`).] → Mitigation: those
  other controllers are `State` fields disposed in `State.dispose()`, which
  is a different (safe) lifecycle. Leave a short comment at each removed
  call site's former location is unnecessary noise; the fix is scoped to
  this one file's dialog-local controllers only.
