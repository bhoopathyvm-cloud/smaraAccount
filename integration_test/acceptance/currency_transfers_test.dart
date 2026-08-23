import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smara_accounting/domain/models/account_group.dart';
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

      // Create a EUR group through the real "Create group" dialog - the
      // INTEGRATION tier's changeAccountGroupCurrency backdoor has no GUI
      // equivalent to reuse here.
      await createGroupThroughGui(tester, name: 'Euro Group', currency: 'EUR');

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
      await createAccountButtonTapThroughGui(tester, name: 'Euro Savings');

      // Only two accounts exist now (Cash & Bank USD, Euro Savings EUR),
      // so TransferView's defaults already pick a cross-currency pair -
      // no From/To dropdown interaction needed.
      await openTransferScreen(tester);
      await submitTransferThroughGui(
        tester,
        fromAccountName: 'Cash & Bank',
        toAccountName: 'Euro Savings',
        amountText: '100.00',
      );
      // TransferView's onSaved is a plain context.pop() (app_router.dart),
      // landing back on whichever screen pushed it - here, Accounts, not
      // Home, where "Money in transit" actually renders.
      await tapReliably(
        tester,
        () => find.text(l10n.navHome),
        () => find.text(l10n.homeMoneyInTransit).evaluate().isNotEmpty,
      );
      expect(find.text(l10n.homeMoneyInTransit), findsOneWidget);

      await tapReliably(
        tester,
        () => find.ancestor(
          of: find.text(l10n.homeTapWhenArrived),
          matching: find.byType(ListTile),
        ),
        () => find.text(l10n.whatArrivedTitle).evaluate().isNotEmpty,
      );

      // EUR is formatted/parsed with its own CLDR convention - comma
      // decimal, period thousands separator (money_formatter.dart's
      // parseAmountToMinor uses NumberFormat.currency per-currency, not
      // the app's UI locale) - "92.00" here would strip the "." as a
      // group separator and parse as 9200, not 92.
      await enterTextReliably(
        tester,
        () => find.byType(TextField),
        '92,00',
        () {
          final field =
              find.byType(TextField).evaluate().single.widget as TextField;
          return field.controller?.text == '92,00';
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
      // EUR's own CLDR display convention - comma decimal separator.
      // Multiple rows legitimately show it (net position, account balance).
      await pumpUntilFound(tester, find.text('92,00 EUR'));
      expect(find.text('92,00 EUR'), findsWidgets);

      await tester.pump(const Duration(seconds: 2));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );

  testWidgets(
    'a bounced cross-currency transfer reverses back onto the source account',
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));

      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '1000',
        categoryName: 'Salary',
      );

      await createGroupThroughGui(tester, name: 'Euro Group', currency: 'EUR');

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
      await createAccountButtonTapThroughGui(tester, name: 'Euro Savings');

      await openTransferScreen(tester);
      await submitTransferThroughGui(
        tester,
        fromAccountName: 'Cash & Bank',
        toAccountName: 'Euro Savings',
        amountText: '100.00',
      );
      // TransferView's onSaved is a plain context.pop() (app_router.dart),
      // landing back on whichever screen pushed it - here, Accounts, since
      // that's where openTransferScreen opens it from - not Home, where
      // "Money in transit" actually renders. Navigate there explicitly.
      await tapReliably(
        tester,
        () => find.text(l10n.navHome),
        () => find.text(l10n.homeMoneyInTransit).evaluate().isNotEmpty,
      );
      expect(find.text(l10n.homeMoneyInTransit), findsOneWidget);

      await tapReliably(
        tester,
        () => find.ancestor(
          of: find.text(l10n.homeTapWhenArrived),
          matching: find.byType(ListTile),
        ),
        () => find.text(l10n.whatArrivedTitle).evaluate().isNotEmpty,
      );

      // Bounced: mark it as returned to the source account rather than
      // arrived at the destination.
      await tapReliably(
        tester,
        () => find.text(l10n.homeReturnedTo('Cash & Bank')),
        () => find
            .widgetWithText(
              RadioListTile<String?>,
              l10n.homeReturnedTo('Cash & Bank'),
            )
            .evaluate()
            .isNotEmpty,
      );

      // Returned in full - no shortfall, no fee category needed.
      await enterTextReliably(
        tester,
        () => find.byType(TextField),
        '100.00',
        () {
          final field =
              find.byType(TextField).evaluate().single.widget as TextField;
          return field.controller?.text == '100.00';
        },
      );
      await tapReliably(
        tester,
        () => find.widgetWithText(ElevatedButton, l10n.actionSettle),
        () => find
            .text(l10n.homeWhatYouHaveMinusWhatYouOwe)
            .evaluate()
            .isNotEmpty,
        innerTries: 150,
      );

      expect(find.text(l10n.homeMoneyInTransit), findsNothing);
      // The transfer never actually left Cash & Bank - it's back to the
      // full 1000 opening balance.
      await pumpUntilFound(tester, find.text('1,000.00 USD'));
      expect(find.text('1,000.00 USD'), findsWidgets);

      await tester.pump(const Duration(seconds: 2));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );

  testWidgets(
    'Pay card on a credit-card account pre-fills the transfer destination',
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));

      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '1000',
        categoryName: 'Salary',
      );

      // A liability group to hold the credit card, same currency as the
      // seeded checking account so Pay Card is a same-currency transfer.
      await createGroupThroughGui(
        tester,
        name: 'Credit Cards',
        currency: 'USD',
        kind: AccountGroupKind.liabilityGroup,
      );

      // The credit-card account itself.
      await tapReliably(
        tester,
        () => find.byType(FloatingActionButton),
        () => find.text(l10n.createAccount).evaluate().isNotEmpty,
      );
      await enterTextReliably(
        tester,
        () => find.byType(TextField).first,
        'Visa Card',
        () {
          final field =
              find.byType(TextField).evaluate().first.widget as TextField;
          return field.controller?.text == 'Visa Card';
        },
      );
      await tapReliably(
        tester,
        () => find.text(l10n.liability),
        () => find.text(l10n.thisIsACreditCard).evaluate().isNotEmpty,
      );
      await tapReliably(
        tester,
        () => find.widgetWithText(CheckboxListTile, l10n.thisIsACreditCard),
        () {
          final checkbox =
              find
                      .widgetWithText(CheckboxListTile, l10n.thisIsACreditCard)
                      .evaluate()
                      .single
                      .widget
                  as CheckboxListTile;
          return checkbox.value == true;
        },
      );
      // Defaults to the first liability group (the seeded "Credit &
      // short-term debt"), not the one just created.
      await tapReliably(
        tester,
        () => find.byType(DropdownButtonFormField<String>).last,
        () => find.text('Credit Cards').evaluate().isNotEmpty,
      );
      await tapReliably(
        tester,
        () => find.text('Credit Cards').last,
        () => find.text('Credit Cards').evaluate().length == 1,
      );
      await createAccountButtonTapThroughGui(tester, name: 'Visa Card');

      await tapReliably(
        tester,
        () => find.text(l10n.navHome),
        () => find
            .text(l10n.homeWhatYouHaveMinusWhatYouOwe)
            .evaluate()
            .isNotEmpty,
      );
      await tapReliably(
        tester,
        () => find.ancestor(
          of: find.text('Visa Card'),
          matching: find.byType(ListTile),
        ),
        () => find.text(l10n.registerTitle).evaluate().isNotEmpty,
        innerTries: 150,
      );
      // Register can report mounted before isSelectedAccountCreditCard's
      // own accounts-stream lookup has settled, so Pay Card doesn't exist
      // in the tree yet on the very first check.
      await tester.pumpAndSettle();

      await tapReliably(
        tester,
        () => find.widgetWithText(OutlinedButton, l10n.actionPayCard),
        () => find.text(l10n.captureMovedMoney).evaluate().isNotEmpty,
      );

      // "Visa Card" pre-filled as the To account.
      await pumpUntilFound(tester, find.text('Visa Card'));
      expect(find.text('Visa Card'), findsWidgets);

      await tester.pump(const Duration(seconds: 2));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );

  testWidgets(
    'a group with no accounts can have its currency changed through the GUI',
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));

      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '1000',
        categoryName: 'Salary',
      );

      await createGroupThroughGui(
        tester,
        name: 'Change Currency Group',
        currency: 'GBP',
      );

      Finder groupTile() => find.ancestor(
        of: find.text('Change Currency Group'),
        matching: find.byType(ListTile),
      );

      // A newly-created group is appended last, past the seeded ones -
      // easily below the live window's small viewport (ListView.builder
      // only builds visible rows), so the direct finder above can be
      // empty until scrolled into view.
      if (find.text('Change Currency Group').evaluate().isEmpty) {
        try {
          await tester.scrollUntilVisible(
            find.text('Change Currency Group'),
            -300.0,
            scrollable: find.byType(Scrollable).first,
            maxScrolls: 20,
          );
        } catch (_) {
          await tester.scrollUntilVisible(
            find.text('Change Currency Group'),
            300.0,
            scrollable: find.byType(Scrollable).first,
            maxScrolls: 20,
          );
        }
      }

      await tapReliably(
        tester,
        () => find.descendant(
          of: groupTile(),
          matching: find.byWidgetPredicate(
            (widget) => widget is PopupMenuButton,
          ),
        ),
        () => find.text(l10n.editGroup).evaluate().isNotEmpty,
      );
      await tapReliably(
        tester,
        () => find.text(l10n.editGroup).last,
        () => find.text(l10n.currencyIso).evaluate().isNotEmpty,
      );

      final currencyField = find.byType(TextField).at(1);
      await enterTextReliably(tester, () => currencyField, 'CAD', () {
        final field = currencyField.evaluate().single.widget as TextField;
        return field.controller?.text == 'CAD';
      });
      await tapReliably(
        tester,
        () => find.widgetWithText(ElevatedButton, l10n.actionSave),
        () =>
            find.byType(AlertDialog).evaluate().isEmpty &&
            find
                .descendant(of: groupTile(), matching: find.text('CAD'))
                .evaluate()
                .isNotEmpty,
        innerTries: 150,
      );

      expect(
        find.descendant(of: groupTile(), matching: find.text('CAD')),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 2));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
