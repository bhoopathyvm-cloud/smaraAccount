import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_en.dart';

import 'support/acceptance_harness.dart';

/// Real-build acceptance coverage for `account-currency` (design.md
/// Decision 5, group 2): changing an existing account group's currency
/// through the real "Edit group" dialog - walked entirely through the
/// real GUI, no ViewModel/Repository backdoors.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final l10n = AppLocalizationsEn();

  setUpAll(() async {
    await resetToFreshDevice();
  });

  testWidgets('changing a system group\'s currency to JPY through Edit group', (
    tester,
  ) async {
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

    // "Investments" is the last of the 5 seeded system groups - below
    // the live window's fold (design.md Risks), so find.text() would
    // never see it until scrolled into the lazily-built ListView.
    await tester.drag(find.byType(ListView).first, const Offset(0, -2000));
    await tester.pump(const Duration(milliseconds: 300));

    await tapReliably(
      tester,
      () => find.descendant(
        of: find.ancestor(
          of: find.text(l10n.systemGroupInvestments),
          matching: find.byType(ListTile),
        ),
        matching: find.byTooltip(l10n.editGroup),
      ),
      () => find.byType(AlertDialog).evaluate().isNotEmpty,
    );
    expect(find.text(l10n.editGroup), findsWidgets);

    // The currency field is the second TextField in the dialog (name,
    // then currency); enterText replaces the whole seeded "USD" value.
    await enterTextReliably(
      tester,
      () => find.byType(TextField).at(1),
      'JPY',
      () {
        final field =
            find.byType(TextField).at(1).evaluate().single.widget as TextField;
        return field.controller?.text == 'JPY';
      },
    );
    await tapReliably(
      tester,
      () => find.widgetWithText(ElevatedButton, l10n.actionSave),
      () => find.byType(AlertDialog).evaluate().isEmpty,
      innerTries: 150,
    );

    // The group's own row now shows its new currency - proves the
    // change round-tripped through the real database and the
    // watchAccountGroups() stream back to the UI. Amount formatting
    // itself (including JPY's zero-decimal-digit convention) is
    // covered by money_formatter_test.dart at the unit level and by
    // currency_transfers_test.dart's real-GUI EUR/USD assertions
    // (92,00 EUR / 990.00 USD) at this tier.
    await tester.drag(find.byType(ListView).first, const Offset(0, -2000));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.descendant(
        of: find.ancestor(
          of: find.text(l10n.systemGroupInvestments),
          matching: find.byType(ListTile),
        ),
        matching: find.text('JPY'),
      ),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 2));
  }, timeout: const Timeout(Duration(minutes: 5)));
}
