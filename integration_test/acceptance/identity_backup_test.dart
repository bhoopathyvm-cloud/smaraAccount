import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smara_accounting/domain/crypto/recovery_phrase.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_en.dart';
import 'package:smara_accounting/ui/features/restore/views/restore_identity_view.dart';

import 'support/acceptance_harness.dart';

/// Real-build acceptance coverage for the `ledger-backup` capability group
/// (design.md group 5): recovery-phrase restore, the wrong-phrase negative
/// case, encrypted backup file export/restore, and rejecting a foreign
/// identity's backup - all walked through the real GUI, no ViewModel/
/// Repository backdoors, per this suite's own established conventions.
///
/// Two research findings shape every scenario here (see this change's
/// tasks.md group 5 narrative for the full reasoning):
///  - `resetToFreshDevice()` wipes the database too, which sends a fresh
///    device to onboarding, never to `/restore` - restoring a recovery
///    phrase only makes sense with the database left intact, so these
///    scenarios use the narrower [resetSigningKeyOnly] instead.
///  - A truly identity-less device can never reach the Settings screen
///    (the backup-file save/restore entry point) - the router forces it
///    through onboarding first. So the backup-file scenarios restore back
///    onto the same still-onboarded device (5.3) or to a second,
///    genuinely distinct device identity (5.4), matching the only two
///    ways the real GUI can actually reach that dialog.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final l10n = AppLocalizationsEn();

  setUpAll(() async {
    await resetToFreshDevice();
  });

  testWidgets(
    'a device that lost its signing key restores from its recovery phrase and keeps its books',
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));

      final words = await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '10',
        categoryName: 'Salary',
      );

      await resetSigningKeyOnly(tester);
      await pumpUntilFound(tester, find.byType(RestoreIdentityView));
      expect(find.text(l10n.restoreTitle), findsOneWidget);

      await enterTextReliably(
        tester,
        () => find.byType(TextField).first,
        words.join(' '),
        () {
          final field =
              find.byType(TextField).evaluate().first.widget as TextField;
          return field.controller?.text == words.join(' ');
        },
      );

      await tapReliably(
        tester,
        () => find.widgetWithText(ElevatedButton, l10n.actionRestore),
        () => find
            .text(l10n.homeWhatYouHaveMinusWhatYouOwe)
            .evaluate()
            .isNotEmpty,
        innerTries: 150,
      );

      // The books from before the "reinstall" are still there - restoring
      // a key never recreates or alters ledger data, it only re-derives
      // and matches the private key.
      await tapReliably(
        tester,
        () => find.text(l10n.navRegister),
        () => find.text('Salary').evaluate().isNotEmpty,
      );
      expect(find.text('Salary'), findsOneWidget);
      expect(find.text('10.00'), findsOneWidget);

      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );

  testWidgets(
    'restoring with a recovery phrase that does not match this device is rejected with an explanation',
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));

      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '10',
        categoryName: 'Salary',
      );

      await resetSigningKeyOnly(tester);
      await pumpUntilFound(tester, find.byType(RestoreIdentityView));

      // A syntactically valid but unrelated 24-word phrase - generated
      // fresh here (not through the GUI), the same way any other fixed
      // test fixture value would be authored. Its checksum passes
      // (RecoveryPhrase.fromWords never throws for it), so this exercises
      // the identity-mismatch rejection specifically, not the separate
      // malformed-phrase error path.
      final wrongWords = RecoveryPhrase.generate().words;

      await enterTextReliably(
        tester,
        () => find.byType(TextField).first,
        wrongWords.join(' '),
        () {
          final field =
              find.byType(TextField).evaluate().first.widget as TextField;
          return field.controller?.text == wrongWords.join(' ');
        },
      );

      await tapReliably(
        tester,
        () => find.widgetWithText(ElevatedButton, l10n.actionRestore),
        () =>
            find.text(l10n.errorSigningIdentityMismatch).evaluate().isNotEmpty,
        innerTries: 150,
      );

      // Stays on the restore screen - nothing was matched or altered.
      expect(find.byType(RestoreIdentityView), findsOneWidget);
      expect(find.text(l10n.errorSigningIdentityMismatch), findsOneWidget);

      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );

  testWidgets(
    'an encrypted backup file can be exported and restored back onto the same device',
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));

      final filePicker = FakeFilePickerPlatform();
      FilePickerPlatform.instance = filePicker;

      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '10',
        categoryName: 'Salary',
      );

      final backupBytes = await saveBackupThroughGui(
        tester,
        passphrase: 'correct horse battery staple',
        filePicker: filePicker,
      );

      // Settings is a pushed route with no bottom nav of its own -
      // recordSpentThroughGui starts from the bottom nav's Home tab, so
      // pop back to it first.
      await popPushedScreen(tester);

      // Activity recorded after the backup - this must be gone once the
      // backup is restored back over it. "Groceries" (a starter expense
      // category, app_database.dart's starterExpenseCategories) rather
      // than "Salary" (income-only) - recordSpentThroughGui's category
      // picker only lists categories matching the Spent direction.
      await recordSpentThroughGui(
        tester,
        accountName: 'Cash & Bank',
        amountText: '5',
        categoryName: 'Groceries',
      );
      await tapReliably(
        tester,
        () => find.text(l10n.navRegister),
        () => find.text('5.00').evaluate().isNotEmpty,
      );
      expect(find.text('5.00'), findsOneWidget);

      await restoreBackupThroughGui(
        tester,
        fileBytes: backupBytes,
        passphrase: 'correct horse battery staple',
        filePicker: filePicker,
      );

      // Back to exactly the backup's state: the pre-backup entry is back,
      // the post-backup one is gone.
      await tapReliably(
        tester,
        () => find.text(l10n.navRegister),
        () => find.text('Salary').evaluate().isNotEmpty,
      );
      expect(find.text('Salary'), findsOneWidget);
      expect(find.text('10.00'), findsOneWidget);
      expect(find.text('5.00'), findsNothing);

      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );

  testWidgets(
    "restoring a backup from a different device's identity is rejected and this device's books are unaffected",
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));

      final filePicker = FakeFilePickerPlatform();
      FilePickerPlatform.instance = filePicker;

      // Phase 1: a first, independent device identity - its backup is the
      // "foreign" one phase 2 will try (and fail) to restore.
      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '10',
        categoryName: 'Salary',
      );
      final foreignBackupBytes = await saveBackupThroughGui(
        tester,
        passphrase: 'phase one passphrase',
        filePicker: filePicker,
      );

      // A full reset (not resetSigningKeyOnly) - this scenario needs a
      // genuinely distinct second identity, not a "lost key, same books"
      // reinstall of the first one.
      await resetToFreshDevice(tester);
      await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '20',
        categoryName: 'Salary',
      );

      await restoreBackupThroughGui(
        tester,
        fileBytes: foreignBackupBytes,
        passphrase: 'phase one passphrase',
        filePicker: filePicker,
        expectRejection: true,
      );

      // Dismiss the still-open Restore Backup dialog and confirm phase
      // 2's own books were never touched - the foreign backup's identity
      // check runs before anything is written to disk.
      await tapReliably(
        tester,
        () => find.widgetWithText(TextButton, l10n.actionCancel),
        () => find.text(l10n.actionRestoreBackup).evaluate().length == 1,
      );

      // Settings is a pushed route with no bottom nav/rail of its own.
      await popPushedScreen(tester);

      await tapReliably(
        tester,
        () => find.text(l10n.navRegister),
        () => find.text('Salary').evaluate().isNotEmpty,
      );
      expect(find.text('Salary'), findsOneWidget);
      expect(find.text('20.00'), findsOneWidget);
      expect(find.text('10.00'), findsNothing);

      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
