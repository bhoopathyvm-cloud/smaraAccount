import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/exchange_rate_provider.dart';
import 'package:smara_accounting/ui/features/settings/view_models/settings_view_model.dart';
import 'package:smara_accounting/ui/features/settings/views/settings_view.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockSettingsRepository repository;
  late MockLedgerRepository ledgerRepository;
  late MockAppLockService appLockService;
  late MockBiometricAuthenticator biometricAuthenticator;
  late MockAppLockController appLockController;

  setUp(() {
    repository = MockSettingsRepository();
    ledgerRepository = MockLedgerRepository();
    appLockService = MockAppLockService();
    biometricAuthenticator = MockBiometricAuthenticator();
    appLockController = MockAppLockController();
    when(
      repository.isReferenceRateLookupEnabled(),
    ).thenAnswer((_) async => false);
    when(
      repository.selectedProvider(),
    ).thenAnswer((_) async => ExchangeRateProvider.frankfurter);
    when(
      repository.setReferenceRateLookupEnabled(any),
    ).thenAnswer((_) async {});
    when(repository.setSelectedProvider(any)).thenAnswer((_) async {});
    when(biometricAuthenticator.isAvailable()).thenAnswer((_) async => false);
  });

  Future<SettingsViewModel> pumpSettings(WidgetTester tester) async {
    final viewModel = SettingsViewModel(
      settingsRepository: repository,
      ledgerRepository: ledgerRepository,
      appLockService: appLockService,
      biometricAuthenticator: biometricAuthenticator,
      appLockController: appLockController,
    );
    addTearDown(viewModel.dispose);
    await tester.pumpWidget(
      MaterialApp(home: SettingsView(viewModel: viewModel)),
    );
    await tester.pump();
    return viewModel;
  }

  testWidgets('the provider dropdown lists exactly the predefined enum '
      'values, no custom option', (tester) async {
    when(
      repository.isReferenceRateLookupEnabled(),
    ).thenAnswer((_) async => true);
    await pumpSettings(tester);

    await tester.tap(
      find.byType(DropdownButtonFormField<ExchangeRateProvider>),
    );
    await tester.pumpAndSettle();

    for (final provider in ExchangeRateProvider.values) {
      expect(find.text(provider.displayName), findsWidgets);
    }
    // Every DropdownMenuItem's value is one of the enum's own values -
    // no custom/free-text provider is ever offered.
    final items = tester
        .widgetList<DropdownMenuItem<ExchangeRateProvider>>(
          find.byType(DropdownMenuItem<ExchangeRateProvider>),
        )
        .map((item) => item.value)
        .toSet();
    expect(items, equals(ExchangeRateProvider.values.toSet()));
  });

  testWidgets(
    'the provider dropdown is disabled while the lookup is off, enabled '
    'once turned on',
    (tester) async {
      await pumpSettings(tester);

      final disabledDropdown = tester
          .widget<DropdownButtonFormField<ExchangeRateProvider>>(
            find.byType(DropdownButtonFormField<ExchangeRateProvider>),
          );
      expect(disabledDropdown.onChanged, isNull);

      await tester.tap(
        find.descendant(
          of: find.widgetWithText(
            SwitchListTile,
            'Fetch reference exchange rates',
          ),
          matching: find.byType(Switch),
        ),
      );
      await tester.pump();

      final enabledDropdown = tester
          .widget<DropdownButtonFormField<ExchangeRateProvider>>(
            find.byType(DropdownButtonFormField<ExchangeRateProvider>),
          );
      expect(enabledDropdown.onChanged, isNotNull);
    },
  );

  testWidgets('toggling the switch calls through to the repository', (
    tester,
  ) async {
    await pumpSettings(tester);

    await tester.tap(
      find.descendant(
        of: find.widgetWithText(
          SwitchListTile,
          'Fetch reference exchange rates',
        ),
        matching: find.byType(Switch),
      ),
    );
    await tester.pump();

    verify(repository.setReferenceRateLookupEnabled(true)).called(1);
  });

  testWidgets('choosing a provider calls through to the repository', (
    tester,
  ) async {
    when(
      repository.isReferenceRateLookupEnabled(),
    ).thenAnswer((_) async => true);
    await pumpSettings(tester);

    await tester.tap(
      find.byType(DropdownButtonFormField<ExchangeRateProvider>),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.text(ExchangeRateProvider.openErApi.displayName).last,
    );
    await tester.pumpAndSettle();

    verify(
      repository.setSelectedProvider(ExchangeRateProvider.openErApi),
    ).called(1);
  });

  testWidgets(
    'Save backup opens a passphrase dialog; an empty passphrase blocks it '
    'without calling the Repository',
    (tester) async {
      await pumpSettings(tester);

      await tester.tap(find.text('Save backup'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Choose a passphrase to protect this backup. There is '
          'no way to recover it if you forget the passphrase.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pump();

      expect(find.text('Enter a passphrase.'), findsOneWidget);
      verifyNever(
        ledgerRepository.exportLedgerBackup(passphrase: anyNamed('passphrase')),
      );
    },
  );

  testWidgets(
    'Restore backup opens a dialog; Restore is blocked until a file is '
    'chosen, without calling the Repository',
    (tester) async {
      await pumpSettings(tester);

      await tester.tap(find.text('Restore backup'));
      await tester.pumpAndSettle();
      expect(find.text('Choose backup file'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'hunter2');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Restore'));
      await tester.pump();

      expect(find.text('Choose a backup file first.'), findsOneWidget);
      verifyNever(
        ledgerRepository.restoreLedgerBackup(
          fileContents: anyNamed('fileContents'),
          passphrase: anyNamed('passphrase'),
        ),
      );
    },
  );

  testWidgets('turning on Require unlock opens a set-PIN dialog; matching PINs '
      'enable app lock', (tester) async {
    when(appLockService.setPin(any)).thenAnswer((_) async {});
    when(repository.setAppLockEnabled(true)).thenAnswer((_) async {});
    await pumpSettings(tester);

    await tester.tap(find.text('Require unlock to open the app'));
    await tester.pumpAndSettle();
    expect(find.text('Set a PIN'), findsOneWidget);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '4242');
    await tester.enterText(fields.at(1), '4242');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Set PIN'));
    await tester.pumpAndSettle();

    verify(appLockService.setPin('4242')).called(1);
    verify(repository.setAppLockEnabled(true)).called(1);
    expect(find.text('Set a PIN'), findsNothing);
  });

  testWidgets('mismatched PINs in the set-PIN dialog block submission', (
    tester,
  ) async {
    await pumpSettings(tester);

    await tester.tap(find.text('Require unlock to open the app'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '4242');
    await tester.enterText(fields.at(1), '9999');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Set PIN'));
    await tester.pump();

    expect(find.text("PINs don't match."), findsOneWidget);
    verifyNever(appLockService.setPin(any));
  });

  testWidgets(
    'turning off Require unlock (when already enabled) disables app lock '
    'without a dialog',
    (tester) async {
      when(repository.isAppLockEnabled()).thenAnswer((_) async => true);
      when(appLockService.clearPin()).thenAnswer((_) async {});
      when(repository.setAppLockEnabled(false)).thenAnswer((_) async {});
      when(
        repository.setAppLockBiometricEnabled(false),
      ).thenAnswer((_) async {});
      await pumpSettings(tester);

      await tester.tap(find.text('Require unlock to open the app'));
      await tester.pump();

      verify(appLockService.clearPin()).called(1);
      verify(repository.setAppLockEnabled(false)).called(1);
      expect(find.text('Set a PIN'), findsNothing);
    },
  );

  testWidgets(
    'the timeout dropdown and Change PIN are only shown once app lock is enabled',
    (tester) async {
      when(repository.isAppLockEnabled()).thenAnswer((_) async => false);
      await pumpSettings(tester);
      expect(find.text('Change PIN'), findsNothing);
      expect(find.byType(DropdownButtonFormField<int>), findsNothing);

      when(repository.isAppLockEnabled()).thenAnswer((_) async => true);
      await pumpSettings(tester);
      await tester.pump();
      expect(find.text('Change PIN'), findsOneWidget);
      // The list is now tall enough that this dropdown can be offstage
      // (below the test viewport) - allWidgets/skipOffstage: false still
      // finds it, since it genuinely exists in the tree either way.
      expect(
        find.byType(DropdownButtonFormField<int>, skipOffstage: false),
        findsOneWidget,
      );
    },
  );
}
