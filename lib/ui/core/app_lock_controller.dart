import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../data/repositories/settings_repository.dart';
import '../../domain/lock/app_lock_policy.dart';

/// Thin lifecycle forwarder for [AppLockPolicy] (app-lock-session-policy).
/// A [ChangeNotifier] so `app_router.dart` can pass it as `GoRouter`'s
/// `refreshListenable` - a lock/unlock transition re-runs the redirect.
///
/// Cold start always begins locked. This class has no opinion on whether
/// lock is enabled; that lives on [policy].
class AppLockController extends ChangeNotifier with WidgetsBindingObserver {
  AppLockController({
    required SettingsRepository settingsRepository,
    DateTime Function()? clock,
    AppLockPolicy? policy,
  }) : policy =
           policy ?? AppLockPolicy(settings: settingsRepository, clock: clock) {
    WidgetsBinding.instance.addObserver(this);
    unawaited(
      this.policy.ensureLoaded().then((_) {
        if (_disposed) return;
        notifyListeners();
      }),
    );
  }

  final AppLockPolicy policy;
  var _disposed = false;

  bool get isUnlocked => policy.isUnlocked;

  /// Whether the app is currently in a backgrounded/inactive lifecycle
  /// state - read by the snapshot-hiding overlay, independent of whether
  /// app lock itself is enabled (app-lock spec: "Snapshot Hiding Works
  /// Independently Of App Lock").
  bool get isBackgrounded => policy.isBackgrounded;

  bool get isSnapshotHidingEnabled => policy.isSnapshotHidingEnabled;

  Future<void> setSnapshotHidingEnabled(bool value) async {
    await policy.setSnapshotHidingEnabled(value);
    notifyListeners();
  }

  Future<void> setLockEnabled(bool value) async {
    await policy.setEnabled(value);
    notifyListeners();
  }

  Future<void> setTimeoutMinutes(int minutes) async {
    await policy.setTimeoutMinutes(minutes);
    notifyListeners();
  }

  void markUnlocked() {
    if (policy.isUnlocked) return;
    policy.markUnlocked();
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        policy.onBackgrounded();
        notifyListeners();
      case AppLifecycleState.resumed:
        policy.onResumed();
        notifyListeners();
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
