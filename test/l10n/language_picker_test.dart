import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smara_accounting/data/repositories/settings_repository.dart';
import 'package:smara_accounting/domain/models/exchange_rate_provider.dart';
import 'package:smara_accounting/domain/models/quote_provider.dart';
import 'package:smara_accounting/domain/models/research_tool.dart';
import 'package:smara_accounting/l10n/l10n.dart';
import 'package:smara_accounting/ui/features/settings/view_models/settings_view_model.dart';
import 'package:smara_accounting/ui/features/settings/views/settings_view.dart';

import '../mocks.mocks.dart';

void main() {
  testWidgets(
    'changing the language picker updates already-visible Settings title',
    (tester) async {
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      final localeController = LocaleController(
        settingsRepository: SettingsRepository(),
      );
      await localeController.load();

      final repository = MockSettingsRepository();
      final appLockController = MockAppLockController();
      when(
        repository.isReferenceRateLookupEnabled(),
      ).thenAnswer((_) async => false);
      when(
        repository.selectedProvider(),
      ).thenAnswer((_) async => ExchangeRateProvider.frankfurter);
      when(
        repository.isMarketPriceFetchEnabled(),
      ).thenAnswer((_) async => true);
      when(
        repository.selectedQuoteProvider(),
      ).thenAnswer((_) async => QuoteProvider.stooq);
      when(
        repository.selectedResearchTool(),
      ).thenAnswer((_) async => ResearchTool.chatGpt);
      when(repository.isAppLockEnabled()).thenAnswer((_) async => false);
      when(repository.appLockTimeoutMinutes()).thenAnswer((_) async => 0);
      when(
        repository.isAppLockBiometricEnabled(),
      ).thenAnswer((_) async => false);
      when(appLockController.isSnapshotHidingEnabled).thenReturn(false);

      final biometric = MockBiometricAuthenticator();
      when(biometric.isAvailable()).thenAnswer((_) async => false);

      final viewModel = SettingsViewModel(
        settingsRepository: repository,
        ledgerBackupRepository: MockLedgerBackupRepository(),
        appLockService: MockAppLockService(),
        biometricAuthenticator: biometric,
        appLockController: appLockController,
        localeController: localeController,
      );
      addTearDown(viewModel.dispose);

      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ListenableBuilder(
          listenable: localeController,
          builder: (context, _) {
            return MaterialApp(
              locale: localeController.resolve(const Locale('en')),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: supportedAppLocales,
              home: SettingsView(viewModel: viewModel),
            );
          },
        ),
      );
      await tester.pump();
      while (viewModel.isLoading) {
        await tester.pump();
      }
      await tester.pump();

      expect(find.text('Settings'), findsOneWidget);
      await localeController.setPreference('ta');
      await tester.pumpAndSettle();
      expect(find.text('அமைப்புகள்'), findsOneWidget);
    },
  );
}
