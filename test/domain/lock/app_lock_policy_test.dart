import 'package:smara_accounting/domain/lock/app_lock_policy.dart';
import 'package:smara_accounting/domain/lock/app_lock_settings_store.dart';
import 'package:test/test.dart';

class _FakeLockSettings implements AppLockSettingsStore {
  _FakeLockSettings({this.enabled = false, this.timeoutMinutes = 0});

  bool enabled;
  int timeoutMinutes;
  bool snapshotHiding = false;
  @override
  Future<bool> isAppLockEnabled() async => enabled;

  @override
  Future<void> setAppLockEnabled(bool value) async => enabled = value;

  @override
  Future<int> appLockTimeoutMinutes() async => timeoutMinutes;

  @override
  Future<void> setAppLockTimeoutMinutes(int minutes) async =>
      timeoutMinutes = minutes;

  @override
  Future<bool> isAppSwitcherSnapshotHidingEnabled() async => snapshotHiding;

  @override
  Future<void> setAppSwitcherSnapshotHidingEnabled(bool value) async =>
      snapshotHiding = value;
}

void main() {
  test(
    'starts locked and does not require a lock screen while disabled',
    () async {
      final policy = AppLockPolicy(settings: _FakeLockSettings());
      await policy.ensureLoaded();

      expect(policy.isUnlocked, isFalse);
      expect(policy.requiresLockScreen, isFalse);
    },
  );

  test('requires lock screen when enabled and the session is locked', () async {
    final policy = AppLockPolicy(settings: _FakeLockSettings(enabled: true));
    await policy.ensureLoaded();

    expect(policy.requiresLockScreen, isTrue);
    policy.markUnlocked();
    expect(policy.requiresLockScreen, isFalse);
  });

  test('relocks on resume after the configured timeout', () async {
    var now = DateTime(2026, 1, 1, 12, 0);
    final policy = AppLockPolicy(
      settings: _FakeLockSettings(enabled: true, timeoutMinutes: 5),
      clock: () => now,
    );
    await policy.ensureLoaded();
    policy.markUnlocked();
    policy.onBackgrounded();

    now = now.add(const Duration(minutes: 5));
    policy.onResumed();

    expect(policy.isUnlocked, isFalse);
    expect(policy.requiresLockScreen, isTrue);
  });

  test('does not relock when resumed before the timeout', () async {
    var now = DateTime(2026, 1, 1, 12, 0);
    final policy = AppLockPolicy(
      settings: _FakeLockSettings(enabled: true, timeoutMinutes: 5),
      clock: () => now,
    );
    await policy.ensureLoaded();
    policy.markUnlocked();
    policy.onBackgrounded();

    now = now.add(const Duration(minutes: 4));
    policy.onResumed();

    expect(policy.isUnlocked, isTrue);
  });

  test('timeout of 0 relocks on any backgrounding', () async {
    final policy = AppLockPolicy(
      settings: _FakeLockSettings(enabled: true, timeoutMinutes: 0),
      clock: () => DateTime(2026, 1, 1),
    );
    await policy.ensureLoaded();
    policy.markUnlocked();
    policy.onBackgrounded();
    policy.onResumed();

    expect(policy.isUnlocked, isFalse);
  });

  test('does not relock when lock is disabled', () async {
    final policy = AppLockPolicy(
      settings: _FakeLockSettings(enabled: false, timeoutMinutes: 0),
    );
    await policy.ensureLoaded();
    policy.markUnlocked();
    policy.onBackgrounded();
    policy.onResumed();

    expect(policy.isUnlocked, isTrue);
  });
}
