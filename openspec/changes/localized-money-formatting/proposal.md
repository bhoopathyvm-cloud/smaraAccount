## Why

1234.56 with period and no grouping fails INR/JPY/European daily use.

## What Changes

- Replace `formatAmountMinor`'s hardcoded "1234.56" with `intl`'s
  `NumberFormat.currency` per amount's own currency code — grouping,
  decimal separator, and minor-unit digit count come from `intl`'s
  built-in currency data, not a hand-maintained table.
- `MoneyAmountField` accepts the currency-appropriate decimal separator
  on input, and rejects unparseable input explicitly rather than
  treating it as empty (today's `double.tryParse` silently does the
  latter).
- Formatting follows the amount's own currency, not the viewing device's
  locale, so the same account looks the same on any device.

## Capabilities

### New Capabilities

- `localized-money-formatting`

### Modified Capabilities

- `user-guide`

**Not modified**, checked before scoping this: `account-currency`. That
capability already attaches a currency code to every account group and
derives each account's currency from it — this change only consumes
that existing currency code for display/input formatting; it doesn't
change how a currency gets attached to an account.

## Impact

- New dependency: `intl` (official Dart team package; not currently in
  `pubspec.yaml` — added here, checked against Golden Rule #8's
  dependency-hygiene bar before adding).
- `lib/ui/core/money_formatter.dart`: replace the hardcoded two-decimal
  formatting with `NumberFormat.currency` keyed by currency code.
- `lib/ui/core/money_amount_field.dart`: parsing accepts the relevant
  decimal separator; replaces the current silent-empty-on-unparseable
  behavior with an explicit invalid state.
- Tests and user guide.
