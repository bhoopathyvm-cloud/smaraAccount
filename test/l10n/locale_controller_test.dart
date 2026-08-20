import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smara_accounting/data/repositories/settings_repository.dart';
import 'package:smara_accounting/l10n/locale_controller.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test('defaults to following the device and falls back to English', () async {
    final controller = LocaleController(
      settingsRepository: SettingsRepository(),
    );
    await controller.load();
    expect(controller.overrideLocale, isNull);
    expect(
      controller.resolve(const Locale('xx')),
      equals(const Locale('en')),
    );
  });

  test('persists a manual language override', () async {
    final settings = SettingsRepository();
    final controller = LocaleController(settingsRepository: settings);
    await controller.load();
    await controller.setPreference('en');
    expect(controller.overrideLocale, equals(const Locale('en')));

    final reloaded = LocaleController(settingsRepository: SettingsRepository());
    await reloaded.load();
    expect(reloaded.overrideLocale, equals(const Locale('en')));
  });
}
