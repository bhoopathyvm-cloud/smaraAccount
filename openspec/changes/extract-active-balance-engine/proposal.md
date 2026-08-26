## Why

Quarantine and migration-supersession exclusion is folded in `displayBalanceMinor`, `_buildHomeOverview`, and `RegisterProjection`. `LedgerPosting` still takes a `displayBalanceMinor` callback into the `LedgerRepository` facade — a shallow adapter left by posting extraction. Changing the rule in one place lets Home disagree with Register.

## What Changes

- Extract a domain `ActiveBalanceEngine`: entries + account types → display balances / raw sums under one exclusion policy.
- Posting injects the engine (or a balance port it owns), not a facade method.
- Home overview and `displayBalanceMinor` consume the engine; register projection keeps sign/labels and uses the same “which entries count” rule.
- Preserve Option A liability sign and current quarantine visibility.

## Capabilities

### New Capabilities
- `active-balance-engine`: one module for which journal entries contribute to display balances and home totals.

### Modified Capabilities
- (none — product quarantine / Option A display-balance requirements unchanged)

## Impact

- `lib/data/repositories/ledger_repository.dart` (`displayBalanceMinor`, `_buildHomeOverview`)
- `lib/data/repositories/ledger_posting.dart` constructor callback
- `lib/domain/register/register_projection.dart` (exclusion alignment)
- Domain unit tests; ledger overview/balance tests
