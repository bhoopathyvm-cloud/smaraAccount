## Why

After `unify-register-projection`, register row *projection* is deep, but “is this row Fixable?” and client-side search/filter (including amount text) remain ViewModel policy. Tests need a full ChangeNotifier + mocks; router/view must trust VM methods. Architecture review cycle 5.

## What Changes

- Add Flutter-free `lib/domain/register/register_row_policy.dart` with `isRegisterRowFixable` and `filterRegisterRows`.
- `RegisterViewModel` forwards to those helpers; injects amount formatting into the filter via a callback so domain stays free of UI formatters.
- Preserve Fix and search/filter behavior.

## Capabilities

### New Capabilities
- `register-row-policy`: fixability and client-side register filter rules as a Flutter-free module.

### Modified Capabilities
- (none)

## Impact

- `lib/ui/features/register/view_models/register_view_model.dart`
- New domain module + unit tests
