## Context

An earlier draft left "currency minorUnit from ISO table or static map"
as an open either/or, and claimed `account-currency` as a modified
capability with no actual delta. Resolved both: `intl`'s
`NumberFormat.currency(name: currencyCode)` already carries CLDR-sourced
per-currency grouping, decimal-separator, and minor-unit-digit data — no
custom table needs building or maintaining for known currencies, so the
either/or collapses to "use what `intl` already has." `account-currency`
doesn't need a delta because this change only consumes a currency code
that capability already attaches to every account; it doesn't change how
that attachment works.

`intl` is not currently a `pubspec.yaml` dependency — checked
(`grep intl: pubspec.yaml` → no hits) before treating it as a given.

## Goals / Non-Goals

**Goals:** Looks like a bank statement in the amount's own currency, on
any device.

**Non-Goals:** Out of scope items in proposal. Full app UI localization
(`i18n-foundation`) — this change is money formatting only, independent
of which language the surrounding UI text is in.

## Decisions

### 1. `intl.NumberFormat.currency`, not a hand-maintained minor-unit table
Resolves the earlier either/or. One dependency, already carrying the
data this change needs; no table to keep in sync as currencies or their
conventions change.

### 2. Format by currency, not device locale
An amount's currency code determines its formatting, not the viewing
device's `Locale`. Justification: this is a personal, potentially
multi-currency ledger — an account's own currency figure should read the
same regardless of who's holding the phone, the same way a bank
statement doesn't reformat itself based on the reader's country.

### 3. Unparseable input is rejected explicitly, not silently emptied
Today's `MoneyAmountField` uses `double.tryParse`, so a comma-decimal
amount in a period-expecting field silently resolves to nothing — the
user sees no error, just a field that behaves as if they typed nothing.
This change makes that an explicit invalid-input state instead.

## Risks / Trade-offs

- [Risk] New dependency (`intl`). → Mitigation: official Dart team
  package, already indirectly used by Flutter's own localization
  tooling; not a niche or unmaintained addition.
- [Risk] Scope creep. → Mitigation: child change stays focused on
  formatting/parsing, not full localization.
- [Correction, found during implementation] Decision 1's premise that
  `NumberFormat.currency(name: currencyCode)` alone carries grouping and
  decimal-separator conventions "from `intl`'s built-in currency data" is
  imprecise: `intl` sources grouping/decimal-separator from a *locale*,
  and only the minor-unit *digit count* (e.g. 0 for JPY) is genuinely
  keyed by the currency code. Formatting "by currency, not device locale"
  (Decision 2) therefore needs each currency mapped to one canonical
  formatting locale - a small, explicit `currency -> locale` table
  (`lib/ui/core/money_formatter.dart`'s `_currencyLocale`), not the
  "no table to maintain" framing this decision originally assumed. Kept
  deliberately small: only currencies whose grouping convention actually
  differs from a Western-style fallback need an entry (INR's lakhs
  grouping, JPY, EUR's period-grouping/comma-decimal, and the other
  onboarding quick-pick currencies); everything else falls back to that
  Western convention, which is already correct for most ISO 4217
  currencies.
- [Bug found and fixed during implementation, pre-existing] Cross-currency
  transfer's `impliedRate` (`transfer_view_model.dart`) divided raw minor
  units directly, silently correct only when both currencies shared the
  same minor-unit digit count (previously always true, since the old
  formatter always assumed two decimals everywhere). A USD→JPY transfer
  would have computed a rate wrong by a factor of 100. Fixed to convert
  each side to its own major units first, via a new
  `minorUnitDigitsForCurrency` helper.

## Open Questions

None for v1.
