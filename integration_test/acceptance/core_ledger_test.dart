import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_en.dart';
import 'package:smara_accounting/main.dart';
import 'package:smara_accounting/ui/features/record_transaction/views/record_transaction_view.dart';
import 'package:smara_accounting/ui/features/register/views/register_view.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import 'support/acceptance_harness.dart';

/// Real-build acceptance coverage for the core ledger journeys (design.md
/// Decision 5, group 1), walked entirely through the real GUI against the
/// real on-disk database and real OS keychain - no ViewModel/Repository
/// backdoors. Reversing a posted entry is excluded: the app has no GUI
/// affordance for it anywhere (design.md's coverage-scope note).
///
/// Every scenario starts from a completely fresh device
/// (`resetToFreshDevice` runs once before any test, per design.md
/// Decision 3) and must complete onboarding itself via
/// [completeOnboardingWithGuidedEntry] before reaching any other screen -
/// there is no pre-seeded identity to skip ahead with, unlike the
/// in-memory INTEGRATION tier.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final l10n = AppLocalizationsEn();

  setUpAll(() async {
    await resetToFreshDevice();
  });

  testWidgets(
    'record a transaction through onboarding and see it in the register with the correct running balance',
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));

      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '25',
        categoryName: 'Salary',
      );

      // The guided first entry was recorded during onboarding, before Home
      // was ever reached - it shows up in the register, not on Home itself.
      await tapReliably(
        tester,
        () => find.text(l10n.navRegister),
        () => find.text('Salary').evaluate().isNotEmpty,
      );

      expect(find.text('Salary'), findsOneWidget);
      expect(find.text('25.00'), findsOneWidget);

      // Settle any in-flight go_router redirect (its own async chain -
      // verifyChain(), hasAnyJournalEntries(), etc. - re-runs on every
      // navigation) while the widget tree is still mounted and valid,
      // rather than letting it linger into teardown: an unmount racing a
      // redirect Future throws "Channel was closed before receiving a
      // response" from a zone flutter_test attributes to this test even
      // though it fires after every assertion above already passed.
      await tester.pump(const Duration(seconds: 2));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );

  testWidgets(
    'hiding a category removes it from the picker but keeps its history visible',
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));

      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '10',
        categoryName: 'Salary',
      );

      await tapReliably(
        tester,
        () => find.text(l10n.navCategories),
        () => find.text('Salary').evaluate().isNotEmpty,
      );
      // The categories list can still be mid-layout right as "Salary"
      // first appears (its own row's trailing Hide button one frame
      // behind), which showed up as ensureVisible finding zero elements
      // for a finder scoped to that row.
      await tester.pump(const Duration(milliseconds: 500));

      await tapReliably(
        tester,
        () => find.descendant(
          of: find.ancestor(
            of: find.text('Salary'),
            matching: find.byType(ListTile),
          ),
          matching: find.widgetWithText(OutlinedButton, l10n.actionHide),
        ),
        () => find.text(l10n.hideCategoryTitle).evaluate().isNotEmpty,
      );

      await tapReliably(
        tester,
        () => find.descendant(
          of: find.byType(AlertDialog),
          matching: find.widgetWithText(OutlinedButton, l10n.actionHide),
        ),
        () => find.text(l10n.actionRestore).evaluate().isNotEmpty,
      );

      expect(find.text(l10n.actionRestore), findsOneWidget);

      await tapReliably(
        tester,
        () => find.text(l10n.navRegister),
        () => find.text('Salary').evaluate().isNotEmpty,
      );
      expect(find.text('Salary'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );

  testWidgets('tamper detection: a mutated row is quarantined on restart', (
    tester,
  ) async {
    addTearDown(() => resetToFreshDevice(tester));

    await completeOnboardingWithGuidedEntry(
      tester,
      amountText: '10',
      categoryName: 'Salary',
    );

    // Unmount first so the app's own Drift connection (and the isolate
    // drift_flutter spawns for it) closes before a second, raw
    // connection to the same file opens - matching resetToFreshDevice's
    // own reasoning for why it unmounts before deleting anything.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));

    // Mutate the stored row directly - not through the app - exactly
    // mimicking direct SQLite file access outside the app
    // (drift_flutter names the file "<name>.sqlite"; app_database.dart
    // uses name: 'smara_accounting').
    final dbFile = sqlite3.open(
      '${(await getApplicationSupportDirectory()).path}/smara_accounting.sqlite',
    );
    dbFile.execute(
      "UPDATE journal_entries SET description = 'tampered outside the app'",
    );
    dbFile.close();

    // "Restart": a fresh widget tree, same underlying database file -
    // matching how the real app's database persists across restarts.
    // Identity/first-week-setup state from completeOnboardingWithGuidedEntry
    // already persisted (real Keychain, real SharedPreferences), so this
    // lands straight on Home rather than re-onboarding.
    await tester.pumpWidget(const SmaraAccountingApp());
    await tester.pump();
    await pumpUntilFound(
      tester,
      find.text(l10n.homeWhatYouHaveMinusWhatYouOwe),
    );

    await tapReliably(
      tester,
      () => find.text(l10n.navRegister),
      () => find.byIcon(TablerIcons.lock).evaluate().isNotEmpty,
    );
    expect(find.byIcon(TablerIcons.lock), findsOneWidget);

    // Re-anchoring (acceptance-re-anchoring): record a second clean entry
    // through the Register FAB / capture sheet and assert only the
    // tampered row keeps the quarantine lock badge.
    await tapReliably(
      tester,
      () => find.byType(FloatingActionButton).hitTestable(),
      () => find.text(l10n.captureReceived).evaluate().isNotEmpty,
    );
    await tapReliably(
      tester,
      () => find.text(l10n.captureReceived),
      () => find.byType(RecordTransactionView).evaluate().isNotEmpty,
    );
    await pumpUntilFound(tester, find.text('Cash & Bank'));
    // Scope amount entry to RecordTransactionView: Register stays under the
    // capture route and its search TextField is earlier in the tree — typing
    // into find.byType(TextField).first was filtering the register to "5.00"
    // and hiding the quarantined Salary row.
    Finder amountField() => find
        .descendant(
          of: find.byType(RecordTransactionView),
          matching: find.byType(TextField),
        )
        .first;
    var saved = false;
    for (var attempt = 0; attempt < 3 && !saved; attempt++) {
      await enterTextReliably(tester, amountField, '5.00', () {
        final field = amountField().evaluate().single.widget as TextField;
        return field.controller?.text == '5.00';
      });
      await selectDropdownOption(
        tester,
        fieldLabel: l10n.category,
        optionText: 'Other Income',
      );
      try {
        await tapReliably(
          tester,
          () => find.descendant(
            of: find.byType(RecordTransactionView),
            matching: find.text(l10n.actionSave),
          ),
          () => find.byType(RecordTransactionView).evaluate().isEmpty,
          innerTries: 60,
        );
        saved = true;
      } catch (_) {
        if (attempt == 2) rethrow;
      }
    }
    await tapReliably(
      tester,
      () => find.text(l10n.navRegister),
      () => find.byType(RegisterView).evaluate().isNotEmpty,
    );
    await pumpUntilFound(tester, find.text('Other Income'));
    // Quarantined Salary can sit below the fold on the live 800x600 window.
    for (var i = 0; i < 8; i++) {
      if (find.byIcon(TablerIcons.lock).evaluate().isNotEmpty &&
          find.text('Salary').evaluate().isNotEmpty) {
        break;
      }
      await tester.drag(find.byType(ListView).first, const Offset(0, -200));
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.byIcon(TablerIcons.lock), findsOneWidget);
    expect(find.text('Other Income'), findsOneWidget);
    expect(find.text('Salary'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
  }, timeout: const Timeout(Duration(minutes: 5)));
}
