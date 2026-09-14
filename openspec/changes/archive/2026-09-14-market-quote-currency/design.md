## Context

`InstrumentQuoteRefresh.refresh` calls `InstrumentQuoteService.fetchQuote`,
which dispatches to `_fetchStooq` or `_fetchYahoo` by the selected provider
(`QuoteProvider.values.first` = **Stooq** is the default). The fetched
`{priceMinor, currency}` is cached as an `InstrumentQuote`. Valuation
(`investment_holdings_logic.dart`):

- `quoteIsUsable(quote, groupCurrency)` = `quote != null && quote.currency ==
  groupCurrency`.
- `valueHolding`: `marketValueMinor = canUsePrice ?
  multiplyScaledQuantityPrice(quantityScaled, quote.priceMinor) :
  totalCostMinor`, and `unrealizedGainLossMinor = marketValueMinor -
  totalCostMinor`.
- `quoteUseFor`: quote in a different currency → `currencyMismatch`; no
  usable quote → `missing`/`disabled`.

`_fetchYahoo` reads `meta.currency` and scales by
`minorUnitDigitsForCurrency`. `_fetchStooq` hardcodes `currency: 'USD'` and
`* 100`. Stooq's `q/l/` CSV (`f=sd2t2ohlcv`) genuinely carries no currency
column, but Stooq symbols encode the market: `ticker.<mic>` — `.ch` SIX,
`.de`/`.fr`/`.nl`/`.be`/… Euronext/XETRA, `.uk` LSE, `.jp` Tokyo, `.hk`
HKEX, `.us` / no suffix US.

The multiplication math is correct once a same-currency quote survives the
guard (verified: 1000 units × 25.00 CHF → marketValueMinor 2,500,000 =
25,000.00 CHF; unrealized 2,500,000 − 100,000 = 2,400,000 = +24,000.00 CHF).
Nothing else in the unrealized path is wrong — the fix is to stop
discarding the quote.

## Goals / Non-Goals

**Goals:**
- Stooq quotes are usable for non-USD accounts.
- The user can distinguish "wrong-market ticker" from "no price at all".
- Deterministic, offline-testable mapping — no dependency on a currency the
  provider does not return.

**Non-Goals:**
- FX-converting a foreign-currency quote into the account currency. The
  spec (`investment-holdings` line ~181) says trades post in the account's
  own currency and the app performs no conversion; quotes follow the same
  rule — a genuinely foreign quote stays a mismatch, not a conversion.
- Changing the currency guard, the Yahoo path, or the multiplication.
- Guessing a currency for a Stooq symbol whose suffix we do not recognise.
- Auto-appending a market suffix to the user's ticker.

## Decisions

### 1. Stooq currency from a symbol-suffix → ISO-4217 map

A small `const` map from Stooq market suffix to currency, e.g. `ch→CHF`,
`de→EUR`, `fr→EUR`, `nl→EUR`, `be→EUR`, `es→EUR`, `it→EUR`, `pt→EUR`,
`uk→GBP`, `us→USD`, `jp→JPY`, `hk→HKD`, `ca→CAD`, `au→AUD`. Suffix taken as
the substring after the last `.` in the (lowercased) symbol.

- No `.` → US listing → `USD` (Stooq's convention for bare tickers).
- Suffix in the map → that currency; scale by `minorUnitDigitsForCurrency`.
- Suffix **not** in the map → return `null` (treated as no quote).

**Alternatives considered:**
- *Assume the price is already in the account's group currency.* Rejected:
  silently mis-values a US ticker held in a CHF account, exactly the class
  of error the currency guard exists to prevent.
- *Add a per-instrument "quote currency" field the user sets.* Heavier, and
  the suffix already carries the market unambiguously for Stooq.
- *Switch the default provider to Yahoo.* Out of scope; Yahoo's chart API
  has its own reliability/ToS considerations and both providers should work.

### 2. Surface `currencyMismatch` distinctly in the holdings row

`_HoldingRow` already renders `quoteUseLabel(l10n, quoteUse)`; the
`quoteUseCurrencyMismatch` string exists. Ensure `displayQuoteUse` /
`quoteUseFor` returns `currencyMismatch` (not `missing`) whenever a quote
was fetched but its currency ≠ the account currency, so the row reads
"…using cost · quote is in another currency" rather than "…using cost (no
price)". No behavioural change to the number shown (still cost), only the
explanation.

### 3. Test seam for an acceptance-tier check (optional)

`HoldingsViewModel` / `HomeViewModel` already accept an
`InstrumentQuoteRefresh`, and `InstrumentQuoteRefresh` accepts an
`InstrumentQuoteService`, so widget/integration tests can inject a fake
service directly. For a full-app acceptance test, add a `@visibleForTesting`
static `http.Client` (or `FetchedQuote`) hook on `InstrumentQuoteService`
so the real `main.dart` graph can be driven without a live network. The
integration test in this change uses the constructor seam; the acceptance
hook is a follow-up if the acceptance suite wants to cover it.

## Risks / Trade-offs

- **[Risk]** The suffix map is incomplete for some exchange. →
  **Mitigation:** unknown suffix → `null` (no quote), never a wrong
  currency; the map is a `const` that is cheap to extend.
- **[Risk]** A user enters `ubsg` (no suffix) for a Swiss account and still
  sees cost. → **Mitigation:** the row now says "quote is in another
  currency", which points at the ticker; a future change could hint the
  `.ch` suffix on the instrument form.
- **[Trade-off]** Stooq minor-unit digits now depend on the inferred
  currency; a wrong inference would misscale. Bounded by the same
  known-suffix-only rule.

## Migration Plan

1. Add the suffix→currency map + helper in `instrument_quote_service.dart`;
   use it in `_fetchStooq` for both currency and scale; unknown suffix →
   `null`.
2. Confirm `quoteUseFor` yields `currencyMismatch` for fetched-but-foreign
   quotes and the row renders that label.
3. Unit tests for the mapping and scaling.
4. Integration test: CHF account + `ubsg.ch` + injected 25.00 CHF quote →
   assert Market estimate and Unrealized.
5. `flutter test`; re-check on the Android device with a real `ubsg.ch`.
6. Rollback = revert `_fetchStooq` and the row-label change.

## Open Questions

- Should a bare (suffixless) non-US ticker be `USD` (Stooq convention, and
  what this design assumes) or `null`? Leaning `USD` to keep US tickers
  working with no suffix, accepting that non-US bare tickers will read as a
  currency mismatch.
