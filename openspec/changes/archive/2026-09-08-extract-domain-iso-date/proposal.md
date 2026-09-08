# Proposal: extract-domain-iso-date

## Why
`dateOnly` / `truncateToStoredPrecision` lived under data `repository_date_utils` while the CSV exporter reimplemented ISO formatting in domain. Architecture cycle 15: one Flutter-free domain date seam.

## What Changes
- Add `lib/domain/time/iso_date.dart`.
- Re-export from `repository_date_utils` (bytesEqual stays data-local).
- CSV exporter uses `dateOnly`.

## Impact
- Spec: `domain-iso-date`. Call sites keep working via re-export.
