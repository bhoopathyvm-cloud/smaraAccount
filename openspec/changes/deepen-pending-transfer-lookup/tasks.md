## 1. Shared join

- [ ] 1.1 Extract pending-transfer summary assembly from `_buildHomeOverview`
- [ ] 1.2 Add id lookup on the ledger (or dedicated) read seam; Home list uses the same helper

## 2. Router / settle

- [ ] 2.1 `_buildSettlePendingTransfer` loads by id; drop `HomeViewModel` scan
- [ ] 2.2 Preserve already-settled empty state when lookup is null

## 3. Verify

- [ ] 3.1 Settle widget tests do not require a loaded Home overview
- [ ] 3.2 Home pending-transfer unit coverage still green
