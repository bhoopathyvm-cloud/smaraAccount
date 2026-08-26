## Why

The project's existing `integration_test/app_test.dart` suite drives the real
widget tree end to end, but it always runs against an in-memory database and
in-memory secure storage inside the Flutter Tester harness — it never
launches an actual built app, never touches the real on-disk database file
(Drift's `getApplicationSupportDirectory` path) or the real OS keychain
(`flutter_secure_storage`), and never renders on a real window/simulator/
device. It is an excellent regression net for logic and navigation, but it
cannot catch platform-integration failures the way the
`SnapshotHidingOverlay` `Directionality` crash did: that bug only
reproduced against the real `flutter run -d macos` launch, not against the
widget-tree test, because it lived in *how the real app assembles its
widget tree at startup* — a detail the existing suite's hand-built
`buildAppFor` test harness diverges from. There is currently no repeatable
way to catch that class of bug, no tier above the existing
unit/widget/integration ones in
`Specs/architecture/smara-tech-guidelines.md`'s Testing Rules that exercises
a real build the way a user actually experiences it, and no way to check
that experience across the app's real target platforms (macOS, iOS,
Android) rather than just the widget tester's default surface.

## What Changes

- Add a new **acceptance** testing tier (above unit/widget/integration) that
  drives a real, installed build of the app — not the Flutter Tester
  harness's hand-built widget tree — by launching the app's actual
  `main.dart` root widget, using the app's real on-disk database and real
  secure storage.
- Cover the app's shipped capabilities at the acceptance level, not just one
  narrow flow: port the full set of user journeys the existing INTEGRATION
  tier already proves (record/reverse entries, category and group archive
  lifecycles, tamper detection, cross-currency transfer and bounced-transfer
  settlement, key-loss migration) onto the real-build harness, and add
  acceptance coverage for the capabilities that tier doesn't reach yet —
  onboarding (`deferred-onboarding`, `first-week-setup`), identity restore
  and ledger backup/restore-from-file (`ledger-backup`), data import
  (`csv-transaction-import`, `ofx-transaction-import`), organization
  features (`payees`, `recurring-templates`, `import-category-rules`,
  `monthly-category-limits`, `split-transactions`, `correction-wizard`,
  `register-search`), account/currency handling (`account-currency`,
  `multi-account-ledger`, `credit-card-household-flow`,
  `accounts-home-overview`, `home-hub`, `localized-money-formatting`,
  `reference-exchange-rate-lookup`), and App Lock's PIN path (`app-lock`;
  its biometric path is explicitly out of scope for this change — see
  design.md Decision 1).
- Model "a different device" the way this local-first, backendless app
  actually supports it: no live sync between two running instances exists,
  so restoring on a different device is always fresh app storage + fresh OS
  keychain, restored from a carried-over recovery phrase, keystore file, or
  encrypted backup file — reproduced in a single test process via a
  storage/keychain reset between two phases, not a two-device network
  simulation.
- Make the real target **device selectable per run**: the developer running
  the suite manually chooses which real target to run against — a macOS
  build, an iOS simulator, or an Android emulator/device — via a device
  argument; there is no default that silently picks one for them, and no
  automation that runs all three unattended.
- Add automatic teardown *and* a pre-run cleanup that remove every artifact
  an acceptance run creates on the host — the app's real database directory
  and its real keychain entries — so a run always leaves the device exactly
  as it found it, whether it passed, failed, or was interrupted.
- Add a single developer-facing script under `tool/` that runs the
  acceptance suite against a chosen device, meant to be run manually after
  finishing a large change, before opening a PR. This stays a manual,
  on-demand tool — no CI job, scheduled or otherwise, is added.

## Capabilities

### New Capabilities
- `acceptance-test-suite`: a real-build, GUI-driven acceptance testing tier — spanning the app's shipped capabilities, selectable by target device, restoring entries on a simulated second device, and self-cleaning all host state afterward — plus the manual developer command that runs it.

### Modified Capabilities
(none — this adds a new testing tier and does not change any shipped app requirement)

## Impact

- **Affected code**: new `integration_test/acceptance/` test files (one
  group per capability area, sharing a common real-build harness and
  cleanup helpers); a new `tool/run_acceptance_tests.sh` script; no changes
  to `lib/`.
- **Docs**: `Specs/architecture/smara-tech-guidelines.md` (Testing Rules
  section gets a fourth tier) and `CONTRIBUTING.md` (mention the new
  command and its manual, per-device usage).
- **Dependencies**: none — the recommended approach extends
  `integration_test`, already a dev dependency.
- **CI**: no changes. This tier is manual-only and is never invoked by any
  GitHub Actions workflow.
