// Store preview-video recording. Not part of the acceptance suite and not
// run by CI - run it only through tool/record_store_previews.sh, whose host
// controller (tool/store_media.py) starts/stops a screen recording on each
// `STORE_MEDIA rec_start|rec_stop <name>` marker and then composes:
// - three App Store previews (15-30 s): tour_02_record, tour_04_fix,
//   tour_07_invest;
// - one captioned full tour of every chapter for Google Play (YouTube) and
//   the project website.
//
// Resets the target's real app data and signing keys first - use a
// Simulator/emulator, never a device holding real books.
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'acceptance/support/acceptance_harness.dart';
import 'store_media/store_media_flows.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('record store previews', (tester) async {
    final fast = StoreMediaFlows(tester);
    final slow = StoreMediaFlows(
      tester,
      beat: const Duration(milliseconds: 1200),
    );
    final l10n = fast.l10n;
    await resetToFreshDevice();

    await fast.launchToSetupChoice();
    await fast.clip('tour_01_setup', () => slow.onboard());

    await fast.recordSpent('1450.00', l10n.systemCategoryRentMortgage, 'Rent');
    await fast.recordSpent(
      '62.30',
      l10n.systemCategoryUtilities,
      'Electricity',
    );
    await fast.recordSpent('38.00', l10n.systemCategoryTransport, 'Train pass');
    await fast.relaunchToHome();

    await fast.clip('tour_02_record', () async {
      await slow.recordSpent(
        '84.20',
        l10n.systemCategoryGroceries,
        'Weekly shop',
      );
      await slow.pause(2);
    });

    await fast.clip('tour_03_split', () async {
      await slow.fillSplit(
        total: '120.00',
        firstCategory: l10n.systemCategoryGroceries,
        firstAmount: '80.00',
        secondCategory: l10n.systemCategoryHealth,
        secondAmount: '40.00',
      );
      await slow.saveRecord();
      await slow.goRegister();
      await slow.pause(2);
    });

    await fast.relaunchToHome();
    await fast.clip('tour_04_fix', () async {
      await slow.openFix(newCategory: l10n.systemCategoryFoodOut);
      await slow.confirmFix();
      await slow.pause(2);
    });

    await fast.relaunchToHome();
    await fast.clip('tour_05_limits', () async {
      await slow.setMonthlyLimit(l10n.systemCategoryGroceries, '400.00');
      await slow.goHome();
      await slow.pause(2);
    });

    await fast.createBrokerage();
    await fast.relaunchToHome();
    await fast.clip('tour_06_transfer', () async {
      await slow.fillTransfer('500.00');
      await slow.saveTransfer();
    });

    await fast.relaunchToHome();
    await fast.clip('tour_07_invest', () async {
      await slow.openBrokerage();
      await slow.buyEtf();
    });

    await fast.relaunchToHome();
    await fast.clip('tour_08_search_summary', () async {
      await slow.searchRegister('Rent');
      await slow.pause(2);
      await slow.goSummary();
      await slow.pause(2);
    });

    await fast.addRecurringTemplate(
      name: 'Phone plan',
      category: l10n.systemCategoryPhone,
      amount: '29.00',
      day: DateTime.now().day,
    );
    await fast.relaunchToHome();
    await fast.clip('tour_09_recurring', () async {
      await slow.recordDueTemplate('Phone plan');
    });

    await fast.relaunchToHome();
    await fast.clip('tour_10_import', () async {
      await slow.openImport();
      await slow.pause(2);
    });

    await fast.relaunchToHome();
    await fast.clip('tour_11_settings', () async {
      await slow.openSettings();
      await slow.scrollSettingsTo(find.text(l10n.settingsBackup));
      await slow.pause(2);
      await slow.scrollSettingsTo(find.text(l10n.settingsLock));
      await slow.pause(2);
    });
  }, timeout: const Timeout(Duration(minutes: 40)));
}
