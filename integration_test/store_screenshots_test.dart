// Store screenshot capture (store-listing-assembly: "Screenshots Are
// Regenerated With A Maintained Tool"). Not part of the acceptance suite
// and not run by CI - run it only through tool/capture_store_screenshots.sh,
// whose host controller (tool/store_media.py) takes each screenshot when
// this test prints a `STORE_MEDIA shot <name>` marker.
//
// Resets the target's real app data and signing keys first - use a
// Simulator/emulator, never a device holding real books.
//
// File names are ordered by store priority: the App Store shows at most 10
// per device size and Google Play at most 8, so upload the first 10 / 8.
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'acceptance/support/acceptance_harness.dart';
import 'store_media/store_media_flows.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture store screenshots', (tester) async {
    final f = StoreMediaFlows(tester);
    final l10n = f.l10n;
    await resetToFreshDevice();

    await f.onboard(
      onScreen: (screen) async {
        if (screen == 'setup_choice') await f.shot('18_setup_choice');
        if (screen == 'language') await f.shot('19_language');
      },
    );
    await f.seedHousehold();

    await f.shot('01_home');
    await f.goRegister();
    await f.shot('02_register');

    await f.relaunchToHome();
    await f.openAddSheet();
    await f.shot('03_add');

    await f.relaunchToHome();
    await f.openRecordForm(spent: true);
    await f.fillRecord(
      amount: '18.40',
      category: l10n.systemCategoryFoodOut,
      description: 'Lunch',
    );
    await f.shot('04_record_spent');

    await f.relaunchToHome();
    await f.fillSplit(
      total: '120.00',
      firstCategory: l10n.systemCategoryGroceries,
      firstAmount: '80.00',
      secondCategory: l10n.systemCategoryHealth,
      secondAmount: '40.00',
    );
    await f.shot('05_split');

    await f.relaunchToHome();
    await f.goSummary();
    await f.shot('06_summary');

    await f.goCategories();
    await f.shot('07_categories_limits');

    await f.openBrokerage();
    await f.shot('08_holdings');

    await f.relaunchToHome();
    await f.fillTransfer('500.00');
    await f.shot('09_transfer');

    await f.relaunchToHome();
    await f.openFix(newCategory: l10n.systemCategoryFoodOut);
    await f.shot('10_fix');

    await f.relaunchToHome();
    await f.goAccounts();
    await f.shot('11_accounts');

    await f.searchRegister('Rent');
    await f.shot('12_search');

    await f.relaunchToHome();
    await f.openSettings();
    await f.shot('13_settings');
    await f.scrollSettingsTo(find.text(l10n.settingsBackup));
    await f.shot('14_books_copy');

    await f.relaunchToHome();
    await f.openRecurring();
    await f.shot('15_recurring');

    await f.relaunchToHome();
    await f.openPayees();
    await f.shot('16_payees');

    await f.relaunchToHome();
    await f.openImport();
    await f.shot('17_import');
  }, timeout: const Timeout(Duration(minutes: 30)));
}
