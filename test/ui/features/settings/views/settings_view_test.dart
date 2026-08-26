import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/exchange_rate_provider.dart';
import 'package:smara_accounting/domain/models/quote_provider.dart';
import 'package:smara_accounting/domain/models/research_tool.dart';
import 'package:smara_accounting/ui/features/settings/view_models/settings_view_model.dart';
import 'package:smara_accounting/ui/features/settings/views/settings_view.dart';

import '../../../../mocks.mocks.dart';

void main() {
  late MockSettingsRepository repository;
  late MockLedgerBackupRepository ledgerBackupRepository;
  late MockAppLockService appLockService;
  late MockBiometricAuthenticator biometricAuthenticator;
  late MockAppLockController appLockController;

  setUp(() {
    repository = MockSettingsRepository();
    ledgerBackupRepository = MockLedgerBackupRepository();
    appLockService = MockAppLockService();
    biometricAuthenticator = MockBiometricAuthenticator();
    appLockController = MockAppLockController();
    when(
      repository.isReferenceRateLookupEnabled(),
    ).thenAnswer((_) async => false);
    when(
      repository.selectedProvider(),
    ).thenAnswer((_) async => ExchangeRateProvider.frankfurter);
    when(repository.isMarketPriceFetchEnabled()).thenAnswer((_) async => true);
    when(
      repository.selectedQuoteProvider(),
    ).thenAnswer((_) async => QuoteProvider.stooq);
    when(
      repository.selectedResearchTool(),
    ).thenAnswer((_) async => ResearchTool.chatGpt);
    when(
      repository.setReferenceRateLookupEnabled(any),
    ).thenAnswer((_) async {});
    when(repository.setSelectedProvider(any)).thenAnswer((_) async {});
    when(repository.isAppLockEnabled()).thenAnswer((_) async => false);
    when(repository.appLockTimeoutMinutes()).thenAnswer((_) async => 0);
    when(repository.isAppLockBiometricEnabled()).thenAnswer((_) async => false);
    when(biometricAuthenticator.isAvailable()).thenAnswer((_) async => false);
  });

  Future<SettingsViewModel> pumpSettings(WidgetTester tester) async {
    final viewModel = SettingsViewModel(
      settingsRepository: repository,
      ledgerBackupRepository: ledgerBackupRepository,
      appLockService: appLockService,
      biometricAuthenticator: biometricAuthenticator,
      appLockController: appLockController,
    );
    addTearDown(viewModel.dispose);
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    when(appLockController.isSnapshotHidingEnabled).thenReturn(false);
    await tester.pumpWidget(
      MaterialApp(home: SettingsView(viewModel: viewModel)),
    );
    await tester.pump();
    while (viewModel.isLoading) {
      await tester.pump();
    }
    await tester.pump();
    return viewModel;
  }

  Future<void> tapScrolled(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(finder);
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

      await tapScrolled(tester, find.text('Save backup'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Choose a passphrase to protect this backup. There is no recovery if you forget it.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
      await tester.pump();

      expect(find.text('Enter a passphrase.'), findsOneWidget);
      verifyNever(
        ledgerBackupRepository.exportLedgerBackup(
          passphrase: anyNamed('passphrase'),
        ),
      );
    },
  );

  testWidgets(
    'Restore backup opens a dialog; Restore is blocked until a file is '
    'chosen, without calling the Repository',
    (tester) async {
      await pumpSettings(tester);

      await tapScrolled(tester, find.text('Restore backup'));
      await tester.pumpAndSettle();
      expect(find.text('Choose file'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'hunter2');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Restore'));
      await tester.pump();

      expect(find.text('Choose a backup file first.'), findsOneWidget);
      verifyNever(
        ledgerBackupRepository.restoreLedgerBackup(
          fileContents: anyNamed('fileContents'),
          passphrase: anyNamed('passphrase'),
        ),
      );
    },
  );

  testWidgets('turning on Require unlock opens a set-PIN dialog; matching PINs '
      'enable app lock', (tester) async {
    when(appLockService.setPin(any)).thenAnswer((_) async {});
    when(appLockController.setLockEnabled(true)).thenAnswer((_) async {});
    await pumpSettings(tester);

    await tapScrolled(tester, find.text('Require unlock to open the app'));
    await tester.pumpAndSettle();
    expect(find.text('Set a PIN'), findsOneWidget);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '4242');
    await tester.enterText(fields.at(1), '4242');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Set PIN'));
    await tester.pumpAndSettle();

    verify(appLockService.setPin('4242')).called(1);
    verify(appLockController.setLockEnabled(true)).called(1);
    expect(find.text('Set a PIN'), findsNothing);
  });

  testWidgets('mismatched PINs in the set-PIN dialog block submission', (
    tester,
  ) async {
    await pumpSettings(tester);

    await tapScrolled(tester, find.text('Require unlock to open the app'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '4242');
    await tester.enterText(fields.at(1), '9999');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Set PIN'));
    await tester.pump();

    expect(find.text('The two PINs do not match.'), findsOneWidget);
    verifyNever(appLockService.setPin(any));
  });

  testWidgets(
    'turning off Require unlock (when already enabled) disables app lock '
    'without a dialog',
    (tester) async {
      when(repository.isAppLockEnabled()).thenAnswer((_) async => true);
      when(appLockService.clearPin()).thenAnswer((_) async {});
      when(appLockController.setLockEnabled(false)).thenAnswer((_) async {});
      when(
        repository.setAppLockBiometricEnabled(false),
      ).thenAnswer((_) async {});
      await pumpSettings(tester);

      await tapScrolled(tester, find.text('Require unlock to open the app'));
      await tester.pump();

      verify(appLockService.clearPin()).called(1);
      verify(appLockController.setLockEnabled(false)).called(1);
      expect(find.text('Set a PIN'), findsNothing);
    },
  );

  testWidgets(
    'the timeout dropdown and Change PIN are hidden while app lock is off',
    (tester) async {
      when(repository.isAppLockEnabled()).thenAnswer((_) async => false);
      await pumpSettings(tester);
      expect(find.text('Change PIN', skipOffstage: false), findsNothing);
      expect(
        find.byType(DropdownButtonFormField<int>, skipOffstage: false),
        findsNothing,
      );
    },
  );

  testWidgets(
    'the timeout dropdown and Change PIN are shown once app lock is enabled',
    (tester) async {
      when(repository.isAppLockEnabled()).thenAnswer((_) async => true);
      when(repository.appLockTimeoutMinutes()).thenAnswer((_) async => 0);
      final viewModel = await pumpSettings(tester);
      expect(viewModel.isAppLockEnabled, isTrue);
      expect(find.text('Change PIN'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<int>), findsOneWidget);
    },
  );
}
