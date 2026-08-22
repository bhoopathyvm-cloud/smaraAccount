import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/exchange_rate_provider.dart';
import '../../domain/models/quote_provider.dart';
import '../../domain/models/research_tool.dart';

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
  static const _appLockEnabledKey = 'appLockEnabled';
  static const _appLockTimeoutMinutesKey = 'appLockTimeoutMinutes';
  static const _appLockBiometricEnabledKey = 'appLockBiometricEnabled';
  static const _hideAppSwitcherSnapshotKey = 'hideAppSwitcherSnapshot';
  static const _firstWeekSetupCompletedKey = 'firstWeekSetupCompleted';
  static const _marketPriceFetchEnabledKey = 'marketPriceFetchEnabled';
  static const _quoteProviderKey = 'quoteProvider';
  static const _researchToolKey = 'researchTool';
  static const _preferredLocaleTagKey = 'preferredLocaleTag';

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

  /// Off by default (app-lock spec: "Lock is off by default" - opens
  /// without a lock screen exactly as it always has, unless the user
  /// opts in).
  Future<bool> isAppLockEnabled() async {
    return await _preferences.getBool(_appLockEnabledKey) ?? false;
  }

  Future<void> setAppLockEnabled(bool value) {
    return _preferences.setBool(_appLockEnabledKey, value);
  }

  /// Minutes the app can sit backgrounded before the next resume requires
  /// unlocking again. 0 means "immediately" - re-lock on every
  /// backgrounding, however brief.
  Future<int> appLockTimeoutMinutes() async {
    return await _preferences.getInt(_appLockTimeoutMinutesKey) ?? 0;
  }

  Future<void> setAppLockTimeoutMinutes(int minutes) {
    return _preferences.setInt(_appLockTimeoutMinutesKey, minutes);
  }

  /// Whether the unlock screen should offer device biometrics as well as
  /// the PIN - only meaningful (and only ever set true) on a device where
  /// [BiometricAuthenticator.isAvailable] returned true when the user
  /// turned it on.
  Future<bool> isAppLockBiometricEnabled() async {
    return await _preferences.getBool(_appLockBiometricEnabledKey) ?? false;
  }

  Future<void> setAppLockBiometricEnabled(bool value) {
    return _preferences.setBool(_appLockBiometricEnabledKey, value);
  }

  /// Independent of [isAppLockEnabled] (app-lock spec: "Snapshot Hiding
  /// Works Independently Of App Lock"). Off by default, and only ever
  /// meaningful on a platform with a real mechanism (iOS/Android) - the
  /// Settings UI is what keeps this from being offered anywhere else.
  Future<bool> isAppSwitcherSnapshotHidingEnabled() async {
    return await _preferences.getBool(_hideAppSwitcherSnapshotKey) ?? false;
  }

  Future<void> setAppSwitcherSnapshotHidingEnabled(bool value) {
    return _preferences.setBool(_hideAppSwitcherSnapshotKey, value);
  }

  /// first-week-setup-wizard: false until the wizard finishes once,
  /// gating the app-router redirect that shows it exactly once after
  /// onboarding (tasks.md 1.1).
  Future<bool> isFirstWeekSetupCompleted() async {
    return await _preferences.getBool(_firstWeekSetupCompletedKey) ?? false;
  }

  Future<void> setFirstWeekSetupCompleted(bool value) {
    return _preferences.setBool(_firstWeekSetupCompletedKey, value);
  }

  /// Defaults to enabled so portfolio value works without a scavenger hunt
  /// (investment-holdings design.md Decision 10). Distinct from the FX
  /// reference-rate toggle.
  Future<bool> isMarketPriceFetchEnabled() async {
    return await _preferences.getBool(_marketPriceFetchEnabledKey) ?? true;
  }

  Future<void> setMarketPriceFetchEnabled(bool value) {
    return _preferences.setBool(_marketPriceFetchEnabledKey, value);
  }

  Future<QuoteProvider> selectedQuoteProvider() async {
    final stored = await _preferences.getString(_quoteProviderKey);
    for (final provider in QuoteProvider.values) {
      if (provider.name == stored) return provider;
    }
    return QuoteProvider.values.first;
  }

  Future<void> setSelectedQuoteProvider(QuoteProvider provider) {
    return _preferences.setString(_quoteProviderKey, provider.name);
  }

  Future<ResearchTool> selectedResearchTool() async {
    final stored = await _preferences.getString(_researchToolKey);
    for (final tool in ResearchTool.values) {
      if (tool.name == stored) return tool;
    }
    return ResearchTool.values.first;
  }

  Future<void> setSelectedResearchTool(ResearchTool tool) {
    return _preferences.setString(_researchToolKey, tool.name);
  }

  /// BCP-47 tag such as `en` or `ta`, or `system` to follow the device.
  /// Null means the user has never chosen — treat as `system`.
  Future<String?> preferredLocaleTag() {
    return _preferences.getString(_preferredLocaleTagKey);
  }

  Future<void> setPreferredLocaleTag(String tag) {
    return _preferences.setString(_preferredLocaleTagKey, tag);
  }
}
