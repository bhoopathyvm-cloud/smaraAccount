## Why

`acceptance-test-suite` never ported the INTEGRATION-tier **user-created group archive lifecycle** onto the real-build harness. Archive-while-active rejection, archive-once-empty success, and historical resolution of the archived group remain unproven against a real launched build.

## What Changes

- Add a real-GUI acceptance scenario mirroring `integration_test/app_test.dart`'s "user-created group archive lifecycle" journey: blocked hide while the group has active accounts, successful hide once empty, archived group/account still visible with historical resolution, archived group not offered as a reassignment target.
- Drive setup and assertions through the real Accounts UI where the INTEGRATION test already uses GUI; keep Repository shortcuts only where that reference test already does (e.g. emptying the group by archiving the member account).
- Reuse the existing acceptance harness and cleanup; no new test framework.

## Capabilities

### New Capabilities
- `acceptance-group-archive`: real-build acceptance coverage for the user-created account-group archive lifecycle.

### Modified Capabilities
- (none — `multi-account-ledger` already requires the archive rules; this adds acceptance coverage only)

## Impact

- New or extended file under `integration_test/acceptance/` (likely `core_ledger_test.dart` or a focused companion in the same group)
- Accounts management UI affordances already used by INTEGRATION (`Hide`, confirmation, reassign-group picker)
- Manual run via `tool/run_acceptance_tests.sh -d <device-id>`
