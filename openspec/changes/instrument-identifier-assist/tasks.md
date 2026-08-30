## 1. Exchange registry + Default-exchange setting

- [ ] 1.1 Add `lib/domain/investment/exchange_registry.dart` — a `const` list of ~20 exchanges, each `{name, mic, yahooSuffix, currency, nationalEndpoint?}` (US, LSE, SIX, XETRA, Euronext PA/AM/BR/LS, Borsa Italiana, BME, Nasdaq Nordic ST/HE/CO, TSX, ASX, Tokyo, HKEX, SGX, NSE, BSE, KRX, B3, JSE, TASE)
- [ ] 1.2 Add a `defaultExchange` key to `SettingsRepository` with persistence; first-run default derived from the device region, unrecognised stored value falls back to that default
- [ ] 1.3 Add the Default-exchange dropdown to the Settings screen beside the quote-provider control; predefined list only, no custom field
- [ ] 1.4 Unit tests: registry lookups, region → default mapping, unknown-value fallback

## 2. Offline identifier validation

- [ ] 2.1 Add `lib/domain/investment/isin.dart` — structure check + mod-10 check-digit validation + ISO-country-prefix check (pure, no network)
- [ ] 2.2 Add currency inference: ISIN country → currency, ticker suffix → currency, else default-exchange currency
- [ ] 2.3 Wire into the Add-instrument dialog: structural failure disables Save with an error; check-digit failure shows a warning; inferred-currency ≠ account-currency shows the mismatch warning with the corrective listing hint
- [ ] 2.4 Unit tests: valid ISINs pass (`CH0244767585`, `US0378331005`, `IE00B3RBWM25`), transposition/typo fails check digit, `ZZ...` fails country, currency inference cases

## 3. "Look it up" action

- [ ] 3.1 Add an `identify` prompt template beside the existing research prompt in the investment-research prompt builder — asks for ISIN, exchange, ticker, currency, market-data symbol, cross-listings; forbids advice; includes only the typed name
- [ ] 3.2 Add the look-up button under the Name field in the Add-instrument dialog; reuse `researchQueryUri` + launch-or-copy; localized strings
- [ ] 3.3 Widget test: tapping the button with a stub launcher opens the tool with the identify prompt; offline path copies it

## 4. Resolve on Save + confirm

- [ ] 4.1 Add an identifier search to `InstrumentQuoteService` (Yahoo `v1/finance/search`, `?q=<isin|ticker>`) returning candidate `{name, symbol, exchange, currency}`; sends only the identifier
- [ ] 4.2 On Save (online): run the search, show a confirm sheet listing candidates as name · exchange · currency, pre-selecting the default-exchange match; store `resolvedSymbol` + `exchange` only after confirm
- [ ] 4.3 Add nullable `resolvedSymbol` / `exchange` columns to the `instruments` Drift table + migration (no backfill); extend `Instrument` and `createInstrument`
- [ ] 4.4 Offline / no-result: save with typed values; `InstrumentQuoteRefresh` attempts resolution on its next run and caches the result
- [ ] 4.5 Widget/integration test: two-listing ISIN (CHF vs USD) shows both, pre-selects default, stores only on confirm; offline save defers

## 5. Quote fetch uses the resolved symbol

- [ ] 5.1 `InstrumentQuoteRefresh` sends `resolvedSymbol ?? ticker`
- [ ] 5.2 When the primary provider returns null and the resolved exchange has a `nationalEndpoint`, try it once (start with 1–2 endpoints, e.g. NSE, boerse-frankfurt; others left unimplemented)
- [ ] 5.3 Unit tests: refresh prefers resolved symbol; national fallback invoked only on primary miss

## 6. Verify

- [ ] 6.1 `flutter analyze` clean; `flutter test` green
- [ ] 6.2 Integration test end-to-end: create "UBS" in a CHF account → look-up button opens tool → enter ISIN `CH0244767585` → Save resolves to `UBSG.SW` / SIX / CHF → confirm → holdings Market estimate and Unrealized use the CHF quote (with `market-quote-currency` applied)
- [ ] 6.3 On the Android device: repeat the above against live Yahoo; confirm the mismatch warning appears if the NYSE `UBS` listing is chosen instead
- [ ] 6.4 `tool/run_acceptance_tests.sh -d macos` — investment-holdings / -research acceptance still green
