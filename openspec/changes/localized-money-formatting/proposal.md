## Why

1234.56 with period and no grouping fails INR/JPY/European daily use.

## What Changes

- Replace formatAmountMinor-only display with intl NumberFormat per currency.
- MoneyAmountField accepts locale decimal separator.
- Transfer implied rate comment: respect currency minor units (0/2/3).
- Coordinate with localized-money-formatting capability.

## Capabilities

### New Capabilities

- `localized-money-formatting`

### Modified Capabilities

- `account-currency`
- `user-guide`

## Impact

- UI, repository or settings as described.
- Tests and user guide.
