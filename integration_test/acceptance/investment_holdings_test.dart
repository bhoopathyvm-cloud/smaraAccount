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
}
