/// Persistence for app-lock session flags. Implemented by
/// [SettingsRepository]; PIN hashes stay on [AppLockService] (ADR 0001).
abstract class AppLockSettingsStore {
  Future<bool> isAppLockEnabled();
  Future<void> setAppLockEnabled(bool value);
  Future<int> appLockTimeoutMinutes();
  Future<void> setAppLockTimeoutMinutes(int minutes);
  Future<bool> isAppSwitcherSnapshotHidingEnabled();
  Future<void> setAppSwitcherSnapshotHidingEnabled(bool value);
}
