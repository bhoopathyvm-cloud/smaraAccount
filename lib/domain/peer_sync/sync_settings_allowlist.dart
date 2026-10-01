/// Books-vs-device settings allowlist for MetadataOps sync (design Decision 9 /
/// task 6.5). Mirrors [SettingsRepository] books-settings keys so peer sync
/// never overwrites device settings.
class SyncSettingsAllowlist {
  const SyncSettingsAllowlist._();

  /// Keys that travel in Books Copy and peer MetadataOps.
  static const booksSettingsKeys = {
    'referenceRateLookupEnabled',
    'referenceRateProvider',
    'marketPriceFetchEnabled',
    'quoteProvider',
    'defaultExchange',
    'firstWeekSetupCompleted',
    'defaultCategoryLocale',
  };

  /// Device-only keys that must never apply from a peer.
  static const deviceSettingsKeys = {
    'appLockEnabled',
    'appLockTimeoutMinutes',
    'appLockBiometricEnabled',
    'hideAppSwitcherSnapshot',
    'researchTool',
    'preferredLocaleTag',
    'localDeviceId',
    'localDeviceDisplayName',
    'linkedDevicesPermissionExplained',
    'activeBooksSetId',
  };

  static bool isBooksSetting(String key) => booksSettingsKeys.contains(key);

  static bool isDeviceSetting(String key) => deviceSettingsKeys.contains(key);

  /// Keeps only books settings from a MetadataOps-style settings map.
  static Map<String, Object?> filterBooksSettings(
    Map<String, Object?> settings,
  ) {
    return {
      for (final e in settings.entries)
        if (isBooksSetting(e.key)) e.key: e.value,
    };
  }
}
