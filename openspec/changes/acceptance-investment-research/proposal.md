## Why

Tap-to-browser instrument research has shipped
(`investment-research-enablement`), but the only GUI coverage is an
isolated `HoldingsView` widget test with a mocked launcher. There is no
full-app journey that creates an investment account, records a holding,
picks a favourite tool in Settings, and taps the instrument name on the
real build. The in-progress `acceptance-test-suite` change does not
list this capability.

## What Changes

- Add a new **acceptance** capability group for research enablement,
  reusing the real-build harness and the investment-account helpers
  introduced by `acceptance-investment-holdings`.
- Drive the real GUI through: Settings favourite-tool picker (fixed
  predefined list, no API key / custom URL), tapping an instrument name
  on holdings, and asserting the launched URL (or clipboard fallback)
  contains identifiers and research asks without quantity, cost, or
  account name.
- Do **not** change any shipped product behavior, CI, or dependencies.

## Capabilities

### New Capabilities
- `acceptance-investment-research`: real-build, GUI-driven acceptance
  coverage of favourite-tool selection and tap-to-browser research from
  the holdings inventory.

### Modified Capabilities
(none — this adds a testing group; `investment-research-enablement`
product requirements stay unchanged)

## Impact

- **Affected code**: new
  `integration_test/acceptance/investment_research_test.dart`. May add a
  small test seam on `HoldingsViewModel.launchUrlFn` only if the real
  `url_launcher` call cannot be asserted in-process; prefer observing
  clipboard fallback if the live binding cannot intercept the browser.
- **Docs**: none beyond this change's artifacts.
- **Dependencies**: none.
- **CI**: no changes. Manual-only.
- **Depends on**: `acceptance-investment-holdings` helpers for creating
  an investment account and recording a holding through the GUI. Can be
  implemented after that change's harness helpers land; both remain
  independently runnable test files.
