// Shared GUI flows for the store screenshot and preview-video tools
// (integration_test/store_screenshots_test.dart,
// integration_test/store_previews_test.dart). Not part of the acceptance
// suite. Every step drives the real app through its GUI, reusing the
// acceptance harness, so what the stores show is what the app does.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/l10n/generated/app_localizations.dart';
import 'package:smara_accounting/data/repositories/settings_repository.dart';
import 'package:smara_accounting/main.dart';
import 'package:smara_accounting/ui/core/monthly_limit_progress.dart';
import 'package:smara_accounting/ui/features/category_management/views/category_management_view.dart';
import 'package:smara_accounting/ui/features/payee_management/views/payee_management_view.dart';
import 'package:smara_accounting/ui/features/record_transaction/views/record_transaction_view.dart';
import 'package:smara_accounting/ui/features/recurring_template_management/views/recurring_template_management_view.dart';
import 'package:smara_accounting/ui/features/register/views/register_view.dart';
import 'package:smara_accounting/ui/features/setup_choice/views/setup_choice_view.dart';
import 'package:smara_accounting/ui/features/summary/views/summary_view.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../acceptance/support/acceptance_harness.dart';
import '../acceptance/support/acceptance_locale.dart';

/// Names used across the store media: realistic household books.
abstract final class StoreMediaData {
  static const brokerage = 'Brokerage';
  static const etf = 'Global Equity ETF';
  static const rentPayee = 'Landlord';
}

/// GUI steps over a live [SmaraAccountingApp]. [beat] is the pause between
/// visible steps: zero for screenshots, ~0.8 s for preview videos so a
/// viewer can follow each tap.
class StoreMediaFlows {
  StoreMediaFlows(this.tester, {this.beat = Duration.zero});

  final WidgetTester tester;
  final Duration beat;
  final AppLocalizations l10n = l10nFor(kAcceptanceLocaleTag);

  String get cashBank => l10n.systemAccountCashBank;

  Future<void> pause([int beats = 1]) async {
    if (beat == Duration.zero) {
      await tester.pump(const Duration(milliseconds: 400));
      return;
    }
    for (var i = 0; i < beats; i++) {
      await tester.pump(beat);
    }
  }

  /// Signals the host controller (tool/store_media.py), which watches this
  /// test's output: `shot <name>` takes a device screenshot,
  /// `rec_start <name>` / `rec_stop <name>` start and stop a screen
  /// recording. Waits afterwards so the host acts on a settled screen.
  Future<void> mark(String kind, String name) async {
    await tester.pump(const Duration(milliseconds: 600));
    // ignore: avoid_print
    print('STORE_MEDIA $kind $name');
    await tester.pump(const Duration(milliseconds: 2500));
  }

  Future<void> shot(String name) => mark('shot', name);

  /// Records [body] as one preview clip named [name].
  Future<void> clip(String name, Future<void> Function() body) async {
    await mark('rec_start', name);
    await body();
    await tester.pump(const Duration(milliseconds: 1500));
    await mark('rec_stop', name);
  }

  /// Launches a freshly reset app and waits on the setup-choice screen,
  /// so a recording can start on a real frame (not the test's blank
  /// startup screen). [onboard] continues from here.
  Future<void> launchToSetupChoice() async {
    await SettingsRepository().setFirstWeekSetupCompleted(true);
    await pumpSmaraApp(tester);
    await pumpUntilFound(tester, find.byType(SetupChoiceView));
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> onboard({Future<void> Function(String screen)? onScreen}) =>
      completeOnboardingWithGuidedEntry(
        tester,
        amountText: '3200',
        categoryName: l10n.systemCategorySalary,
        onScreen: onScreen,
      );

  /// Unmounts and relaunches the app on Home; the real database keeps
  /// everything recorded so far. The reliable way out of nested routes.
  Future<void> relaunchToHome() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await pumpSmaraApp(tester);
    await pumpUntilFound(
      tester,
      find.text(l10n.homeWhatYouHaveMinusWhatYouOwe),
    );
    await pause();
  }

  Future<void> goTab(IconData icon, Finder ready) async {
    if (ready.evaluate().isNotEmpty) return;
    // Pushed screens (holdings, settings, forms) hide the tab bar; start
    // again from Home rather than hunting for a back control.
    if (shellNavIcon(icon).hitTestable().evaluate().isEmpty) {
      await relaunchToHome();
      if (ready.evaluate().isNotEmpty) return;
    }
    await tapReliably(
      tester,
      () => shellNavIcon(icon),
      () => ready.evaluate().isNotEmpty,
    );
    await pause();
  }

  Future<void> goHome() =>
      goTab(TablerIcons.home, find.text(l10n.homeWhatYouHaveMinusWhatYouOwe));
  Future<void> goRegister() async {
    await goTab(TablerIcons.receipt, find.byType(RegisterView));
    await selectAccount();
  }

  /// Picks Cash & Bank in the visible "Account" dropdown (forms and the
  /// register default to the first account by sort order, which is the
  /// brokerage once it exists).
  Future<void> selectAccount() async {
    await selectDropdownOption(
      tester,
      fieldLabel: l10n.account,
      optionText: cashBank,
    );
    await pause();
  }

  Future<void> goSummary() =>
      goTab(TablerIcons.chartBar, find.byType(SummaryView));
  Future<void> goAccounts() =>
      goTab(TablerIcons.wallet, find.byTooltip(l10n.createGroup));
  Future<void> goCategories() =>
      goTab(TablerIcons.tag, find.byType(CategoryManagementView));

  Future<void> openAddSheet() async {
    await tapReliably(
      tester,
      () => find.byType(FloatingActionButton).hitTestable(),
      () => find.text(l10n.captureSpent).evaluate().isNotEmpty,
    );
    await pause();
  }

  Future<void> openRecordForm({required bool spent}) async {
    await openAddSheet();
    await tapReliably(
      tester,
      () => find.widgetWithText(
        ListTile,
        spent ? l10n.captureSpent : l10n.captureReceived,
      ),
      () => find.byType(RecordTransactionView).evaluate().isNotEmpty,
    );
    await pumpUntilFound(tester, find.text(l10n.account));
    await selectAccount();
  }

  Finder _recordField(String label) => find.descendant(
    of: find.byType(RecordTransactionView),
    matching: find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.labelText == label,
    ),
  );

  Future<void> _enter(Finder Function() field, String text) async {
    await enterTextReliably(tester, field, text, () {
      final w = field().evaluate().single.widget as TextField;
      return w.controller?.text == text;
    });
    await pause();
  }

  /// Fills the open record form (amount, category, optional description)
  /// without saving.
  Future<void> fillRecord({
    required String amount,
    required String category,
    String? description,
  }) async {
    await _enter(() => _recordField(l10n.amount).first, amount);
    await selectDropdownOption(
      tester,
      fieldLabel: l10n.category,
      optionText: category,
    );
    await pause();
    if (description != null) {
      final field = _recordField(l10n.descriptionOptional);
      await tester.ensureVisible(field);
      await tester.showKeyboard(field);
      await tester.enterText(field, description);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await pause();
    }
  }

  Future<void> saveRecord() async {
    await tapReliably(
      tester,
      () => find.descendant(
        of: find.byType(RecordTransactionView),
        matching: find.text(l10n.actionSave),
      ),
      () => find.byType(RecordTransactionView).evaluate().isEmpty,
      innerTries: 150,
    );
    await pause();
  }

  Future<void> recordSpent(
    String amount,
    String category, [
    String? description,
  ]) async {
    await openRecordForm(spent: true);
    await fillRecord(
      amount: amount,
      category: category,
      description: description,
    );
    await saveRecord();
  }

  /// Opens the record form and splits [total] across two categories,
  /// leaving it unsaved and balanced.
  Future<void> fillSplit({
    required String total,
    required String firstCategory,
    required String firstAmount,
    required String secondCategory,
    required String secondAmount,
  }) async {
    await openRecordForm(spent: true);
    await _enter(() => _recordField(l10n.amount).first, total);
    await tapReliably(
      tester,
      () => find.text(l10n.splitIntoCategories),
      () => find.text(l10n.categoryN('1')).evaluate().isNotEmpty,
    );
    await pause();
    await selectDropdownOption(
      tester,
      fieldLabel: l10n.categoryN('1'),
      optionText: firstCategory,
    );
    await _enter(() => _recordField(l10n.amount).at(1), firstAmount);
    await selectDropdownOption(
      tester,
      fieldLabel: l10n.categoryN('2'),
      optionText: secondCategory,
    );
    await _enter(() => _recordField(l10n.amount).at(2), secondAmount);
  }

  Future<void> setMonthlyLimit(String category, String amount) async {
    await goCategories();
    await tester.ensureVisible(find.text(category));
    await tester.pump(const Duration(milliseconds: 200));
    final row = find.ancestor(
      of: find.text(category),
      matching: find.byType(ListTile),
    );
    await tapReliably(
      tester,
      () => find
          .descendant(of: row, matching: find.byTooltip(l10n.monthlyLimit))
          .hitTestable(),
      () =>
          find.text(l10n.monthlyLimitHint).evaluate().isNotEmpty ||
          find.byType(TextField).evaluate().length > 1,
    );
    await _enter(() => find.byType(TextField).last, amount);
    await tapReliably(
      tester,
      () => find.widgetWithText(ElevatedButton, l10n.actionSave),
      () => find.byType(MonthlyLimitProgress).evaluate().isNotEmpty,
      innerTries: 100,
    );
    await pause();
  }

  Future<void> createBrokerage() async {
    await createInvestmentAccountThroughGui(
      tester,
      name: StoreMediaData.brokerage,
      openingBalanceText: '5000',
    );
    await pause();
  }

  Future<void> openBrokerage() async {
    await goHome();
    // On shorter screens the floating Add button covers the last Home row;
    // scroll the brokerage row clear of it before tapping.
    final row = find.widgetWithText(ListTile, StoreMediaData.brokerage);
    for (var i = 0; i < 8; i++) {
      final hit = row.hitTestable().evaluate();
      if (hit.isNotEmpty) {
        final box = tester.getRect(row.first);
        final fab = tester.getRect(find.byType(FloatingActionButton).first);
        if (!box.overlaps(fab)) break;
      }
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -250));
      await tester.pump(const Duration(milliseconds: 300));
    }
    await tapReliably(
      tester,
      () => row.hitTestable(),
      () => find.text(l10n.holdingsCash).evaluate().isNotEmpty,
      innerTries: 150,
      scrollIntoView: false,
    );
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await pause();
  }

  Future<void> buyEtf() async {
    await recordCashFundedBuyThroughGui(
      tester,
      instrumentName: StoreMediaData.etf,
      quantityText: '12',
      unitPriceText: '98.50',
    );
    await pause(2);
  }

  /// Accounts → Transfer, filled from Cash & Bank to Brokerage, unsaved.
  Future<void> fillTransfer(String amount) async {
    await goAccounts();
    await tapReliably(
      tester,
      () => find.byTooltip(l10n.actionTransfer),
      () => find.text(l10n.fromAccount).evaluate().isNotEmpty,
    );
    await pause();
    await selectDropdownOption(
      tester,
      fieldLabel: l10n.fromAccount,
      optionText: cashBank,
    );
    await selectDropdownOption(
      tester,
      fieldLabel: l10n.toAccount,
      optionText: StoreMediaData.brokerage,
    );
    await _enter(() => textFieldWithLabel(l10n.amount).first, amount);
  }

  Future<void> saveTransfer() async {
    await tapReliably(
      tester,
      () => find.widgetWithText(ElevatedButton, l10n.captureMovedMoney),
      () => find.text(l10n.fromAccount).evaluate().isEmpty,
      innerTries: 150,
    );
    await pause(2);
  }

  /// Taps a recurring template listed under Home's "Due today".
  Future<void> recordDueTemplate(String name) async {
    await pumpUntilFound(tester, find.text(l10n.homeDueToday));
    await pause();
    await tapReliably(
      tester,
      () => find.text(name),
      () =>
          find.text(l10n.homeDueToday).evaluate().isEmpty ||
          find.text(name).evaluate().isEmpty,
      innerTries: 150,
    );
    await pause(2);
  }

  /// Register → Fix on the newest correctable row → new category, unsaved.
  Future<void> openFix({String? newCategory}) async {
    await goRegister();
    await tapReliably(
      tester,
      () => find.text(l10n.actionFix).first,
      () => find.text(l10n.actionConfirmFix).evaluate().isNotEmpty,
      innerTries: 100,
    );
    await pause();
    if (newCategory != null) {
      await selectDropdownOption(
        tester,
        fieldLabel: l10n.category,
        optionText: newCategory,
      );
      await pause();
    }
  }

  Future<void> confirmFix() async {
    await tapReliably(
      tester,
      () => find.widgetWithText(ElevatedButton, l10n.actionConfirmFix),
      () => find.text(l10n.actionConfirmFix).evaluate().isEmpty,
      innerTries: 150,
    );
    await pause(2);
  }

  Future<void> searchRegister(String query) async {
    await goRegister();
    await _enter(() => find.widgetWithText(TextField, l10n.searchLabel), query);
  }

  Future<void> openSettings() async {
    await goHome();
    await tapReliably(
      tester,
      () => find.byTooltip(l10n.settingsTitle),
      () => find.text(l10n.settingsFetchFxRates).evaluate().isNotEmpty,
    );
    await pause();
  }

  Future<void> scrollSettingsTo(Finder target) async {
    // Home's ListView stays mounted under Settings; see the helper.
    await scrollSettingsUntilVisible(tester, target);
    await tester.ensureVisible(target);
    await pause();
  }

  Future<void> openPayees() async {
    await openSettings();
    await scrollSettingsTo(find.text(l10n.settingsManagePayees));
    await tapReliably(
      tester,
      () => find.widgetWithText(OutlinedButton, l10n.settingsManagePayees),
      () => find.text(l10n.payeesTitle).evaluate().isNotEmpty,
      innerTries: 80,
    );
    await pause();
  }

  Future<void> openRecurring() async {
    await openSettings();
    await scrollSettingsTo(find.text(l10n.settingsManageRecurring));
    await tapReliably(
      tester,
      () => find.widgetWithText(OutlinedButton, l10n.settingsManageRecurring),
      () => find.text(l10n.recurringTitle).evaluate().isNotEmpty,
      innerTries: 80,
    );
    await pause();
  }

  Future<void> addPayee(String name) async {
    await openPayees();
    await tapReliably(
      tester,
      () => find.descendant(
        of: find.byType(PayeeManagementView),
        matching: find.byType(FloatingActionButton),
      ),
      () => find.text(l10n.addPayee).evaluate().isNotEmpty,
    );
    await _enter(() => find.byType(TextField).last, name);
    await tapReliably(
      tester,
      () => find.widgetWithText(ElevatedButton, l10n.actionAdd),
      () => find.text(l10n.addPayee).evaluate().isEmpty,
    );
    await pause();
  }

  Future<void> addRecurringTemplate({
    required String name,
    required String category,
    required String amount,
    required int day,
  }) async {
    await openRecurring();
    await tapReliably(
      tester,
      () => find.descendant(
        of: find.byType(RecurringTemplateManagementView),
        matching: find.byType(FloatingActionButton),
      ),
      () => find.widgetWithText(TextField, l10n.name).evaluate().isNotEmpty,
    );
    await _enter(() => find.widgetWithText(TextField, l10n.name), name);
    if (find.text(l10n.account).evaluate().isNotEmpty) await selectAccount();
    await selectDropdownOption(
      tester,
      fieldLabel: l10n.category,
      optionText: category,
    );
    await _enter(() => find.widgetWithText(TextField, l10n.amount), amount);
    await _enter(() => find.widgetWithText(TextField, l10n.dayOfMonth), '$day');
    await tapReliably(
      tester,
      () => find.widgetWithText(ElevatedButton, l10n.actionAdd),
      () =>
          find.text(name).evaluate().isNotEmpty &&
          find.byType(AlertDialog).evaluate().isEmpty,
      innerTries: 150,
    );
    await pause();
  }

  Future<void> openImport() async {
    await goAccounts();
    await tapReliably(
      tester,
      () => find.byTooltip(l10n.importOfx),
      () => find.text(l10n.whatKindOfStatement).evaluate().isNotEmpty,
    );
    await pause();
  }

  /// Seeds realistic books after onboarding: everyday spending, a rent
  /// bill, a grocery limit, a brokerage account with one ETF buy, a
  /// remembered payee, and a recurring template due today. Leaves the app
  /// on Home.
  Future<void> seedHousehold() async {
    await recordSpent('84.20', l10n.systemCategoryGroceries, 'Weekly shop');
    await recordSpent('1450.00', l10n.systemCategoryRentMortgage, 'Rent');
    await recordSpent('62.30', l10n.systemCategoryUtilities, 'Electricity');
    await recordSpent('45.00', l10n.systemCategoryFoodOut, 'Dinner out');
    await recordSpent('38.00', l10n.systemCategoryTransport, 'Train pass');
    await recordSpent('23.50', l10n.systemCategoryGroceries, 'Bakery');
    await setMonthlyLimit(l10n.systemCategoryGroceries, '400.00');
    await createBrokerage();
    await openBrokerage();
    await buyEtf();
    await addPayee(StoreMediaData.rentPayee);
    await relaunchToHome();
    await addRecurringTemplate(
      name: 'Phone plan',
      category: l10n.systemCategoryPhone,
      amount: '29.00',
      day: DateTime.now().day,
    );
    await relaunchToHome();
  }
}
