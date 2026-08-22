## Context

`Specs/architecture/smara-tech-guidelines.md`'s Testing Rules define three
tiers: UNIT (Repository/ViewModel), WIDGET (per-View), and INTEGRATION (full
user journeys). The INTEGRATION tier already exists as
`integration_test/app_test.dart` and is strong: it drives the *real* widget
tree through `tester.tap`/`enterText`, including a journey that already
simulates a "different device" in miniature — the "reinstall with the
recovery phrase restores the identity" test builds a second
`LedgerRepository`/`SigningKeyService` against a fresh `InMemorySecureKeyStorage`
(same database file, empty keychain — exactly what a real reinstall looks
like) and walks the real Restore UI.

What that tier cannot catch is failures in *how the real app comes
together outside the test double*, or failures specific to a real OS
target. That's precisely what slipped through with `SnapshotHidingOverlay`:
it crashed every real `flutter run -d macos` launch with "No Directionality
widget found," but `integration_test/app_test.dart`'s `buildAppFor` helper
builds the widget tree by hand (`MultiProvider` → `Builder` →
`MaterialApp.router`, without `SnapshotHidingOverlay` at all) rather than
reusing `main.dart`'s actual `SmaraAccountingApp` root widget, so no
existing test ever assembled the tree the way the real app does. The gap
isn't test *coverage* of behavior — it's fidelity to the real build, on the
real platforms this app ships to (macOS, iOS, Android).

This app is explicitly local-first and backendless (`pubspec.yaml`
description) — there is no server to sync through, so "a different device"
in this app is never a live connection between two running instances. It is
always: fresh app storage + fresh OS keychain, restored from something the
user carried over by hand (a 24-word recovery phrase, a keystore file, or an
encrypted `ledger-backup` file). The acceptance suite models exactly that.

## Goals / Non-Goals

**Goals:**
- Run real GUI-driven user journeys against a real launched build — by
  reusing `main.dart`'s actual root widget, not a hand-rebuilt tree — using
  the app's real on-disk database and real secure storage.
- Cover the app's shipped capabilities broadly, not one narrow flow: every
  journey the INTEGRATION tier already proves, plus the capability areas
  that tier doesn't reach today (onboarding, backup/restore-from-file, data
  import, organization features, account/currency handling, App Lock's PIN
  path).
- Let the developer choose which real target platform to run against
  (macOS, iOS simulator, Android emulator/device) per manual invocation.
- Leave the host machine/simulator exactly as found: no leftover database
  file, no leftover keychain entries, whether the run passed, failed, or
  was interrupted.
- Give the developer one manual command to run after finishing a large
  change, before opening a PR.
- Stay inside the project's existing tooling conventions (Golden Rule: no
  duplicated/unnecessary dependencies) unless a clear capability gap
  justifies a new one.

**Non-Goals:**
- Simulating real network sync between two simultaneously-connected devices
  — this app has no such feature.
- Any CI automation — scheduled, optional, or otherwise. This tier is
  manual-only, run by a developer on demand; `flutter-ci.yml` is untouched.
- Automatically running all three target platforms in one invocation — the
  developer picks one device per run.
- Full biometric-path coverage of `app-lock` — a real biometric prompt is
  native OS chrome outside what plain `integration_test` can dismiss (see
  Decision 1). This change covers `app-lock`'s PIN path; the biometric path
  stays out of scope until native-dialog automation is separately adopted.
- Docs-only specs with no independently testable app behavior
  (`contributor-guide`, `project-website`, `user-guide`,
  `shared-ui-components`) are not acceptance-test targets.

## Decisions

### Decision 1 — Driving framework: extend `integration_test`, reusing the real app's root widget

Four realistic options exist for driving a real, installed build through its
GUI:

**A. Flutter's own `integration_test` package, targeted at a real device**
(`flutter test integration_test/<file>.dart -d <device-id>`). This is the
same package `integration_test/app_test.dart` already uses — the test
process runs *inside* the real app binary, giving it direct, in-process
access to the same `path_provider`/`flutter_secure_storage` APIs the app
uses (relevant to Decision 3). Zero new dependencies. Weakness: it cannot
dismiss native, non-Flutter OS chrome (a real biometric Face ID/Touch ID
sheet, a system permission dialog).

**B. Patrol** — adds `NativeAutomator` (dismiss OS permission/biometric
dialogs, background/foreground the app) on top of `integration_test`, plus
a CLI for multi-device runs. Would close Option A's native-dialog gap —
relevant to `app-lock`'s biometric path (Non-Goals) — but costs a new dev
dependency and native bootstrap code generated into `ios/`, `macos/`, and
`android/` to maintain going forward.

**C. Maestro** — black-box, drives the installed app package through the OS
accessibility tree with no test code compiled in; highest fidelity to "what
a user experiences," including native dialogs. Blocker: no first-party
macOS or Windows desktop driver (iOS, Android, limited web only) — this app
ships to macOS desktop as a primary target (the motivating bug only
reproduced with `-d macos`), so Maestro would cover two of the platforms
this suite needs to target and miss the third outright.

**D. Appium** — the only option with reach across every platform this app
ships to (including macOS/Windows desktop) through one framework, but the
heaviest: a running Appium server, per-platform driver installs, and a real
learning curve, for a project this size.

**Decision: A**, confirmed. No new dependency; directly closes the fidelity
gap for the platforms this change targets (macOS, iOS, Android — all
natively supported by `integration_test`). Patrol (B) remains the
documented upgrade path specifically for `app-lock`'s biometric path,
deliberately deferred (Non-Goals) rather than adopted now.

**Consequence for the harness itself**: since the motivating bug was a gap
between the real app's composition and the test's hand-rebuilt one, the
acceptance harness reuses `main.dart`'s actual `SmaraAccountingApp` root
widget directly (`pumpWidget(const SmaraAccountingApp())`), rather than
reassembling `MultiProvider`/`MaterialApp.router` by hand the way
`integration_test/app_test.dart`'s `buildAppFor` does. `SmaraAccountingApp`
already constructs its own real `AppDatabase()` and real repositories
internally with no test seam — which is exactly what the acceptance tier
wants (real storage), so no seam needs adding. This guarantees the
acceptance tier can never again silently diverge from what `main()` builds.

### Decision 2 — Device targeting and the "different device" restore model

**Restore model, confirmed: single device, two phases, real storage reset
between them.** One `flutter test` run with two `testWidgets` phases
(mirroring the shape of the existing in-memory "reinstall with the recovery
phrase" test): phase one launches the real app, walks onboarding, records
entries through the GUI, and captures the recovery phrase off screen;
between phases, the test wipes the real database file and calls the real
secure storage's `deleteAll()` (simulating "new device, same carried-over
secret" — the private key is gone, the phrase is what's carried over);
phase two relaunches the real app fresh and walks the real Restore UI,
asserting the entries and balances reappear unchanged. This proves
restore-correctness with one command and no cross-process orchestration.
(A true two-concurrent-device variant, with the phrase handed off between
independently launched processes, is not built in this change — the
device-targeting below already gives per-platform coverage without it, and
nothing in this change currently needs the two devices to be *simultaneous*.)

**Target device, confirmed: selectable per manual run, across macOS, iOS,
and Android.** The developer running the suite chooses the target — there
is no hardcoded or silently-defaulted device. The entry point (Decision 4)
takes a device argument the same way `flutter test -d <device-id>` does; a
developer checking a change runs it once per platform they want confidence
on (e.g. `tool/run_acceptance_tests.sh -d macos`, then
`-d "iPhone 17 Pro"`, then `-d emulator-5554`), not all three
automatically. Because cleanup (Decision 3) works in-process through
`path_provider`/`flutter_secure_storage` — APIs that already abstract over
macOS's Application Support + Keychain, iOS's app container + Keychain, and
Android's app-private storage + Keystore — the same Dart cleanup code is
correct on all three targets with no per-platform branching needed.

### Decision 3 — Cleanup strategy (confirmed)

Because the acceptance test process runs *inside* the real app binary
(Decision 1), it already has in-process access to exactly the same APIs
`main.dart`/`app_database.dart` use to locate its own state:
`path_provider`'s `getApplicationSupportDirectory()` for the database file,
and the real secure-storage implementation's `deleteAll()` for every
keychain entry the app wrote. An `addTearDown` in every acceptance test
that deletes that directory and calls `deleteAll()` runs whether the test
passes or fails; the same cleanup also runs once at process start (before
any test), so a prior crashed run's leftovers never contaminate the next
one. This needs no per-OS shell scripting and is correct across macOS/iOS/
Android by construction (Decision 2).

### Decision 4 — How the suite is triggered (confirmed: manual only)

A `tool/run_acceptance_tests.sh` script, run manually by the developer
after finishing a large change, before opening a PR, with a required device
argument (Decision 2) — matches this repo's existing `tool/` convention
(`tool/l10n/`, `tool/git-hooks/`) and costs nothing in CI. No CI job of any
kind — scheduled, optional, or required — is added by this change; that
possibility is dropped rather than left open, since the suite is meant to
stay a manual, developer-triggered tool.

### Decision 5 — Coverage scope

The acceptance suite is not limited to one flow. It's organized into
capability groups, each a set of `testWidgets` under
`integration_test/acceptance/`, sharing the real-build harness (Decision 1)
and cleanup helpers (Decision 3):

1. **Core ledger journeys** (`core-ledger-single-account`,
   `multi-account-ledger`, `ledger-integrity-signing`) — recording entries,
   category and account-group archive lifecycles, tamper detection and
   re-anchoring. Ports the existing INTEGRATION-tier journeys onto the
   real-build harness, with one exception: reversing a posted entry has no
   GUI affordance anywhere in the app today (`RegisterViewModel.reverseEntry`
   is called directly by the INTEGRATION tier's own test, never from any
   View) - excluded from this GUI-only tier rather than faked through a
   backdoor call, not merely deferred.
2. **Currency and transfers** (`account-currency`,
   `foreign-currency-settlement`, `credit-card-household-flow`,
   `localized-money-formatting`, `reference-exchange-rate-lookup`) —
   cross-currency transfer lifecycle, bounced-transfer settlement,
   formatted-amount display. Also ports existing journeys.
3. **Identity and backup** (`ledger-backup`) — the restore-on-a-simulated-
   second-device flow (Decision 2), plus exporting and restoring an
   encrypted backup file through the GUI, plus the wrong-phrase/wrong-file
   negative cases.
4. **Onboarding** (`deferred-onboarding`, `first-week-setup`) — first-run
   setup through the real GUI, including the deferred-setup path.
5. **Data import** (`csv-transaction-import`, `ofx-transaction-import`) —
   importing a real file through the platform file picker and verifying
   entries land correctly.
6. **Organization** (`payees`, `recurring-templates`,
   `import-category-rules`, `monthly-category-limits`,
   `split-transactions`, `correction-wizard`, `register-search`) — day-to-
   day bookkeeping features layered on the ledger.
7. **Home and accounts overview** (`accounts-home-overview`, `home-hub`,
   `account-management-ui`) — dashboard/summary rendering against real
   recorded data.
8. **App Lock, PIN path only** (`app-lock`) — lock/unlock via PIN through
   the real GUI; biometric enrollment/approval is out of scope (Non-Goals).

Groups 1–3 are the priority for this change (they're what the motivating
bug and the restore scenario are about); groups 4–8 extend coverage to the
rest of the app's shipped capabilities per the same harness, tracked as
their own task groups in tasks.md so they can land incrementally without
blocking on each other.

## Risks / Trade-offs

- **[Risk]** A real `flutter run`/`flutter test -d macos` launch can fail to
  foreground or hang in headless/CI-like environments (observed during this
  proposal's own research: `Failed to foreground app; open returned 1`) →
  **Mitigation**: this tier targets local developer machines with a real
  attached display/simulator, not headless environments; documented as a
  known quirk, not solved here.
- **[Risk]** Real crypto (key generation, per-entry signing) and real
  secure-storage (Keychain/Keystore) I/O are noticeably slower per step
  than the INTEGRATION tier's in-memory doubles - a fixed short
  `tester.pump(duration)` that's plenty for the in-memory suite can leave
  the *previous* screen still showing on a real device, making an
  otherwise-correct scenario look like a hang or a broken flow →
  **Mitigation**: every acceptance scenario waits with a bounded
  `pumpUntilFound` polling loop for the *next* screen's marker widget
  (confirmed during this change's own implementation: a scenario that
  looked hung at a fixed 200ms pump completed correctly once given a
  generous polling wait), never a fixed short pump, and each `testWidgets`
  is given a multi-minute `timeout` rather than the test framework's
  default.
- **[Risk]** The live macOS window opens at a fixed 800x600, shorter than
  several onboarding/entry screens' content - a target below the fold sits
  entirely outside the render tree's bounds (`tester.tap()`'s own
  diagnostic confirmed this directly: "Offset(400.0, 1010.4) is outside
  the bounds of the root of the render tree, Size(800.0, 600.0)"), not
  merely hard to hit. `tester.view.physicalSize` overrides (used by the
  INTEGRATION tier to force a phone-sized surface) don't reliably resize
  this real, live window either. This was the root cause behind several
  confusing-looking failures during this change's own implementation
  (`enterText` appearing to succeed but the field's value never actually
  registering; a tap warning followed by a downstream "screen not found"
  several steps later) before being traced back to this one cause →
  **Mitigation**: [tapReliably]/[enterTextReliably] call
  `tester.ensureVisible(target)` before every interaction, matching
  `integration_test/app_test.dart`'s own pre-existing `ensureVisible`
  convention for exactly this; a bounded retry remains as a second layer
  for anything that still misses.
- **[Risk]** `FlutterSecureStorage.deleteAll()` fails on an ad-hoc signed
  macOS build with `PlatformException(..., errSecMissingEntitlement,
  -34018, ...)`, even using the same `MacOsOptions(usesDataProtectionKeychain:
  false)` legacy-Keychain fallback the app's own code uses. So does
  deleting an individual key that was never written - only
  writing/deleting a key that *already exists* (what the app itself
  actually does in practice) avoids the error (confirmed during this
  change's own implementation). Mitigation: the cleanup helper deletes
  each known key individually (`SigningKeyService`'s two storage keys,
  duplicated as a small constant in the harness since they're private
  there) instead of calling `deleteAll()`, and swallows
  `PlatformException` from each delete - the goal (the key doesn't exist)
  already holds either way.
- **[Risk]** Mid-route-transition, GoRouter briefly keeps the outgoing
  screen's widgets mounted alongside the incoming one, so an unscoped
  `find.text(...)` for a button label reused across screens (e.g. every
  onboarding step's "Continue") can match more than one widget and make
  `tester.tap()` throw "ambiguously found multiple matching widgets".
  Mitigation: every such tap is scoped with `find.descendant(of:
  find.byType(<ThatScreen>), matching: find.text(...))` rather than a bare
  `find.text(...)`.
- **[Risk]** `tester.enterText()` on this live binding has been observed to
  update the target `TextField`'s controller text (a naive "did the
  controller's `.text` end up right" check passes) without its `onChanged`
  callback ever actually firing - `MoneyAmountField`'s `onChangedMinor`
  never reached the ViewModel, so `_amountMinor` stayed null and Save kept
  failing its own validation silently downstream. Mitigation: `enterTextReliably`
  calls `tester.showKeyboard(target)` to explicitly focus the field first,
  then `tester.testTextInput.receiveAction(TextInputAction.done)` after
  entering, before checking success.
- **[Risk]** `RecordTransactionViewModel`'s account picker auto-selects
  once its accounts `watch()` stream delivers a value - real Drift I/O,
  not instant, and on the guided first-entry screen that stream's first
  useful value (the account `FirstAccountNameView` just created) can take
  a moment to arrive. Proceeding to enter an amount/category before that
  landed left `financialAccountId` null, surfacing as the same generic
  "Amount, account, and category are required." validation as the
  `enterText` issue above - two different root causes producing an
  identical-looking symptom. Mitigation: wait for the specific account
  name to appear (`pumpUntilFound(tester, find.text(<account name>))`)
  before touching anything else on that screen.
- **[Risk]** Letting a `testWidgets` body return (or `addTearDown`
  unmounting the tree) while a `go_router` redirect is still in flight -
  its own redirect chain re-runs `verifyChain()`/`hasAnyJournalEntries()`/etc.
  on every navigation, so one is almost always in flight right after the
  last navigation a scenario performs - throws `GoException: Exception
  during redirect: Channel was closed before receiving a response`, which
  `flutter_test` attributes to the test even though every `expect()` in it
  already passed ("but after the test had completed" in the failure
  output is the tell). Mitigation: pump for a couple of real seconds
  immediately after a scenario's last navigation/assertion, before the
  test body returns, and `resetToFreshDevice(tester)`'s own teardown pump
  does the same before unmounting, as a second layer.
- **[Risk]** The `enterText` → `onChanged` gap above is genuinely
  non-deterministic on this live binding, not merely slow: the identical
  onboarding sequence passed cleanly as this suite's first `testWidgets`
  and then failed the same way on its very next `testWidgets` in the same
  file/process. `MoneyAmountField`'s callback chain is fully synchronous
  (`setAmountMinor` just assigns and calls `notifyListeners()`, no async
  gap at all), so this isn't a timing/settle problem to poll longer for -
  it's binary, whether `onChanged` fires at all. Mitigation: the whole
  amount-entry-through-Save sequence in `completeOnboardingWithGuidedEntry`
  retries as one unit (re-entering the amount, not just re-tapping Save) up
  to 3 times, since retrying only the tap can't fix an amount that never
  truly registered.
- **[Risk]** The seed data creates 8 default categories, not 1 - a
  `tapReliably` success-check written assuming "Salary" is the only
  category with a "Hide" button (`find.text(actionHide).evaluate().length
  == 2`, one row + one confirm dialog) silently could never succeed, since
  the real count was 9. A generic finder assumption should be checked
  against the actual seed data, not the specific category a scenario cares
  about - `tapReliably`'s failure-dump (visible texts) is what surfaced
  this immediately once added.
- **[Risk]** A `tapReliably`/`enterTextReliably` success-check that only
  checks "does a `TextField`/target exist" can be trivially satisfied by
  something already on screen before the tap, silently masking a tap that
  never actually landed (observed: checking for "any `TextField`" after
  tapping the Register FAB passed instantly because Register's own search
  bar is already a `TextField`, so the flow proceeded to enter text into
  the search box instead of an entry form that was never reached).
  Mitigation: check for the specific screen/widget type the tap should
  have navigated to, never a generic "something exists" condition.
- **[Risk]** Even a flow proven correct and passing repeatedly (the same
  `completeOnboardingWithGuidedEntry` two other scenarios in this file
  pass reliably with) can still hang for the tier's full multi-minute
  `timeout` on an isolated run, with no different code path and no new
  error signature - observed once during this change's own
  implementation. This looks like genuine, irreducible flakiness in
  driving a live macOS window in this environment, not a remaining logic
  bug; not resolved here. A scenario timing out on a step that's
  otherwise reliable is worth a bare rerun before assuming a real
  regression.
- **[Risk]** After the tamper-detection scenario's "restart," the
  Register FAB (`find.byIcon(TablerIcons.plus)`) was not found at all
  (`ensureVisible` finding zero elements) in a run that otherwise
  completed the tamper-quarantine check correctly - unexplained, and
  distinct from every other issue logged here (not a scroll/bounds issue,
  not a stale-check issue, not an onboarding-timing issue). Not resolved
  in this change - the re-anchoring half of the tamper-detection scenario
  (recording a second entry after quarantine) was scoped out rather than
  chased further; whoever picks this up next should start by confirming
  whether the FAB genuinely doesn't render in this state or the finder
  itself is wrong, since the lock-badge check immediately before it
  passes reliably.
- **[Risk]** Real on-disk database + real keychain means a crashed test run
  (not just a failed one) could skip `addTearDown` → **Mitigation**: pre-run
  cleanup (Decision 3) runs before every invocation regardless of how the
  previous run ended.
- **[Risk]** This tier is slower than the existing in-memory integration
  tier and requires a real simulator/device to be available → **Mitigation**:
  it's manual and on-demand (Decision 4), never a merge blocker.
- **[Risk]** Broad coverage (Decision 5, groups 4–8) is a meaningful amount
  of new test code → **Mitigation**: grouped as independent task groups
  sharing one harness, so they can be implemented and land incrementally.
- **[Trade-off]** App Lock's biometric path stays unverified by this tier →
  accepted; documented as the trigger for adopting Patrol later (Decision 1,
  Option B) if that coverage becomes a priority.
