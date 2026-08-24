import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/l10n/locale_controller.dart';
import 'package:smara_accounting/ui/features/lock/view_models/lock_view_model.dart';
import 'package:smara_accounting/ui/features/lock/views/lock_view.dart';

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
    when(
      settingsRepository.isAppLockBiometricEnabled(),
    ).thenAnswer((_) async => false);
  });

  Future<LockViewModel> pumpLockView(WidgetTester tester) async {
    final viewModel = LockViewModel(
      appLockService: appLockService,
      biometricAuthenticator: biometricAuthenticator,
      settingsRepository: settingsRepository,
      lockController: lockController,
      localeController: localeController,
    );
    addTearDown(viewModel.dispose);
    await tester.pumpWidget(MaterialApp(home: LockView(viewModel: viewModel)));
    await tester.pump();
    return viewModel;
  }

  testWidgets('submitting the correct PIN unlocks', (tester) async {
    when(appLockService.verifyPin('4242')).thenAnswer((_) async => true);
    await pumpLockView(tester);

    await tester.enterText(find.byType(TextField), '4242');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Unlock'));
    await tester.pump();

    verify(lockController.markUnlocked()).called(1);
  });

  testWidgets('a wrong PIN shows an error and does not unlock', (tester) async {
    when(appLockService.verifyPin('0000')).thenAnswer((_) async => false);
    await pumpLockView(tester);

    await tester.enterText(find.byType(TextField), '0000');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Unlock'));
    await tester.pump();

    expect(find.text('Wrong PIN. Try again.'), findsOneWidget);
    verifyNever(lockController.markUnlocked());
  });

  testWidgets(
    'the biometrics button is only shown when biometric unlock is enabled',
    (tester) async {
      when(
        settingsRepository.isAppLockBiometricEnabled(),
      ).thenAnswer((_) async => true);
      await pumpLockView(tester);

      expect(find.text('Use biometrics'), findsOneWidget);
    },
  );

  testWidgets('no biometrics button when biometric unlock is disabled', (
    tester,
  ) async {
    await pumpLockView(tester);

    expect(find.text('Use biometrics'), findsNothing);
  });
}
