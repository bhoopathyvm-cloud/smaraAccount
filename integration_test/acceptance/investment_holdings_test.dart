import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_en.dart';

import 'support/acceptance_harness.dart';

/// Real-build acceptance coverage for investment accounting (design.md
/// Decision 5, group tracked by `acceptance-investment-holdings`),
/// walked entirely through the real GUI against the real on-disk
/// database and real OS keychain - no ViewModel/Repository backdoors.
///
/// Every scenario starts from a completely fresh device
/// (`resetToFreshDevice` runs once before any test, per the parent
/// `acceptance-test-suite` design.md Decision 3) and must complete
/// onboarding itself via [completeOnboardingWithGuidedEntry] before
/// reaching any other screen.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final l10n = AppLocalizationsEn();

  setUpAll(() async {
    await resetToFreshDevice();
  });

  testWidgets('opening cash seeds holdings cash and leaves inventory empty', (
    tester,
  ) async {
    addTearDown(() => resetToFreshDevice(tester));

    await completeOnboardingWithGuidedEntry(
      tester,
      amountText: '1000',
      categoryName: 'Salary',
    );

    await createInvestmentAccountThroughGui(
      tester,
      accountName: 'Brokerage',
      openingCashText: '500',
    );

    await openHoldingsFor(tester, 'Brokerage');

    expect(find.text(l10n.holdingsCash), findsOneWidget);
    // Cash, book value, and market estimate all read 500.00 USD with no
    // holdings recorded yet, so more than one row legitimately shows it.
    expect(find.text('500.00 USD'), findsWidgets);
    expect(find.text(l10n.holdingsNoHoldings), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
  }, timeout: const Timeout(Duration(minutes: 5)));

  testWidgets(
    'transferring cash in and out of an investment account leaves inventory empty',
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));

      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '1000',
        categoryName: 'Salary',
      );
      await createInvestmentAccountThroughGui(tester, accountName: 'Brokerage');

      await openTransferScreen(tester);
      // The paired "Brokerage Inventory" account (type: inventory) must
      // never be selectable as a transfer endpoint.
      expect(find.text('Brokerage Inventory'), findsNothing);
      await submitTransferThroughGui(
        tester,
        fromAccountName: 'Cash & Bank',
        toAccountName: 'Brokerage',
        amountText: '300',
      );

      await openTransferScreen(tester);
      expect(find.text('Brokerage Inventory'), findsNothing);
      await submitTransferThroughGui(
        tester,
        fromAccountName: 'Brokerage',
        toAccountName: 'Cash & Bank',
        amountText: '100',
      );

      await openHoldingsFor(tester, 'Brokerage');
      expect(find.text('200.00 USD'), findsWidgets);
      expect(find.text(l10n.holdingsNoHoldings), findsOneWidget);
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );

  testWidgets('cash-out transfer greater than available cash is rejected', (
    tester,
  ) async {
    addTearDown(() => resetToFreshDevice(tester));

    await completeOnboardingWithGuidedEntry(
      tester,
      amountText: '1000',
      categoryName: 'Salary',
    );
    await createInvestmentAccountThroughGui(
      tester,
      accountName: 'Brokerage',
      openingCashText: '200',
    );

    await openTransferScreen(tester);
    await submitTransferThroughGui(
      tester,
      fromAccountName: 'Brokerage',
      toAccountName: 'Cash & Bank',
      amountText: '500',
      expectSuccess: false,
    );
    await popPushedScreen(tester);

    await openHoldingsFor(tester, 'Brokerage');
    expect(find.text('200.00 USD'), findsWidgets);
  }, timeout: const Timeout(Duration(minutes: 5)));

  testWidgets(
    'recording Spent against an investment account only decreases its cash',
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));

      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '1000',
        categoryName: 'Salary',
      );
      await createInvestmentAccountThroughGui(
        tester,
        accountName: 'Brokerage',
        openingCashText: '200',
      );

      await recordSpentThroughGui(
        tester,
        accountName: 'Brokerage',
        amountText: '50',
        categoryName: 'Groceries',
      );

      await openHoldingsFor(tester, 'Brokerage');
      expect(find.text('150.00 USD'), findsWidgets);
      expect(find.text(l10n.holdingsNoHoldings), findsOneWidget);
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );

  testWidgets(
    'cash-funded Buy is rejected when an investment account has no cash',
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));

      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '1000',
        categoryName: 'Salary',
      );
      await createInvestmentAccountThroughGui(tester, accountName: 'Brokerage');
      await openHoldingsFor(tester, 'Brokerage');

      await recordCashFundedBuyThroughGui(
        tester,
        instrumentName: 'Acme Corp',
        quantityText: '10',
        unitPriceText: '25',
        expectSuccess: false,
      );

      expect(find.text(l10n.holdingsNoHoldings), findsOneWidget);
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );

  testWidgets(
    'cash-funded Buy of a new instrument with brokerage decreases cash and shows inventory',
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));

      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '1000',
        categoryName: 'Salary',
      );
      await createInvestmentAccountThroughGui(
        tester,
        accountName: 'Brokerage',
        openingCashText: '1000',
      );
      await openHoldingsFor(tester, 'Brokerage');

      await recordCashFundedBuyThroughGui(
        tester,
        instrumentName: 'Acme Corp',
        quantityText: '5',
        unitPriceText: '20',
        brokerageText: '10',
        brokerageExpenseCategory: 'Other Expense',
      );

      // 1000 - (5 * 20) - 10 brokerage = 890.
      expect(find.textContaining('890.00 USD'), findsWidgets);
      expect(find.textContaining('5 units'), findsWidgets);
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );

  testWidgets(
    'a future lock-until keeps locked units out of what can be sold',
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));

      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '1000',
        categoryName: 'Salary',
      );
      await createInvestmentAccountThroughGui(
        tester,
        accountName: 'Brokerage',
        openingCashText: '1000',
      );
      await openHoldingsFor(tester, 'Brokerage');

      await recordCashFundedBuyThroughGui(
        tester,
        instrumentName: 'Acme Corp',
        quantityText: '3',
        unitPriceText: '20',
      );

      final lockUntil = DateTime(2026, 9, 21);
      await recordNonCashBuyThroughGui(
        tester,
        instrumentName: 'Acme Corp',
        quantityText: '1',
        unitPriceText: '25',
        incomeCategory: 'Other Income',
        lockUntil: lockUntil,
      );

      expect(find.textContaining('4 units'), findsWidgets);

      await recordSellThroughGui(
        tester,
        quantityText: '4',
        unitPriceText: '30',
        gainIncomeCategory: 'Other Income',
        expectSuccess: false,
      );

      expect(find.text(l10n.errorLockedUntil('2026-09-21')), findsOneWidget);
      // Inventory is unchanged - the rejected Sell posted nothing.
      expect(find.textContaining('4 units'), findsWidgets);
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );

  testWidgets(
    'selling unlocked units at a gain decreases quantity and increases cash',
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));

      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '1000',
        categoryName: 'Salary',
      );
      await createInvestmentAccountThroughGui(
        tester,
        accountName: 'Brokerage',
        openingCashText: '1000',
      );
      await openHoldingsFor(tester, 'Brokerage');

      await recordCashFundedBuyThroughGui(
        tester,
        instrumentName: 'Acme Corp',
        quantityText: '5',
        unitPriceText: '20',
      );
      // Cash: 1000 - 100 = 900.

      await recordSellThroughGui(
        tester,
        quantityText: '2',
        unitPriceText: '30',
        gainIncomeCategory: 'Other Income',
      );
      // Cash: 900 + (2 * 30) = 960.

      expect(find.textContaining('3 units'), findsWidgets);
      expect(find.textContaining('960.00 USD'), findsWidgets);
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );

  testWidgets('a Dividend increases cash without changing held quantity', (
    tester,
  ) async {
    addTearDown(() => resetToFreshDevice(tester));

    await completeOnboardingWithGuidedEntry(
      tester,
      amountText: '1000',
      categoryName: 'Salary',
    );
    await createInvestmentAccountThroughGui(
      tester,
      accountName: 'Brokerage',
      openingCashText: '1000',
    );
    await openHoldingsFor(tester, 'Brokerage');

    await recordCashFundedBuyThroughGui(
      tester,
      instrumentName: 'Acme Corp',
      quantityText: '5',
      unitPriceText: '20',
    );
    // Cash: 1000 - 100 = 900.

    await recordDividendThroughGui(
      tester,
      amountText: '15',
      incomeCategory: 'Other Income',
    );
    // Cash: 900 + 15 = 915.

    expect(find.textContaining('915.00 USD'), findsWidgets);
    expect(find.textContaining('5 units'), findsWidgets);
  }, timeout: const Timeout(Duration(minutes: 5)));

  testWidgets(
    'selling the remaining sellable quantity still allows a later Dividend',
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));

      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '1000',
        categoryName: 'Salary',
      );
      await createInvestmentAccountThroughGui(
        tester,
        accountName: 'Brokerage',
        openingCashText: '1000',
      );
      await openHoldingsFor(tester, 'Brokerage');

      await recordCashFundedBuyThroughGui(
        tester,
        instrumentName: 'Acme Corp',
        quantityText: '5',
        unitPriceText: '20',
      );
      // Cash: 1000 - 100 = 900.

      await recordSellThroughGui(
        tester,
        quantityText: '5',
        unitPriceText: '25',
        gainIncomeCategory: 'Other Income',
      );
      // Cash: 900 + 125 = 1025.

      expect(find.text(l10n.holdingsNoHoldings), findsOneWidget);

      await recordDividendThroughGui(
        tester,
        amountText: '10',
        incomeCategory: 'Other Income',
      );
      // Cash: 1025 + 10 = 1035.

      expect(find.textContaining('1,035.00 USD'), findsWidgets);
      // A fully-sold instrument stays out of the inventory list.
      expect(find.text(l10n.holdingsNoHoldings), findsOneWidget);
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );

  testWidgets(
    'archiving an investment account still allows closeout, Sell, and a later closeout',
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));

      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '1000',
        categoryName: 'Salary',
      );
      await createInvestmentAccountThroughGui(
        tester,
        accountName: 'Brokerage',
        openingCashText: '1000',
      );
      await openHoldingsFor(tester, 'Brokerage');

      await recordCashFundedBuyThroughGui(
        tester,
        instrumentName: 'Acme Corp',
        quantityText: '5',
        unitPriceText: '20',
      );
      // Cash: 1000 - 100 = 900.

      await popPushedScreen(tester);
      await archiveAccountThroughGui(tester, 'Brokerage');

      await closeoutArchivedAccountThroughGui(
        tester,
        accountName: 'Brokerage',
        toAccountName: 'Cash & Bank',
      );
      // Cash: 900 -> 0 (closed out to Cash & Bank).

      await openHoldingsFor(tester, 'Brokerage');
      expect(find.textContaining('0.00 USD'), findsWidgets);
      // Buy is disabled once archived - Sell and Dividend stay usable.
      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, l10n.actionBuy),
            )
            .onPressed,
        isNull,
      );

      await recordSellThroughGui(
        tester,
        quantityText: '2',
        unitPriceText: '25',
        gainIncomeCategory: 'Other Income',
      );
      // Cash: 0 + (2 * 25) = 50.
      expect(find.textContaining('50.00 USD'), findsWidgets);

      // Selling back into a positive balance offers closeout again.
      await popPushedScreen(tester);
      await tapReliably(
        tester,
        () => find.text(l10n.navRegister),
        () => find.text(l10n.account).evaluate().isNotEmpty,
      );
      await selectDropdownOption(
        tester,
        fieldLabel: l10n.account,
        optionText: l10n.nameHidden('Brokerage'),
      );
      expect(
        find.widgetWithText(OutlinedButton, l10n.transferRemainingBalance),
        findsOneWidget,
      );
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );

  testWidgets(
    'Home shows an investment account as a market estimate and opens holdings on tap',
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));

      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '1000',
        categoryName: 'Salary',
      );
      await createInvestmentAccountThroughGui(
        tester,
        accountName: 'Brokerage',
        openingCashText: '500',
      );

      // find.text('Brokerage') alone is a collision-prone "landed on Home"
      // signal here - createInvestmentAccountThroughGui already leaves the
      // account name visible on the Accounts screen this starts from, so
      // that check would be trivially true before the tap even lands.
      await tapReliably(
        tester,
        () => find.text(l10n.navHome),
        () => find
            .text(l10n.homeWhatYouHaveMinusWhatYouOwe)
            .evaluate()
            .isNotEmpty,
      );
      expect(find.textContaining(l10n.homeMarketEstimate), findsWidgets);

      await tapReliably(
        tester,
        () => find.ancestor(
          of: find.text('Brokerage'),
          matching: find.byType(ListTile),
        ),
        () => find.text(l10n.holdingsInventory).evaluate().isNotEmpty,
        innerTries: 150,
      );
      expect(find.text(l10n.holdingsCash), findsOneWidget);
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
