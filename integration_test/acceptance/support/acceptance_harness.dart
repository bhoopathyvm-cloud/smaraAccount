import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smara_accounting/data/repositories/settings_repository.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_en.dart';
import 'package:smara_accounting/main.dart';
import 'package:smara_accounting/ui/features/onboarding/view_models/recovery_phrase_setup_view_model.dart';
import 'package:smara_accounting/ui/features/onboarding/views/currency_selection_view.dart';
import 'package:smara_accounting/ui/features/onboarding/views/first_account_name_view.dart';
import 'package:smara_accounting/ui/features/onboarding/views/recovery_phrase_confirm_view.dart';
import 'package:smara_accounting/ui/features/onboarding/views/recovery_phrase_view.dart';
import 'package:smara_accounting/ui/features/record_transaction/views/record_transaction_view.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

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
  // app-lock PIN hash (acceptance-app-lock-unlock) - must clear between
  // runs or a leftover PIN leaks into the next scenario's lock state.
  'app_lock_pin_record',
];

/// Wipes every artifact a run of the real app leaves on this host: its
/// Application Support directory (home to the real Drift database file,
/// matching `app_database.dart`'s `_openConnection`), every real OS
/// keychain entry it wrote, and every real `SharedPreferences` key
/// (`SettingsRepository`'s first-week-setup flag, app-lock/locale/FX
/// toggles, and so on - these persist to a real on-disk store exactly
/// like the database and keychain do, so leaving them alone would let one
/// test's settings silently leak into the next). This is what "a fresh
/// device" (design.md Decision 2) means for this suite - the same reset
/// simulates a reinstall/new-device restore and, run before every test
/// file's first test, guarantees a crashed prior run's leftovers never
/// contaminate the next one (design.md Decision 3).
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
  await SharedPreferencesAsync().clear();
}

Future<void> _deleteDatabaseDirectory() async {
  final dir = await getApplicationSupportDirectory();
  Object? lastError;
  for (var attempt = 0; attempt < 5; attempt++) {
    try {
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
      return;
    } catch (error) {
      lastError = error;
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
  }
  if (lastError != null) {
    throw lastError;
  }
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
  bool scrollIntoView = true,
}) async {
  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    // A previous attempt's tap can have actually worked and already
    // navigated away by the time this attempt starts (innerTries
    // exhausted just before `succeeded()` would have turned true) -
    // `tapTarget()`/`ensureVisible` then throws because the target is
    // legitimately gone, not because anything is actually wrong. Treat
    // that as success-already-happened rather than a real failure.
    try {
      var target = tapTarget();
      for (var i = 0; i < innerTries && target.evaluate().isEmpty; i++) {
        if (succeeded()) return;
        await tester.pump(const Duration(milliseconds: 100));
        target = tapTarget();
      }
      if (scrollIntoView && target.hitTestable().evaluate().isEmpty) {
        await tester.ensureVisible(target);
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.tap(
        target.hitTestable().evaluate().isNotEmpty
            ? target.hitTestable()
            : target,
        warnIfMissed: false,
      );
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

/// Shell destinations on a wide window are a [NavigationRail] whose
/// unselected labels are not hit-testable (`labelType: selected`). Tap the
/// rail/bar icon instead of [find.text].
Finder shellNavIcon(IconData icon) {
  final inRail = find.descendant(
    of: find.byType(NavigationRail),
    matching: find.byIcon(icon),
  );
  if (inRail.evaluate().isNotEmpty) return inRail;
  final inBar = find.descendant(
    of: find.byType(BottomNavigationBar),
    matching: find.byIcon(icon),
  );
  if (inBar.evaluate().isNotEmpty) return inBar;
  return find.byIcon(icon);
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
  bool skipFirstWeekSetup = true,
}) async {
  final l10n = AppLocalizationsEn();

  // The first-week-setup wizard is a separate onboarding concern (design.md
  // Decision 5, group 4) - skipped here the same way
  // integration_test/app_test.dart skips it for tests that aren't about the
  // wizard itself, so the confirm step below lands straight on Home.
  // [skipFirstWeekSetup] false (the wizard's own acceptance coverage) lands
  // on FirstWeekSetupView instead - see the final success check below.
  if (skipFirstWeekSetup) {
    await SettingsRepository().setFirstWeekSetupCompleted(true);
  }

  await tester.pumpWidget(const SmaraAccountingApp());
  await tester.pump();
  await pumpUntilFound(tester, find.byType(CurrencySelectionView));
  if (find.byType(CurrencySelectionView).evaluate().isEmpty) {
    fail(
      'completeOnboardingWithGuidedEntry: CurrencySelectionView never '
      'appeared (device may not have been reset).\n$_visibleTextsDump()',
    );
  }

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

  // Amount field must be keyed by label: the form also has the optional
  // transaction-currency TextField (and a description field), so
  // find.byType(TextField).first is not stably the amount.
  Finder amountField() => textFieldWithLabel(l10n.amount);

  // The whole entry retries as a unit, not just the Save tap: `enterText`
  // updating the controller's raw text is a weak proxy for its `onChanged`
  // having actually reached the ViewModel (design.md Risks) - observed to
  // pass its own check yet still leave `_amountMinor` null, surfacing only
  // downstream as Save's validation failing. Retrying Save alone can't fix
  // that; re-entering the amount can.
  //
  // Category selection must go through [selectDropdownOption]: closed
  // DropdownButtonFormFields keep every DropdownMenuItem mounted offstage,
  // so `find.text(categoryName).isNotEmpty` is true before any pick and a
  // naive tap "succeeds" without setting categoryId - then Save fails with
  // "Amount, account, and category are required." That false-positive is
  // much more likely on the second scenario in a file (categories already
  // warmed), which is how home_and_lock_test flakes after a full suite.
  var saved = false;
  for (var attempt = 0; attempt < 3 && !saved; attempt++) {
    await enterTextReliably(tester, amountField, amountText, () {
      final field = amountField().evaluate().single.widget as TextField;
      return field.controller?.text == amountText;
    });
    await selectDropdownOption(
      tester,
      fieldLabel: l10n.category,
      optionText: categoryName,
    );
    // Save is often below the live 800x600 fold (design.md Risks) - a raw
    // tap() hits whatever sits at that offset instead of the button, and
    // the miss is silent enough that the 2s recovery-phrase poll just
    // retries the whole entry forever on a wedged run. tapReliably scrolls
    // it into view and re-taps until the phrase screen appears.
    // Catch so a failed Save attempt can re-enter amount/category (same
    // pattern as core_ledger_test's re-anchoring Save loop).
    try {
      await tapReliably(
        tester,
        () => find.descendant(
          of: find.byType(RecordTransactionView),
          matching: find.text(l10n.actionSave),
        ),
        () => find.text(l10n.iveSavedRecoveryPhrase).evaluate().isNotEmpty,
        innerTries: 150,
      );
      saved = true;
    } catch (_) {
      if (attempt == 2) rethrow;
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
  // Confirming goes straight to Home when the wizard is pre-skipped - the
  // identity (and its currency) was already committed back at
  // CurrencySelectionView. With [skipFirstWeekSetup] false, it lands on
  // FirstWeekSetupView instead (app_router.dart's redirect chain).
  await tapReliably(
    tester,
    () => find.text(l10n.actionConfirm).hitTestable(),
    () =>
        find.byType(RecoveryPhraseConfirmView).evaluate().isEmpty &&
        (skipFirstWeekSetup
            ? find
                  .text(l10n.homeWhatYouHaveMinusWhatYouOwe)
                  .evaluate()
                  .isNotEmpty
            : find.text(l10n.firstWeekTitle).evaluate().isNotEmpty),
    innerTries: 150,
  );

  return words;
}

Finder textFieldWithLabel(String label) {
  return find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.labelText == label,
  );
}

Finder dropdownWithLabel(String label) {
  return find.byWidgetPredicate((widget) {
    if (widget is! DropdownButtonFormField<String>) return false;
    return widget.decoration.labelText == label;
  });
}

/// Closed [DropdownButton]s keep every [DropdownMenuItem] in an offstage
/// [IndexedStack], so counting mounted items is not an "open" signal.
/// The overlay route's private `_DropdownMenu<T>` exists only while the
/// menu is showing.
bool dropdownOverlayOpen() => find
    .byWidgetPredicate(
      (widget) => widget.runtimeType.toString().startsWith('_DropdownMenu<'),
    )
    .evaluate()
    .isNotEmpty;

Finder dropdownMenu() => find.byWidgetPredicate(
  (widget) => widget.runtimeType.toString().startsWith('_DropdownMenu<'),
);

Future<void> selectDropdownOption(
  WidgetTester tester, {
  required String fieldLabel,
  required String optionText,
}) async {
  final visibleInField = find
      .descendant(
        of: dropdownWithLabel(fieldLabel),
        matching: find.text(optionText),
      )
      .hitTestable();
  if (visibleInField.evaluate().isNotEmpty && !dropdownOverlayOpen()) {
    return;
  }

  if (!dropdownOverlayOpen()) {
    await tapReliably(
      tester,
      () => dropdownWithLabel(fieldLabel).hitTestable(),
      dropdownOverlayOpen,
    );
  }
  await tester.pump(const Duration(milliseconds: 400));

  await tapReliably(
    tester,
    () => find.descendant(of: dropdownMenu(), matching: find.text(optionText)),
    () => !dropdownOverlayOpen(),
    scrollIntoView: false,
  );
}

/// Accounts tab → Create → investment checkbox → Investments group →
/// optional opening cash. Leaves the tester on the Accounts screen with
/// [name] visible.
Future<void> createInvestmentAccountThroughGui(
  WidgetTester tester, {
  required String name,
  String? openingBalanceText,
}) async {
  final l10n = AppLocalizationsEn();

  await tapReliably(
    tester,
    () => shellNavIcon(TablerIcons.wallet),
    () => find
        .byWidgetPredicate(
          (widget) =>
              widget is FloatingActionButton &&
              widget.heroTag == 'accounts-fab',
        )
        .hitTestable()
        .evaluate()
        .isNotEmpty,
  );

  await tapReliably(
    tester,
    () => find
        .byWidgetPredicate(
          (widget) =>
              widget is FloatingActionButton &&
              widget.heroTag == 'accounts-fab',
        )
        .hitTestable(),
    () => find.text(l10n.createAccount).evaluate().isNotEmpty,
  );

  await enterTextReliably(tester, () => find.byType(TextField).first, name, () {
    final field = find.byType(TextField).evaluate().first.widget as TextField;
    return field.controller?.text == name;
  });

  await tapReliably(
    tester,
    () => find.text(l10n.thisAccountHoldsInvestments).hitTestable(),
    () {
      final tiles = find.byType(CheckboxListTile).evaluate();
      if (tiles.isEmpty) return false;
      return (tiles.first.widget as CheckboxListTile).value == true;
    },
  );

  await selectDropdownOption(
    tester,
    fieldLabel: l10n.groupLabel,
    optionText: l10n.systemGroupInvestments,
  );

  if (openingBalanceText != null) {
    await enterTextReliably(
      tester,
      () => textFieldWithLabel(l10n.openingBalanceOptional),
      openingBalanceText,
      () {
        final field =
            textFieldWithLabel(
                  l10n.openingBalanceOptional,
                ).evaluate().single.widget
                as TextField;
        return field.controller?.text == openingBalanceText;
      },
    );
  }

  await tapReliably(
    tester,
    () => find.widgetWithText(ElevatedButton, l10n.actionCreate),
    () =>
        find.text(l10n.createAccount).evaluate().isEmpty &&
        find.widgetWithText(ListTile, name).evaluate().isNotEmpty,
    innerTries: 150,
  );
}

/// Home → tap the investment account (pushes `/holdings/:id`).
Future<void> openHoldingsFor(WidgetTester tester, String accountName) async {
  final l10n = AppLocalizationsEn();
  if (find.text(l10n.holdingsCash).evaluate().isNotEmpty &&
      find.text(accountName).evaluate().isNotEmpty) {
    return;
  }

  await tapReliably(
    tester,
    () => shellNavIcon(TablerIcons.home),
    () => find.text(l10n.homeWhatYouHaveMinusWhatYouOwe).evaluate().isNotEmpty,
  );

  await tapReliably(
    tester,
    () => find.widgetWithText(ListTile, accountName).hitTestable(),
    () => find.text(l10n.holdingsCash).evaluate().isNotEmpty,
    innerTries: 150,
  );
}

/// Holdings → Buy dialog → new instrument (Stock) → Record buy.
Future<void> recordCashFundedBuyThroughGui(
  WidgetTester tester, {
  required String instrumentName,
  required String quantityText,
  required String unitPriceText,
  String? tickerText,
  String? brokerageText,
  String? brokerageExpenseCategory,
  bool expectSuccess = true,
}) async {
  final l10n = AppLocalizationsEn();

  await tapReliably(
    tester,
    () => find.widgetWithText(ElevatedButton, l10n.actionBuy).hitTestable(),
    () => find.text(l10n.actionRecordBuy).evaluate().isNotEmpty,
  );

  await tapReliably(
    tester,
    () => find.text(l10n.newInstrument).hitTestable(),
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

  if (tickerText != null) {
    await enterTextReliably(
      tester,
      () => textFieldWithLabel(l10n.tickerOptional),
      tickerText,
      () {
        final field =
            textFieldWithLabel(l10n.tickerOptional).evaluate().single.widget
                as TextField;
        return field.controller?.text == tickerText;
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
    await tester.ensureVisible(
      find.widgetWithText(ElevatedButton, l10n.actionRecordBuy),
    );
    await tester.tap(find.widgetWithText(ElevatedButton, l10n.actionRecordBuy));
    await pumpUntilFound(tester, find.text(l10n.errorInsufficientCash));
  }
}
