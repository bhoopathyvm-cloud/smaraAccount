## Why

Home overview assembly (~130 lines of group sections, net positions, pending inclusion) still lives on `LedgerRepository` after posting extraction. Investment portfolio cash+inventory folds are duplicated between Home (`_portfolioForInvestmentAccount`) and HoldingsViewModel. Architecture review cycle 4: extract a deep overview module so net-position and pending-inclusion rules have locality, and share the portfolio fold.

## What Changes

- Add Flutter-free `lib/domain/home/home_overview_engine.dart` with `investmentPortfolioTotals` and `buildHomeOverview`.
- `LedgerRepository._buildHomeOverview` loads inputs (groups, accounts, entries, pending, holdings) and calls the engine.
- `HoldingsViewModel` uses `investmentPortfolioTotals` for book/portfolio getters.
- Preserve pending quarantine exclusion and Option A display balances.

## Capabilities

### New Capabilities
- `home-overview-engine`: domain module assembling HomeOverview from chart + balances + pending inputs + investment portfolio totals.

### Modified Capabilities
- (none)

## Impact

- `lib/data/repositories/ledger_repository.dart`
- `lib/ui/features/holdings/view_models/holdings_view_model.dart`
- New domain module + unit tests
- ADR 0002: no new repository cycles
