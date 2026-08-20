## Why

Guide promises tap-to-reverse; UI never wires it. Users need Fix amount/category/account/date without learning reversal.

## What Changes

- Register row tap → Fix flow: prefilled form, confirm posts reversal + new entry.
- One confirmation explains old line stays, correction adds new line.
- Wire RegisterRowTile onReverse / onTap.
- Repository: optional fixTransaction helper or VM orchestrates reverse + record.

## Capabilities

### New Capabilities

- `correction-wizard`

### Modified Capabilities

- `core-ledger-single-account`
- `user-guide`

## Impact

- UI, repository or settings as described.
- Tests and user guide.
