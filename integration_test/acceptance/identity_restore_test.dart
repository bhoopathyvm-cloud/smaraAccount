import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smara_accounting/l10n/generated/app_localizations_en.dart';
import 'package:smara_accounting/main.dart';
import 'package:smara_accounting/ui/features/restore/views/restore_identity_view.dart';

import 'support/acceptance_harness.dart';

/// Same real-keychain access as acceptance_harness.dart's
/// `resetToFreshDevice` - duplicated here for the same reason its own
/// comment gives (avoiding `deleteAll()`, which fails under an ad-hoc
/// signed macOS build with errSecMissingEntitlement).
const _secureStorage = FlutterSecureStorage(
  mOptions: MacOsOptions(usesDataProtectionKeychain: false),
);
const _secureStorageKeys = [
  'ledger_signing_private_key_seed',
  'ledger_pending_recovery_phrase_words',
];

/// Clears only the real OS keychain entries the signing key lives under -
/// unlike `resetToFreshDevice()`, this keeps the real on-disk database
/// intact. `RestoreIdentityViewModel`'s own doc comment is explicit that
/// restoring from a recovery phrase "never re-signs or alters any entry -
/// only re-derives and matches the device's private key": it cannot
/// recover entry data that isn't there, so this - not a full database wipe
/// - is what "reinstall, same identity, lost private key" actually means
/// for this app's architecture (matches the existing INTEGRATION-tier
/// reference test's own mechanics: a shared database across two
/// `LedgerRepository` instances with only secure storage reset between
/// them).
Future<void> _clearSigningKeyOnly(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  for (final key in _secureStorageKeys) {
    try {
      await _secureStorage.delete(key: key);
    } on PlatformException {
      // Deleting a key that was never written throws
      // errSecMissingEntitlement on this ad-hoc signed macOS build's
      // legacy Keychain fallback - the goal (the key doesn't exist)
      // already holds either way.
    }
  }
}

TextField _phraseField(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField).first);

/// Real-build acceptance coverage for `key-loss-migration`'s "Recoverable
/// Reinstall or Device Migration": restoring a lost signing key from the
/// recovery phrase captured during onboarding, and rejecting a wrong one.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final l10n = AppLocalizationsEn();

  setUpAll(() async {
    await resetToFreshDevice();
  });

  testWidgets(
    'a lost signing key is restored from the recovery phrase; a wrong '
    'phrase is rejected first',
    (tester) async {
      addTearDown(() => resetToFreshDevice(tester));

      final words = await completeOnboardingWithGuidedEntry(
        tester,
        amountText: '250',
        categoryName: 'Salary',
      );
      expect(words, hasLength(24));

      // Simulate reinstall: same device, database intact, private key gone.
      await _clearSigningKeyOnly(tester);
      await tester.pumpWidget(const SmaraAccountingApp());
      await tester.pump();
      await pumpUntilFound(tester, find.byType(RestoreIdentityView));
      expect(find.byType(RestoreIdentityView), findsOneWidget);

      // Wrong phrase first: reversing the word order breaks the BIP39
      // checksum (or, on the rare chance it doesn't, derives a key that
      // matches no identity in the database) - either way, rejected.
      final wrongPhrase = words.reversed.join(' ');
      // Setting the controller directly rather than enterTextReliably's
      // live-IME simulation: _RestoreIdentityViewState reads
      // _phraseController.text straight off the controller at submit time
      // (no onChanged-tracked state), and re-focusing the field after the
      // Restore button tap below stole focus was observed to leave the
      // live IME's enterText silently not updating the controller at all.
      _phraseField(tester).controller!.text = wrongPhrase;
      await tester.pump();
      await tapReliably(
        tester,
        () => find.widgetWithText(ElevatedButton, l10n.actionRestore),
        () =>
            find
                .text(l10n.errorSigningIdentityMismatch)
                .evaluate()
                .isNotEmpty ||
            find.text(l10n.validationRestorePhraseFailed).evaluate().isNotEmpty,
        innerTries: 150,
      );
      expect(
        find.byType(RestoreIdentityView),
        findsOneWidget,
        reason: 'a wrong phrase must not navigate away or restore anything',
      );

      // Now the real phrase.
      final correctPhrase = words.join(' ');
      _phraseField(tester).controller!.text = correctPhrase;
      await tester.pump();
      await tapReliably(
        tester,
        () => find.widgetWithText(ElevatedButton, l10n.actionRestore),
        () => find
            .text(l10n.homeWhatYouHaveMinusWhatYouOwe)
            .evaluate()
            .isNotEmpty,
        innerTries: 150,
      );
      expect(find.text(l10n.homeWhatYouHaveMinusWhatYouOwe), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
