# Proposal: extract-ledger-csv-exporter

## Why
CSV serialization (`_csvField` / `_csvAmount` / row assembly) still lives on `LedgerRepository` after register projection was unified. Architecture cycle 13: Flutter-free exporter.

## What Changes
- Add `ledger_csv_exporter.dart` with escape/format/build helpers.
- `exportLedgerCsv` loads + projects, then calls `buildLedgerCsv`.

## Impact
- Spec: `ledger-csv-exporter`. Behavior unchanged.
