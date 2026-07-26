import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/exchange_rate_provider.dart';

/// Plain, non-secret app preferences (currently just the reference
/// exchange-rate lookup's enable/disable flag and selected provider).
/// Deliberately not `flutter_secure_storage` - that's reserved for actual
/// secret material (recovery phrase / signing key), and these values
/// aren't secrets.
class SettingsRepository {
  SettingsRepository({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  static const _referenceRateLookupEnabledKey = 'referenceRateLookupEnabled';
  static const _referenceRateProviderKey = 'referenceRateProvider';

  /// Defaults to disabled - this app has never made a network call before
  /// the reference-rate lookup, so the one new network-touching feature is
  /// opt-in, not opt-out.
  Future<bool> isReferenceRateLookupEnabled() async {
    return await _preferences.getBool(_referenceRateLookupEnabledKey) ?? false;
  }

  Future<void> setReferenceRateLookupEnabled(bool value) {
    return _preferences.setBool(_referenceRateLookupEnabledKey, value);
  }

  /// Defaults to the first predefined provider. If the stored value
  /// doesn't match any current [ExchangeRateProvider] case (e.g. a future
  /// release renamed or removed the one the user had selected), falls back
  /// to the default rather than throwing.
  Future<ExchangeRateProvider> selectedProvider() async {
    final stored = await _preferences.getString(_referenceRateProviderKey);
    for (final provider in ExchangeRateProvider.values) {
      if (provider.name == stored) return provider;
    }
    return ExchangeRateProvider.values.first;
  }

  Future<void> setSelectedProvider(ExchangeRateProvider provider) {
    return _preferences.setString(_referenceRateProviderKey, provider.name);
  }
}
