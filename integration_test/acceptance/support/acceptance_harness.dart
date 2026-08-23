import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    hide WindowsOptions, LinuxOptions, WebOptions, AndroidOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smara_accounting/data/repositories/settings_repository.dart';
import 'package:smara_accounting/domain/models/account_group.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_en.dart';
import 'package:smara_accounting/main.dart';
import 'package:smara_accounting/ui/features/onboarding/view_models/recovery_phrase_setup_view_model.dart';
import 'package:smara_accounting/ui/features/onboarding/views/currency_selection_view.dart';
import 'package:smara_accounting/ui/features/onboarding/views/first_account_name_view.dart';
import 'package:smara_accounting/ui/features/onboarding/views/recovery_phrase_confirm_view.dart';
import 'package:smara_accounting/ui/features/onboarding/views/recovery_phrase_view.dart';
import 'package:smara_accounting/ui/features/record_transaction/views/record_transaction_view.dart';

/// Real OS keychain access, matching the options
/// `FlutterSecureKeyStorage` (lib/domain/crypto/secure_key_storage.dart)
/// uses in production - macOS falls back to the legacy file-based Keychain
/// API since ad-hoc signed builds hang under the Data Protection Keychain.
const _secureStorage = FlutterSecureStorage(
  mOptions: MacOsOptions(usesDataProtectionKeychain: false),
);

/// The exact keys `SigningKeyService` (lib/domain/crypto/signing_key_service.dart)
/// writes under - duplicated here (both are private there) rather than
/// calling `FlutterSecureStorage.deleteAll()`, which fails under an ad-hoc
/// signed macOS build with `errSecMissingEntitlement` (-34018) even with
/// the same legacy-Keychain fallback options that make individual
/// read/write/delete calls (what the app itself actually uses) work fine.
const _secureStorageKeys = [
  'ledger_signing_private_key_seed',
  'ledger_pending_recovery_phrase_words',
];

/// Wipes every artifact a run of the real app leaves on this host: its
/// Application Support directory (home to the real Drift database file,
/// matching `app_database.dart`'s `_openConnection`) and every real OS
/// keychain entry it wrote. This is what "a fresh device" (design.md
/// Decision 2) means for this suite - the same reset simulates a
/// reinstall/new-device restore and, run before every test file's first
/// test, guarantees a crashed prior run's leftovers never contaminate the
/// next one (design.md Decision 3).
///
/// If [tester] is given, the currently-pumped widget tree is unmounted
/// first (`pumpWidget` an empty tree) so any open database connection is
/// closed via its `Provider`'s `dispose` callback before the file
/// underneath it is deleted - required when resetting mid-test (the
/// restore scenarios' "simulate a new device" step), not needed for the
/// very first, pre-run reset where nothing has been pumped yet.
Future<void> resetToFreshDevice([WidgetTester? tester]) async {
  if (tester != null) {
    // A settle pump first: unmounting immediately after the scenario's
    // last action can catch an in-flight go_router redirect Future,
    // which then throws once its channel is torn down mid-flight
    // ("Exception during redirect: Channel was closed before receiving a
    // response") - a teardown-only failure observed even on an otherwise
    // fully-passing run of this suite's own first scenario.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  }
  await _deleteDatabaseDirectory();
  for (final key in _secureStorageKeys) {
    try {
      await _secureStorage.delete(key: key);
    } on PlatformException {
      // Deleting a key that was never written throws
      // errSecMissingEntitlement on this ad-hoc signed macOS build's
      // legacy Keychain fallback, even though writing/deleting a key that
      // *does* exist (what the app itself actually does) does not. The
      // goal here - the key doesn't exist - already holds either way.
    }
  }
}

Future<void> _deleteDatabaseDirectory() async {
  final dir = await getApplicationSupportDirectory();
  if (dir.existsSync()) {
    dir.deleteSync(recursive: true);
  }
}

/// Simulates "this device lost its signing key but kept its books" - the
/// exact precondition `RestoreIdentityView`'s router gate checks
/// (`identity != null && !hasMatchingStoredKey`, app_router.dart's
/// redirect logic). Deliberately narrower than [resetToFreshDevice]: the
/// on-disk database is left untouched. `LedgerRepository.restoreIdentity`
/// looks up a pre-existing `signing_identities` row matching the derived
/// public key and throws if none is found - it never recreates ledger
/// data, so wiping the database here (as [resetToFreshDevice] does) would
/// send the router to fresh onboarding instead of `/restore`, not what
/// "restore onto this device" scenarios need.
Future<void> resetSigningKeyOnly(WidgetTester tester) async {
  // See resetToFreshDevice's matching comment: settle any in-flight
  // redirect before tearing down the widget tree.
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  for (final key in _secureStorageKeys) {
    try {
      await _secureStorage.delete(key: key);
    } on PlatformException {
      // See resetToFreshDevice's matching catch: deleting an
      // already-absent key throws errSecMissingEntitlement on this
      // ad-hoc signed macOS build's legacy Keychain fallback.
    }
  }
  await tester.pumpWidget(const SmaraAccountingApp());
  await tester.pump();
}

/// Pumps until [finder] resolves to at least one widget, or gives up after
/// [maxTries]. Real crypto/Keychain I/O per onboarding step is noticeably
/// slower on a real device than the INTEGRATION tier's in-memory doubles
/// (design.md Risks), so this polls in bounded slices rather than trusting
/// a single fixed-duration pump to be long enough.
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxTries = 200,
}) async {
  for (var i = 0; i < maxTries; i++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pump(const Duration(milliseconds: 100));
}

/// Enters [text] into whatever [fieldTarget] resolves to, then polls (like
/// [pumpUntilFound]) for [succeeded] to become true; if it doesn't, enters
/// the text again (up to [maxAttempts] times). Root cause confirmed during
/// this change's own implementation (design.md Risks): the live macOS
/// window opens at a fixed 800x600 - shorter than several onboarding/entry
/// screens' content - so a target below the fold sits outside the render
/// tree's bounds entirely until scrolled into view, exactly like
/// `integration_test/app_test.dart`'s own `ensureVisible` calls already
/// account for; `enterText`'s target can suffer the same problem, so this
/// scrolls it into view first too.
Future<void> enterTextReliably(
  WidgetTester tester,
  Finder Function() fieldTarget,
  String text,
  bool Function() succeeded, {
  int maxAttempts = 3,
}) async {
  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    // See tapReliably's matching try/catch: a previous attempt can have
    // already succeeded and navigated away just before its own poll
    // window closed, making this attempt's target legitimately gone.
    try {
      final target = fieldTarget();
      await tester.ensureVisible(target);
      await tester.pump(const Duration(milliseconds: 100));
      // Explicit focus first: on this live binding, `enterText` alone has
      // been observed to update the controller's raw text without the
      // field's `onChanged` callback actually firing (the ViewModel never
      // saw the value), unlike a virtual-clock widget test.
      await tester.showKeyboard(target);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(target, text);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.testTextInput.receiveAction(TextInputAction.done);
    } catch (_) {
      if (succeeded()) return;
      rethrow;
    }
    await tester.pump();
    for (var i = 0; i < 20; i++) {
      if (succeeded()) return;
      await tester.pump(const Duration(milliseconds: 100));
    }
  }
  fail(
    'enterTextReliably: "$text" never satisfied its success check after '
    '$maxAttempts attempts - failing loudly here rather than letting the '
    'flow silently continue in a state the caller assumed was reached.\n'
    '${_visibleTextsDump()}',
  );
}

/// Taps [tapTarget], then polls (like [pumpUntilFound]) for [succeeded] to
/// become true; if it doesn't within one poll cycle, taps again (up to
/// [maxAttempts] times) before giving up. Scrolls the target into view
/// first (`ensureVisible`) for the same reason [enterTextReliably] does -
/// the live macOS window's fixed 800x600 size means a target below the
/// fold is entirely outside the render tree's bounds, not just hard to
/// hit, matching `integration_test/app_test.dart`'s existing convention
/// for exactly this. The retry loop remains as a second layer, for any
/// tap that still misses despite being scrolled into view.
///
/// [innerTries] bounds how long each attempt polls for [succeeded] before
/// giving up and re-tapping - default 40 (4s) is enough for most taps, but
/// a submit that itself does real I/O (recording a transaction, posting a
/// transfer) can genuinely take longer than that to reach the screen
/// [succeeded] checks for. A tap that actually worked but wasn't detected
/// in time causes the *next* attempt's `tapTarget()` to resolve to zero
/// elements (the button is legitimately gone, having already navigated
/// away) - confirmed during this change's own implementation on a
/// cross-currency transfer submit.
Future<void> tapReliably(
  WidgetTester tester,
  Finder Function() tapTarget,
  bool Function() succeeded, {
  int maxAttempts = 3,
  int innerTries = 40,
}) async {
  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    // A previous attempt's tap can have actually worked and already
    // navigated away by the time this attempt starts (innerTries
    // exhausted just before `succeeded()` would have turned true) -
    // `tapTarget()`/`ensureVisible` then throws because the target is
    // legitimately gone, not because anything is actually wrong. Treat
    // that as success-already-happened rather than a real failure.
    try {
      final target = tapTarget();
      await tester.ensureVisible(target);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(target);
    } catch (e) {
      if (succeeded()) return;
      // ignore: avoid_print
      print(
        'tapReliably: target/ensureVisible/tap threw ($e) and succeeded() '
        'was still false - not the delayed-success case.\n'
        '${_visibleTextsDump()}',
      );
      rethrow;
    }
    for (var i = 0; i < innerTries; i++) {
      if (succeeded()) return;
      await tester.pump(const Duration(milliseconds: 100));
    }
  }
  fail(
    'tapReliably: success check never satisfied after $maxAttempts '
    'attempts - failing loudly here rather than letting the flow silently '
    'continue in a state the caller assumed was reached.\n'
    '${_visibleTextsDump()}',
  );
}

/// Every currently-rendered `Text` widget's data, for a failure message
/// that shows what screen/state a helper actually gave up on instead of
/// leaving that to be reconstructed by hand from a stack trace alone.
String _visibleTextsDump() {
  final texts = find
      .byType(Text)
      .evaluate()
      .map((e) => (e.widget as Text).data)
      .toList();
  return 'Visible texts at failure: $texts';
}

/// Finds a `TextField`/`MoneyAmountField` (which renders a bare
/// `TextField`) by its exact `InputDecoration.labelText`, rather than a
/// positional index into `find.byType(TextField)`. The investment dialogs
/// (Create account, Buy, Sell, Dividend) have several fields whose
/// presence and order shift with conditional branches (cash vs non-cash,
/// new-vs-existing instrument, gain vs loss category) - a label-based
/// finder stays correct regardless of which branch is showing, unlike
/// counting `.first`/`.at(n)` the way the simpler, linear onboarding
/// screens allowed elsewhere in this harness.
Finder textFieldWithLabel(String label) {
  return find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.labelText == label,
  );
}

/// Taps the `DropdownButtonFormField` labelled [fieldLabel] (an
/// `EntityPickerField`), opens it, and selects [optionText]. Scoped by
/// label rather than position for the same reason [textFieldWithLabel]
/// is - these dialogs have several dropdowns whose presence/order is
/// conditional.
Future<void> selectDropdownOption<T>(
  WidgetTester tester, {
  required String fieldLabel,
  required String optionText,
}) async {
  // T defaults to dynamic when unspecified (as it is at every existing
  // call site) - `is DropdownButtonFormField<dynamic>` still matches any
  // instantiation, since Dart's `is` checks are covariant in the type
  // argument. Callers only need to pass a concrete T (e.g.
  // `selectDropdownOption<ResearchTool>`) when a screen has more than one
  // DropdownButtonFormField of different value types sharing this label -
  // not needed anywhere in this suite yet, but kept general since this
  // helper is otherwise agnostic to the dropdown's value type.
  Finder dropdown() => find.byWidgetPredicate(
    (widget) =>
        widget is DropdownButtonFormField<T> &&
        widget.decoration.labelText == fieldLabel,
  );
  // [optionText] can already be visible elsewhere on screen (e.g. a
  // group name that's also a section header on the underlying Accounts
  // list, still present in the tree - just covered by the dialog's
  // modal barrier), so a bare find.text(optionText) presence check is
  // unreliable here, unlike most other dropdowns in this harness.
  //
  // A *closed* DropdownButtonFormField always keeps exactly one
  // DropdownMenuItem mounted - the currently selected value's own
  // rendered child - so counting DropdownMenuItem widgets can't tell
  // "menu open" from "menu closed" (that count is 1 either way) and
  // "isEmpty" can never become true once a selection exists. Instead,
  // check whether [optionText] is the dropdown's own current selection
  // by scoping the text search to the dropdown widget's subtree, which
  // sidesteps the underlying-screen collision entirely.
  bool isSelected() => find
      .descendant(of: dropdown(), matching: find.text(optionText))
      .evaluate()
      .isNotEmpty;

  if (isSelected()) return;

  for (var attempt = 0; attempt < 3 && !isSelected(); attempt++) {
    await tester.ensureVisible(dropdown());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(dropdown());
    await tester.pumpAndSettle();
    // The popup is pushed onto the root Overlay after the app's main
    // content, so its copy of optionText is the last match in traversal
    // order - the same convention this harness's other dropdowns rely
    // on for an unambiguous tap target.
    final option = find.text(optionText).last;
    if (option.evaluate().isNotEmpty) {
      await tester.tap(option);
      await tester.pumpAndSettle();
    } else {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  expect(
    isSelected(),
    isTrue,
    reason:
        'selectDropdownOption: "$optionText" was never selected for the '
        '"$fieldLabel" dropdown after retries.\n${_visibleTextsDump()}',
  );
}

/// Creates an investment account through the real Accounts GUI: Create
/// account -> check "This account holds investments" -> pick the seeded
/// "Investments" group -> optional opening cash -> Create. Assumes the
/// app is already on some screen with the bottom nav reachable (i.e.
/// after [completeOnboardingWithGuidedEntry]). Leaves the app on the
/// Accounts screen with the new account visible.
Future<void> createInvestmentAccountThroughGui(
  WidgetTester tester, {
  required String accountName,
  String? openingCashText,
  String groupName = 'Investments',
}) async {
  final l10n = AppLocalizationsEn();

  await tapReliably(
    tester,
    () => find.text(l10n.navAccounts),
    () => find.byType(FloatingActionButton).evaluate().isNotEmpty,
  );
  await tapReliably(
    tester,
    () => find.byType(FloatingActionButton),
    () => find.text(l10n.createAccount).evaluate().isNotEmpty,
  );

  await enterTextReliably(
    tester,
    () => find.byType(TextField).first,
    accountName,
    () {
      final field = find.byType(TextField).evaluate().first.widget as TextField;
      return field.controller?.text == accountName;
    },
  );

  // Type defaults to Asset, which is what makes the investments checkbox
  // available - no SegmentedButton interaction needed.
  await tapReliably(
    tester,
    () =>
        find.widgetWithText(CheckboxListTile, l10n.thisAccountHoldsInvestments),
    () {
      final checkbox =
          find
                  .widgetWithText(
                    CheckboxListTile,
                    l10n.thisAccountHoldsInvestments,
                  )
                  .evaluate()
                  .single
                  .widget
              as CheckboxListTile;
      return checkbox.value == true;
    },
  );

  // The group picker defaults to the first asset group (a seeded
  // default, not "Investments") - must be selected explicitly.
  await selectDropdownOption(
    tester,
    fieldLabel: l10n.groupLabel,
    optionText: groupName,
  );

  if (openingCashText != null) {
    await enterTextReliably(
      tester,
      () => textFieldWithLabel(l10n.openingBalanceOptional),
      openingCashText,
      () {
        final field =
            textFieldWithLabel(
                  l10n.openingBalanceOptional,
                ).evaluate().single.widget
                as TextField;
        return field.controller?.text == openingCashText;
      },
    );
  }

  // find.text() also matches the Name TextField's own EditableText, which
  // still renders `accountName` while the dialog is open - a trivially
  // true, collision-prone success signal (same class of bug as the group
  // dropdown's, described above). Check the dialog itself is gone instead.
  await tapReliably(
    tester,
    () => find.widgetWithText(ElevatedButton, l10n.actionCreate),
    () => find.byType(AlertDialog).evaluate().isEmpty,
    innerTries: 150,
  );
}

/// Opens [accountName]'s holdings screen from Home (the
/// `onInvestmentAccountTap` path - tapping the account's own row, not a
/// sub-icon). Waits for the "INVENTORY" section header, which only
/// renders on `HoldingsView`.
Future<void> openHoldingsFor(WidgetTester tester, String accountName) async {
  final l10n = AppLocalizationsEn();
  // find.text(accountName) alone is a collision-prone "landed on Home"
  // signal - a caller arriving here straight from the Accounts screen
  // (e.g. right after createInvestmentAccountThroughGui) already has that
  // same name visible there, so the check could be trivially satisfied
  // even if this tap's gesture itself silently missed. Requiring Home's
  // own always-present net-position text too rules that out.
  await tapReliably(
    tester,
    () => find.text(l10n.navHome),
    () =>
        find.text(l10n.homeWhatYouHaveMinusWhatYouOwe).evaluate().isNotEmpty &&
        find.text(accountName).evaluate().isNotEmpty,
  );
  // The account name can transiently satisfy the check above from the
  // outgoing screen's still-mounted widgets mid-transition, before Home
  // itself has actually settled - pumpAndSettle here so the next tap
  // targets Home's real, final ListTile rather than a ghost that's about
  // to be replaced.
  await tester.pumpAndSettle();
  await tapReliably(
    tester,
    () => find.ancestor(
      of: find.text(accountName),
      matching: find.byType(ListTile),
    ),
    () => find.text(l10n.holdingsInventory).evaluate().isNotEmpty,
    innerTries: 150,
  );
}

/// Records a cash-funded Buy of a *new* instrument through the real
/// holdings Buy dialog. Assumes the app is already on that account's
/// holdings screen (via [openHoldingsFor]). If [brokerageText] and
/// [brokerageExpenseCategory] are both given, fills the brokerage
/// fields; otherwise leaves them blank. If [expectSuccess] is false,
/// submits and waits for `errorInsufficientCash` instead of the
/// instrument appearing - for the zero-cash-rejected scenario.
Future<void> recordCashFundedBuyThroughGui(
  WidgetTester tester, {
  required String instrumentName,
  required String quantityText,
  required String unitPriceText,
  String? ticker,
  String? brokerageText,
  String? brokerageExpenseCategory,
  bool expectSuccess = true,
}) async {
  final l10n = AppLocalizationsEn();

  // Settles any still-running exit transition from whatever dialog the
  // caller's previous action just closed - tapping this button one frame
  // too early has been observed to throw "Bad state: No element" even
  // though its own text/success signal had already reported done.
  await tester.pumpAndSettle();

  await tapReliably(
    tester,
    () => find.widgetWithText(ElevatedButton, l10n.actionBuy),
    () => find.text(l10n.newInstrument).evaluate().isNotEmpty,
    innerTries: 150,
  );

  await tapReliably(
    tester,
    () => find.text(l10n.newInstrument),
    () => textFieldWithLabel(l10n.name).evaluate().isNotEmpty,
  );

  await enterTextReliably(
    tester,
    () => textFieldWithLabel(l10n.name),
    instrumentName,
    () {
      final field =
          textFieldWithLabel(l10n.name).evaluate().single.widget as TextField;
      return field.controller?.text == instrumentName;
    },
  );

  // Kind defaults to Stock - no picker interaction needed for the
  // common case this helper covers.

  if (ticker != null) {
    await enterTextReliably(
      tester,
      () => textFieldWithLabel(l10n.tickerOptional),
      ticker,
      () {
        final field =
            textFieldWithLabel(l10n.tickerOptional).evaluate().single.widget
                as TextField;
        return field.controller?.text == ticker;
      },
    );
  }

  await enterTextReliably(
    tester,
    () => textFieldWithLabel(l10n.quantity),
    quantityText,
    () {
      final field =
          textFieldWithLabel(l10n.quantity).evaluate().single.widget
              as TextField;
      return field.controller?.text == quantityText;
    },
  );

  await enterTextReliably(
    tester,
    () => textFieldWithLabel(l10n.unitPrice),
    unitPriceText,
    () {
      final field =
          textFieldWithLabel(l10n.unitPrice).evaluate().single.widget
              as TextField;
      return field.controller?.text == unitPriceText;
    },
  );

  if (brokerageText != null && brokerageExpenseCategory != null) {
    await enterTextReliably(
      tester,
      () => textFieldWithLabel(l10n.brokerageOptional),
      brokerageText,
      () {
        final field =
            textFieldWithLabel(l10n.brokerageOptional).evaluate().single.widget
                as TextField;
        return field.controller?.text == brokerageText;
      },
    );
    await selectDropdownOption(
      tester,
      fieldLabel: l10n.brokerageExpenseCategory,
      optionText: brokerageExpenseCategory,
    );
  }

  if (expectSuccess) {
    await tapReliably(
      tester,
      () => find.widgetWithText(ElevatedButton, l10n.actionRecordBuy),
      () =>
          find.text(instrumentName).evaluate().isNotEmpty &&
          find.text(l10n.actionRecordBuy).evaluate().isEmpty,
      innerTries: 150,
    );
  } else {
    final submit = find.widgetWithText(ElevatedButton, l10n.actionRecordBuy);
    await tester.ensureVisible(submit);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(submit);
    await pumpUntilFound(tester, find.text(l10n.errorInsufficientCash));
  }
}

const _weekdayAbbr = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _monthAbbr = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// The `showDatePicker` header's "EEE, MMM d" label for [date] (e.g. "Mon,
/// Sep 21") - what the dialog echoes once its input-mode text field has
/// successfully parsed a typed date.
String _datePickerHeaderLabel(DateTime date) =>
    '${_weekdayAbbr[date.weekday - 1]}, ${_monthAbbr[date.month - 1]} ${date.day}';

/// Sets a date in whichever real `showDatePicker` dialog is currently
/// open, via its "Switch to input" text-entry mode (a plain `mm/dd/yyyy`
/// TextField labelled "Enter Date") rather than the calendar day grid -
/// reachable regardless of which month the calendar happens to be
/// showing, unlike tapping a specific day number would be.
Future<void> pickDateViaTextEntry(WidgetTester tester, DateTime date) async {
  Finder dateField() => find.byWidgetPredicate(
    (widget) =>
        widget is TextField && widget.decoration?.labelText == 'Enter Date',
  );
  await tapReliably(
    tester,
    () => find.byTooltip('Switch to input'),
    () => dateField().evaluate().isNotEmpty,
  );
  final dateText =
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.year}';
  // This field's TextField has no exposed `controller` (InputDatePickerFormField
  // manages its own internal state), so `field.controller?.text` is always
  // null - the header's parsed-date echo is the only readable success
  // signal that the typed text was actually accepted.
  await enterTextReliably(
    tester,
    dateField,
    dateText,
    () => find.text(_datePickerHeaderLabel(date)).evaluate().isNotEmpty,
  );
  await tapReliably(
    tester,
    () => find.text('OK').last,
    () => dateField().evaluate().isEmpty,
  );
}

/// Taps the Buy/Sell dialog's "Lock until (optional)" row and sets it to
/// [date] via [pickDateViaTextEntry]. Assumes the dialog is already open.
Future<void> setLockUntilDate(WidgetTester tester, DateTime date) async {
  final l10n = AppLocalizationsEn();
  await tapReliably(
    tester,
    () => find.text(l10n.lockUntilOptional),
    () => find.byTooltip('Switch to input').evaluate().isNotEmpty,
  );
  await pickDateViaTextEntry(tester, date);
}

/// Records a non-cash-funded Buy of an *existing* instrument (selected by
/// name from the Instrument picker, unlike [recordCashFundedBuyThroughGui]
/// which always creates a new one) through the real Buy dialog. Assumes
/// the app is already on that account's holdings screen. If [lockUntil]
/// is given, sets it via [setLockUntilDate] before submitting.
Future<void> recordNonCashBuyThroughGui(
  WidgetTester tester, {
  required String instrumentName,
  required String quantityText,
  required String unitPriceText,
  required String incomeCategory,
  DateTime? lockUntil,
}) async {
  final l10n = AppLocalizationsEn();

  await tester.pumpAndSettle();

  await tapReliably(
    tester,
    () => find.widgetWithText(ElevatedButton, l10n.actionBuy),
    () => find.text(l10n.newInstrument).evaluate().isNotEmpty,
    innerTries: 150,
  );

  await tapReliably(
    tester,
    () => find.text(l10n.nonCash),
    () => find.text(l10n.incomeCategory).evaluate().isNotEmpty,
  );

  await selectDropdownOption(
    tester,
    fieldLabel: l10n.instrument,
    optionText: instrumentName,
  );

  await enterTextReliably(
    tester,
    () => textFieldWithLabel(l10n.quantity),
    quantityText,
    () {
      final field =
          textFieldWithLabel(l10n.quantity).evaluate().single.widget
              as TextField;
      return field.controller?.text == quantityText;
    },
  );

  await enterTextReliably(
    tester,
    () => textFieldWithLabel(l10n.unitPrice),
    unitPriceText,
    () {
      final field =
          textFieldWithLabel(l10n.unitPrice).evaluate().single.widget
              as TextField;
      return field.controller?.text == unitPriceText;
    },
  );

  if (lockUntil != null) {
    await setLockUntilDate(tester, lockUntil);
  }

  await selectDropdownOption(
    tester,
    fieldLabel: l10n.incomeCategory,
    optionText: incomeCategory,
  );

  await tapReliably(
    tester,
    () => find.widgetWithText(ElevatedButton, l10n.actionRecordBuy),
    () => find.text(l10n.actionRecordBuy).evaluate().isEmpty,
    innerTries: 150,
  );
}

/// Records a Sell through the real Sell dialog. Assumes the app is
/// already on the holdings screen and that the instrument to sell is
/// `viewModel.holdings.first` (true whenever a scenario has bought only
/// one instrument, which is all this suite's Sell scenarios do) - the
/// Sell dialog's own instrument picker is left at that default rather
/// than driven explicitly. If [expectSuccess] is false, submits once and
/// leaves the dialog open (a rejected Sell doesn't pop it) for the caller
/// to assert its own expected error text against.
Future<void> recordSellThroughGui(
  WidgetTester tester, {
  required String quantityText,
  required String unitPriceText,
  String? gainIncomeCategory,
  String? lossExpenseCategory,
  bool expectSuccess = true,
}) async {
  final l10n = AppLocalizationsEn();

  await tester.pumpAndSettle();

  await tapReliably(
    tester,
    () => find.widgetWithText(OutlinedButton, l10n.actionSell),
    () => find.text(l10n.recordTradeBlurb).evaluate().isNotEmpty,
  );

  await enterTextReliably(
    tester,
    () => textFieldWithLabel(l10n.quantity),
    quantityText,
    () {
      final field =
          textFieldWithLabel(l10n.quantity).evaluate().single.widget
              as TextField;
      return field.controller?.text == quantityText;
    },
  );

  await enterTextReliably(
    tester,
    () => textFieldWithLabel(l10n.unitPrice),
    unitPriceText,
    () {
      final field =
          textFieldWithLabel(l10n.unitPrice).evaluate().single.widget
              as TextField;
      return field.controller?.text == unitPriceText;
    },
  );

  if (gainIncomeCategory != null) {
    await selectDropdownOption(
      tester,
      fieldLabel: l10n.gainIncomeCategory,
      optionText: gainIncomeCategory,
    );
  }
  if (lossExpenseCategory != null) {
    await selectDropdownOption(
      tester,
      fieldLabel: l10n.lossExpenseCategory,
      optionText: lossExpenseCategory,
    );
  }

  final submit = find.widgetWithText(ElevatedButton, l10n.actionRecordSell);
  if (expectSuccess) {
    await tapReliably(
      tester,
      () => submit,
      () => find.text(l10n.actionRecordSell).evaluate().isEmpty,
      innerTries: 150,
    );
  } else {
    await tester.ensureVisible(submit);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(submit);
    await tester.pumpAndSettle();
  }
}

/// Records a Dividend through the real Dividend dialog. Assumes the app
/// is already on the holdings screen and that [instrumentName] is
/// `heldInstruments.first` (true whenever a scenario has ever bought only
/// one instrument for that account) - the dialog's own instrument picker
/// is left at that default rather than driven explicitly.
Future<void> recordDividendThroughGui(
  WidgetTester tester, {
  required String amountText,
  required String incomeCategory,
}) async {
  final l10n = AppLocalizationsEn();

  await tester.pumpAndSettle();

  await tapReliably(
    tester,
    () => find.widgetWithText(OutlinedButton, l10n.actionDividend),
    () => textFieldWithLabel(l10n.amount).evaluate().isNotEmpty,
  );

  await enterTextReliably(
    tester,
    () => textFieldWithLabel(l10n.amount),
    amountText,
    () {
      final field =
          textFieldWithLabel(l10n.amount).evaluate().single.widget as TextField;
      return field.controller?.text == amountText;
    },
  );

  await selectDropdownOption(
    tester,
    fieldLabel: l10n.incomeCategory,
    optionText: incomeCategory,
  );

  await tapReliably(
    tester,
    () => find.widgetWithText(ElevatedButton, l10n.actionRecordDividend),
    () => find.text(l10n.actionRecordDividend).evaluate().isEmpty,
    innerTries: 150,
  );
}

/// Navigates Accounts tab -> the app-bar Transfer icon (`l10n.actionTransfer`
/// tooltip) and waits for the Transfer screen (`l10n.captureMovedMoney`
/// used as both its title and submit button) to be reachable. Leaves the
/// screen open with its From/To pickers at whatever they last defaulted
/// to, for [submitTransferThroughGui] (or an inline assertion, e.g. that
/// an investment account's inventory companion never appears in either
/// picker) to act on next.
Future<void> openTransferScreen(WidgetTester tester) async {
  final l10n = AppLocalizationsEn();
  await tapReliably(
    tester,
    () => find.text(l10n.navAccounts),
    () => find.byTooltip(l10n.actionTransfer).evaluate().isNotEmpty,
  );
  await tapReliably(
    tester,
    () => find.byTooltip(l10n.actionTransfer),
    () => find.text(l10n.captureMovedMoney).evaluate().isNotEmpty,
  );
}

/// Fills and submits the Transfer screen already opened by
/// [openTransferScreen]. If [expectSuccess], waits for the whole screen
/// (title and button both read `l10n.captureMovedMoney`) to disappear -
/// TransferView pops back on success. If not, submits once and waits for
/// the inline `l10n.errorInvestmentCashExceeded` banner instead - the
/// screen is a full page (not a dialog), so a rejected submit just leaves
/// it exactly as is rather than closing anything.
Future<void> submitTransferThroughGui(
  WidgetTester tester, {
  required String fromAccountName,
  required String toAccountName,
  required String amountText,
  bool expectSuccess = true,
}) async {
  final l10n = AppLocalizationsEn();

  await selectDropdownOption(
    tester,
    fieldLabel: l10n.fromAccount,
    optionText: fromAccountName,
  );
  await selectDropdownOption(
    tester,
    fieldLabel: l10n.toAccount,
    optionText: toAccountName,
  );

  await enterTextReliably(
    tester,
    () => textFieldWithLabel(l10n.amount),
    amountText,
    () {
      final field =
          textFieldWithLabel(l10n.amount).evaluate().single.widget as TextField;
      return field.controller?.text == amountText;
    },
  );

  final submit = find.widgetWithText(ElevatedButton, l10n.captureMovedMoney);
  if (expectSuccess) {
    await tapReliably(
      tester,
      () => submit,
      () => find.text(l10n.captureMovedMoney).evaluate().isEmpty,
      innerTries: 150,
    );
  } else {
    await tester.ensureVisible(submit);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(submit);
    await pumpUntilFound(tester, find.text(l10n.errorInvestmentCashExceeded));
  }
}

/// Pops the current pushed route (e.g. the Transfer screen after a
/// rejected submit leaves it open) via its auto-generated AppBar back
/// button, back to whatever pushed it.
Future<void> popPushedScreen(WidgetTester tester) async {
  await tapReliably(
    tester,
    () => find.byType(BackButton),
    () => find.byType(BackButton).evaluate().isEmpty,
  );
}

/// Records a Spent transaction against [accountName] through the ordinary
/// Home FAB -> capture sheet -> `l10n.captureSpent` -> RecordTransactionView
/// flow (the same screen [completeOnboardingWithGuidedEntry] drives for
/// the guided first entry). Used to confirm an investment account behaves
/// like any other financial account here - this posts a plain expense,
/// decreasing the account's cash and never touching its inventory.
Future<void> recordSpentThroughGui(
  WidgetTester tester, {
  required String accountName,
  required String amountText,
  required String categoryName,
}) async {
  final l10n = AppLocalizationsEn();

  await tapReliably(
    tester,
    () => find.text(l10n.navHome),
    () => find.byType(FloatingActionButton).evaluate().isNotEmpty,
  );
  await tapReliably(
    tester,
    () => find.byType(FloatingActionButton),
    () => find.text(l10n.captureSpent).evaluate().isNotEmpty,
  );
  await tapReliably(
    tester,
    () => find.text(l10n.captureSpent),
    () => find.byType(RecordTransactionView).evaluate().isNotEmpty,
  );

  await selectDropdownOption(
    tester,
    fieldLabel: l10n.account,
    optionText: accountName,
  );

  await enterTextReliably(
    tester,
    () => find.byType(TextField).first,
    amountText,
    () {
      final field = find.byType(TextField).evaluate().first.widget as TextField;
      return field.controller?.text == amountText;
    },
  );

  await selectDropdownOption(
    tester,
    fieldLabel: l10n.category,
    optionText: categoryName,
  );

  await tapReliably(
    tester,
    () => find.descendant(
      of: find.byType(RecordTransactionView),
      matching: find.text(l10n.actionSave),
    ),
    () => find.byType(RecordTransactionView).evaluate().isEmpty,
    innerTries: 150,
  );
}

/// Pumps the real app from a completely fresh device
/// (`resetToFreshDevice` must already have run) all the way through the
/// real onboarding GUI and its mandatory guided first entry, landing on
/// Home with a real recovery phrase captured - the starting point every
/// acceptance scenario needs (design.md Decision 5), since there is no
/// pre-seeded identity to skip ahead with on this tier. Returns the 24
/// recovery-phrase words.
///
/// Walks: CurrencySelectionView (defaults to USD) -> FirstAccountNameView
/// (defaults to a starter name) -> RecordTransactionView (the guided first
/// entry, recording [amountText] against [categoryName]) ->
/// RecoveryPhraseView -> KeystoreExportView (Skip) ->
/// RecoveryPhraseConfirmView -> Home. Every step's ordering and the fixes
/// applied here were hard-won against a real macOS build - see design.md
/// Risks before changing this sequence.
Future<List<String>> completeOnboardingWithGuidedEntry(
  WidgetTester tester, {
  required String amountText,
  required String categoryName,
}) async {
  final l10n = AppLocalizationsEn();

  // The first-week-setup wizard is a separate onboarding concern (design.md
  // Decision 5, group 4) - skipped here the same way
  // integration_test/app_test.dart skips it for tests that aren't about the
  // wizard itself, so the confirm step below lands straight on Home.
  await SettingsRepository().setFirstWeekSetupCompleted(true);

  await tester.pumpWidget(const SmaraAccountingApp());
  await tester.pump();
  await pumpUntilFound(tester, find.byType(CurrencySelectionView));

  await tapReliably(
    tester,
    () => find.descendant(
      of: find.byType(CurrencySelectionView),
      matching: find.text(l10n.actionContinue),
    ),
    () => find.byType(FirstAccountNameView).evaluate().isNotEmpty,
  );

  await tapReliably(
    tester,
    () => find.descendant(
      of: find.byType(FirstAccountNameView),
      matching: find.text(l10n.actionContinue),
    ),
    () => find.byType(RecordTransactionView).evaluate().isNotEmpty,
  );

  // The account picker auto-selects once RecordTransactionViewModel's
  // account watch() stream delivers the account FirstAccountNameView just
  // created - real Drift I/O, not instant - so this waits for that
  // specific account name before entering anything else; proceeding too
  // early leaves financialAccountId null and Save silently blocked on
  // "Amount, account, and category are required." (design.md Risks).
  await pumpUntilFound(tester, find.text('Cash & Bank'));

  // The whole entry retries as a unit, not just the Save tap: `enterText`
  // updating the controller's raw text is a weak proxy for its `onChanged`
  // having actually reached the ViewModel (design.md Risks) - observed to
  // pass its own check yet still leave `_amountMinor` null, surfacing only
  // downstream as Save's validation failing. Retrying Save alone can't fix
  // that; re-entering the amount can.
  var saved = false;
  for (var attempt = 0; attempt < 3 && !saved; attempt++) {
    await enterTextReliably(
      tester,
      () => find.byType(TextField).first,
      amountText,
      () {
        final field =
            find.byType(TextField).evaluate().first.widget as TextField;
        return field.controller?.text == amountText;
      },
    );
    await tapReliably(
      tester,
      () => find.byType(DropdownButtonFormField<String>).last,
      () => find.text(categoryName).evaluate().isNotEmpty,
    );
    await tapReliably(
      tester,
      () => find.text(categoryName).last,
      () => find.text(categoryName).evaluate().length == 1,
    );
    await tester.tap(
      find.descendant(
        of: find.byType(RecordTransactionView),
        matching: find.text(l10n.actionSave),
      ),
    );
    for (var i = 0; i < 20 && !saved; i++) {
      if (find.text(l10n.iveSavedRecoveryPhrase).evaluate().isNotEmpty) {
        saved = true;
      } else {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }
  }
  if (!saved) {
    fail(
      'completeOnboardingWithGuidedEntry: Save never succeeded after 3 '
      'full re-entry attempts.\n${_visibleTextsDump()}',
    );
  }

  // Landing here also awaits the router's own redirect chain re-reading
  // hasAnyJournalEntries() from the real database - as slow, in real
  // wall-clock terms, as everything else real I/O touches in this suite,
  // so this polls as patiently as pumpUntilFound rather than a handful of
  // short tries.
  List<String>? words;
  for (var attempt = 0; attempt < 200 && words == null; attempt++) {
    final matches = find.byType(RecoveryPhraseView).evaluate();
    if (matches.length == 1) {
      words = (matches.single.widget as RecoveryPhraseView).viewModel.words;
    } else {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }
  if (words == null) {
    fail(
      'completeOnboardingWithGuidedEntry: RecoveryPhraseView never stably '
      'found.\n${_visibleTextsDump()}',
    );
  }

  await tapReliably(
    tester,
    () => find.text(l10n.iveSavedRecoveryPhrase),
    () => find.text(l10n.actionSkip).evaluate().isNotEmpty,
  );
  await tapReliably(
    tester,
    () => find.text(l10n.actionSkip),
    () => find.byType(RecoveryPhraseConfirmView).evaluate().isNotEmpty,
  );

  final wordFields = find.descendant(
    of: find.byType(RecoveryPhraseConfirmView),
    matching: find.byType(TextField),
  );
  for (
    var i = 0;
    i < RecoveryPhraseSetupViewModel.confirmationWordIndices.length;
    i++
  ) {
    await tester.enterText(
      wordFields.at(i),
      words[RecoveryPhraseSetupViewModel.confirmationWordIndices[i]],
    );
  }
  await tester.pump();
  // Confirming goes straight to Home - the identity (and its currency) was
  // already committed back at CurrencySelectionView.
  await tapReliably(
    tester,
    () => find.text(l10n.actionConfirm),
    () => find.text(l10n.homeWhatYouHaveMinusWhatYouOwe).evaluate().isNotEmpty,
  );

  return words;
}

/// Creates an account group named [name] with [currency] through the real
/// "Create group" dialog (Accounts screen's folder-plus tooltip). [kind]
/// defaults to an asset group; pass [AccountGroupKind.liabilityGroup] for
/// a liability one (taps the dialog's own Asset/Liability segment first).
///
/// Submits with a single explicit tap, not tapReliably's retry-by-
/// re-tapping: this dialog's Create button has been observed, across
/// multiple independent scenarios, to sometimes close the dialog without
/// the group ever appearing in the list (consistent with, though not
/// confirmed as, a tap landing on the modal barrier instead of the
/// button). Once the dialog is gone - whether from a real create or a
/// missed tap - a retry's tapTarget() finds nothing and throws, and
/// "target now gone" is indistinguishable from real success at that
/// point, so tapReliably's own "already succeeded" heuristic would wrongly
/// treat a barrier-dismiss as success. Waited out patiently instead, with
/// a loud failure if the group genuinely never appears.
Future<void> createGroupThroughGui(
  WidgetTester tester, {
  required String name,
  required String currency,
  AccountGroupKind kind = AccountGroupKind.assetGroup,
}) async {
  final l10n = AppLocalizationsEn();

  await tapReliably(
    tester,
    () => find.text(l10n.navAccounts),
    () => find.byTooltip(l10n.createGroup).evaluate().isNotEmpty,
  );
  await tapReliably(
    tester,
    () => find.byTooltip(l10n.createGroup),
    () => find.byType(AlertDialog).evaluate().isNotEmpty,
  );
  await enterTextReliably(tester, () => find.byType(TextField).first, name, () {
    final field = find.byType(TextField).evaluate().first.widget as TextField;
    return field.controller?.text == name;
  });
  if (kind == AccountGroupKind.liabilityGroup) {
    await tapReliably(tester, () => find.text(l10n.liability), () {
      final segmented =
          find
                  .byType(SegmentedButton<AccountGroupKind>)
                  .evaluate()
                  .single
                  .widget
              as SegmentedButton<AccountGroupKind>;
      return segmented.selected.contains(AccountGroupKind.liabilityGroup);
    });
  }
  await tapReliably(
    tester,
    () => find.widgetWithText(ChoiceChip, currency),
    () {
      final chip =
          find.widgetWithText(ChoiceChip, currency).evaluate().single.widget
              as ChoiceChip;
      return chip.selected;
    },
  );

  final createButton = find.widgetWithText(ElevatedButton, l10n.actionCreate);
  await tester.ensureVisible(createButton);
  await tester.pump(const Duration(milliseconds: 100));
  await tester.tap(createButton);
  await pumpUntilFound(tester, find.text(name), maxTries: 300);
  if (find.text(name).evaluate().isEmpty) {
    fail(
      'createGroupThroughGui: "$name" never appeared after tapping '
      'Create.\nVisible texts: '
      '${find.byType(Text).evaluate().map((e) => (e.widget as Text).data).toList()}',
    );
  }
  // The dialog can still be mid-exit-animation right as its name text
  // becomes findable, leaving the underlying screen not yet properly
  // hit-testable for whatever the caller does next.
  await tester.pumpAndSettle();
}

/// Taps the already-open "Create account" dialog's Create button and
/// waits for [name] to appear - the final step of scripting that dialog,
/// with everything before it (name/type/group/etc.) left to the caller,
/// since those vary per scenario. Same single-explicit-tap-then-patient-
/// wait rationale as [createGroupThroughGui]: this dialog's Create button
/// has shown the same "dialog closes but nothing was created" flake.
Future<void> createAccountButtonTapThroughGui(
  WidgetTester tester, {
  required String name,
}) async {
  final l10n = AppLocalizationsEn();
  final createButton = find.widgetWithText(ElevatedButton, l10n.actionCreate);
  await tester.ensureVisible(createButton);
  await tester.pump(const Duration(milliseconds: 100));
  await tester.tap(createButton);
  await pumpUntilFound(tester, find.text(name), maxTries: 300);
  if (find.text(name).evaluate().isEmpty) {
    fail(
      'createAccountButtonTapThroughGui: "$name" never appeared after '
      'tapping Create.\nVisible texts: '
      '${find.byType(Text).evaluate().map((e) => (e.widget as Text).data).toList()}',
    );
  }
  // The dialog can still be mid-exit-animation right as its name text
  // becomes findable, leaving the underlying screen not yet properly
  // hit-testable for whatever the caller does next.
  await tester.pumpAndSettle();
}

/// Archives (hides) [accountName] through the real Accounts screen: opens
/// its row's overflow menu, taps Hide, then confirms the destructive
/// dialog. `PopupMenuButton<_AccountAction>`'s type argument is private to
/// account_management_view.dart, so it's matched with a raw `is
/// PopupMenuButton` predicate (which - unlike `find.byType`, an exact
/// runtimeType match - matches any generic instantiation) rather than by
/// type argument.
Future<void> archiveAccountThroughGui(
  WidgetTester tester,
  String accountName,
) async {
  final l10n = AppLocalizationsEn();

  Finder accountTile() => find.ancestor(
    of: find.text(accountName),
    matching: find.byType(ListTile),
  );

  // accountTile() alone is collision-prone as an "on Accounts now" signal
  // - Home shows the same account inside its own ListTile too, so that
  // check could already be trivially true before this tap ever lands.
  // The Transfer tooltip only exists on the Accounts screen's app bar.
  await tapReliably(
    tester,
    () => find.text(l10n.navAccounts),
    () => find.byTooltip(l10n.actionTransfer).evaluate().isNotEmpty,
  );

  await tapReliably(
    tester,
    () => find.descendant(
      of: accountTile(),
      matching: find.byWidgetPredicate((widget) => widget is PopupMenuButton),
    ),
    () => find.text(l10n.actionHide).evaluate().isNotEmpty,
  );

  await tapReliably(
    tester,
    () => find.text(l10n.actionHide).last,
    () => find.text(l10n.hideAccountTitle).evaluate().isNotEmpty,
  );

  await tapReliably(
    tester,
    () => find.widgetWithText(OutlinedButton, l10n.actionHide),
    () => find.text(l10n.hideAccountTitle).evaluate().isEmpty,
  );
}

/// Closes out [accountName] (already archived - selected in Register via
/// its `l10n.nameHidden` label) to [toAccountName] through the real
/// "Transfer remaining balance" flow. Assumes `toAccountName` is already
/// `closeoutDestinationCandidates.first`, the dialog's default - true
/// whenever it's the only other eligible account, as in this suite's
/// scenarios. Waits for the trigger button itself to disappear on success
/// (it's gated on the account's balance being positive, so a successful
/// zero-out hides it, not just the dialog closing).
Future<void> closeoutArchivedAccountThroughGui(
  WidgetTester tester, {
  required String accountName,
  required String toAccountName,
}) async {
  final l10n = AppLocalizationsEn();
  final hiddenName = l10n.nameHidden(accountName);

  await tapReliably(
    tester,
    () => find.text(l10n.navRegister),
    () => find.text(l10n.account).evaluate().isNotEmpty,
  );

  await selectDropdownOption(
    tester,
    fieldLabel: l10n.account,
    optionText: hiddenName,
  );

  await tapReliably(
    tester,
    () => find.widgetWithText(OutlinedButton, l10n.transferRemainingBalance),
    () => find.text(l10n.transferRemainingBalance).evaluate().length > 1,
  );

  await tapReliably(
    tester,
    () => find.widgetWithText(ElevatedButton, l10n.actionTransfer),
    () => find.text(l10n.transferRemainingBalance).evaluate().isEmpty,
    innerTries: 150,
  );
}

/// A fake [FilePickerPlatform] that `settings_view.dart`'s real
/// `FilePicker.saveFile`/`FilePicker.pickFiles` calls delegate to once
/// installed as [FilePickerPlatform.instance] - design.md rejected
/// Patrol/Maestro/Appium, so no real native file-picker dialog is ever
/// driven here. `FilePicker`'s own static methods are a thin wrapper over
/// `FilePickerPlatform.instance`, itself a swappable `PlatformInterface`
/// singleton (the same seam every federated Flutter plugin exposes for
/// exactly this purpose) - intercepting there means the app's real
/// export/import code paths still run for real, only the native OS dialog
/// is replaced.
class FakeFilePickerPlatform extends FilePickerPlatform {
  /// The bytes most recently passed to [saveFile] - what a Save Backup
  /// dialog actually produced. Null until a save happens; helpers that
  /// watch this field for a save to complete reset it to null first.
  Uint8List? lastSavedBytes;

  /// What the next [pickFiles] call resolves to - set before driving the
  /// "Choose file" button to simulate the user picking that file.
  List<PlatformFile> filesToReturn = const [];

  @override
  Future<Uri?> saveFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    String? dialogTitle,
    String? initialDirectory,
    Function(FilePickerStatus)? onFileSaving,
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    lastSavedBytes = bytes;
    return Uri.file(fileName);
  }

  @override
  Future<List<PlatformFile>> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    return filesToReturn;
  }
}

/// A [PlatformFile] wrapping in-memory [bytes] - what
/// [FakeFilePickerPlatform.pickFiles] hands back. Only [name] and
/// [readAsBytes] are exercised by this app's real restore-backup code
/// path (`settings_view.dart`'s `file?.readAsBytes()`); every other
/// member throws, since nothing in this suite calls them. `PlatformFile`
/// is an `abstract base class`, not `final`/`sealed`, so it can be
/// `extends`-ed from outside its own package (only `implements` is
/// restricted) - the same mechanism used to fake any other federated
/// plugin's platform interface.
base class InMemoryPlatformFile extends PlatformFile {
  InMemoryPlatformFile({required this.name, required Uint8List bytes})
    : _bytes = bytes;

  @override
  final String name;
  final Uint8List _bytes;

  @override
  Future<Uint8List> readAsBytes() async => _bytes;

  @override
  Future<int> length() async => _bytes.length;

  @override
  Stream<Uint8List> readAsByteStream() => Stream.value(_bytes);

  @override
  Uri get uri => Uri.file(name);

  // Return type deliberately omitted (inferred from the overridden
  // getter) so this file doesn't need to import cross_file's XFile just
  // to name a type this suite never actually constructs or calls.
  @override
  get xFile => throw UnimplementedError('unused in acceptance tests');
}

/// Opens Settings from wherever the bottom nav is reachable - the app's
/// only entry point (`home_view.dart`'s settings-gear tooltip on Home's
/// AppBar). Lands with the Settings screen's Backup section visible.
Future<void> openSettings(WidgetTester tester) async {
  final l10n = AppLocalizationsEn();

  // The bottom-nav/rail branches (`AppShell`'s `StatefulNavigationShell`)
  // are backed by an IndexedStack, not per-branch Offstage/Route
  // wrapping - `find.text`'s default skipOffstage only excludes Offstage
  // widgets and inactive Routes (flutter_test's own doc comment), neither
  // of which IndexedStack's non-selected children are. Confirmed directly
  // during this change's own implementation: once Home has been visited
  // once, both its overview text AND its settings-gear tooltip keep
  // resolving via `find` even while a different branch (e.g. Register) is
  // the one actually on screen - so a "does this text exist" check can
  // never distinguish "Home is active" from "Home was merely visited
  // earlier and IndexedStack kept it alive offstage". A single direct tap
  // + settle is used instead, exactly like this harness's Create-dialog
  // helpers - final success is verified only once, at the real
  // destination (Settings actually reached), not at this intermediate
  // step.
  // Scoped to the NavigationRail specifically (not a bare find.text) -
  // when already on Home, its own AppBar title is *also* literally
  // Text(l10n.navHome) (home_view.dart), so an unscoped finder matches
  // both and ensureVisible's ".single" throws "Too many elements". This
  // suite's live macOS window (800x600, > the 600 breakpoint in
  // app_shell.dart) always renders the NavigationRail layout, never the
  // narrow-screen BottomNavigationBar.
  final homeTab = find.descendant(
    of: find.byType(NavigationRail),
    matching: find.text(l10n.navHome),
  );
  await tester.ensureVisible(homeTab);
  await tester.pump(const Duration(milliseconds: 100));
  await tester.tap(homeTab);
  await tester.pumpAndSettle();

  final gearIcon = find.byTooltip(l10n.settingsTitle);
  await tester.ensureVisible(gearIcon);
  await tester.pump(const Duration(milliseconds: 100));
  await tester.tap(gearIcon);
  await pumpUntilFound(tester, find.text(l10n.settingsBackup), maxTries: 300);
  if (find.text(l10n.settingsBackup).evaluate().isEmpty) {
    fail(
      'openSettings: Settings screen never appeared after tapping Home '
      'then the settings gear.\n${_visibleTextsDump()}',
    );
  }
}

/// Scrolls the nearest `Scrollable` until [finder] is built and visible.
/// Needed before interacting with anything the Settings screen's long
/// `ListView` hasn't built yet - the live macOS window's fixed 800x600
/// size (design.md Risks) means most of that screen's content starts out
/// virtualized away entirely, not just scrolled off-screen, so a bare
/// `ensureVisible` (which needs the target to already be in the tree)
/// isn't enough on its own. Tries both scroll directions since this
/// suite has never definitively pinned down `scrollUntilVisible`'s sign
/// convention here (matching `currency_transfers_test.dart`'s own
/// account-currency scenario, which hit the same thing).
Future<void> scrollUntilVisibleBidirectional(
  WidgetTester tester,
  Finder finder,
) async {
  try {
    await tester.scrollUntilVisible(
      finder,
      -300.0,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 20,
    );
  } catch (_) {
    await tester.scrollUntilVisible(
      finder,
      300.0,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 20,
    );
  }
}

/// Saves a backup through the real Settings -> "Save backup" dialog with
/// [passphrase], via [filePicker] (already installed as
/// [FilePickerPlatform.instance]) intercepting the real
/// `FilePicker.saveFile` call. Returns the exported ciphertext bytes.
///
/// Success is checked via [filePicker]'s own captured state
/// (`lastSavedBytes` becoming non-null) rather than "the dialog closed" -
/// unlike the Create-group/Create-account dialogs elsewhere in this
/// harness, this dialog's real work (AES-256-GCM/PBKDF2 export, then the
/// save call) gives an unambiguous, non-racy success signal to poll for
/// directly, so there's no barrier-dismiss-vs-real-success ambiguity to
/// work around here.
Future<Uint8List> saveBackupThroughGui(
  WidgetTester tester, {
  required String passphrase,
  required FakeFilePickerPlatform filePicker,
}) async {
  final l10n = AppLocalizationsEn();
  await openSettings(tester);

  final saveBackupButton = find.widgetWithText(
    ElevatedButton,
    l10n.actionSaveBackup,
  );
  await scrollUntilVisibleBidirectional(tester, saveBackupButton);
  await tapReliably(
    tester,
    () => saveBackupButton,
    () => find.text(l10n.choosePassphraseTitle).evaluate().isNotEmpty,
  );

  Finder passphraseField() => find.descendant(
    of: find.byType(AlertDialog),
    matching: find.byType(TextField),
  );
  await enterTextReliably(tester, passphraseField, passphrase, () {
    final elements = passphraseField().evaluate();
    if (elements.isEmpty) return false;
    final field = elements.first.widget as TextField;
    return field.controller?.text == passphrase;
  });

  filePicker.lastSavedBytes = null;
  final saveButton = find.widgetWithText(ElevatedButton, l10n.actionSave);
  await tester.ensureVisible(saveButton);
  await tester.pump(const Duration(milliseconds: 100));
  await tester.tap(saveButton);
  for (var i = 0; i < 300 && filePicker.lastSavedBytes == null; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  if (filePicker.lastSavedBytes == null) {
    fail(
      'saveBackupThroughGui: FilePicker.saveFile was never called after '
      'tapping Save.\n${_visibleTextsDump()}',
    );
  }
  await tester.pumpAndSettle();
  return filePicker.lastSavedBytes!;
}

/// Restores a backup through the real Settings -> "Restore backup"
/// dialog: simulates picking a file containing [fileBytes] (via
/// [filePicker], already installed as [FilePickerPlatform.instance]),
/// enters [passphrase], then confirms the destructive "Replace your local
/// books?" dialog.
///
/// Deliberately does NOT tap the post-restore "Close app" button -
/// `settings_view.dart`'s `_showRestoredSuccessDialog` wires that to
/// `exit(0)` on desktop, which would kill this very test process rather
/// than just the widget tree. Instead, once `l10n.backupRestored`
/// appears, unmounts/remounts [SmaraAccountingApp] the same way this
/// suite's tamper-detection restart scenario does, so a fresh database
/// connection reads the just-replaced file - literally what
/// `backupRestoredBody`'s "close and reopen the app" means here.
///
/// If [expectRejection] is true, asserts the restore is instead rejected
/// (foreign-identity backup onto a device with its own active identity):
/// the Restore Backup dialog stays open showing
/// `l10n.errorForeignBackupIdentity`, nothing was written to disk, and no
/// unmount/remount happens - the dialog is left open for the caller to
/// dismiss.
Future<void> restoreBackupThroughGui(
  WidgetTester tester, {
  required Uint8List fileBytes,
  required String passphrase,
  required FakeFilePickerPlatform filePicker,
  String fileName = 'restored.smarabackup',
  bool expectRejection = false,
}) async {
  final l10n = AppLocalizationsEn();
  await openSettings(tester);

  final restoreBackupButton = find.widgetWithText(
    OutlinedButton,
    l10n.actionRestoreBackup,
  );
  await scrollUntilVisibleBidirectional(tester, restoreBackupButton);
  await tapReliably(
    tester,
    () => restoreBackupButton,
    () => find.text(l10n.restoreBackupBlurb).evaluate().isNotEmpty,
  );

  filePicker.filesToReturn = [
    InMemoryPlatformFile(name: fileName, bytes: fileBytes),
  ];
  await tapReliably(
    tester,
    () => find.widgetWithText(OutlinedButton, l10n.actionChooseFile),
    () => find.text(fileName).evaluate().isNotEmpty,
  );

  Finder passphraseField() => find.descendant(
    of: find.byType(AlertDialog),
    matching: find.byType(TextField),
  );
  await enterTextReliably(tester, passphraseField, passphrase, () {
    final elements = passphraseField().evaluate();
    if (elements.isEmpty) return false;
    final field = elements.first.widget as TextField;
    return field.controller?.text == passphrase;
  });

  final restoreButton = find.widgetWithText(ElevatedButton, l10n.actionRestore);
  await tester.ensureVisible(restoreButton);
  await tester.pump(const Duration(milliseconds: 100));
  await tester.tap(restoreButton);
  await pumpUntilFound(tester, find.text(l10n.replaceBooksTitle));
  if (find.text(l10n.replaceBooksTitle).evaluate().isEmpty) {
    fail(
      'restoreBackupThroughGui: the destructive confirmation dialog never '
      'appeared after tapping Restore.\n${_visibleTextsDump()}',
    );
  }

  final replaceButton = find.widgetWithText(OutlinedButton, l10n.actionReplace);
  await tester.ensureVisible(replaceButton);
  await tester.pump(const Duration(milliseconds: 100));
  await tester.tap(replaceButton);

  if (expectRejection) {
    await pumpUntilFound(
      tester,
      find.text(l10n.errorForeignBackupIdentity),
      maxTries: 300,
    );
    if (find.text(l10n.errorForeignBackupIdentity).evaluate().isEmpty) {
      fail(
        'restoreBackupThroughGui: expected rejection '
        '("${l10n.errorForeignBackupIdentity}") never appeared.\n'
        '${_visibleTextsDump()}',
      );
    }
    return;
  }

  await pumpUntilFound(tester, find.text(l10n.backupRestored), maxTries: 300);
  if (find.text(l10n.backupRestored).evaluate().isEmpty) {
    fail(
      'restoreBackupThroughGui: "${l10n.backupRestored}" never appeared '
      'after confirming replace.\n${_visibleTextsDump()}',
    );
  }

  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpWidget(const SmaraAccountingApp());
  await tester.pump();
  await pumpUntilFound(tester, find.text(l10n.homeWhatYouHaveMinusWhatYouOwe));
}
