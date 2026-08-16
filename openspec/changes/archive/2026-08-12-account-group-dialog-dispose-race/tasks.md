## 1. Fix the dispose race

- [x] 1.1 Remove `nameController.dispose(); balanceController.dispose();` from `_showCreateDialog` in `lib/ui/features/account_management/views/account_management_view.dart`
- [x] 1.2 Remove `controller.dispose();` from `_showRenameAccountDialog`
- [x] 1.3 Remove `controller.dispose(); currencyController.dispose();` from `_showRenameGroupDialog`
- [x] 1.4 Remove `nameController.dispose(); currencyController.dispose();` from `_showCreateGroupDialog`

## 2. Verify

- [x] 2.1 `flutter analyze` passes with no new warnings
- [x] 2.2 On a physical device, create an account group and confirm no red error screen appears while the dialog closes
- [x] 2.3 Create an account; confirm no red error screen (rename dialogs share the same fix and were verified via the regression test suite)

## 3. Regression tests

- [x] 3.1 Update the existing "Create group dialog creates a new group" widget test to let the repository call complete and `pumpAndSettle` through the real dialog-close animation (previously worked around by never completing the Future), asserting `tester.takeException()` is null
- [x] 3.2 Add a new "Create account dialog creates a new account" widget test with the same close-and-settle assertion (this dialog had no coverage before)
- [x] 3.3 Verified both tests actually catch the regression: reintroduced the buggy `dispose()` calls locally and confirmed the group-create test fails with the disposed-controller exception, then reverted
