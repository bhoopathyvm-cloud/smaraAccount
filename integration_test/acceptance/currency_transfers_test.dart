import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_en.dart';

import 'support/acceptance_harness.dart';

/// Real-build acceptance coverage for currency and transfers (design.md
/// Decision 5, group 2): a cross-currency transfer, walked entirely
/// through the real GUI against the real on-disk database and real OS
/// keychain - no ViewModel/Repository backdoors. Sets up its own EUR
/// group/account through the real "Create group"/"Create account"
/// dialogs, rather than the INTEGRATION tier's `changeAccountGroupCurrency`
/// backdoor, since that's not reachable through any GUI.
///
/// Every scenario starts from a completely fresh device
/// (`resetToFreshDevice` runs once before any test, per design.md
/// Decision 3) and must complete onboarding itself via
/// [completeOnboardingWithGuidedEntry] before reaching any other screen.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final l10n = AppLocalizationsEn();

  setUpAll(() async {
    await resetToFreshDevice();
  });

  testWidgets(
    'full cross-currency transfer lifecycle: provisional, pending on Home, then settled',
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));

      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '1000',
        categoryName: 'Salary',
      );

      await tapReliably(
        tester,
        () => find.text(l10n.navAccounts),
        () => find.byTooltip(l10n.createGroup).evaluate().isNotEmpty,
      );

      // Create a EUR group through the real "Create group" dialog - the
      // INTEGRATION tier's changeAccountGroupCurrency backdoor has no GUI
      // equivalent to reuse here.
      await tapReliably(
        tester,
        () => find.byTooltip(l10n.createGroup),
        () => find.byType(AlertDialog).evaluate().isNotEmpty,
      );
      await enterTextReliably(
        tester,
        () => find.byType(TextField).first,
        'Euro Group',
        () {
          final field =
              find.byType(TextField).evaluate().first.widget as TextField;
          return field.controller?.text == 'Euro Group';
        },
      );
      await tapReliably(tester, () => find.text('EUR'), () {
        final chip =
            find.widgetWithText(ChoiceChip, 'EUR').evaluate().single.widget
                as ChoiceChip;
        return chip.selected;
      });
      await tapReliably(
        tester,
        () => find.widgetWithText(ElevatedButton, l10n.actionCreate),
        () => find.text('Euro Group').evaluate().isNotEmpty,
        innerTries: 150,
      );

      // Create the EUR account within that group via the Accounts FAB -
      // it has no tooltip (design.md's research on this screen), so it's
      // scoped by type instead.
      await tapReliably(
        tester,
        () => find.byType(FloatingActionButton),
        () => find.text(l10n.createAccount).evaluate().isNotEmpty,
      );
      await enterTextReliably(
        tester,
        () => find.byType(TextField).first,
        'Euro Savings',
        () {
          final field =
              find.byType(TextField).evaluate().first.widget as TextField;
          return field.controller?.text == 'Euro Savings';
        },
      );
      // The group picker defaults to the first asset group (a seeded
      // default), not the new one just created - must be selected
      // explicitly.
      await tapReliably(
        tester,
        () => find.byType(DropdownButtonFormField<String>).last,
        () => find.text('Euro Group').evaluate().isNotEmpty,
      );
      await tapReliably(
        tester,
        () => find.text('Euro Group').last,
        () => find.text('Euro Group').evaluate().length == 1,
      );
      await tapReliably(
        tester,
        () => find.widgetWithText(ElevatedButton, l10n.actionCreate),
        () => find.text('Euro Savings').evaluate().isNotEmpty,
        innerTries: 150,
      );

      // Only two accounts exist now (Cash & Bank USD, Euro Savings EUR),
      // so TransferView's defaults already pick a cross-currency pair -
      // no From/To dropdown interaction needed.
      await tapReliably(
        tester,
        () => find.byTooltip(l10n.actionTransfer),
        () => find.text(l10n.destinationAmountOptional).evaluate().isNotEmpty,
      );
      await enterTextReliably(
        tester,
        () => find.byType(TextField).first,
        '100.00',
        () {
          final field =
              find.byType(TextField).evaluate().first.widget as TextField;
          return field.controller?.text == '100.00';
        },
      );
      await tapReliably(
        tester,
        () => find.widgetWithText(ElevatedButton, l10n.captureMovedMoney),
        () => find.text(l10n.homeMoneyInTransit).evaluate().isNotEmpty,
        innerTries: 150,
      );

      // Transfer pops back to Home on success; the pending item shows.
      expect(find.text(l10n.homeMoneyInTransit), findsOneWidget);

      await tapReliably(
        tester,
        () => find.ancestor(
          of: find.text(l10n.homeTapWhenArrived),
          matching: find.byType(ListTile),
        ),
        () => find.text(l10n.whatArrivedTitle).evaluate().isNotEmpty,
      );

      await enterTextReliably(
        tester,
        () => find.byType(TextField),
        '92.00',
        () {
          final field =
              find.byType(TextField).evaluate().single.widget as TextField;
          return field.controller?.text == '92.00';
        },
      );
      // A shortfall vs. the reference-rate-implied amount may or may not
      // trigger depending on the live rate this run - if it does, the fee
      // category is required before Settle will succeed.
      if (find.text(l10n.feeLossCategory).evaluate().isNotEmpty) {
        await tapReliably(
          tester,
          () => find.widgetWithText(
            DropdownButtonFormField<String>,
            l10n.feeLossCategory,
          ),
          () => find.text('Other Expense').evaluate().isNotEmpty,
        );
        await tapReliably(
          tester,
          () => find.text('Other Expense').last,
          () => find.text('Other Expense').evaluate().length == 1,
        );
      }
      await tapReliably(
        tester,
        () => find.widgetWithText(ElevatedButton, l10n.actionSettle),
        // Not "MONEY IN TRANSIT absent" - that's also (trivially) true
        // before ever navigating anywhere. Home's own net-position label
        // proves settling actually popped back to Home.
        () => find
            .text(l10n.homeWhatYouHaveMinusWhatYouOwe)
            .evaluate()
            .isNotEmpty,
        innerTries: 150,
      );

      expect(find.text(l10n.homeMoneyInTransit), findsNothing);
      await pumpUntilFound(tester, find.text('92.00 EUR'));
      expect(find.text('92.00 EUR'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
