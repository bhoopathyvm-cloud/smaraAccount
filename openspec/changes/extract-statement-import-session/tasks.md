## 1. Session module

- [ ] 1.1 Inventory VM step enum, CSV mapping fields, grouping, and transitions
- [ ] 1.2 Implement `StatementImportSession` with unit tests for mapping validity and step order

## 2. Thin adapter

- [ ] 2.1 ViewModel forwards to the session and exposes a snapshot
- [ ] 2.2 Widget tests keep using the ViewModel; delete duplicated VM-only helpers

## 3. Verify

- [ ] 3.1 Statement-import view-model and widget tests green
- [ ] 3.2 Preview still goes through `buildPreviewRows` (no per-row suggest)
