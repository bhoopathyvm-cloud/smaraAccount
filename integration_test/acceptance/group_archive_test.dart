import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:smara_accounting/data/database/tables/account_groups_table.dart';
import 'package:smara_accounting/data/database/tables/accounts_table.dart';
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_en.dart';
import 'package:smara_accounting/main.dart';

import 'support/acceptance_harness.dart';

/// Real-build acceptance coverage for user-created group archive
/// (`acceptance-group-archive`): hide blocked while active, hide once empty,
/// historical visibility, and omission from reassignment targets.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final l10n = AppLocalizationsEn();

  setUpAll(() async {
    await resetToFreshDevice();
  });

  testWidgets(
    'user-created group archive lifecycle: blocked while active, allowed once empty',
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));

      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '1000',
        categoryName: 'Salary',
      );

      var accountRepository = Provider.of<AccountRepository>(
        tester.element(find.byType(MaterialApp)),
        listen: false,
      );
      final group = await accountRepository.createAccountGroup(
        name: 'Business',
        kind: AccountGroupKind.assetGroup,
        currency: 'USD',
      );
      await accountRepository.createFinancialAccount(
        name: 'Business Checking',
        type: AccountType.asset,
        groupId: group.id,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.pumpWidget(const SmaraAccountingApp());
      await tester.pump();
      await pumpUntilFound(
        tester,
        find.text(l10n.homeWhatYouHaveMinusWhatYouOwe),
      );
      accountRepository = Provider.of<AccountRepository>(
        tester.element(find.byType(MaterialApp)),
        listen: false,
      );

      await tapReliably(
        tester,
        () => find.text(l10n.navAccounts),
        () => find.byTooltip(l10n.createGroup).evaluate().isNotEmpty,
      );
      await _scrollUntilText(tester, 'Business');
      expect(find.text('Business Checking'), findsOneWidget);

      // Blocked hide while Business Checking is still active (mirrors
      // integration_test/app_test.dart's popup-menu flow).
      await _tapPopupMenuOnListTile(tester, 'Business');
      await tester.tap(find.text(l10n.actionHide));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.widgetWithText(OutlinedButton, l10n.actionHide));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      // Blocked: group stays active (USD subtitle), member account stays active.
      final businessGroupTile = find.ancestor(
        of: find.text('Business'),
        matching: find.byType(ListTile),
      );
      expect(
        find.descendant(of: businessGroupTile, matching: find.text('USD')),
        findsOneWidget,
      );
      expect(find.text('Business Checking'), findsOneWidget);

      final businessAccounts = await accountRepository
          .watchFinancialAccounts(includeArchived: true)
          .first;
      final businessAccountId = businessAccounts
          .firstWhere((a) => a.name == 'Business Checking')
          .id;
      await accountRepository.archiveFinancialAccount(businessAccountId);
      await tester.pump(const Duration(milliseconds: 400));
      await _scrollUntilText(tester, 'Business');

      await _tapPopupMenuOnListTile(tester, 'Business');
      await tester.tap(find.text(l10n.actionHide));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.widgetWithText(OutlinedButton, l10n.actionHide));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Business'), findsOneWidget);
      expect(find.text('Business Checking'), findsOneWidget);
      expect(find.text(l10n.hiddenLabel), findsWidgets);

      await _scrollUntilText(tester, 'Cash & Bank', fromTop: true);
      await _tapPopupMenuOnListTile(tester, 'Cash & Bank');
      await tester.tap(find.text(l10n.reassignGroup));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      // Archived Business must not be offered inside the open picker menu.
      expect(
        find.descendant(of: dropdownMenu(), matching: find.text('Business')),
        findsNothing,
      );
      expect(find.text(l10n.systemGroupCashEquivalents), findsWidgets);

      await tester.pump(const Duration(seconds: 2));
    },
    timeout: const Timeout(Duration(minutes: 8)),
  );
}

/// PopupMenuButton's default tooltip ("Show menu") is stable across
/// platforms; locate the one on the ListTile whose title is [name].
Future<void> _tapPopupMenuOnListTile(WidgetTester tester, String name) async {
  await tester.ensureVisible(find.text(name));
  await tester.pump(const Duration(milliseconds: 200));
  final menus = find.byTooltip('Show menu');
  for (var i = 0; i < menus.evaluate().length; i++) {
    final menu = menus.at(i);
    final tile = find.ancestor(of: menu, matching: find.byType(ListTile));
    if (tile.evaluate().isEmpty) continue;
    final listTile = tile.evaluate().first.widget as ListTile;
    final title = listTile.title;
    if (title is Text && title.data == name) {
      await tester.tap(menu);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      return;
    }
  }
  fail(
    'No popup menu found for ListTile "$name" among '
    '${menus.evaluate().length} "Show menu" controls.',
  );
}

Future<void> _scrollUntilText(
  WidgetTester tester,
  String text, {
  bool fromTop = false,
}) async {
  if (fromTop) {
    for (var i = 0; i < 8; i++) {
      await tester.drag(find.byType(ListView).first, const Offset(0, 400));
      await tester.pump(const Duration(milliseconds: 200));
    }
  }
  for (var i = 0; i < 16; i++) {
    if (find.text(text).hitTestable().evaluate().isNotEmpty) {
      await tester.ensureVisible(find.text(text));
      await tester.pump(const Duration(milliseconds: 200));
      return;
    }
    await tester.drag(find.byType(ListView).first, const Offset(0, -280));
    await tester.pump(const Duration(milliseconds: 250));
  }
  await pumpUntilFound(tester, find.text(text));
  await tester.ensureVisible(find.text(text));
  await tester.pump(const Duration(milliseconds: 200));
}
