## 1. Shared join

- [x] 1.1 Extract pending-transfer summary assembly from `_buildHomeOverview`
- [x] 1.2 Add id lookup on the ledger (or dedicated) read seam; Home list uses the same helper

## 2. Router / settle

- [x] 2.1 `_buildSettlePendingTransfer` loads by id; drop `HomeViewModel` scan
- [x] 2.2 Preserve already-settled empty state when lookup is null

## 3. Verify

- [x] 3.1 Settle widget tests do not require a loaded Home overview
- [x] 3.2 Home pending-transfer unit coverage still green
