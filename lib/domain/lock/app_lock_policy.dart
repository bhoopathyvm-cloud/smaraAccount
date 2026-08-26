import 'app_lock_settings_store.dart';

/// Session lock policy: enabled, timeout, snapshot hiding, and whether
/// this session is unlocked. Distinct from [AppLockService] PIN crypto
/// (app-lock-session-policy, ADR 0001).
///
/// Settings are cached so lifecycle events and router redirects do not
/// race a fresh async read. Call [ensureLoaded] before relying on
/// [requiresLockScreen].
class AppLockPolicy {
  AppLockPolicy({
    required AppLockSettingsStore settings,
    DateTime Function()? clock,
  }) : _settings = settings,
       _now = clock ?? DateTime.now;

  final AppLockSettingsStore _settings;
  final DateTime Function() _now;

  var _loaded = false;
  Future<void>? _loadFuture;

  var _enabled = false;
  var _timeoutMinutes = 0;
  var _snapshotHidingEnabled = false;
  var _unlocked = false;
  DateTime? _backgroundedAt;

  bool get isEnabled => _enabled;
  bool get isUnlocked => _unlocked;
  bool get requiresLockScreen => _enabled && !_unlocked;
  bool get isBackgrounded => _backgroundedAt != null;
  bool get isSnapshotHidingEnabled => _snapshotHidingEnabled;
  int get timeoutMinutes => _timeoutMinutes;

  Future<void> ensureLoaded() {
    return _loadFuture ??= _load();
  }

  Future<void> _load() async {
    _enabled = await _settings.isAppLockEnabled();
    _timeoutMinutes = await _settings.appLockTimeoutMinutes();
    _snapshotHidingEnabled = await _settings
        .isAppSwitcherSnapshotHidingEnabled();
    _loaded = true;
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    await _settings.setAppLockEnabled(value);
  }

  Future<void> setTimeoutMinutes(int minutes) async {
    _timeoutMinutes = minutes;
    await _settings.setAppLockTimeoutMinutes(minutes);
  }

  Future<void> setSnapshotHidingEnabled(bool value) async {
    _snapshotHidingEnabled = value;
    await _settings.setAppSwitcherSnapshotHidingEnabled(value);
  }

  void markUnlocked() {
    _unlocked = true;
  }

  void onBackgrounded() {
    _backgroundedAt ??= _now();
  }

  /// Applies timeout policy using cached settings. Synchronous after
  /// [ensureLoaded] so unit tests need no widget tree.
  void onResumed() {
    final backgroundedAt = _backgroundedAt;
    _backgroundedAt = null;
    if (!_loaded || backgroundedAt == null || !_unlocked || !_enabled) {
      return;
    }
    final elapsed = _now().difference(backgroundedAt);
    if (_timeoutMinutes <= 0 || elapsed >= Duration(minutes: _timeoutMinutes)) {
      _unlocked = false;
    }
  }
}
