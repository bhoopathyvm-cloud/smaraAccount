import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/investment/exchange_registry.dart';
import '../../domain/lock/app_lock_settings_store.dart';
import '../../domain/models/exchange_rate_provider.dart';
import '../../domain/models/quote_provider.dart';
import '../../domain/models/research_tool.dart';
import '../../domain/peer_sync/sync_settings_allowlist.dart';
import '../books_set/books_set_paths.dart';

/// Plain, non-secret app preferences (currently just the reference
/// exchange-rate lookup's enable/disable flag and selected provider).
/// Deliberately not `flutter_secure_storage` - that's reserved for actual
/// secret material (signing key), and these values
/// aren't secrets.
class SettingsRepository implements AppLockSettingsStore {
  SettingsRepository({
    SharedPreferencesAsync? preferences,
    BooksSetStore? booksSetStore,
  }) : _preferences = preferences ?? SharedPreferencesAsync(),
       _booksSetStore = booksSetStore;

  final SharedPreferencesAsync _preferences;
  final BooksSetStore? _booksSetStore;

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
  static const _defaultExchangeKey = 'defaultExchange';
  static const _preferredLocaleTagKey = 'preferredLocaleTag';
  static const _localDeviceIdKey = 'localDeviceId';
  static const _localDeviceDisplayNameKey = 'localDeviceDisplayName';
  static const _linkedDevicesPermissionExplainedKey =
      'linkedDevicesPermissionExplained';
  static const _claimsReceiptPermissionExplainedKey =
      'claimsReceiptPermissionExplained';

  /// Stable this-device id for Linked devices membership (device setting —
  /// does not sync).
  Future<String?> localDeviceId() => _preferences.getString(_localDeviceIdKey);

  Future<void> setLocalDeviceId(String id) =>
      _preferences.setString(_localDeviceIdKey, id);

  Future<String?> localDeviceDisplayName() =>
      _preferences.getString(_localDeviceDisplayNameKey);

  Future<void> setLocalDeviceDisplayName(String name) =>
      _preferences.setString(_localDeviceDisplayNameKey, name);

  /// Whether the Linked devices local-network permission sentence was shown.
  Future<bool> hasLinkedDevicesPermissionExplained() async {
    return await _preferences.getBool(_linkedDevicesPermissionExplainedKey) ??
        false;
  }

  Future<void> setLinkedDevicesPermissionExplained(bool value) {
    return _preferences.setBool(_linkedDevicesPermissionExplainedKey, value);
  }

  /// Whether the Claim receipt camera/photos permission sentence was shown.
  Future<bool> hasClaimsReceiptPermissionExplained() async {
    return await _preferences.getBool(_claimsReceiptPermissionExplainedKey) ??
        false;
  }

  Future<void> setClaimsReceiptPermissionExplained(bool value) {
    return _preferences.setBool(_claimsReceiptPermissionExplainedKey, value);
  }

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
  @override
  Future<bool> isAppLockEnabled() async {
    return await _preferences.getBool(_appLockEnabledKey) ?? false;
  }

  @override
  Future<void> setAppLockEnabled(bool value) {
    return _preferences.setBool(_appLockEnabledKey, value);
  }

  /// Minutes the app can sit backgrounded before the next resume requires
  /// unlocking again. 0 means "immediately" - re-lock on every
  /// backgrounding, however brief.
  @override
  Future<int> appLockTimeoutMinutes() async {
    return await _preferences.getInt(_appLockTimeoutMinutesKey) ?? 0;
  }

  @override
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
  @override
  Future<bool> isAppSwitcherSnapshotHidingEnabled() async {
    return await _preferences.getBool(_hideAppSwitcherSnapshotKey) ?? false;
  }

  @override
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

  /// The raw stored Default-exchange registry code, or null when the user
  /// has never chosen one. Callers that need a concrete exchange should use
  /// [selectedDefaultExchange], which applies the region/default fallback.
  Future<String?> defaultExchangeCode() {
    return _preferences.getString(_defaultExchangeKey);
  }

  Future<void> setDefaultExchange(Exchange exchange) {
    return _preferences.setString(_defaultExchangeKey, exchange.code);
  }

  /// The Default exchange: the stored code when it is still in the registry,
  /// otherwise the [deviceRegion]'s regional default, otherwise the global
  /// default. Same "unrecognised stored value falls back" rule as
  /// [selectedProvider].
  Future<Exchange> selectedDefaultExchange({String? deviceRegion}) async {
    final stored = await _preferences.getString(_defaultExchangeKey);
    return resolveDefaultExchange(storedCode: stored, regionCode: deviceRegion);
  }

  /// BCP-47 tag such as `en` or `ta`, or `system` to follow the device.
  /// Null means the user has never chosen — treat as `system`.
  Future<String?> preferredLocaleTag() {
    return _preferences.getString(_preferredLocaleTagKey);
  }

  Future<void> setPreferredLocaleTag(String tag) {
    return _preferences.setString(_preferredLocaleTagKey, tag);
  }

  // --- Books Copy: books settings export/import (never device settings) ---

  static const _booksSettingsKeys = SyncSettingsAllowlist.booksSettingsKeys;

  /// Books settings only. Device settings (locale, research tool, App Lock,
  /// reminder state) are never included.
  Future<Map<String, Object?>> exportBooksSettings() async {
    return {
      _referenceRateLookupEnabledKey: await isReferenceRateLookupEnabled(),
      _referenceRateProviderKey: (await selectedProvider()).name,
      _marketPriceFetchEnabledKey: await isMarketPriceFetchEnabled(),
      _quoteProviderKey: (await selectedQuoteProvider()).name,
      _defaultExchangeKey: await defaultExchangeCode(),
      _firstWeekSetupCompletedKey: await isFirstWeekSetupCompleted(),
    };
  }

  /// Applies books settings from a Books Copy. Does not touch device
  /// settings. Unknown keys are ignored.
  Future<void> importBooksSettings(Map<String, Object?> settings) async {
    for (final entry in settings.entries) {
      if (!_booksSettingsKeys.contains(entry.key)) continue;
      final value = entry.value;
      switch (entry.key) {
        case _referenceRateLookupEnabledKey:
          if (value is bool) await setReferenceRateLookupEnabled(value);
        case _referenceRateProviderKey:
          if (value is String) {
            for (final provider in ExchangeRateProvider.values) {
              if (provider.name == value) {
                await setSelectedProvider(provider);
                break;
              }
            }
          }
        case _marketPriceFetchEnabledKey:
          if (value is bool) await setMarketPriceFetchEnabled(value);
        case _quoteProviderKey:
          if (value is String) {
            for (final provider in QuoteProvider.values) {
              if (provider.name == value) {
                await setSelectedQuoteProvider(provider);
                break;
              }
            }
          }
        case _defaultExchangeKey:
          if (value is String) {
            Exchange? exchange;
            for (final candidate in kExchangeRegistry) {
              if (candidate.code == value) {
                exchange = candidate;
                break;
              }
            }
            if (exchange != null) await setDefaultExchange(exchange);
          } else if (value == null) {
            await _preferences.remove(_defaultExchangeKey);
          }
        case _firstWeekSetupCompletedKey:
          if (value is bool) await setFirstWeekSetupCompleted(value);
      }
    }
  }

  // --- Backup reminder (device-local; never exported) ---
  // Threshold prefs (enabled/days/entries) are device-wide. Last-copy and
  // snooze counters are keyed by active books set so a copy of set A does
  // not silence the reminder for set B (linked-devices design Decision 4).

  static const _lastCopySavedAtKey = 'lastCopySavedAt';
  static const _entryCountAtLastCopyKey = 'entryCountAtLastCopy';
  static const _snoozeUntilKey = 'backupReminderSnoozeUntil';
  static const _entryCountAtSnoozeKey = 'backupReminderEntryCountAtSnooze';
  static const _reminderEnabledKey = 'backupReminderEnabled';
  static const _reminderDaysKey = 'backupReminderDays';
  static const _reminderEntriesKey = 'backupReminderEntries';
  static const _snoozeDaysKey = 'backupReminderSnoozeDays';
  static const _snoozeEntriesKey = 'backupReminderSnoozeEntries';
  static const _keyAccessibilityMigratedKey = 'keyAccessibilityMigrated';

  static const defaultReminderDays = 30;
  static const defaultReminderEntries = 500;
  static const defaultSnoozeDays = 7;
  static const defaultSnoozeEntries = 500;

  Future<String> _scopedReminderKey(String base) async {
    final setId = await _booksSetStore?.activeBooksSetId();
    if (setId == null || setId.isEmpty) return base;
    return '$base:$setId';
  }

  Future<void> recordBooksCopySaved({
    required DateTime at,
    required int entryCount,
  }) async {
    await _preferences.setString(
      await _scopedReminderKey(_lastCopySavedAtKey),
      at.toUtc().toIso8601String(),
    );
    await _preferences.setInt(
      await _scopedReminderKey(_entryCountAtLastCopyKey),
      entryCount,
    );
    await _preferences.remove(await _scopedReminderKey(_snoozeUntilKey));
    await _preferences.remove(await _scopedReminderKey(_entryCountAtSnoozeKey));
  }

  Future<DateTime?> lastCopySavedAt() async {
    final scoped = await _preferences.getString(
      await _scopedReminderKey(_lastCopySavedAtKey),
    );
    // Fall back to unscoped legacy key when this set has no scoped value.
    final raw = scoped ?? await _preferences.getString(_lastCopySavedAtKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<int> entryCountAtLastCopy() async {
    final scoped = await _preferences.getInt(
      await _scopedReminderKey(_entryCountAtLastCopyKey),
    );
    if (scoped != null) return scoped;
    return await _preferences.getInt(_entryCountAtLastCopyKey) ?? 0;
  }

  Future<void> snoozeBackupReminder({
    required DateTime until,
    required int entryCount,
  }) async {
    await _preferences.setString(
      await _scopedReminderKey(_snoozeUntilKey),
      until.toUtc().toIso8601String(),
    );
    await _preferences.setInt(
      await _scopedReminderKey(_entryCountAtSnoozeKey),
      entryCount,
    );
  }

  Future<DateTime?> snoozeUntil() async {
    final scoped = await _preferences.getString(
      await _scopedReminderKey(_snoozeUntilKey),
    );
    final raw = scoped ?? await _preferences.getString(_snoozeUntilKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<int?> entryCountAtSnooze() async {
    final scoped = await _preferences.getInt(
      await _scopedReminderKey(_entryCountAtSnoozeKey),
    );
    return scoped ?? await _preferences.getInt(_entryCountAtSnoozeKey);
  }

  Future<bool> isBackupReminderEnabled() async {
    return await _preferences.getBool(_reminderEnabledKey) ?? true;
  }

  Future<void> setBackupReminderEnabled(bool value) {
    return _preferences.setBool(_reminderEnabledKey, value);
  }

  Future<int> backupReminderDays() async {
    return await _preferences.getInt(_reminderDaysKey) ?? defaultReminderDays;
  }

  Future<void> setBackupReminderDays(int days) {
    return _preferences.setInt(_reminderDaysKey, days);
  }

  Future<int> backupReminderEntries() async {
    return await _preferences.getInt(_reminderEntriesKey) ??
        defaultReminderEntries;
  }

  Future<void> setBackupReminderEntries(int entries) {
    return _preferences.setInt(_reminderEntriesKey, entries);
  }

  Future<int> backupReminderSnoozeDays() async {
    return await _preferences.getInt(_snoozeDaysKey) ?? defaultSnoozeDays;
  }

  Future<void> setBackupReminderSnoozeDays(int days) {
    return _preferences.setInt(_snoozeDaysKey, days);
  }

  Future<int> backupReminderSnoozeEntries() async {
    return await _preferences.getInt(_snoozeEntriesKey) ?? defaultSnoozeEntries;
  }

  Future<void> setBackupReminderSnoozeEntries(int entries) {
    return _preferences.setInt(_snoozeEntriesKey, entries);
  }

  Future<bool> isKeyAccessibilityMigrated() async {
    return await _preferences.getBool(_keyAccessibilityMigratedKey) ?? false;
  }

  Future<void> setKeyAccessibilityMigrated(bool value) {
    return _preferences.setBool(_keyAccessibilityMigratedKey, value);
  }
}
