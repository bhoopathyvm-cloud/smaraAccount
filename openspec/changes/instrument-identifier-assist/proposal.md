## Why

Market estimate and unrealized gain/loss are wrong on the holdings screen
whenever the instrument's identifier doesn't resolve to a quote in the
account's currency — the on-device case was a CHF account holding "ubs"
with ticker `ubsg` (needs `ubsg.ch`), which produced no quote at all, so
Market estimate fell back to book and every Unrealized showed 0.00.
`market-quote-currency` makes the quote loop honest about currency once a
quote arrives; this change stops the bad identifier from being entered in
the first place, and turns whatever the user types into the exact symbol
the quote provider wants.

Today the Add-instrument form has bare `Ticker (optional)` / `ISIN
(optional)` text fields with no validation, no help finding the right
value, and no check that what was entered can actually be priced.

## What Changes

- **"Look it up" action on the Add-instrument form**, after the Name field:
  opens the user's already-chosen favourite AI tool (the
  `investment-research-enablement` machinery) with an *identify* prompt —
  "give me the ISIN, primary exchange, ticker, trading currency, and Yahoo
  symbol for «{name}»" — or copies it when offline. No new API, no key.
- **Offline identifier validation at entry:**
  - ISIN is checked for structure (12 chars, `AA` + 9 alnum + digit) and its
    **mod-10 check digit**. A structurally impossible ISIN blocks save; a
    well-formed ISIN whose check digit fails shows a "looks mistyped"
    warning but does not block.
  - If the instrument's currency can be inferred (ISIN country, ticker
    market suffix, or the default exchange) and differs from the investment
    account's currency, an inline warning explains that automatic quotes
    won't match and points at the right listing.
- **A predefined exchange registry + a "Default exchange" setting.** Each
  registry entry carries a display name, MIC, Yahoo suffix, currency, and an
  optional national fallback quote endpoint. The setting is seeded with ~20
  major world exchanges, defaults from the device region on first run, and
  is user-changeable. It is a fixed list (code change to extend) — no custom
  entry, matching the quote-provider and research-tool settings.
- **Resolve on Save.** When the form is saved and the device is online, the
  system searches Yahoo (by ISIN when present, else ticker, biased to the
  default exchange) and shows the candidate listing(s) — display name,
  exchange, currency — for the user to **confirm** (the default-exchange
  match is pre-selected; nothing is auto-committed). On confirm, the
  instrument stores a **canonical market symbol** and exchange alongside the
  raw ticker/ISIN. Offline or no result: the instrument saves with what was
  typed and resolution is retried on the next quote refresh.
- **Market-price fetching prefers the resolved canonical symbol** over the
  raw ticker; the national fallback endpoint for the resolved exchange is
  tried when the primary provider returns nothing.

## Capabilities

### New Capabilities

- `instrument-identifier-assist`: help the user enter a correct, priceable
  instrument identifier — a look-up prompt, offline ISIN/currency
  validation, a Default-exchange setting backed by a predefined exchange
  registry, and a Save-time resolve-and-confirm that stores the canonical
  market symbol.

### Modified Capabilities

- `investment-holdings`: instrument identity may additionally carry a
  resolved canonical market symbol and exchange; background market-price
  fetching uses that resolved symbol in preference to the raw ticker, and
  may fall back to the resolved exchange's national endpoint. No change to
  how lots, cost, quantity, buy/sell/dividend, or the existing quote
  scenarios behave.

## Impact

- `lib/domain/models/instrument.dart` + Drift `instruments` table — new
  optional `resolvedSymbol` / `exchange` columns (migration).
- `lib/ui/features/holdings/views/holdings_view.dart` — Add-instrument
  dialog: look-up button, validation messages, the confirm step.
- `lib/data/instrument_quote_service.dart` /
  `instrument_quote_refresh.dart` — use resolved symbol; national fallback.
- New `lib/domain/investment/exchange_registry.dart` (the predefined list)
  and a `defaultExchange` settings key.
- `lib/ui/features/settings/` — the Default-exchange dropdown.
- New Yahoo *search* call (identifier → candidates); a new outbound request
  type that sends only the typed identifier, on Save only.
- `lib/l10n/*` — new strings (look-up button, warnings, confirm dialog,
  exchange names may stay untranslated proper nouns).
- Companion to `market-quote-currency` (quote-side currency plumbing +
  Stooq/manual/offline fallback); no file overlap expected beyond the quote
  service.
