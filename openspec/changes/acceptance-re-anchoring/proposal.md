## Why

The acceptance suite's tamper-detection scenario proves quarantine on restart, but the **re-anchoring** half — recording a second clean entry after quarantine and asserting only the tampered row keeps the lock badge — was scoped out of `acceptance-test-suite` after an unexplained "no FAB found" failure on the real macOS build. INTEGRATION already covers re-anchoring; the real-build tier does not. Closing that hole needs a dedicated investigation, not another silent skip.

## What Changes

- Diagnose why the Register FAB (`TablerIcons.plus`) is missing (or unfindable) after the acceptance tamper "restart" path.
- Fix the product UI and/or the acceptance harness so the flow is reliable.
- Land a real-GUI acceptance scenario that completes re-anchoring after quarantine (second clean entry; lock badge only on the tampered row; integrity events as appropriate via UI-visible outcomes).
- Leave biometric App Lock and other deferred acceptance gaps to their own changes.

## Capabilities

### New Capabilities
- `acceptance-re-anchoring`: real-build acceptance coverage for post-quarantine re-anchoring through the GUI.

### Modified Capabilities
- (none — product `ledger-integrity-signing` requirements already define re-anchoring; this change only adds acceptance coverage and any harness/UI fixes needed to exercise them)

## Impact

- `integration_test/acceptance/core_ledger_test.dart` (extend or complete the tamper scenario)
- Possibly `acceptance_harness.dart` finders/waits if the FAB miss is harness-side
- Possibly Register / Home shell widgets if the FAB truly does not render after quarantine restart
- No CI automation; still manual via `tool/run_acceptance_tests.sh`
