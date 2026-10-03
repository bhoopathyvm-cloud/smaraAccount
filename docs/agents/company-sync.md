# Company sync acceptance run

How agents run the Acme Travel Co multi-instance acceptance suite
(`real-sync-and-company-acceptance` group 7–8).

## Pieces

- `tool/company_sync/scenario.dart` — Acme + dry-run step lists
- `tool/company_sync/conductor.dart` — HTTP coordinator on the host Mac
- `tool/company_sync/run_conductor.dart` — process entry that prints `CONDUCTOR_PORT=`
- `integration_test/company_sync/` — role runner (`COMPANY_SYNC_ROLE`, `COMPANY_SYNC_CONDUCTOR`)
- `tool/run_company_sync_test.sh` — device boot, fixtures, builds, launches
- `test_fixtures/receipts/` — JPEG + PDF seeds for Claimant pickers

## Quick dry run (task 7.2)

Owner on macOS + one iOS simulator Claimant:

```bash
tool/run_company_sync_test.sh --dry
```

## Small cast (default)

```bash
tool/run_company_sync_test.sh --employees 2
```

## Full cast

```bash
tool/run_company_sync_test.sh --employees 5
```

Requires ≥10 GB free RAM. Android AVDs `smara_store_phone` and
`smara_kiosk_pixel` are started with `-vmnet-shared` (one `sudo` prompt);
decline falls back to `--ios-only`.

## Artifacts

On every run (and especially on failure), look under
`build/company_sync/<timestamp>/`:

- `conductor/report.json` + `timeline.txt`
- `<role>/*.visible.txt`, `instance.log`, screenshots when available
- `conductor/*.log` for build / emulator output

## Unit checks without devices

```bash
flutter test tool/company_sync/
flutter test test/data/company_sync_fixed_rates_test.dart
```

## Notes

- Join uses **Enter code instead** in the GUI; the conductor relays join
  and check codes between roles.
- `--dart-define=COMPANY_SYNC_TEST=true` enables fixed GBP/JPY→EUR rates
  (compiled out of release builds).
- Prefer `--employees 2` until the host has enough free memory for five
  Claimants plus Owner and Approver.
