import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/l10n/locale_controller.dart';
import 'package:smara_accounting/ui/features/lock/view_models/lock_view_model.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockAppLockService appLockService;
  late MockBiometricAuthenticator biometricAuthenticator;
  late MockSettingsRepository settingsRepository;
  late MockAppLockController lockController;
  late LocaleController localeController;

  setUp(() {
    appLockService = MockAppLockService();
    biometricAuthenticator = MockBiometricAuthenticator();
    settingsRepository = MockSettingsRepository();
    lockController = MockAppLockController();
    localeController = LocaleController(settingsRepository: settingsRepository);
  });

  LockViewModel buildViewModel() {
    return LockViewModel(
      appLockService: appLockService,
      biometricAuthenticator: biometricAuthenticator,
      settingsRepository: settingsRepository,
      lockController: lockController,
      localeController: localeController,
    );
  }

  group('submitPin', () {
    test(
      'a correct PIN marks the controller unlocked and returns true',
      () async {
        when(
          settingsRepository.isAppLockBiometricEnabled(),
        ).thenAnswer((_) async => false);
        when(appLockService.verifyPin('1234')).thenAnswer((_) async => true);
        final viewModel = buildViewModel();

        final result = await viewModel.submitPin('1234');

        expect(result, isTrue);
        expect(viewModel.errorMessage, isNull);
        verify(lockController.markUnlocked()).called(1);
      },
    );

    test('a wrong PIN sets an error message and never unlocks', () async {
      when(
        settingsRepository.isAppLockBiometricEnabled(),
      ).thenAnswer((_) async => false);
      when(appLockService.verifyPin('0000')).thenAnswer((_) async => false);
      final viewModel = buildViewModel();

      final result = await viewModel.submitPin('0000');

      expect(result, isFalse);
      expect(viewModel.errorMessage, isNotNull);
      verifyNever(lockController.markUnlocked());
    });
  });

  group('biometrics', () {
    test(
      'auto-prompts on open when biometric unlock is enabled, and unlocks on success',
      () async {
        when(
          settingsRepository.isAppLockBiometricEnabled(),
        ).thenAnswer((_) async => true);
        when(
          biometricAuthenticator.authenticate(reason: anyNamed('reason')),
        ).thenAnswer((_) async => true);

        buildViewModel();
        await Future<void>.delayed(Duration.zero);

        verify(
          biometricAuthenticator.authenticate(reason: anyNamed('reason')),
        ).called(1);
        verify(lockController.markUnlocked()).called(1);
      },
    );

    test('does not auto-prompt when biometric unlock is disabled', () async {
      when(
        settingsRepository.isAppLockBiometricEnabled(),
      ).thenAnswer((_) async => false);

      buildViewModel();
      await Future<void>.delayed(Duration.zero);

      verifyNever(
        biometricAuthenticator.authenticate(reason: anyNamed('reason')),
      );
    });

    test(
      'a cancelled/failed biometric prompt does not unlock and sets no error '
      '(the PIN field stays available)',
      () async {
        when(
          settingsRepository.isAppLockBiometricEnabled(),
        ).thenAnswer((_) async => true);
        when(
          biometricAuthenticator.authenticate(reason: anyNamed('reason')),
        ).thenAnswer((_) async => false);

        final viewModel = buildViewModel();
        await Future<void>.delayed(Duration.zero);

        verifyNever(lockController.markUnlocked());
        expect(viewModel.errorMessage, isNull);
      },
    );
  });
}
