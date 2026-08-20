import 'package:flutter/widgets.dart';

import '../../data/repositories/settings_repository.dart';
import 'supported_locales.dart';

/// Holds the in-app language override (or "follow the device") and notifies
/// [MaterialApp.router] so a picker change rebuilds the tree immediately.
class LocaleController extends ChangeNotifier {
  LocaleController({required SettingsRepository settingsRepository})
    : _settingsRepository = settingsRepository;

  final SettingsRepository _settingsRepository;

  /// Null means follow the device locale (with English fallback).
  Locale? _override;
  Locale? get overrideLocale => _override;

  bool _loaded = false;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    final stored = await _settingsRepository.preferredLocaleTag();
    if (stored == null || stored == kSystemLocalePreference) {
      _override = null;
    } else if (isSupportedLocaleTag(stored)) {
      _override = localeFromTag(stored);
    } else {
      _override = const Locale('en');
    }
    _loaded = true;
    notifyListeners();
  }

  /// [tag] is a supported locale tag, or [kSystemLocalePreference].
  Future<void> setPreference(String tag) async {
    if (tag == kSystemLocalePreference) {
      _override = null;
    } else {
      _override = localeFromTag(tag);
    }
    notifyListeners();
    await _settingsRepository.setPreferredLocaleTag(tag);
  }

  Locale resolve(Locale? deviceLocale) {
    return _override ?? resolveSupportedLocale(deviceLocale);
  }
}
