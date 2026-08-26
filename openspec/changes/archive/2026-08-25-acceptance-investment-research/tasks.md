## 1. Setup (depends on holdings helpers)

- [x] 1.1 Confirm `createInvestmentAccountThroughGui` and a cash-funded Buy helper exist on `acceptance_harness.dart` (from `acceptance-investment-holdings`). If this change is applied first, copy those helpers here rather than seeding holdings through the repository.
- [x] 1.2 Create `integration_test/acceptance/investment_research_test.dart` with the same binding, `resetToFreshDevice`, English l10n finders, and 5-minute timeouts as the other acceptance files.

## 2. Settings favourite tool

- [x] 2.1 Scenario: after onboarding, open Settings and assert the favourite-research-tool control lists ChatGPT, Claude, Gemini, and Meta AI.
- [x] 2.2 Assert Settings has no API key field and no arbitrary/custom URL field for research. Select a non-default predefined tool.

## 3. Tap-to-research

- [x] 3.1 Create an investment account, cash-funded Buy of an instrument with a ticker, open holdings.
- [x] 3.2 Tap the instrument name. Observe launch via clipboard (`Clipboard.getData`) and/or an in-process URL capture if `url_launcher` cannot be asserted. Only add a `lib/` capture hook if both fail on macOS (design.md Decision 2).
- [x] 3.3 Assert the prompt/query contains name and ticker, asks for news/downside/upside, forbids a buy/sell recommendation, and omits quantity, cost, and the account name.

## 4. Verification

- [x] 4.1 Run `flutter test integration_test/acceptance/investment_research_test.dart -d macos` and fix until green. The file must not require any other acceptance file to run first.
