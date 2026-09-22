## Context

The Add-instrument dialog (`holdings_view.dart` ~line 240–445) has
`Name`, `Kind`, `Ticker (optional)`, `ISIN (optional)` fields feeding
`createInstrument`. `Instrument` (`lib/domain/models/instrument.dart`) is
`{id, name, kind, ticker?, isin?, archived}`. `InstrumentQuoteRefresh`
sends `instrument.ticker` (or `isin`) to the selected provider;
`_fetchStooq` / `_fetchYahoo` return `{priceMinor, currency}`, and
`quoteIsUsable` requires `quote.currency == groupCurrency`. Yahoo reports
currency; Stooq does not.

The app already has the "hand the user a prompt and a link" pattern
(`investment-research-enablement`: fixed tool list, `researchQueryUri`,
launch-or-copy, no API key) and the "fixed predefined provider list, no
custom URL/key" pattern (`reference-exchange-rate-lookup`,
quote-provider setting).

This design is the outcome of an exploration that ruled out: a resurrected
Google Finance API (dead since 2012), a single free global keyless
quote+search source (does not exist for equities), and forcing ISIN-first
entry (US users are ticker-native).

## Goals / Non-Goals

**Goals**
- A correct, priceable identifier is easy to enter and hard to fat-finger.
- Whatever the user types is canonicalised once, against the source that
  will quote it, so currency stops being a guess.
- Every step degrades: offline, no-result, provider-down all fall back
  without blocking instrument creation.
- Reuse the research-tool and predefined-list patterns already shipped.

**Non-Goals**
- An in-app name→results autocomplete/picker (fragile endpoint, more UI;
  the "look it up" prompt covers discovery at far lower cost).
- FX-converting a foreign quote into the account currency (that is a
  separate question; here a foreign listing is surfaced as a mismatch).
- Per-user API keys or custom endpoints, ever.
- Changing how trades post or how lots/cost/quantity are computed.

## Decisions

### 1. Discovery = the existing research-tool prompt, second template

Add an *identify* prompt template beside the existing *research* one, and a
button on the Add-instrument form. Reuses `settingsFavouriteResearchTool`,
`researchQueryUri`, and the launch-or-copy fallback verbatim. Prompt asks
for ISIN, primary exchange + ticker, trading currency, Yahoo symbol, and —
if cross-listed — each venue with its currency; forbids advice; includes
only the typed name.

**Alternative considered:** a dedicated in-app search field hitting Yahoo
search as the user types. Rejected for v1 — more UI, a live dependency on a
fragile endpoint on every keystroke, and it duplicates what the prompt does
for free. The Save-time resolve (Decision 4) already uses Yahoo search once,
where it matters.

### 2. Offline validation: block only what is provably wrong

| Check | Result |
| --- | --- |
| ISIN not 12 chars / illegal characters | **block save** — "this isn't an ISIN" |
| ISIN 12 chars but mod-10 check digit fails | **warn**, allow save — "looks mistyped" |
| ISIN country prefix not a real ISO/`XS` code | warn |
| inferred currency ≠ account currency | warn, with the fix ("use the `.SW` listing") |

The check digit is deterministic (letter-expand + Luhn mod-10) — a failure
is always a typo, never a false positive. It is a warning not a block only
because the ISIN field is optional and the app gates nothing else; a
project decision could promote it to a block. The currency warning is the
highest-value one — it pre-empts the exact on-device bug at entry time,
entirely offline.

### 3. Exchange registry + Default-exchange setting

A `const` list (code change to extend), each entry:
`{name, mic, yahooSuffix, currency, nationalEndpoint?}`. Seeded with ~20:
US (NYSE+Nasdaq), LSE, SIX, XETRA, Euronext Paris/Amsterdam/Brussels/
Lisbon, Borsa Italiana, BME Madrid, Nasdaq Nordic (ST/HE/CO), TSX, ASX,
Tokyo, HKEX, SGX, NSE, BSE, KRX, B3, JSE, TASE. First-run default from the
device region (`de-CH`→SIX, `en-IN`→NSE, `en-US`→US); user-changeable in
Settings next to the quote-provider control; unrecognised stored value
falls back to the default (same rule as the rate-provider setting).

The registry is the single source of truth that (a) biases resolve/confirm,
(b) supplies the currency for a resolved symbol, (c) binds the national
fallback endpoint, (d) can seed a new investment account's currency, (e)
lets a bare ticker be tried as `TICKER` + default suffix.

**Alternative considered:** derive everything per-instrument from the ISIN
country and skip the setting. Rejected — most people trade only on their
home exchange, so a one-time global default removes a decision from every
instrument; the ISIN country is still used when it disagrees with the
default (drives the mismatch warning).

### 4. Resolve on Save, always confirm

On Save, if online: one Yahoo *search* call — `?q={isin}` when an ISIN is
present (most precise), else `?q={ticker}` — then present the candidate
listing(s) as `{name · exchange · currency}`. The entry matching the
default exchange is pre-selected; the user taps to confirm; nothing is
auto-committed (a single unambiguous match still shows a one-line confirm).
On confirm, persist `resolvedSymbol` (e.g. `UBSG.SW`) and `exchange`.

Offline, or search returns nothing: save with the typed values;
`InstrumentQuoteRefresh` retries resolution on its next run and caches the
result. A resolve that later succeeds updates the stored symbol silently.

**Why confirm, not auto-pick:** an ISIN identifies the *security*, not the
*listing* — `CH0244767585` is UBS on SIX (CHF) and on NYSE (USD). Auto-
picking the first result would sometimes store the wrong-currency line for
the user's actual holding. Confirm makes the venue/currency choice explicit
at the one moment the user knows the answer.

### 5. Quote fetch prefers the resolved symbol; national fallback

`InstrumentQuoteRefresh` sends `resolvedSymbol ?? ticker`. If the primary
provider returns nothing and the resolved exchange has a `nationalEndpoint`,
try that once. National endpoints are added incrementally; absence just
means "no fallback for that exchange".

## Risks / Trade-offs

- **[Risk]** Yahoo search is the same unofficial endpoint as Yahoo quotes —
  a Yahoo outage takes down search *and* quotes. → **Mitigation:** it adds
  no new failure *class* for Yahoo users; Stooq users keep manual symbol +
  `market-quote-currency` suffix inference; resolution failure never blocks
  save.
- **[Risk]** The identify prompt's LLM answer can contain a hallucinated
  ISIN. → **Mitigation:** the check digit catches an off-by-one; the
  Save-time resolve cross-checks against Yahoo; a valid-but-wrong ISIN is
  still caught at confirm ("that's the German listing, not the Swiss one").
- **[Risk]** A new outbound request type (identifier search on Save). →
  **Mitigation:** sends only the typed identifier, only on Save, only when
  online; documented like the quote/rate lookups.
- **[Trade-off]** New `resolvedSymbol`/`exchange` columns + a migration for
  a feature some users won't touch. Nullable, additive, no backfill.
- **[Trade-off]** ~20-entry exchange registry to maintain. Small `const`;
  extending it is a code change, consistent with the app's other lists.

## Migration Plan

1. Add nullable `resolvedSymbol`, `exchange` to the `instruments` table
   (Drift migration, no backfill).
2. Add `exchange_registry.dart` + the `defaultExchange` setting + Settings
   dropdown (+ first-run region default).
3. Add the *identify* prompt template + the look-up button on the
   Add-instrument dialog.
4. Add offline ISIN/currency validation to the dialog.
5. Add the Yahoo search call + the Save-time confirm sheet; persist the
   resolved symbol.
6. Point `InstrumentQuoteRefresh` at `resolvedSymbol`; wire the national
   fallback.
7. Tests (see tasks); re-check the on-device UBS/CHF scenario.
8. Rollback = drop the two columns, the setting, the button, the confirm
   step; quote fetch reverts to raw ticker.

## Open Questions

- **Check digit: block or warn?** Design says warn (app-consistency);
  flagged for the team.
- **Confirm UI** — a bottom sheet with radio options, or reuse the dialog?
  Leaning bottom sheet so it composes with the existing dialog.
- **Does the identify look-up also live on the buy dialog**, or only on
  instrument creation? Instrument identity is set once; leaning creation
  only, with the currency-mismatch warning echoed on buy.
- **Auto-seed a new investment account's currency from the default
  exchange?** Nice consistency; out of scope unless it's cheap.
