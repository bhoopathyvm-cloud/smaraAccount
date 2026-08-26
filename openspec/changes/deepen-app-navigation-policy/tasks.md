## 1. Extract policy

- [x] 1.1 Inventory redirect gates, path constants, and session-once chain verify
- [x] 1.2 Implement `AppNavigationPolicy.resolve` with unit tests for each gate outcome

## 2. Wire router

- [x] 2.1 `GoRouter.redirect` delegates to the policy
- [x] 2.2 Provide lock/biometric adapters from `main.dart`; stop constructing them in route builders

## 3. Verify

- [ ] 3.1 Router/widget tests still green; policy unit tests cover gate order
- [ ] 3.2 Spot-check onboarding + app-lock acceptance on macOS
