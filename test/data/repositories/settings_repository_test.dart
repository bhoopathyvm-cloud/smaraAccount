import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smara_accounting/data/repositories/settings_repository.dart';
import 'package:smara_accounting/domain/models/exchange_rate_provider.dart';

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
}
