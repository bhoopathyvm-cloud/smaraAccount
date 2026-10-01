import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smara_accounting/data/repositories/settings_repository.dart';
import 'package:smara_accounting/domain/investment/exchange_registry.dart';
import 'package:smara_accounting/domain/models/exchange_rate_provider.dart';
import 'package:smara_accounting/domain/models/research_tool.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test(
    'lookup defaults to disabled and provider defaults to the first entry',
    () async {
      final repository = SettingsRepository();

      expect(await repository.isReferenceRateLookupEnabled(), isFalse);
      expect(
        await repository.selectedProvider(),
        equals(ExchangeRateProvider.values.first),
      );
    },
  );

  test('toggling the lookup enabled flag persists across instances', () async {
    final repository = SettingsRepository();

    await repository.setReferenceRateLookupEnabled(true);

    expect(await SettingsRepository().isReferenceRateLookupEnabled(), isTrue);
  });

  test('changing the selected provider persists across instances', () async {
    final repository = SettingsRepository();

    await repository.setSelectedProvider(ExchangeRateProvider.openErApi);

    expect(
      await SettingsRepository().selectedProvider(),
      equals(ExchangeRateProvider.openErApi),
    );
  });

  test(
    'an unrecognized persisted provider name falls back to the default provider',
    () async {
      // Simulates a future release renaming/removing a provider the user
      // had previously selected - written via the same public
      // SharedPreferencesAsync API the repository itself uses, under the
      // key SettingsRepository stores the provider name at.
      final prefs = SharedPreferencesAsync();
      await prefs.setString('referenceRateProvider', 'aRemovedLegacyProvider');

      final rate = await SettingsRepository().selectedProvider();

      expect(rate, equals(ExchangeRateProvider.values.first));
    },
  );

  test(
    'first-week setup defaults to not completed, and persists across instances '
    'once marked complete',
    () async {
      final repository = SettingsRepository();

      expect(await repository.isFirstWeekSetupCompleted(), isFalse);

      await repository.setFirstWeekSetupCompleted(true);

      expect(await SettingsRepository().isFirstWeekSetupCompleted(), isTrue);
    },
  );

  test('market price fetch defaults to enabled', () async {
    expect(await SettingsRepository().isMarketPriceFetchEnabled(), isTrue);
  });

  group('default exchange', () {
    test('first run uses the device region when none is stored', () async {
      final repository = SettingsRepository();

      expect((await repository.selectedDefaultExchange()).code, equals('US'));
      expect(
        (await repository.selectedDefaultExchange(deviceRegion: 'CH')).code,
        equals('SIX'),
      );
    });

    test('a chosen exchange persists across instances', () async {
      await SettingsRepository().setDefaultExchange(exchangeForCode('LSE')!);

      expect(
        (await SettingsRepository().selectedDefaultExchange(
          deviceRegion: 'CH',
        )).code,
        equals('LSE'),
      );
    });

    test(
      'an unrecognised stored code falls back to the regional default',
      () async {
        final prefs = SharedPreferencesAsync();
        await prefs.setString('defaultExchange', 'aRemovedExchange');

        expect(
          (await SettingsRepository().selectedDefaultExchange(
            deviceRegion: 'CH',
          )).code,
          equals('SIX'),
        );
      },
    );
  });

  group('exportBooksSettings', () {
    test('includes only books settings keys', () async {
      final repository = SettingsRepository();
      await repository.setReferenceRateLookupEnabled(true);
      await repository.setSelectedProvider(ExchangeRateProvider.openErApi);
      await repository.setMarketPriceFetchEnabled(false);
      await repository.setDefaultExchange(exchangeForCode('LSE')!);
      await repository.setFirstWeekSetupCompleted(true);

      final exported = await repository.exportBooksSettings();

      expect(
        exported.keys.toSet(),
        equals({
          'referenceRateLookupEnabled',
          'referenceRateProvider',
          'marketPriceFetchEnabled',
          'quoteProvider',
          'defaultExchange',
          'firstWeekSetupCompleted',
        }),
      );
      expect(exported['referenceRateLookupEnabled'], isTrue);
      expect(exported['referenceRateProvider'], equals('openErApi'));
      expect(exported['marketPriceFetchEnabled'], isFalse);
      expect(exported['defaultExchange'], equals('LSE'));
      expect(exported['firstWeekSetupCompleted'], isTrue);
    });

    test('never includes device settings even when they are set', () async {
      final repository = SettingsRepository();
      await repository.setPreferredLocaleTag('ta');
      await repository.setSelectedResearchTool(ResearchTool.claude);
      await repository.setAppLockEnabled(true);
      await repository.setAppLockTimeoutMinutes(5);
      await repository.setAppLockBiometricEnabled(true);
      await repository.recordBooksCopySaved(
        at: DateTime.utc(2026, 1, 15),
        entryCount: 42,
      );
      await repository.setBackupReminderEnabled(false);

      final exported = await repository.exportBooksSettings();

      expect(exported.containsKey('preferredLocaleTag'), isFalse);
      expect(exported.containsKey('researchTool'), isFalse);
      expect(exported.containsKey('appLockEnabled'), isFalse);
      expect(exported.containsKey('appLockTimeoutMinutes'), isFalse);
      expect(exported.containsKey('appLockBiometricEnabled'), isFalse);
      expect(exported.containsKey('hideAppSwitcherSnapshot'), isFalse);
      expect(exported.containsKey('lastCopySavedAt'), isFalse);
      expect(exported.containsKey('entryCountAtLastCopy'), isFalse);
      expect(exported.containsKey('backupReminderEnabled'), isFalse);
      expect(exported.containsKey('backupReminderDays'), isFalse);
      expect(exported.containsKey('backupReminderEntries'), isFalse);
      expect(exported.containsKey('backupReminderSnoozeUntil'), isFalse);
    });
  });

  group('importBooksSettings', () {
    test('applies books settings from a copy', () async {
      final repository = SettingsRepository();
      await repository.importBooksSettings({
        'referenceRateLookupEnabled': true,
        'referenceRateProvider': 'openErApi',
        'marketPriceFetchEnabled': false,
        'quoteProvider': 'stooq',
        'defaultExchange': 'LSE',
        'firstWeekSetupCompleted': true,
      });

      expect(await repository.isReferenceRateLookupEnabled(), isTrue);
      expect(
        await repository.selectedProvider(),
        equals(ExchangeRateProvider.openErApi),
      );
      expect(await repository.isMarketPriceFetchEnabled(), isFalse);
      expect(await repository.isFirstWeekSetupCompleted(), isTrue);
      expect(await repository.defaultExchangeCode(), equals('LSE'));
    });

    test('never overwrites device settings carried in a hostile map', () async {
      final repository = SettingsRepository();
      await repository.setPreferredLocaleTag('hi');
      await repository.setSelectedResearchTool(ResearchTool.claude);
      await repository.setAppLockEnabled(true);
      await repository.setAppLockTimeoutMinutes(15);
      await repository.setBackupReminderEnabled(false);
      await repository.setBackupReminderDays(10);
      await repository.recordBooksCopySaved(
        at: DateTime.utc(2026, 2, 1),
        entryCount: 7,
      );

      await repository.importBooksSettings({
        'preferredLocaleTag': 'ta',
        'researchTool': 'chatgpt',
        'appLockEnabled': false,
        'appLockTimeoutMinutes': 1,
        'backupReminderEnabled': true,
        'backupReminderDays': 99,
        'lastCopySavedAt': '2099-01-01T00:00:00.000Z',
        'entryCountAtLastCopy': 9999,
        'referenceRateLookupEnabled': true,
        'firstWeekSetupCompleted': true,
      });

      expect(await repository.preferredLocaleTag(), equals('hi'));
      expect(
        await repository.selectedResearchTool(),
        equals(ResearchTool.claude),
      );
      expect(await repository.isAppLockEnabled(), isTrue);
      expect(await repository.appLockTimeoutMinutes(), equals(15));
      expect(await repository.isBackupReminderEnabled(), isFalse);
      expect(await repository.backupReminderDays(), equals(10));
      expect(
        await repository.lastCopySavedAt(),
        equals(DateTime.utc(2026, 2, 1)),
      );
      expect(await repository.entryCountAtLastCopy(), equals(7));
      expect(await repository.isReferenceRateLookupEnabled(), isTrue);
      expect(await repository.isFirstWeekSetupCompleted(), isTrue);
    });
  });
}
