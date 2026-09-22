import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/domain/models/exchange_rate_provider.dart';
import 'package:smara_accounting/domain/models/quote_provider.dart';
import 'package:smara_accounting/domain/models/research_tool.dart';
import 'package:smara_accounting/ui/features/settings/view_models/settings_view_model.dart';
import 'package:smara_accounting/ui/features/settings/views/device_migration_bundle_export_view.dart';

import '../../../../mocks.mocks.dart';

// Never exercises the actual file save (file_picker needs a platform
// channel this test environment doesn't have) - only what's reachable
// without one: initial render, the combined-risk disclosure text, and the
// empty-passphrase validation message.
void main() {
  late MockSettingsRepository settingsRepository;
  late MockLedgerBackupRepository ledgerBackupRepository;
  late MockDeviceMigrationBundleRepository deviceMigrationBundleRepository;
  late MockAppLockService appLockService;
  late MockBiometricAuthenticator biometricAuthenticator;
  late MockAppLockController appLockController;
  late SettingsViewModel viewModel;

  setUp(() {
    settingsRepository = MockSettingsRepository();
    ledgerBackupRepository = MockLedgerBackupRepository();
    deviceMigrationBundleRepository = MockDeviceMigrationBundleRepository();
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
    when(biometricAuthenticator.isAvailable()).thenAnswer((_) async => false);
    viewModel = SettingsViewModel(
      settingsRepository: settingsRepository,
      ledgerBackupRepository: ledgerBackupRepository,
      deviceMigrationBundleRepository: deviceMigrationBundleRepository,
      appLockService: appLockService,
      biometricAuthenticator: biometricAuthenticator,
      appLockController: appLockController,
    );
  });

  testWidgets('shows the combined-risk disclosure and passphrase field', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: DeviceMigrationBundleExportView(viewModel: viewModel)),
    );

    expect(
      find.textContaining('read your books and sign new entries'),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('exporting with an empty passphrase shows a validation message, '
      'never calling the Repository', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: DeviceMigrationBundleExportView(viewModel: viewModel)),
    );

    await tester.tap(find.text('Export bundle'));
    await tester.pump();

    expect(find.text('Enter a passphrase.'), findsOneWidget);
    verifyNever(
      deviceMigrationBundleRepository.exportBundle(
        passphrase: anyNamed('passphrase'),
      ),
    );
  });
}
