import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_en.dart';
import 'package:smara_accounting/ui/features/transfer/views/transfer_view.dart';

import 'support/acceptance_harness.dart';

/// Real-build acceptance coverage for currency and transfers (design.md
/// Decision 5, group 2): cross-currency transfer lifecycles, walked
/// entirely through the real GUI against the real on-disk database and
/// real OS keychain - no ViewModel/Repository backdoors. Sets up its own
/// EUR group/account through the real "Create group"/"Create account"
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
      await _setUpCrossCurrencyTransfer(tester, l10n);

      await tapReliably(
        tester,
        () => find.ancestor(
          of: find.text(l10n.homeTapWhenArrived),
          matching: find.byType(ListTile),
        ),
        () => find.text(l10n.whatArrivedTitle).evaluate().isNotEmpty,
      );

      // EUR parses with 'de_DE' conventions (period grouping, comma
      // decimal - currency_minor_units.dart) - '92.00' would parse as
      // 9,200.00, not 92.00.
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

      await _waitForMoneyInTransitToClear(tester, l10n);
      // Home is a ListView too - the Euro Savings row can sort below the
      // live window's fold, same caveat as the Accounts screen earlier.
      await tester.drag(find.byType(ListView).first, const Offset(0, -2000));
      await tester.pump(const Duration(milliseconds: 300));
      // '92,00 EUR', not '92.00 EUR' - de_DE display convention. Shows in
      // more than one place (cash balance, net position, group total).
      await pumpUntilFound(tester, find.text('92,00 EUR'));
      expect(find.text('92,00 EUR'), findsWidgets);

      await tester.pump(const Duration(seconds: 2));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );

  testWidgets('a bounced transfer settled back to the source retains a fee', (
    tester,
  ) async {
    addTearDown(() => resetToFreshDevice(tester));
    await _setUpCrossCurrencyTransfer(tester, l10n);

    await tapReliably(
      tester,
      () => find.ancestor(
        of: find.text(l10n.homeTapWhenArrived),
        matching: find.byType(ListTile),
      ),
      () => find.text(l10n.whatArrivedTitle).evaluate().isNotEmpty,
    );

    // "Returned to Cash & Bank" - the money bounced back to the source
    // account instead of arriving at the destination. Selecting it
    // switches the amount field's currency suffix from EUR to USD
    // (settledAmountCurrency follows the selected account), which is
    // the success signal here.
    await tapReliably(
      tester,
      () => find.text(l10n.homeReturnedTo('Cash & Bank')),
      () => find.text('USD').evaluate().isNotEmpty,
    );

    // Sent 100.00 USD; only 90.00 USD came back - the other 10.00
    // became a retained fee (a bank/intermediary charge on the bounce).
    // USD parses with plain-period decimals, unlike the EUR field in
    // the "arrived" scenario above.
    await enterTextReliably(tester, () => find.byType(TextField), '90.00', () {
      final field =
          find.byType(TextField).evaluate().single.widget as TextField;
      return field.controller?.text == '90.00';
    });
    await pumpUntilFound(tester, find.text(l10n.feeLossCategory));
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
    await tapReliably(
      tester,
      () => find.widgetWithText(ElevatedButton, l10n.actionSettle),
      () =>
          find.text(l10n.homeWhatYouHaveMinusWhatYouOwe).evaluate().isNotEmpty,
      innerTries: 150,
    );

    await _waitForMoneyInTransitToClear(tester, l10n);
    // Net cash: 1000 salary - 100 sent + 90 returned = 990.00 USD.
    await pumpUntilFound(tester, find.text('990.00 USD'));
    expect(find.text('990.00 USD'), findsWidgets);

    await tester.pump(const Duration(seconds: 2));
  }, timeout: const Timeout(Duration(minutes: 5)));
}

/// Onboards, creates a EUR group + a "Euro Savings" account within it
/// through the real "Create group"/"Create account" dialogs, then sends a
/// 100.00 USD provisional (unknown-rate) cross-currency transfer from Cash
/// & Bank to it, leaving the tester on Home with the pending item showing.
Future<void> _setUpCrossCurrencyTransfer(
  WidgetTester tester,
  AppLocalizationsEn l10n,
) async {
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
      final field = find.byType(TextField).evaluate().first.widget as TextField;
      return field.controller?.text == 'Euro Group';
    },
  );
  await tapReliably(tester, () => find.text('EUR'), () {
    final chip =
        find.widgetWithText(ChoiceChip, 'EUR').evaluate().single.widget
            as ChoiceChip;
    return chip.selected;
  });
  // Not a "Euro Group" text check: the Accounts list is a lazily-built
  // ListView, and a newly-appended group sorts to the end, below the
  // live macOS window's fold - find.text() would never see it without
  // scrolling first (design.md Risks: "below the fold" - confirmed by
  // this change's own diagnosis to apply to verification, not just
  // interaction). The dialog closing is itself the success signal:
  // Navigator.pop() only runs after `viewModel.createGroup` returns
  // true.
  await tapReliably(
    tester,
    () => find.widgetWithText(ElevatedButton, l10n.actionCreate),
    () => find.byType(AlertDialog).evaluate().isEmpty,
    innerTries: 150,
  );

  // Create the EUR account within that group via the Accounts FAB - it
  // has no tooltip (design.md's research on this screen), so it's
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
      final field = find.byType(TextField).evaluate().first.widget as TextField;
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
  // Same below-the-fold caveat as the group creation above.
  await tapReliably(
    tester,
    () => find.widgetWithText(ElevatedButton, l10n.actionCreate),
    () => find.byType(AlertDialog).evaluate().isEmpty,
    innerTries: 150,
  );

  // Only two accounts exist now (Cash & Bank USD, Euro Savings EUR), so
  // TransferView's defaults already pick a cross-currency pair - no
  // From/To dropdown interaction needed.
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
      final field = find.byType(TextField).evaluate().first.widget as TextField;
      return field.controller?.text == '100.00';
    },
  );
  // Let the live reference-rate lookup (shown just above the submit
  // button once it resolves) settle first.
  await tester.pump(const Duration(seconds: 1));
  // Success check is "the Transfer form's own field is gone", not a
  // destination-specific marker like homeMoneyInTransit: matches the
  // proven pattern in investment_holdings_test.dart's
  // _transferThroughGui. A destination-specific check is too narrow a
  // gate for tapReliably itself - if it doesn't turn true within one
  // attempt's inner wait even though the tap genuinely worked, the
  // retry loop re-evaluates the (already-gone) submit button and throws
  // "Bad state: No element" from ensureVisible (design.md Risks;
  // reproduced repeatedly during this change's own implementation
  // before switching to this check).
  await tapReliably(
    tester,
    () => find.descendant(
      of: find.byType(TransferView),
      matching: find.widgetWithText(ElevatedButton, l10n.captureMovedMoney),
    ),
    () => find.text(l10n.fromAccount).evaluate().isEmpty,
    innerTries: 150,
  );

  // Transfer pops back to whichever screen pushed it - here, Accounts
  // (reached via its own toolbar icon, not Home) - not unconditionally
  // to Home. Navigate to Home explicitly to see the pending item.
  await tapReliably(
    tester,
    () => find.text(l10n.navHome),
    () => find.text(l10n.homeMoneyInTransit).evaluate().isNotEmpty,
  );
  expect(find.text(l10n.homeMoneyInTransit), findsOneWidget);
}

/// Home's own async re-read of pending transfers (now empty after
/// settling) needs a moment - the section can still show briefly on
/// stale data right after landing back on Home.
Future<void> _waitForMoneyInTransitToClear(
  WidgetTester tester,
  AppLocalizationsEn l10n,
) async {
  for (
    var i = 0;
    i < 20 && find.text(l10n.homeMoneyInTransit).evaluate().isNotEmpty;
    i++
  ) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(find.text(l10n.homeMoneyInTransit), findsNothing);
}
