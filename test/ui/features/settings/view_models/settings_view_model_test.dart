import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/exceptions.dart';
import 'package:smara_accounting/domain/investment/exchange_registry.dart';
import 'package:smara_accounting/domain/models/exchange_rate_provider.dart';
import 'package:smara_accounting/domain/models/quote_provider.dart';
import 'package:smara_accounting/domain/models/research_tool.dart';
import 'package:smara_accounting/ui/features/settings/view_models/settings_view_model.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockSettingsRepository settingsRepository;
  late MockBooksCopyRepository booksCopyRepository;
  late MockAppLockService appLockService;
  late MockBiometricAuthenticator biometricAuthenticator;
  late MockAppLockController appLockController;
  late SettingsViewModel viewModel;

  setUp(() {
    settingsRepository = MockSettingsRepository();
    booksCopyRepository = MockBooksCopyRepository();
    appLockService = MockAppLockService();
    biometricAuthenticator = MockBiometricAuthenticator();
    appLockController = MockAppLockController();
    when(
      settingsRepository.isReferenceRateLookupEnabled(),
    ).thenAnswer((_) async => false);
    when(
      settingsRepository.selectedProvider(),
    ).thenAnswer((_) async => ExchangeRateProvider.frankfurter);
    when(
      settingsRepository.isMarketPriceFetchEnabled(),
    ).thenAnswer((_) async => true);
    when(
      settingsRepository.selectedQuoteProvider(),
    ).thenAnswer((_) async => QuoteProvider.stooq);
    when(
      settingsRepository.selectedResearchTool(),
    ).thenAnswer((_) async => ResearchTool.chatGpt);
    when(
      settingsRepository.selectedDefaultExchange(
        deviceRegion: anyNamed('deviceRegion'),
      ),
    ).thenAnswer((_) async => exchangeForCode('US')!);
    when(biometricAuthenticator.isAvailable()).thenAnswer((_) async => false);
    when(settingsRepository.isAppLockEnabled()).thenAnswer((_) async => false);
    when(settingsRepository.appLockTimeoutMinutes()).thenAnswer((_) async => 0);
    when(
      settingsRepository.isAppLockBiometricEnabled(),
    ).thenAnswer((_) async => false);
    when(
      settingsRepository.isBackupReminderEnabled(),
    ).thenAnswer((_) async => true);
    when(settingsRepository.backupReminderDays()).thenAnswer((_) async => 30);
    when(
      settingsRepository.backupReminderEntries(),
    ).thenAnswer((_) async => 500);
    when(
      settingsRepository.backupReminderSnoozeDays(),
    ).thenAnswer((_) async => 7);
    when(
      settingsRepository.backupReminderSnoozeEntries(),
    ).thenAnswer((_) async => 500);
    viewModel = SettingsViewModel(
      settingsRepository: settingsRepository,
      booksCopyRepository: booksCopyRepository,
      appLockService: appLockService,
      biometricAuthenticator: biometricAuthenticator,
      appLockController: appLockController,
    );
  });

  group('exportBackup', () {
    test('returns the encrypted contents on success', () async {
      when(
        booksCopyRepository.saveBooksCopy(passphrase: anyNamed('passphrase')),
      ).thenAnswer((_) async => '{"kind":"smara-books-copy"}');

      final result = await viewModel.exportBackup(passphrase: 'hunter2');

      expect(result, equals('{"kind":"smara-books-copy"}'));
      expect(viewModel.backupErrorMessage, isNull);
      expect(viewModel.isBackingUp, isFalse);
    });

    test('returns null and sets an error message on failure', () async {
      when(
        booksCopyRepository.saveBooksCopy(passphrase: anyNamed('passphrase')),
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
        booksCopyRepository.restoreBooksCopy(
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
      'surfaces InvalidLedgerBackupException as a plain-language message',
      () async {
        when(
          booksCopyRepository.restoreBooksCopy(
            fileContents: anyNamed('fileContents'),
            passphrase: anyNamed('passphrase'),
          ),
        ).thenThrow(InvalidLedgerBackupException('not a valid backup'));

        final ok = await viewModel.restoreBackup(
          fileContents: '{}',
          passphrase: 'hunter2',
        );

        expect(ok, isFalse);
        expect(
          viewModel.backupErrorMessage,
          equals('This file is not a valid Smara backup.'),
        );
      },
    );

    test(
      'any other failure (e.g. wrong passphrase) surfaces a generic message',
      () async {
        when(
          booksCopyRepository.restoreBooksCopy(
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

  group('pinValidationError', () {
    test('rejects a PIN shorter than 4 characters', () {
      expect(
        viewModel.pinValidationError('123', '123'),
        AppErrorCode.validationPinTooShort,
      );
    });

    test('rejects a mismatched confirmation', () {
      expect(
        viewModel.pinValidationError('1234', '4321'),
        AppErrorCode.validationPinsDoNotMatch,
      );
    });

    test('accepts a matching PIN of at least 4 characters', () {
      expect(viewModel.pinValidationError('1234', '1234'), isNull);
    });
  });

  group('passphraseValidationError', () {
    test('rejects blank and whitespace-only passphrases', () {
      expect(
        viewModel.passphraseValidationError(''),
        AppErrorCode.validationPassphraseRequired,
      );
      expect(
        viewModel.passphraseValidationError('   '),
        AppErrorCode.validationPassphraseRequired,
      );
    });

    test('accepts a non-blank passphrase', () {
      expect(viewModel.passphraseValidationError('hunter2'), isNull);
    });
  });
}
