import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_picker_platform_interface/file_picker_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_en.dart';
import 'package:smara_accounting/main.dart';
import 'package:smara_accounting/ui/core/monthly_limit_progress.dart';
import 'package:smara_accounting/ui/features/payee_management/views/payee_management_view.dart';
import 'package:smara_accounting/ui/features/record_transaction/views/record_transaction_view.dart';
import 'package:smara_accounting/ui/features/recurring_template_management/views/recurring_template_management_view.dart';
import 'package:smara_accounting/ui/features/register/views/register_row_tile.dart';
import 'package:smara_accounting/ui/features/register/views/register_view.dart';

import 'support/acceptance_harness.dart';

/// Real-build acceptance coverage for day-to-day organization features
/// (acceptance-test-suite task 8.1): payees, recurring templates,
/// import-category-rules, monthly-category-limits, split-transactions,
/// correction-wizard, and register-search.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final l10n = AppLocalizationsEn();
  late final FilePickerPlatform defaultFilePickerPlatform;

  setUpAll(() async {
    defaultFilePickerPlatform = FilePickerPlatform.instance;
    await resetToFreshDevice();
  });

  testWidgets('selecting a payee prefills its remembered category', (
    tester,
  ) async {
    addTearDown(() => resetToFreshDevice(tester));

    await completeOnboardingWithGuidedEntry(
      tester,
      amountText: '1000',
      categoryName: 'Salary',
    );

    await _openSettings(tester, l10n);
    await _scrollUntilVisible(tester, find.text(l10n.settingsManagePayees));
    await tapReliably(
      tester,
      () => find.widgetWithText(OutlinedButton, l10n.settingsManagePayees),
      () => find.text(l10n.payeesTitle).evaluate().isNotEmpty,
      innerTries: 80,
    );
    await tapReliably(
      tester,
      () => find.descendant(
        of: find.byType(PayeeManagementView),
        matching: find.byType(FloatingActionButton),
      ),
      () => find.text(l10n.addPayee).evaluate().isNotEmpty,
    );
    await enterTextReliably(
      tester,
      () => find.byType(TextField).last,
      'Starbucks',
      () {
        final field =
            find.byType(TextField).evaluate().last.widget as TextField;
        return field.controller?.text == 'Starbucks';
      },
    );
    await tapReliably(
      tester,
      () => find.widgetWithText(ElevatedButton, l10n.actionAdd),
      () => find.text(l10n.addPayee).evaluate().isEmpty,
    );
    expect(find.text('Starbucks'), findsOneWidget);

    // Desktop Material often leaves /payees without a hit-testable Back
    // control while Settings chrome stays in the route stack. Relaunch
    // lands on Home with the payee already persisted in the real DB.
    await _relaunchToHome(tester, l10n);

    // First use: pick the payee and a category so usage remembers the default.
    await _openCapture(tester, l10n, spent: true);
    await _enterAmount(tester, '5.00');
    await _selectCategory(tester, 'Other Expense');
    await _selectPayeeSuggestion(
      tester,
      l10n,
      query: 'Star',
      payee: 'Starbucks',
    );
    await _saveRecord(tester, l10n);

    // Second use: selecting the payee alone should prefill Other Expense.
    await _openCapture(tester, l10n, spent: true);
    await _enterAmount(tester, '3.00');
    await _selectPayeeSuggestion(
      tester,
      l10n,
      query: 'Star',
      payee: 'Starbucks',
    );
    await pumpUntilFound(tester, find.text('Other Expense'));
    expect(find.text('Other Expense'), findsWidgets);

    await tester.pump(const Duration(seconds: 2));
  }, timeout: const Timeout(Duration(minutes: 8)));

  testWidgets('a due recurring template records with one tap from Home', (
    tester,
  ) async {
    addTearDown(() => resetToFreshDevice(tester));

    await completeOnboardingWithGuidedEntry(
      tester,
      amountText: '1000',
      categoryName: 'Salary',
    );

    final today = DateTime.now().day;

    await _openSettings(tester, l10n);
    await _scrollUntilVisible(tester, find.text(l10n.settingsManageRecurring));
    await tapReliably(
      tester,
      () => find.widgetWithText(OutlinedButton, l10n.settingsManageRecurring),
      () => find.text(l10n.recurringTitle).evaluate().isNotEmpty,
      innerTries: 80,
    );
    await tapReliably(
      tester,
      () => find.descendant(
        of: find.byType(RecurringTemplateManagementView),
        matching: find.byType(FloatingActionButton),
      ),
      () =>
          find.text(l10n.addTemplate).evaluate().isNotEmpty ||
          find.widgetWithText(TextField, l10n.name).evaluate().isNotEmpty,
    );

    await enterTextReliably(
      tester,
      () => find.widgetWithText(TextField, l10n.name),
      'Rent',
      () {
        final field =
            find.widgetWithText(TextField, l10n.name).evaluate().single.widget
                as TextField;
        return field.controller?.text == 'Rent';
      },
    );
    await selectDropdownOption(
      tester,
      fieldLabel: l10n.category,
      optionText: 'Other Expense',
    );
    await enterTextReliably(
      tester,
      () => find.widgetWithText(TextField, l10n.amount),
      '50.00',
      () {
        final field =
            find.widgetWithText(TextField, l10n.amount).evaluate().single.widget
                as TextField;
        return field.controller?.text == '50.00';
      },
    );
    await enterTextReliably(
      tester,
      () => find.widgetWithText(TextField, l10n.dayOfMonth),
      '$today',
      () {
        final field =
            find
                    .widgetWithText(TextField, l10n.dayOfMonth)
                    .evaluate()
                    .single
                    .widget
                as TextField;
        return field.controller?.text == '$today';
      },
    );
    await tapReliably(
      tester,
      () => find.widgetWithText(ElevatedButton, l10n.actionAdd),
      () =>
          find.text('Rent').evaluate().isNotEmpty &&
          find.byType(AlertDialog).evaluate().isEmpty,
      innerTries: 150,
    );
    // Let any dialog setState/futures settle before tearing the tree down.
    await tester.pump(const Duration(seconds: 1));

    await _relaunchToHome(tester, l10n);
    await pumpUntilFound(tester, find.text(l10n.homeDueToday));

    await tapReliably(
      tester,
      () => find.text('Rent'),
      () =>
          find.text(l10n.homeDueToday).evaluate().isEmpty ||
          find.text('Rent').evaluate().isEmpty,
      innerTries: 150,
    );
    // After recording, Home no longer lists it as due (or amount appears
    // in this-month activity).
    await pumpUntilFound(tester, find.textContaining('50.00'));

    await tester.pump(const Duration(seconds: 2));
  }, timeout: const Timeout(Duration(minutes: 8)));

  testWidgets(
    'saving an import category rule from preview stores it for later',
    (tester) async {
      addTearDown(() {
        FilePickerPlatform.instance = defaultFilePickerPlatform;
        return resetToFreshDevice(tester);
      });
      FilePickerPlatform.instance = _FakeFilePickerPlatform(
        _FakePlatformFile(
          name: 'statement.csv',
          bytes: Uint8List.fromList(_csvFixture.codeUnits),
        ),
      );

      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '1000',
        categoryName: 'Salary',
      );

      await tapReliably(
        tester,
        () => find.text(l10n.navAccounts),
        () => find.byTooltip(l10n.importOfx).evaluate().isNotEmpty,
      );
      await tapReliably(
        tester,
        () => find.byTooltip(l10n.importOfx),
        () => find.text(l10n.whatKindOfStatement).evaluate().isNotEmpty,
      );
      await tapReliably(
        tester,
        () => find.text(l10n.importCsvFile),
        () => find.text(l10n.actionChooseFile).evaluate().isNotEmpty,
      );
      await tapReliably(
        tester,
        () => find.text(l10n.actionChooseFile),
        () => find.text(l10n.importIntoAccount).evaluate().isNotEmpty,
      );
      await selectDropdownOption(
        tester,
        fieldLabel: l10n.importIntoAccount,
        optionText: 'Cash & Bank',
      );
      await tester.pump(const Duration(milliseconds: 500));

      await tapReliably(
        tester,
        () => _intDropdownWithLabel(l10n.dateColumn).hitTestable(),
        dropdownOverlayOpen,
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tapReliably(
        tester,
        () => find.descendant(of: dropdownMenu(), matching: find.text('Date')),
        () => !dropdownOverlayOpen(),
        scrollIntoView: false,
      );
      await tapReliably(
        tester,
        () => find.widgetWithText(CheckboxListTile, 'Description'),
        () {
          final tile =
              find
                      .widgetWithText(CheckboxListTile, 'Description')
                      .evaluate()
                      .single
                      .widget
                  as CheckboxListTile;
          return tile.value == true;
        },
      );
      await tapReliably(
        tester,
        () => _intDropdownWithLabel(l10n.amountColumn).hitTestable(),
        dropdownOverlayOpen,
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tapReliably(
        tester,
        () =>
            find.descendant(of: dropdownMenu(), matching: find.text('Amount')),
        () => !dropdownOverlayOpen(),
        scrollIntoView: false,
      );
      await tapReliably(
        tester,
        () => find.widgetWithText(ElevatedButton, l10n.actionContinue),
        () => find.text(l10n.confirmImport).evaluate().isNotEmpty,
        innerTries: 150,
      );

      await _categorizeRowAndSaveRule(
        tester,
        l10n,
        description: 'Grocery Store',
        category: 'Other Expense',
        keyword: 'Grocery',
      );
      await _categorizeRowSkipRule(
        tester,
        l10n,
        description: 'Paycheck',
        category: 'Salary',
      );

      await tapReliably(
        tester,
        () => find.byTooltip(l10n.manageSavedCategoryRules),
        () =>
            find.textContaining('Grocery').evaluate().isNotEmpty ||
            find.textContaining('grocery').evaluate().isNotEmpty ||
            find.text('Other Expense').evaluate().isNotEmpty,
        innerTries: 100,
      );

      await tester.pump(const Duration(seconds: 2));
    },
    timeout: const Timeout(Duration(minutes: 8)),
  );

  testWidgets('a monthly category limit shows progress after spending', (
    tester,
  ) async {
    addTearDown(() => resetToFreshDevice(tester));

    await completeOnboardingWithGuidedEntry(
      tester,
      amountText: '1000',
      categoryName: 'Salary',
    );

    await _openCapture(tester, l10n, spent: true);
    await _enterAmount(tester, '40.00');
    await _selectCategory(tester, 'Other Expense');
    await _saveRecord(tester, l10n);

    await tapReliably(
      tester,
      () => find.text(l10n.navCategories),
      () => find.text('Other Expense').evaluate().isNotEmpty,
    );
    // Limit control is on the expense row - scroll if needed.
    await tester.ensureVisible(find.text('Other Expense'));
    await tester.pump(const Duration(milliseconds: 200));
    final otherExpenseRow = find.ancestor(
      of: find.text('Other Expense'),
      matching: find.byType(ListTile),
    );
    await tapReliably(
      tester,
      () => find
          .descendant(
            of: otherExpenseRow,
            matching: find.byTooltip(l10n.monthlyLimit),
          )
          .hitTestable(),
      () =>
          find.text(l10n.monthlyLimitHint).evaluate().isNotEmpty ||
          find.byType(TextField).evaluate().length > 1,
    );
    await enterTextReliably(
      tester,
      () => find.byType(TextField).last,
      '100.00',
      () {
        final field =
            find.byType(TextField).evaluate().last.widget as TextField;
        return field.controller?.text == '100.00';
      },
    );
    await tapReliably(
      tester,
      () => find.widgetWithText(ElevatedButton, l10n.actionSave),
      () => find.byType(MonthlyLimitProgress).evaluate().isNotEmpty,
      innerTries: 100,
    );
    expect(find.byType(MonthlyLimitProgress), findsWidgets);
    expect(find.textContaining('40.00'), findsWidgets);
    expect(find.textContaining('100.00'), findsWidgets);

    await tester.pump(const Duration(seconds: 2));
  }, timeout: const Timeout(Duration(minutes: 8)));

  testWidgets(
    'splitting a transaction updates remaining and saves when balanced',
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));

      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '1000',
        categoryName: 'Salary',
      );

      await _openCapture(tester, l10n, spent: true);
      await _enterAmount(tester, '100.00');
      await tapReliably(
        tester,
        () => find.text(l10n.splitIntoCategories),
        () => find.text(l10n.categoryN('1')).evaluate().isNotEmpty,
      );

      await selectDropdownOption(
        tester,
        fieldLabel: l10n.categoryN('1'),
        optionText: 'Other Expense',
      );
      // Split lines: [0]=transaction total, [1]=line 1, [2]=line 2.
      await enterTextReliably(
        tester,
        () => _amountFields(l10n).at(1),
        '60.00',
        () {
          final field =
              _amountFields(l10n).at(1).evaluate().single.widget as TextField;
          return field.controller?.text == '60.00';
        },
      );
      expect(find.textContaining('Remaining:'), findsOneWidget);
      expect(find.textContaining('40.00'), findsWidgets);

      await selectDropdownOption(
        tester,
        fieldLabel: l10n.categoryN('2'),
        optionText: 'Groceries',
      );
      await enterTextReliably(
        tester,
        () => _amountFields(l10n).at(2),
        '40.00',
        () {
          final field =
              _amountFields(l10n).at(2).evaluate().single.widget as TextField;
          return field.controller?.text == '40.00';
        },
      );
      await pumpUntilFound(tester, find.text(l10n.homeRemaining('0.00 USD')));

      await _saveRecord(tester, l10n);
      await tapReliably(
        tester,
        () => find.text(l10n.navRegister),
        () => find.byType(RegisterView).evaluate().isNotEmpty,
      );
      // Split rows summarize as "first category +N more", not every name.
      expect(
        find.text(l10n.splitCounterpartMore('Other Expense', '1')),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 2));
    },
    timeout: const Timeout(Duration(minutes: 8)),
  );

  testWidgets(
    'Fix on a register row changes its category via the correction wizard',
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));

      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '1000',
        categoryName: 'Salary',
      );

      // Prefer bottom-nav text over the receipt icon: after onboarding the
      // Home shell can leave the icon non-hit-testable while "Register" is.
      await tapReliably(
        tester,
        () => find.text(l10n.navRegister),
        () => find.byType(RegisterView).evaluate().isNotEmpty,
      );
      await pumpUntilFound(tester, find.text('Salary'));
      await tapReliably(
        tester,
        () => find.text(l10n.actionFix).first,
        () => find.text(l10n.actionConfirmFix).evaluate().isNotEmpty,
        innerTries: 100,
      );
      await selectDropdownOption(
        tester,
        fieldLabel: l10n.category,
        optionText: 'Other Income',
      );
      await tapReliably(
        tester,
        () => find.widgetWithText(ElevatedButton, l10n.actionConfirmFix),
        () => find.text(l10n.actionConfirmFix).evaluate().isEmpty,
        innerTries: 150,
      );
      await pumpUntilFound(tester, find.text('Other Income'));
      expect(find.text('Salary'), findsWidgets);
      expect(find.text('Other Income'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
    },
    timeout: const Timeout(Duration(minutes: 8)),
  );

  testWidgets('register search filters rows by text', (tester) async {
    addTearDown(() => resetToFreshDevice(tester));

    await completeOnboardingWithGuidedEntry(
      tester,
      amountText: '1000',
      categoryName: 'Salary',
    );

    await _openCapture(tester, l10n, spent: true);
    await _enterAmount(tester, '12.00');
    await _selectCategory(tester, 'Other Expense');
    await _enterDescription(tester, l10n, 'Coffee run');
    await _saveRecord(tester, l10n);

    await tapReliably(
      tester,
      () => find.text(l10n.navRegister),
      () => find.byType(RegisterView).evaluate().isNotEmpty,
    );
    await pumpUntilFound(tester, find.textContaining('Coffee run'));
    expect(find.byType(RegisterRowTile), findsAtLeastNWidgets(2));

    await enterTextReliably(
      tester,
      () => find.widgetWithText(TextField, l10n.searchLabel),
      'Coffee',
      () {
        final field =
            find
                    .widgetWithText(TextField, l10n.searchLabel)
                    .evaluate()
                    .single
                    .widget
                as TextField;
        return field.controller?.text == 'Coffee';
      },
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Coffee run'), findsOneWidget);
    expect(find.text('Salary'), findsNothing);

    await tester.pump(const Duration(seconds: 2));
  }, timeout: const Timeout(Duration(minutes: 8)));
}

Future<void> _openSettings(WidgetTester tester, AppLocalizationsEn l10n) async {
  await tapReliably(
    tester,
    () => find.byTooltip(l10n.settingsTitle),
    () => find.text(l10n.settingsBackup).evaluate().isNotEmpty,
  );
}

/// Settings is taller than the live 800x600 window; drag until [target]
/// is on-screen and hit-testable rather than assuming a fixed scroll.
Future<void> _scrollUntilVisible(WidgetTester tester, Finder target) async {
  for (var i = 0; i < 12; i++) {
    if (target.hitTestable().evaluate().isNotEmpty) return;
    await tester.dragFrom(const Offset(400, 300), const Offset(0, -220));
    await tester.pump(const Duration(milliseconds: 250));
  }
  await tester.ensureVisible(target);
  await tester.pump(const Duration(milliseconds: 200));
}

/// Prefer an explicit back control over [WidgetTester.pageBack]: the
/// shell can leave more than one Back affordance in the tree, and
/// pageBack asserts exactly one. Desktop AppBars sometimes expose
/// [BackButton] without a hit-testable "Back" tooltip.
/// Unmount and pump a fresh [SmaraAccountingApp] so nested Settings/Payees
/// routes are gone; on-disk DB + keychain keep the data created so far.
Future<void> _relaunchToHome(
  WidgetTester tester,
  AppLocalizationsEn l10n,
) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  await tester.pumpWidget(const SmaraAccountingApp());
  await tester.pump();
  await pumpUntilFound(tester, find.text(l10n.homeWhatYouHaveMinusWhatYouOwe));
}

Future<void> _openCapture(
  WidgetTester tester,
  AppLocalizationsEn l10n, {
  required bool spent,
}) async {
  await tapReliably(
    tester,
    () => find.byType(FloatingActionButton).hitTestable(),
    () => find.text(l10n.captureSpent).evaluate().isNotEmpty,
  );
  await tapReliably(
    tester,
    () => find.text(spent ? l10n.captureSpent : l10n.captureReceived),
    () => find.byType(RecordTransactionView).evaluate().isNotEmpty,
  );
  await pumpUntilFound(tester, find.text('Cash & Bank'));
}

Future<void> _enterAmount(WidgetTester tester, String amount) async {
  await enterTextReliably(
    tester,
    () => find.byType(TextField).first,
    amount,
    () {
      final field = find.byType(TextField).evaluate().first.widget as TextField;
      return field.controller?.text == amount;
    },
  );
}

Future<void> _selectCategory(WidgetTester tester, String categoryName) async {
  await selectDropdownOption(
    tester,
    fieldLabel: AppLocalizationsEn().category,
    optionText: categoryName,
  );
}

Finder _amountFields(AppLocalizationsEn l10n) {
  return find.descendant(
    of: find.byType(RecordTransactionView),
    matching: find.byWidgetPredicate((widget) {
      if (widget is! TextField) return false;
      return widget.decoration?.labelText == l10n.amount;
    }),
  );
}

Finder _recordDescriptionField(AppLocalizationsEn l10n) {
  return find.descendant(
    of: find.byType(RecordTransactionView),
    matching: find.byWidgetPredicate((widget) {
      if (widget is! TextField) return false;
      return widget.decoration?.labelText == l10n.descriptionOptional;
    }),
  );
}

/// Autocomplete's field must not get [TextInputAction.done] from
/// [enterTextReliably] — that submits the field and can clear the query
/// before options are tappable.
Future<void> _enterDescription(
  WidgetTester tester,
  AppLocalizationsEn l10n,
  String text,
) async {
  for (var attempt = 0; attempt < 3; attempt++) {
    final target = _recordDescriptionField(l10n);
    await tester.ensureVisible(target);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.showKeyboard(target);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(target, text);
    await tester.pump(const Duration(milliseconds: 200));
    final field = target.evaluate().single.widget as TextField;
    if (field.controller?.text == text) return;
  }
  fail(
    '_enterDescription: "$text" never stuck in the description field.\n'
    'Visible texts: ${find.byType(Text).evaluate().map((e) => (e.widget as Text).data).toList()}',
  );
}

Future<void> _selectPayeeSuggestion(
  WidgetTester tester,
  AppLocalizationsEn l10n, {
  required String query,
  required String payee,
}) async {
  await _enterDescription(tester, l10n, query);
  await pumpUntilFound(tester, find.text(payee));
  await tapReliably(tester, () => find.text(payee).last, () {
    final field =
        _recordDescriptionField(l10n).evaluate().single.widget as TextField;
    return field.controller?.text == payee;
  });
}

Future<void> _saveRecord(WidgetTester tester, AppLocalizationsEn l10n) async {
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

Finder _intDropdownWithLabel(String label) {
  return find.byWidgetPredicate((widget) {
    if (widget is! DropdownButtonFormField<int>) return false;
    return widget.decoration.labelText == label;
  });
}

Future<void> _categorizeRowAndSaveRule(
  WidgetTester tester,
  AppLocalizationsEn l10n, {
  required String description,
  required String category,
  required String keyword,
}) async {
  final rowCard = find.ancestor(
    of: find.text(description),
    matching: find.byType(Card),
  );
  await tapReliably(
    tester,
    () => find
        .descendant(
          of: rowCard,
          matching: find.byType(DropdownButtonFormField<String>),
        )
        .hitTestable(),
    dropdownOverlayOpen,
  );
  await tester.pump(const Duration(milliseconds: 400));
  await tapReliably(
    tester,
    () => find.descendant(of: dropdownMenu(), matching: find.text(category)),
    () => !dropdownOverlayOpen(),
    scrollIntoView: false,
  );
  await pumpUntilFound(tester, find.text(l10n.saveAsRule));
  // Single-row groups start with an empty keyword; Save is a no-op until set.
  await enterTextReliably(
    tester,
    () => find.byWidgetPredicate((widget) {
      if (widget is! TextField) return false;
      return widget.decoration?.labelText == l10n.keyword;
    }),
    keyword,
    () {
      final field =
          find
                  .byWidgetPredicate((widget) {
                    if (widget is! TextField) return false;
                    return widget.decoration?.labelText == l10n.keyword;
                  })
                  .evaluate()
                  .single
                  .widget
              as TextField;
      return field.controller?.text == keyword;
    },
  );
  await tapReliably(
    tester,
    () => find.widgetWithText(ElevatedButton, l10n.actionSaveRule),
    () => find.byType(AlertDialog).evaluate().isEmpty,
    innerTries: 100,
  );
}

Future<void> _categorizeRowSkipRule(
  WidgetTester tester,
  AppLocalizationsEn l10n, {
  required String description,
  required String category,
}) async {
  final rowCard = find.ancestor(
    of: find.text(description),
    matching: find.byType(Card),
  );
  await tapReliably(
    tester,
    () => find
        .descendant(
          of: rowCard,
          matching: find.byType(DropdownButtonFormField<String>),
        )
        .hitTestable(),
    dropdownOverlayOpen,
  );
  await tester.pump(const Duration(milliseconds: 400));
  await tapReliably(
    tester,
    () => find.descendant(of: dropdownMenu(), matching: find.text(category)),
    () => !dropdownOverlayOpen(),
    scrollIntoView: false,
  );
  await tapReliably(
    tester,
    () => find.widgetWithText(TextButton, l10n.actionSkip),
    () => find.byType(AlertDialog).evaluate().isEmpty,
  );
}

const _csvFixture =
    'Date,Description,Amount\n'
    '15/01/2026,Grocery Store,-45.67\n'
    '16/01/2026,Paycheck,1200.00\n';

final class _FakePlatformFile extends PlatformFile {
  _FakePlatformFile({required this.name, required Uint8List bytes})
    : _bytes = bytes;

  @override
  final String name;
  final Uint8List _bytes;

  @override
  Uri get uri => Uri.file(name);

  @override
  XFile get xFile => XFile.fromData(_bytes, name: name);

  @override
  Future<int> length() async => _bytes.length;

  @override
  Future<Uint8List> readAsBytes() async => _bytes;

  @override
  Stream<Uint8List> readAsByteStream() => Stream.value(_bytes);
}

class _FakeFilePickerPlatform extends FilePickerPlatform {
  _FakeFilePickerPlatform(this._file);

  final PlatformFile? _file;

  @override
  Future<PlatformFile?> pickFile({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async => _file;
}
