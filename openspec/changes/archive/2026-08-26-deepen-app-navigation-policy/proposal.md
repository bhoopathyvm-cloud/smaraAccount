## Why

Startup gates (identity, first-entry, key match, chain verify-once, currency backfill, first-week setup, app lock) live in `GoRouter.redirect` (~75 lines). The interface is the whole router: tests cannot exercise gate order without Flutter navigation, and deep links re-evaluate the same closure.

## What Changes

- Extract a deep `AppNavigationPolicy` module: given location + repository/policy snapshots, return the redirect path (or none).
- Keep `GoRouter` as a thin adapter: register routes and call `resolve`.
- Move `AppLockService` / biometric adapter construction out of route builders into the Provider graph.
- Preserve existing onboarding, restore, backfill, setup-wizard, and lock routing.

## Capabilities

### New Capabilities
- `app-navigation-policy`: one module for startup/resume redirect decisions, testable without `GoRouter`.

### Modified Capabilities
- (none — product onboarding/lock/restore routing requirements unchanged)

## Impact

- `lib/ui/app_router.dart`
- `lib/main.dart` providers for lock/biometric adapters
- New unit tests for gate order (no WidgetTester required for the policy itself)
- Spot-check onboarding and app-lock acceptance on macOS
