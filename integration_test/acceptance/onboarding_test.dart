import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_en.dart';
import 'package:smara_accounting/main.dart';
import 'package:smara_accounting/ui/features/onboarding/views/currency_selection_view.dart';
import 'package:smara_accounting/ui/features/onboarding/views/first_account_name_view.dart';
import 'package:smara_accounting/ui/features/onboarding/views/recovery_phrase_view.dart';
import 'package:smara_accounting/ui/features/record_transaction/views/record_transaction_view.dart';

import 'support/acceptance_harness.dart';

/// Real-build acceptance coverage for onboarding: the first-week-setup
/// wizard (`first-week-setup`) and the deferred-onboarding acknowledgment
/// gate (`deferred-onboarding`).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final l10n = AppLocalizationsEn();

  setUpAll(() async {
    await resetToFreshDevice();
  });

  testWidgets(
    'the first-week setup wizard creates a credit card and a cash account',
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));

      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '500',
        categoryName: 'Salary',
        skipFirstWeekSetup: false,
      );
      expect(find.text(l10n.firstWeekTitle), findsOneWidget);

      await tapReliably(
        tester,
        () => find.widgetWithText(SwitchListTile, l10n.addCreditCard),
        () =>
            find.widgetWithText(TextField, l10n.cardName).evaluate().isNotEmpty,
      );
      await enterTextReliably(
        tester,
        () => find.widgetWithText(TextField, l10n.cardName),
        'My Card',
        () {
          final field =
              find
                      .widgetWithText(TextField, l10n.cardName)
                      .evaluate()
                      .single
                      .widget
                  as TextField;
          return field.controller?.text == 'My Card';
        },
      );

      await tapReliably(
        tester,
        () => find.widgetWithText(SwitchListTile, l10n.addCashAccount),
        () => find
            .widgetWithText(TextField, l10n.cashAccountName)
            .evaluate()
            .isNotEmpty,
      );
      await enterTextReliably(
        tester,
        () => find.widgetWithText(TextField, l10n.cashAccountName),
        'Pocket Cash',
        () {
          final field =
              find
                      .widgetWithText(TextField, l10n.cashAccountName)
                      .evaluate()
                      .single
                      .widget
                  as TextField;
          return field.controller?.text == 'Pocket Cash';
        },
      );

      await tapReliably(
        tester,
        () => find.widgetWithText(ElevatedButton, l10n.actionFinish),
        () => find
            .text(l10n.homeWhatYouHaveMinusWhatYouOwe)
            .evaluate()
            .isNotEmpty,
        innerTries: 150,
      );
      // A settle pump: the wizard's own "My Card" TextField was observed
      // still mounted immediately after this check passes (GoRouter
      // mid-transition double-mounting, design.md Risks), which would
      // make the "My Card" search below ambiguous.
      await tester.pump(const Duration(milliseconds: 500));

      await tapReliably(
        tester,
        () => find.text(l10n.navAccounts),
        () => find.byTooltip(l10n.createGroup).evaluate().isNotEmpty,
      );
      // Pocket Cash lands in "Cash & cash equivalents" (the topmost
      // seeded group), already visible without scrolling - checked before
      // scrolling down, since scrolling down would push it back out of
      // view above the fold rather than into it.
      expect(find.text('Pocket Cash'), findsOneWidget);
      expect(find.text('My Card'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );

  testWidgets(
    'closing and reopening after the guided first entry still requires '
    'phrase acknowledgment',
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));

      await tester.pumpWidget(const SmaraAccountingApp());
      await tester.pump();
      await pumpUntilFound(tester, find.byType(CurrencySelectionView));
      expect(find.byType(CurrencySelectionView), findsOneWidget);

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
      await pumpUntilFound(tester, find.text('Cash & Bank'));

      // The whole entry retries as a unit, not just the Save tap -
      // mirrors completeOnboardingWithGuidedEntry's own documented
      // workaround (design.md Risks): enterText updating the controller's
      // raw text is a weak proxy for its onChanged having actually
      // reached the ViewModel, observed to pass its own check yet still
      // leave the amount null, surfacing only downstream as Save's
      // validation failing.
      var saved = false;
      for (var attempt = 0; attempt < 3 && !saved; attempt++) {
        await enterTextReliably(
          tester,
          () => find.byType(TextField).first,
          '75',
          () {
            final field =
                find.byType(TextField).evaluate().first.widget as TextField;
            return field.controller?.text == '75';
          },
        );
        await tapReliably(
          tester,
          () => find.byType(DropdownButtonFormField<String>).last,
          () => find.text('Salary').evaluate().isNotEmpty,
        );
        await tapReliably(
          tester,
          () => find.text('Salary').last,
          () => find.text('Salary').evaluate().length == 1,
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
        fail('Save never succeeded after 3 full re-entry attempts.');
      }
      // The guided first entry has posted; acknowledgment (spec: "the
      // mandatory recovery-phrase acknowledgment flow") is showing but
      // deliberately NOT completed here - simulating the app being closed
      // right at this point instead.
      expect(find.byType(RecoveryPhraseView), findsOneWidget);

      // Simulate closing and reopening the app - same on-disk database and
      // keychain, no resetToFreshDevice (spec: "...or resuming the app
      // after it was closed or killed").
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.pumpWidget(const SmaraAccountingApp());
      await tester.pump();

      await pumpUntilFound(tester, find.text(l10n.iveSavedRecoveryPhrase));
      expect(
        find.byType(RecoveryPhraseView),
        findsOneWidget,
        reason:
            'reopening before acknowledgment must not skip straight to Home',
      );
      expect(find.text(l10n.homeWhatYouHaveMinusWhatYouOwe), findsNothing);

      await tester.pump(const Duration(seconds: 2));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
