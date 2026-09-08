## 1. Policy module

- [x] 1.1 Add `PendingTransferSettlement` + unit tests

## 2. Wire both adapters

- [x] 2.1 `SettlePendingDraft` resolves target + shortfall through it
- [x] 2.2 `LedgerPosting.settlePendingTransfer` resolves through it; remove inline restatement

## 3. Verify

- [x] 3.1 analyze + unit/widget/repo tests green
- [x] 3.2 settle-pending acceptance (Linux)
