## 1. Exchange registry + Default-exchange setting

- [x] 1.1 Shipped in `lib/domain/investment/exchange_registry.dart` (merged via PR #130, `97955e8`): a `const` registry of ~20 exchanges (`US, TSX, B3, LSE, SIX, XETRA, XPAR, XAMS, XBRU, XLIS, BIT, BME, ST, HE, CO, ASX, TSE, HKEX, SGX, NSE, BSE, KRX, JSE, TASE`), each with `{code, name, mic, yahooSuffix, currency, nationalEndpoint?}`.
- [x] 1.2 Shipped: `SettingsRepository.defaultExchangeCode()` / `setDefaultExchange()`, persisted, with `kDefaultExchangeCode = 'US'` as the fallback for a stored value not in the current registry.
- [x] 1.3 Shipped: `settings_view.dart`'s Default-exchange dropdown next to the quote-provider control (`l10n.settingsDefaultExchange`), wired through `SettingsViewModel.defaultExchange` / `setDefaultExchange`.
- [x] 1.4 Shipped: `test/domain/investment/exchange_registry_test.dart` and `test/data/repositories/settings_repository_test.dart` (registry lookups, region → default mapping, unknown-value fallback).

## 2. Offline identifier validation

- [x] 2.1 Shipped in `lib/domain/investment/isin.dart` (`validateIsin`, `IsinCheck` enum: structure + mod-10 check digit + ISO-country-prefix).
- [x] 2.2 Shipped in `lib/domain/investment/instrument_currency_inference.dart` (`inferTradingCurrency`, `suffixHintForCurrency`).
- [x] 2.3 Shipped: wired into the Buy dialog's new-instrument fields in `holdings_view.dart` — malformed ISIN blocks Save (`validateIsin(...) == IsinCheck.malformed` gate before `_createResolvedInstrument`), a bad check digit shows `_DialogWarning`, and `_currencyMismatchWarning` shows the mismatch hint.
- [x] 2.4 Shipped: `test/domain/investment/isin_test.dart` and `test/domain/investment/instrument_currency_inference_test.dart`.

## 3. "Look it up" action

- [x] 3.1 Shipped in `lib/domain/investment_research_prompt.dart` (an `identify` prompt template alongside the existing research prompt) — see `test/domain/investment_research_prompt_test.dart`.
- [x] 3.2 Shipped: the look-up `TextButton.icon` under the Name field in the Buy dialog's new-instrument section (`l10n.instrumentLookUp`), calling `_lookUpIdentifiers` → `viewModel.lookUpIdentifiers` (reuses `researchQueryUri` + launch-or-copy).
- [x] 3.3 Covered by `test/domain/investment_research_prompt_test.dart` (prompt content) plus `holdings_view_test.dart`'s existing research-launch tests (stub launcher, launch vs. copy). No dedicated "identify" widget test beyond the prompt-builder unit test was added in the original PR; the launch/copy mechanism itself is already proven by the pre-existing research-button tests it reuses verbatim.

## 4. Resolve on Save + confirm

- [x] 4.1 Shipped: `InstrumentQuoteService.searchIdentifier(String query)` (Yahoo `v1/finance/search`), returning `List<InstrumentCandidate>` (`{name, symbol, exchangeDisplay, currency, exchangeCode?}`).
- [x] 4.2 Shipped: `holdings_view.dart`'s `_confirmListing` bottom sheet (name · exchange · currency radio list, default-exchange match pre-selected via `candidates.firstWhere((c) => c.exchangeCode == defaultExchange.code, orElse: () => candidates.first)`); `_createResolvedInstrument` only calls `createInstrument(resolvedSymbol:, exchange:)` after the sheet returns a confirmed candidate.
- [x] 4.3 Shipped: nullable `resolved_symbol` / `exchange` columns on the `instruments` Drift table, `schemaVersion` bumped to 17 with a migration (no backfill); `Instrument` and `InvestmentRepository.createInstrument` extended. Verified via `test/data/database/app_database_migration_test.dart`.
- [x] 4.4 Shipped: offline/no-result save proceeds with typed values and shows `l10n.resolveDeferredSaved`; `InstrumentQuoteRefresh.refresh`'s `_resolve` retries on the next run and calls `investmentRepository.setInstrumentResolution` to cache the result silently.
- [x] 4.5 Added `integration_test/instrument_identifier_resolve_test.dart` (this session, since the original PR shipped only unit-level coverage for the pieces, not a widget/integration test driving the real confirm-sheet interaction): drives the real Buy dialog end to end for ISIN `CH0244767585` — two listings (CHF/SIX, USD/US) both shown, CHF pre-selected (`RadioGroup.groupValue.symbol == 'UBSG.SW'`) per the Default-exchange setting, and `resolvedSymbol`/`exchange` are persisted to the real database only after tapping Confirm. Passed locally on macOS (`flutter test -d macos integration_test/instrument_identifier_resolve_test.dart`). Found and fixed one real bug while writing it: the test's own fake `fetchQuote` initially answered on every call, which — combined with a cached quote re-triggering the holdings stream — spun in a tight 99%-CPU loop; fixed by delivering the canned quote only once, matching `market_quote_currency_test.dart`'s established pattern for this exact hazard.

## 5. Quote fetch uses the resolved symbol

- [x] 5.1 Shipped: `InstrumentQuoteRefresh.refresh` computes `symbol = resolvedSymbol ?? (ticker ?? isin)` and sends it as `fetchQuote(symbol: ...)`. Also exposed as `Instrument.quoteSymbol` (resolved symbol preferred, else raw ticker).
- [x] 5.2 Shipped: national fallback — `if (fetched == null && endpoint != null && symbol != null) fetched = await _quoteService.fetchNationalQuote(endpoint: endpoint, symbol: symbol)`, using the resolved exchange's `nationalEndpoint`.
- [x] 5.3 Shipped: `test/data/instrument_quote_refresh_test.dart` (refresh prefers resolved symbol; national fallback invoked only on primary miss) and `test/data/instrument_quote_service_test.dart` (search/candidate parsing).

## 6. Verify

- [x] 6.1 Fresh run (this session, post-merge): `flutter analyze` — no issues. `flutter test` — 904/904 passed.
- [x] 6.2 Added as part of task 4.5's new integration test (same file): the exact end-to-end scenario asked for here — create "UBS" in a CHF account with ISIN `CH0244767585`, resolve via a faked search to `UBSG.SW`/SIX/CHF, confirm, and verify the holdings screen's Market estimate (+25,000.00 CHF market contribution) and Unrealized (+24,000.00 CHF) both reflect the CHF quote via `market-quote-currency`'s currency-aware logic (`displayQuoteUse == QuoteUse.live`). The look-up button itself isn't tapped in this test (it only opens an external browser/clipboard, already covered by task 3.3's reused research-launch tests) — the test starts from a typed ISIN, matching what a real look-up's answer would be typed into.
- [ ] 6.3 Cannot verify from this environment: no Android device is connected to this session (only a macOS target, an iOS Simulator, and a wirelessly-connected iPhone were available via `flutter devices` when checked). This step needs a live Android device with real network access to Yahoo, which the original PR's author would need to run by hand.
- [x] 6.4 Re-ran fresh (this session, post-merge) rather than relying on older or indirect evidence: `tool/run_acceptance_tests.sh -d macos investment_holdings` — 12/12 tests passed (3:00 total). `tool/run_acceptance_tests.sh -d macos investment_research` — 2/2 tests passed (0:41 total). Both groups green; no regression from this change.
