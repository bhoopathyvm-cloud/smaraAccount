## Why

On the holdings screen for a non-USD investment account, **Market estimate**
shows the book cost and every instrument's **Unrealized** shows 0.00, even
when the instrument has a ticker that a market-data provider can price.
Observed on-device: a CHF "shares" account holding 1000 units of "ubs"
(ticker `ubsg`, cost 1.00 CHF) shows Book 5,000.00 CHF, Market estimate
5,000.00 CHF, Unrealized 0.00 CHF, "Using cost (no price)".

Root cause: **Stooq — the default quote provider — hardcodes every quote's
currency to `USD`** (`instrument_quote_service.dart` `_fetchStooq` returns
`FetchedQuote(priceMinor: (close * 100).round(), currency: 'USD')`), and also
hardcodes 2-decimal (`* 100`) minor-unit scaling. The valuation layer's
currency guard (`quoteIsUsable`: `quote.currency == groupCurrency`) then
rejects that quote for any account whose currency is not USD, so
`marketValueMinor` falls back to `totalCostMinor` and
`unrealizedGainLossMinor = marketValueMinor - totalCostMinor` collapses to 0.
The Yahoo provider reads the real currency and digit count from its
response and is unaffected; Stooq's light CSV has no currency field.

So "market estimate not displayed correctly" and "unrealized not correctly
calculated" are one bug: the Stooq quote is silently unusable for non-USD
holdings.

## What Changes

- **Stooq quote currency is inferred from the symbol's market suffix**
  (`ubsg.ch` → CHF, `.de`/`.fr`/`.nl`/… → EUR, `.uk` → GBP, `.jp` → JPY,
  `.hk` → HKD, `.us` or no suffix → USD, …). Minor-unit scaling then uses
  `minorUnitDigitsForCurrency` for that currency instead of a hardcoded
  `* 100`, matching the Yahoo path.
- When the suffix is present but not in the map, `_fetchStooq` returns
  `null` (no quote) rather than guessing a currency — an unknown market is
  treated as "no price", not as a silent mismatch.
- The holdings row distinguishes **currency mismatch** from **no quote**: a
  quote that came back in a currency that cannot be reconciled with the
  account's currency shows the existing `quoteUseCurrencyMismatch` label
  (already defined) instead of the generic "using cost (no price)", so the
  user can tell a wrong-market ticker (`ubs` / `ubsg` for a Swiss account)
  from a genuinely unpriceable one.
- Tests: unit tests for the Stooq suffix→currency/scale mapping; an
  **integration test** that reproduces the on-device scenario (CHF account,
  `ubsg.ch`, 1000 units at 1.00 cost, injected quote 25.00 CHF) and asserts
  Market estimate = 25,000.00 CHF over the holding and Unrealized =
  +24,000.00 CHF — not the cost fallback.

## Capabilities

### Modified Capabilities

- `investment-holdings`: the "Background Market Prices" requirement gains
  currency handling — a fetched price is interpreted in the currency the
  provider reports or, when the provider reports none, the currency implied
  by the instrument's market symbol; a price whose currency cannot be
  reconciled with the account currency is treated as a missing quote and
  labeled distinctly, not shown as cost without explanation.

## Impact

- `lib/data/instrument_quote_service.dart` (`_fetchStooq`: currency + scale;
  a small market-suffix → ISO-currency map).
- `lib/ui/features/holdings/views/holdings_view.dart` /
  `holdings_view_model.dart` (surface `currencyMismatch` distinctly).
- `lib/l10n/*` only if the mismatch string needs wording tweaks (key exists).
- `test/data/instrument_quote_service_test.dart` (new unit tests).
- `integration_test/` — new holdings valuation integration test with an
  injected `InstrumentQuoteService`.
- No change to how trades post, to the currency guard itself, or to the
  Yahoo provider.
