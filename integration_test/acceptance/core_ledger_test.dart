import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_en.dart';

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
}
