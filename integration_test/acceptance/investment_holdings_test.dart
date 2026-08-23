import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_en.dart';
import 'package:smara_accounting/ui/features/holdings/views/holdings_view.dart';
import 'package:smara_accounting/ui/features/record_transaction/views/record_transaction_view.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import 'support/acceptance_harness.dart';

const _brokerage = 'Brokerage';
const _checking = 'Cash & Bank';
const _instrument = 'Acme Stock';

/// Real-build acceptance coverage for investment accounting. Walks the
/// real GUI against the real on-disk database — no Repository backdoors.
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
      amountText: '25',
      categoryName: 'Salary',
    );
    await createInvestmentAccountThroughGui(
      tester,
      name: _brokerage,
      openingBalanceText: '500.00',
    );
    await openHoldingsFor(tester, _brokerage);
    expect(find.text(l10n.holdingsCash), findsOneWidget);
    expect(find.text('500.00 USD'), findsWidgets);
    expect(find.text(l10n.holdingsNoHoldings), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  }, timeout: const Timeout(Duration(minutes: 5)));

  testWidgets(
    'cash in and cash out leave inventory empty; picker hides inventory companion',
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));
      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '1000',
        categoryName: 'Salary',
      );
      await createInvestmentAccountThroughGui(
        tester,
        name: _brokerage,
        openingBalanceText: '100.00',
      );
      await _transferThroughGui(
        tester,
        fromName: _checking,
        toName: _brokerage,
        amountText: '50.00',
      );
      expect(find.text('$_brokerage Inventory'), findsNothing);
      await _transferThroughGui(
        tester,
        fromName: _brokerage,
        toName: _checking,
        amountText: '20.00',
      );
      await openHoldingsFor(tester, _brokerage);
      expect(
        find.text('130.00 USD'),
        findsWidgets,
        reason: find
            .byType(Text)
            .evaluate()
            .map((e) => (e.widget as Text).data)
            .where((t) => t != null && t.contains('USD'))
            .join(', '),
      );
      expect(find.text(l10n.holdingsNoHoldings), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );

  testWidgets('cash out greater than cash is rejected and cash is unchanged', (
    tester,
  ) async {
    addTearDown(() => resetToFreshDevice(tester));
    await completeOnboardingWithGuidedEntry(
      tester,
      amountText: '25',
      categoryName: 'Salary',
    );
    await createInvestmentAccountThroughGui(
      tester,
      name: _brokerage,
      openingBalanceText: '100.00',
    );
    await _transferThroughGui(
      tester,
      fromName: _brokerage,
      toName: _checking,
      amountText: '999.00',
      expectSuccess: false,
    );
    expect(find.text(l10n.errorInvestmentCashExceeded), findsOneWidget);
    await tapReliably(
      tester,
      () => find.byTooltip('Back'),
      () => find.text(l10n.fromAccount).evaluate().isEmpty,
    );
    await openHoldingsFor(tester, _brokerage);
    expect(find.text('100.00 USD'), findsWidgets);
    await tester.pump(const Duration(seconds: 2));
  }, timeout: const Timeout(Duration(minutes: 5)));

  testWidgets(
    'ordinary spent against investment cash does not touch inventory',
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));
      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '25',
        categoryName: 'Salary',
      );
      await createInvestmentAccountThroughGui(
        tester,
        name: _brokerage,
        openingBalanceText: '200.00',
      );
      await _recordSpentAgainst(
        tester,
        accountName: _brokerage,
        amountText: '25.00',
        categoryName: 'Groceries',
      );
      await openHoldingsFor(tester, _brokerage);
      expect(find.text('175.00 USD'), findsWidgets);
      expect(find.text(l10n.holdingsNoHoldings), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );

  testWidgets('a zero-cash investment account cannot buy until funded', (
    tester,
  ) async {
    addTearDown(() => resetToFreshDevice(tester));
    await completeOnboardingWithGuidedEntry(
      tester,
      amountText: '25',
      categoryName: 'Salary',
    );
    await createInvestmentAccountThroughGui(tester, name: _brokerage);
    await openHoldingsFor(tester, _brokerage);
    await recordCashFundedBuyThroughGui(
      tester,
      instrumentName: _instrument,
      quantityText: '1',
      unitPriceText: '10.00',
      expectSuccess: false,
    );
    expect(find.text(l10n.errorInsufficientCash), findsOneWidget);
    await tapReliably(
      tester,
      () => find.widgetWithText(TextButton, l10n.actionCancel).hitTestable(),
      () => find.text(l10n.actionRecordBuy).evaluate().isEmpty,
    );
    expect(find.text(l10n.holdingsNoHoldings), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
  }, timeout: const Timeout(Duration(minutes: 5)));

  testWidgets('cash-funded buy with brokerage updates cash and inventory', (
    tester,
  ) async {
    addTearDown(() => resetToFreshDevice(tester));
    await completeOnboardingWithGuidedEntry(
      tester,
      amountText: '25',
      categoryName: 'Salary',
    );
    await createInvestmentAccountThroughGui(
      tester,
      name: _brokerage,
      openingBalanceText: '2000.00',
    );
    await openHoldingsFor(tester, _brokerage);
    await recordCashFundedBuyThroughGui(
      tester,
      instrumentName: _instrument,
      quantityText: '10',
      unitPriceText: '100.00',
      brokerageText: '5.00',
      brokerageExpenseCategory: 'Other Expense',
    );
    expect(find.text(_instrument), findsOneWidget);
    expect(find.textContaining('10 units'), findsOneWidget);
    expect(find.text('995.00 USD'), findsWidgets);
    await tester.pump(const Duration(seconds: 2));
  }, timeout: const Timeout(Duration(minutes: 5)));

  testWidgets(
    'employer-match buy with lock-until blocks selling the locked unit',
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));
      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '25',
        categoryName: 'Salary',
      );
      await createInvestmentAccountThroughGui(
        tester,
        name: _brokerage,
        openingBalanceText: '1000.00',
      );
      await openHoldingsFor(tester, _brokerage);
      await recordCashFundedBuyThroughGui(
        tester,
        instrumentName: _instrument,
        quantityText: '3',
        unitPriceText: '100.00',
      );
      await _recordNonCashBuyThroughGui(
        tester,
        instrumentName: _instrument,
        quantityText: '1',
        unitPriceText: '100.00',
        incomeCategory: 'Salary',
        lockUntil: true,
      );
      expect(find.textContaining('4 units'), findsOneWidget);
      await _openSellDialog(tester);
      await enterTextReliably(
        tester,
        () => textFieldWithLabel(l10n.quantity),
        '4',
        () {
          final field =
              textFieldWithLabel(l10n.quantity).evaluate().single.widget
                  as TextField;
          return field.controller?.text == '4';
        },
      );
      await enterTextReliably(
        tester,
        () => textFieldWithLabel(l10n.unitPrice),
        '100.00',
        () {
          final field =
              textFieldWithLabel(l10n.unitPrice).evaluate().single.widget
                  as TextField;
          return field.controller?.text == '100.00';
        },
      );
      await tapReliably(
        tester,
        () => find.widgetWithText(ElevatedButton, l10n.actionRecordSell),
        () => find.textContaining('locked until').evaluate().isNotEmpty,
        innerTries: 150,
      );
      expect(find.textContaining('locked until'), findsOneWidget);
      await tapReliably(
        tester,
        () => find.widgetWithText(TextButton, l10n.actionCancel).hitTestable(),
        () => find.text(l10n.actionRecordSell).evaluate().isEmpty,
      );
      expect(find.textContaining('4 units'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );

  testWidgets(
    'sell of unlocked units at a gain increases cash and reduces inventory',
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));
      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '25',
        categoryName: 'Salary',
      );
      await createInvestmentAccountThroughGui(
        tester,
        name: _brokerage,
        openingBalanceText: '2000.00',
      );
      await openHoldingsFor(tester, _brokerage);
      await recordCashFundedBuyThroughGui(
        tester,
        instrumentName: _instrument,
        quantityText: '10',
        unitPriceText: '100.00',
      );
      await _recordSellThroughGui(
        tester,
        quantityText: '3',
        unitPriceText: '120.00',
        gainIncomeCategory: 'Salary',
      );
      expect(find.textContaining('7 units'), findsOneWidget);
      expect(find.text('1,360.00 USD'), findsWidgets);
      await tester.pump(const Duration(seconds: 2));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );

  testWidgets('dividend increases cash without changing quantity', (
    tester,
  ) async {
    addTearDown(() => resetToFreshDevice(tester));
    await completeOnboardingWithGuidedEntry(
      tester,
      amountText: '25',
      categoryName: 'Salary',
    );
    await createInvestmentAccountThroughGui(
      tester,
      name: _brokerage,
      openingBalanceText: '2000.00',
    );
    await openHoldingsFor(tester, _brokerage);
    await recordCashFundedBuyThroughGui(
      tester,
      instrumentName: _instrument,
      quantityText: '5',
      unitPriceText: '100.00',
    );
    await _recordDividendThroughGui(
      tester,
      amountText: '40.00',
      incomeCategory: 'Salary',
    );
    expect(find.textContaining('5 units'), findsOneWidget);
    expect(find.text('1,540.00 USD'), findsWidgets);
    await tester.pump(const Duration(seconds: 2));
  }, timeout: const Timeout(Duration(minutes: 5)));

  testWidgets('dividend still posts after the position is fully sold', (
    tester,
  ) async {
    addTearDown(() => resetToFreshDevice(tester));
    await completeOnboardingWithGuidedEntry(
      tester,
      amountText: '25',
      categoryName: 'Salary',
    );
    await createInvestmentAccountThroughGui(
      tester,
      name: _brokerage,
      openingBalanceText: '2000.00',
    );
    await openHoldingsFor(tester, _brokerage);
    await recordCashFundedBuyThroughGui(
      tester,
      instrumentName: _instrument,
      quantityText: '5',
      unitPriceText: '100.00',
    );
    await _recordSellThroughGui(
      tester,
      quantityText: '5',
      unitPriceText: '110.00',
      gainIncomeCategory: 'Salary',
    );
    expect(find.text(l10n.holdingsNoHoldings), findsOneWidget);
    await _recordDividendThroughGui(
      tester,
      amountText: '15.00',
      incomeCategory: 'Salary',
    );
    expect(find.text(l10n.holdingsNoHoldings), findsOneWidget);
    expect(find.text('2,065.00 USD'), findsWidgets);
    await tester.pump(const Duration(seconds: 2));
  }, timeout: const Timeout(Duration(minutes: 5)));

  testWidgets(
    'archived investment account allows sell and repeatable cash closeout',
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));
      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '25',
        categoryName: 'Salary',
      );
      await createInvestmentAccountThroughGui(
        tester,
        name: _brokerage,
        openingBalanceText: '200.00',
      );
      await openHoldingsFor(tester, _brokerage);
      await recordCashFundedBuyThroughGui(
        tester,
        instrumentName: _instrument,
        quantityText: '2',
        unitPriceText: '50.00',
      );
      await _archiveAccount(tester, _brokerage);
      await openHoldingsFor(tester, _brokerage);
      final buy = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, l10n.actionBuy),
      );
      expect(buy.onPressed, isNull);
      await tapReliably(
        tester,
        () => find.byTooltip(l10n.homeCashRegister).hitTestable(),
        () => find.text(l10n.transferRemainingBalance).evaluate().isNotEmpty,
        innerTries: 150,
      );
      await tapReliably(
        tester,
        () => find
            .widgetWithText(OutlinedButton, l10n.transferRemainingBalance)
            .hitTestable(),
        () => find.text(l10n.toAccount).evaluate().isNotEmpty,
      );
      await tapReliably(
        tester,
        () => find.widgetWithText(ElevatedButton, l10n.actionTransfer),
        () => find
            .widgetWithText(OutlinedButton, l10n.transferRemainingBalance)
            .evaluate()
            .isEmpty,
        innerTries: 150,
      );
      await openHoldingsFor(tester, _brokerage);
      await _recordSellThroughGui(
        tester,
        quantityText: '2',
        unitPriceText: '60.00',
        gainIncomeCategory: 'Salary',
      );
      await tapReliably(
        tester,
        () => find.byTooltip(l10n.homeCashRegister).hitTestable(),
        () => find.text(l10n.transferRemainingBalance).evaluate().isNotEmpty,
        innerTries: 150,
      );
      expect(find.text(l10n.transferRemainingBalance), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );

  testWidgets(
    'home shows a labeled market estimate and tapping opens holdings',
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));
      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '25',
        categoryName: 'Salary',
      );
      await createInvestmentAccountThroughGui(
        tester,
        name: _brokerage,
        openingBalanceText: '500.00',
      );
      await tapReliably(
        tester,
        () => shellNavIcon(TablerIcons.home),
        () => find.byTooltip(l10n.settingsTitle).evaluate().isNotEmpty,
      );
      await tapReliably(
        tester,
        () => find.byTooltip(l10n.settingsTitle).hitTestable(),
        () => find.text(l10n.settingsFetchMarketPrices).evaluate().isNotEmpty,
        innerTries: 150,
      );
      bool marketFetchOff() {
        final tiles = find.byType(SwitchListTile).evaluate();
        for (final tile in tiles) {
          final widget = tile.widget;
          if (widget is SwitchListTile &&
              widget.title is Text &&
              (widget.title as Text).data == l10n.settingsFetchMarketPrices) {
            return widget.value == false;
          }
        }
        return false;
      }

      if (!marketFetchOff()) {
        await tapReliably(
          tester,
          () => find.text(l10n.settingsFetchMarketPrices).hitTestable(),
          marketFetchOff,
        );
      }
      await tapReliably(
        tester,
        () => find.byTooltip('Back'),
        () => find.text(l10n.settingsFetchMarketPrices).evaluate().isEmpty,
      );
      await openHoldingsFor(tester, _brokerage);
      await recordCashFundedBuyThroughGui(
        tester,
        instrumentName: _instrument,
        quantityText: '2',
        unitPriceText: '100.00',
      );
      await tapReliably(
        tester,
        () => find.byTooltip('Back'),
        () => find.byType(HoldingsView).evaluate().isEmpty,
      );
      expect(find.text(l10n.homeMarketEstimate), findsOneWidget);
      await tapReliably(
        tester,
        () => find.widgetWithText(ListTile, _brokerage).hitTestable(),
        () => find.text(l10n.holdingsCash).evaluate().isNotEmpty,
      );
      expect(find.text(l10n.holdingsCash), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}

Future<void> _openCashRegisterFor(
  WidgetTester tester,
  String accountName,
) async {
  final l10n = AppLocalizationsEn();
  await openHoldingsFor(tester, accountName);
  await tapReliably(
    tester,
    () => find.byTooltip(l10n.homeCashRegister),
    () => find.text(l10n.registerTitle).hitTestable().evaluate().isNotEmpty,
    innerTries: 150,
    scrollIntoView: false,
  );
  // RegisterViewModel.selectAccount is posted to the next frame, and the
  // default watch emission selects Cash & Bank first. Wait until this
  // account is the visible picker value so Transfer/Spent prefills it.
  for (var i = 0; i < 80; i++) {
    final selected = find
        .descendant(
          of: dropdownWithLabel(l10n.account),
          matching: find.text(accountName),
        )
        .hitTestable();
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty &&
        selected.evaluate().isNotEmpty) {
      return;
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
  fail(
    'Register never showed $accountName as the selected account.\n'
    '${find.byType(Text).evaluate().map((e) => (e.widget as Text).data).toList()}',
  );
}

Finder _registerAddFab() => find.byWidgetPredicate(
  (widget) =>
      widget is FloatingActionButton && widget.heroTag == 'register-add-fab',
);

Future<void> _transferThroughGui(
  WidgetTester tester, {
  required String fromName,
  required String toName,
  required String amountText,
  bool expectSuccess = true,
}) async {
  final l10n = AppLocalizationsEn();

  if (fromName == _brokerage) {
    await _openCashRegisterFor(tester, _brokerage);
    await tapReliably(
      tester,
      _registerAddFab,
      () => find.text(l10n.captureMovedMoney).evaluate().isNotEmpty,
    );
    await tapReliably(
      tester,
      () => find.text(l10n.captureMovedMoney).first,
      () => find.text(l10n.fromAccount).evaluate().isNotEmpty,
    );
  } else {
    await tapReliably(
      tester,
      () => shellNavIcon(TablerIcons.wallet),
      () => find.byTooltip(l10n.actionTransfer).evaluate().isNotEmpty,
    );
    await tapReliably(
      tester,
      () => find.byTooltip(l10n.actionTransfer),
      () => find.text(l10n.fromAccount).evaluate().isNotEmpty,
    );
  }

  // Financial accounts are ordered by sortOrder then name. Brokerage
  // sorts before "Cash & Bank" when both share sortOrder 0, so the
  // transfer form's default From is the investment account. Always pick
  // From/To explicitly. Opening From also lets us assert the inventory
  // companion is not a transfer target.
  await tester.pump(const Duration(milliseconds: 500));
  if (!dropdownOverlayOpen()) {
    await tapReliably(
      tester,
      () => dropdownWithLabel(l10n.fromAccount).hitTestable(),
      dropdownOverlayOpen,
    );
  }
  await tester.pump(const Duration(milliseconds: 400));
  expect(
    find.descendant(
      of: dropdownMenu(),
      matching: find.text('$_brokerage Inventory'),
    ),
    findsNothing,
  );
  expect(
    find.descendant(of: dropdownMenu(), matching: find.text(fromName)),
    findsOneWidget,
  );
  expect(
    find.descendant(of: dropdownMenu(), matching: find.text(toName)),
    findsOneWidget,
  );
  await tapReliably(
    tester,
    () => find.descendant(of: dropdownMenu(), matching: find.text(fromName)),
    () => !dropdownOverlayOpen(),
    scrollIntoView: false,
  );
  await selectDropdownOption(
    tester,
    fieldLabel: l10n.toAccount,
    optionText: toName,
  );

  await enterTextReliably(
    tester,
    () => textFieldWithLabel(l10n.amount),
    amountText,
    () {
      final field =
          textFieldWithLabel(l10n.amount).evaluate().single.widget as TextField;
      return field.controller?.text == amountText;
    },
  );
  if (expectSuccess) {
    await tapReliably(
      tester,
      () => find.widgetWithText(ElevatedButton, l10n.captureMovedMoney),
      () => find.text(l10n.fromAccount).evaluate().isEmpty,
      innerTries: 150,
    );
  } else {
    await tester.ensureVisible(
      find.widgetWithText(ElevatedButton, l10n.captureMovedMoney),
    );
    await tester.tap(
      find.widgetWithText(ElevatedButton, l10n.captureMovedMoney),
    );
    await pumpUntilFound(tester, find.text(l10n.errorInvestmentCashExceeded));
  }
}

Future<void> _recordSpentAgainst(
  WidgetTester tester, {
  required String accountName,
  required String amountText,
  required String categoryName,
}) async {
  final l10n = AppLocalizationsEn();
  await _openCashRegisterFor(tester, accountName);
  await tapReliably(
    tester,
    _registerAddFab,
    () => find.text(l10n.captureSpent).evaluate().isNotEmpty,
  );
  await tapReliably(
    tester,
    () => find.text(l10n.captureSpent),
    () => find.byType(RecordTransactionView).evaluate().isNotEmpty,
  );
  await enterTextReliably(
    tester,
    () => textFieldWithLabel(l10n.amount),
    amountText,
    () {
      final field =
          textFieldWithLabel(l10n.amount).evaluate().single.widget as TextField;
      return field.controller?.text == amountText;
    },
  );
  await selectDropdownOption(
    tester,
    fieldLabel: l10n.category,
    optionText: categoryName,
  );
  await tapReliably(
    tester,
    () => find.descendant(
      of: find.byType(RecordTransactionView),
      matching: find.text(l10n.actionSave),
    ),
    () => find.byType(RecordTransactionView).evaluate().isEmpty,
    innerTries: 150,
  );
}

Future<void> _recordNonCashBuyThroughGui(
  WidgetTester tester, {
  required String instrumentName,
  required String quantityText,
  required String unitPriceText,
  required String incomeCategory,
  bool lockUntil = false,
}) async {
  final l10n = AppLocalizationsEn();
  await tapReliably(
    tester,
    () => find.widgetWithText(ElevatedButton, l10n.actionBuy).hitTestable(),
    () => find.text(l10n.actionRecordBuy).evaluate().isNotEmpty,
  );
  await tapReliably(tester, () => find.text(l10n.nonCash).hitTestable(), () {
    return dropdownWithLabel(l10n.incomeCategory).evaluate().isNotEmpty;
  });
  await selectDropdownOption(
    tester,
    fieldLabel: l10n.instrument,
    optionText: instrumentName,
  );
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
  await selectDropdownOption(
    tester,
    fieldLabel: l10n.incomeCategory,
    optionText: incomeCategory,
  );
  if (lockUntil) {
    await tapReliably(
      tester,
      () => find.text(l10n.lockUntilOptional),
      () =>
          find.byType(DatePickerDialog).evaluate().isNotEmpty ||
          find.text('OK').evaluate().isNotEmpty,
    );
    final next = find.byTooltip('Next month');
    if (next.evaluate().isNotEmpty) {
      await tester.tap(next);
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tester.tap(find.text('15').last);
    await tester.pump();
    await tester.tap(find.text('OK'));
    await pumpUntilFound(tester, find.textContaining('Locked until'));
  }
  await tapReliably(
    tester,
    () => find.widgetWithText(ElevatedButton, l10n.actionRecordBuy),
    () => find.text(l10n.actionRecordBuy).evaluate().isEmpty,
    innerTries: 150,
  );
}

Future<void> _openSellDialog(WidgetTester tester) async {
  final l10n = AppLocalizationsEn();
  await tapReliably(
    tester,
    () => find.widgetWithText(OutlinedButton, l10n.actionSell).hitTestable(),
    () => find.text(l10n.actionRecordSell).evaluate().isNotEmpty,
  );
}

Future<void> _recordSellThroughGui(
  WidgetTester tester, {
  required String quantityText,
  required String unitPriceText,
  required String gainIncomeCategory,
}) async {
  final l10n = AppLocalizationsEn();
  await _openSellDialog(tester);
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
  await pumpUntilFound(tester, find.text(l10n.looksLikeGain));
  await selectDropdownOption(
    tester,
    fieldLabel: l10n.gainIncomeCategory,
    optionText: gainIncomeCategory,
  );
  await tapReliably(
    tester,
    () => find.widgetWithText(ElevatedButton, l10n.actionRecordSell),
    () => find.text(l10n.actionRecordSell).evaluate().isEmpty,
    innerTries: 150,
  );
}

Future<void> _recordDividendThroughGui(
  WidgetTester tester, {
  required String amountText,
  required String incomeCategory,
}) async {
  final l10n = AppLocalizationsEn();
  await tapReliably(
    tester,
    () =>
        find.widgetWithText(OutlinedButton, l10n.actionDividend).hitTestable(),
    () => find.text(l10n.actionRecordDividend).evaluate().isNotEmpty,
  );
  await enterTextReliably(
    tester,
    () => textFieldWithLabel(l10n.amount),
    amountText,
    () {
      final field =
          textFieldWithLabel(l10n.amount).evaluate().single.widget as TextField;
      return field.controller?.text == amountText;
    },
  );
  await selectDropdownOption(
    tester,
    fieldLabel: l10n.incomeCategory,
    optionText: incomeCategory,
  );
  await tapReliably(
    tester,
    () => find.widgetWithText(ElevatedButton, l10n.actionRecordDividend),
    () => find.text(l10n.actionRecordDividend).evaluate().isEmpty,
    innerTries: 150,
  );
}

Future<void> _archiveAccount(WidgetTester tester, String accountName) async {
  final l10n = AppLocalizationsEn();
  if (find.byType(HoldingsView).evaluate().isNotEmpty) {
    await tapReliably(
      tester,
      () => find.byTooltip('Back'),
      () => find.byType(HoldingsView).evaluate().isEmpty,
    );
  }
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
    () => find.descendant(
      of: find.widgetWithText(ListTile, accountName),
      matching: find.byWidgetPredicate((widget) => widget is PopupMenuButton),
    ),
    () => find.text(l10n.actionHide).evaluate().isNotEmpty,
  );
  await tapReliably(
    tester,
    () => find.text(l10n.actionHide).last,
    () => find.text(l10n.hideAccountTitle).evaluate().isNotEmpty,
  );
  await tapReliably(
    tester,
    () => find.text(l10n.actionHide).last,
    () => find.text(l10n.hiddenLabel).evaluate().isNotEmpty,
    innerTries: 150,
  );
}
