import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../data/repositories/settings_repository.dart';

/// Tracks whether the app is currently locked (app-lock spec: "Application
/// Lock", "Lock on resume"). A [ChangeNotifier] so `app_router.dart` can
/// pass it as `GoRouter`'s `refreshListenable` - a lock/unlock transition
/// re-runs the redirect immediately, the same mechanism every other gate
/// in this router (onboarding, restore, ...) relies on for its own state.
///
/// Cold start always begins locked ([_isUnlocked] defaults to false) -
/// the router redirect only actually enforces that if app lock turns out
/// to be enabled once the async settings read completes; this class has
/// no opinion on whether lock is enabled, only on whether *this session*
/// has been unlocked.
class AppLockController extends ChangeNotifier with WidgetsBindingObserver {
  AppLockController({required SettingsRepository settingsRepository})
    : _settingsRepository = settingsRepository {
    WidgetsBinding.instance.addObserver(this);
    _loadSnapshotHidingPreference();
  }

  final SettingsRepository _settingsRepository;

  bool _isUnlocked = false;
  bool get isUnlocked => _isUnlocked;

  DateTime? _backgroundedAt;

  /// Whether the app is currently in a backgrounded/inactive lifecycle
  /// state - read by the snapshot-hiding overlay, independent of whether
  /// app lock itself is enabled (app-lock spec: "Snapshot Hiding Works
  /// Independently Of App Lock").
  bool get isBackgrounded => _backgroundedAt != null;

  // Cached synchronously (not read fresh from Settings on every
  // backgrounding) so didChangeAppLifecycleState below can decide whether
  // to show the snapshot-hiding overlay with zero async gap: the OS
  // captures the app-switcher snapshot right around this same lifecycle
  // transition, so an async settings read at that moment risks the
  // overlay rendering one frame after the snapshot was already taken.
  // Defaults to false until the one-time load below completes - a small,
  // accepted window right at cold start.
  bool _isSnapshotHidingEnabled = false;
  bool get isSnapshotHidingEnabled => _isSnapshotHidingEnabled;

  Future<void> _loadSnapshotHidingPreference() async {
    _isSnapshotHidingEnabled = await _settingsRepository
        .isAppSwitcherSnapshotHidingEnabled();
    notifyListeners();
  }

  /// The single write path for this setting - keeps the synchronous cache
  /// and the persisted value from ever disagreeing. [SettingsViewModel]
  /// delegates here rather than writing [SettingsRepository] directly.
  Future<void> setSnapshotHidingEnabled(bool value) async {
    _isSnapshotHidingEnabled = value;
    notifyListeners();
    await _settingsRepository.setAppSwitcherSnapshotHidingEnabled(value);
  }

  void markUnlocked() {
    if (_isUnlocked) return;
    _isUnlocked = true;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _backgroundedAt ??= DateTime.now();
        notifyListeners();
      case AppLifecycleState.resumed:
        final backgroundedAt = _backgroundedAt;
        _backgroundedAt = null;
        notifyListeners();
        if (backgroundedAt != null) {
          unawaited(_maybeRelock(backgroundedAt));
        }
      case AppLifecycleState.detached:
        break;
    }
  }

  Future<void> _maybeRelock(DateTime backgroundedAt) async {
    if (!_isUnlocked) return;
    final enabled = await _settingsRepository.isAppLockEnabled();
    if (!enabled) return;
    final timeoutMinutes = await _settingsRepository.appLockTimeoutMinutes();
    final elapsed = DateTime.now().difference(backgroundedAt);
    if (timeoutMinutes <= 0 || elapsed >= Duration(minutes: timeoutMinutes)) {
      _isUnlocked = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
