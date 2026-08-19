import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/exceptions.dart';
import 'package:smara_accounting/domain/models/exchange_rate_provider.dart';
import 'package:smara_accounting/ui/features/settings/view_models/settings_view_model.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockSettingsRepository settingsRepository;
  late MockLedgerRepository ledgerRepository;
  late MockAppLockService appLockService;
  late MockBiometricAuthenticator biometricAuthenticator;
  late MockAppLockController appLockController;
  late SettingsViewModel viewModel;

  setUp(() {
    settingsRepository = MockSettingsRepository();
    ledgerRepository = MockLedgerRepository();
    appLockService = MockAppLockService();
    biometricAuthenticator = MockBiometricAuthenticator();
    appLockController = MockAppLockController();
    when(
      settingsRepository.isReferenceRateLookupEnabled(),
    ).thenAnswer((_) async => false);
    when(
      settingsRepository.selectedProvider(),
    ).thenAnswer((_) async => ExchangeRateProvider.frankfurter);
    when(biometricAuthenticator.isAvailable()).thenAnswer((_) async => false);
    viewModel = SettingsViewModel(
      settingsRepository: settingsRepository,
      ledgerRepository: ledgerRepository,
      appLockService: appLockService,
      biometricAuthenticator: biometricAuthenticator,
      appLockController: appLockController,
    );
  });

  group('exportBackup', () {
    test('returns the encrypted contents on success', () async {
      when(
        ledgerRepository.exportLedgerBackup(passphrase: anyNamed('passphrase')),
      ).thenAnswer((_) async => '{"kind":"smara-ledger-backup"}');

      final result = await viewModel.exportBackup(passphrase: 'hunter2');

      expect(result, equals('{"kind":"smara-ledger-backup"}'));
      expect(viewModel.backupErrorMessage, isNull);
      expect(viewModel.isBackingUp, isFalse);
    });

    test('returns null and sets an error message on failure', () async {
      when(
        ledgerRepository.exportLedgerBackup(passphrase: anyNamed('passphrase')),
      ).thenThrow(Exception('disk full'));

      final result = await viewModel.exportBackup(passphrase: 'hunter2');

      expect(result, isNull);
      expect(viewModel.backupErrorMessage, isNotNull);
      expect(viewModel.isBackingUp, isFalse);
    });
  });

  group('restoreBackup', () {
    test('returns true on success', () async {
      when(
        ledgerRepository.restoreLedgerBackup(
          fileContents: anyNamed('fileContents'),
          passphrase: anyNamed('passphrase'),
        ),
      ).thenAnswer((_) async {});

      final ok = await viewModel.restoreBackup(
        fileContents: '{}',
        passphrase: 'hunter2',
      );

      expect(ok, isTrue);
      expect(viewModel.backupErrorMessage, isNull);
      expect(viewModel.isRestoring, isFalse);
    });

    test(
      'surfaces ForeignBackupIdentityException as a plain-language message',
      () async {
        when(
          ledgerRepository.restoreLedgerBackup(
            fileContents: anyNamed('fileContents'),
            passphrase: anyNamed('passphrase'),
          ),
        ).thenThrow(
          ForeignBackupIdentityException('belongs to a different identity'),
        );

        final ok = await viewModel.restoreBackup(
          fileContents: '{}',
          passphrase: 'hunter2',
        );

        expect(ok, isFalse);
        expect(
          viewModel.backupErrorMessage,
          equals('belongs to a different identity'),
        );
      },
    );

    test(
      'surfaces InvalidLedgerBackupException as a plain-language message',
      () async {
        when(
          ledgerRepository.restoreLedgerBackup(
            fileContents: anyNamed('fileContents'),
            passphrase: anyNamed('passphrase'),
          ),
        ).thenThrow(InvalidLedgerBackupException('not a valid backup'));

        final ok = await viewModel.restoreBackup(
          fileContents: '{}',
          passphrase: 'hunter2',
        );

        expect(ok, isFalse);
        expect(viewModel.backupErrorMessage, equals('not a valid backup'));
      },
    );

    test(
      'any other failure (e.g. wrong passphrase) surfaces a generic message',
      () async {
        when(
          ledgerRepository.restoreLedgerBackup(
            fileContents: anyNamed('fileContents'),
            passphrase: anyNamed('passphrase'),
          ),
        ).thenThrow(Exception('SecretBoxAuthenticationError'));

        final ok = await viewModel.restoreBackup(
          fileContents: '{}',
          passphrase: 'wrong',
        );

        expect(ok, isFalse);
        expect(viewModel.backupErrorMessage, isNotNull);
        expect(viewModel.isRestoring, isFalse);
      },
    );
  });
}
