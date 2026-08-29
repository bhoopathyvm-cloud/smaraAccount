## 1. Stooq quote currency + scale

- [ ] 1.1 In `lib/data/instrument_quote_service.dart`, add a `const` map from Stooq market suffix to ISO-4217 currency (`ch→CHF`, `de/fr/nl/be/es/it/pt→EUR`, `uk→GBP`, `us→USD`, `jp→JPY`, `hk→HKD`, `ca→CAD`, `au→AUD`) and a helper that returns the currency for a symbol (suffix after the last `.`; no `.` → `USD`; unmapped suffix → `null`)
- [ ] 1.2 In `_fetchStooq`, resolve the currency via that helper; if it is `null`, return `null` (no quote). Otherwise return `FetchedQuote(priceMinor: (close * pow(10, minorUnitDigitsForCurrency(currency))).round(), currency: currency)` — same scaling approach as `_fetchYahoo`
- [ ] 1.3 Leave `_fetchYahoo` unchanged (it already reads `meta.currency` and scales by digits)

## 2. Surface currency mismatch in the holdings row

- [ ] 2.1 Confirm `quoteUseFor` / `HoldingsViewModel.displayQuoteUse` returns `QuoteUse.currencyMismatch` (not `missing`) whenever a quote was fetched but `quote.currency != groupCurrency`, including for cached quotes
- [ ] 2.2 Confirm `_HoldingRow` renders `quoteUseLabel(l10n, QuoteUse.currencyMismatch)` for that case; adjust the `quoteUseCurrencyMismatch` string if its current wording is unclear (e.g. "using cost · quote is in another currency")

## 3. Unit tests

- [ ] 3.1 `test/data/instrument_quote_service_test.dart`: Stooq symbol → currency mapping (`ubsg.ch`→CHF, `sap.de`→EUR, `aapl`→USD, `vod.uk`→GBP, `7203.jp`→JPY, `xxx.zz`→null)
- [ ] 3.2 Stooq price scaling: a CHF close of 25 → `priceMinor` 2500; a JPY close of 3000 → `priceMinor` 3000 (0 digits)
- [ ] 3.3 A Stooq fetch for an unmapped-suffix symbol returns `null`

## 4. Integration test

- [ ] 4.1 Add an integration test (under `integration_test/`) that builds `HoldingsView` + `HoldingsViewModel` for a CHF investment account, with an injected `InstrumentQuoteRefresh(quoteService: <fake>)` whose fake returns `FetchedQuote(priceMinor: 2500, currency: 'CHF')` for the held instrument's ticker
- [ ] 4.2 Seed the account: cash 4000 CHF, one buy of 1000 units of an instrument (ticker `ubsg.ch`) at 1.00 CHF (book cost 1000 CHF) — mirrors the on-device repro
- [ ] 4.3 Assert after a quote refresh: the holding row shows Unrealized +24,000.00 CHF and quote-use label "live" (not "using cost"), and the account **Market estimate** = 29,000.00 CHF (cash 4000 + market 25,000), distinct from **Book** 5,000.00 CHF
- [ ] 4.4 Second case in the same test: fake returns `currency: 'USD'` → Market estimate falls back to Book and the row shows the currency-mismatch label, not "no price"

## 5. Verify

- [ ] 5.1 `flutter analyze` clean; `flutter test` green
- [ ] 5.2 On the Android device: CHF investment account, instrument ticker `ubsg.ch`, enable market-price fetch → Market estimate and Unrealized reflect the live Stooq CHF price, not book cost
- [ ] 5.3 `tool/run_acceptance_tests.sh -d macos` — existing investment-holdings / -research acceptance files still green
