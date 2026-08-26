import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:smara_accounting/ui/core/app_lock_controller.dart';

import '../../mocks.mocks.dart';

// Plain test(), not testWidgets(): this controller has no widget tree of
// its own, and testWidgets' frame-pumping machinery has nothing to attach
// to here - TestWidgetsFlutterBinding.ensureInitialized() below is enough
// to satisfy the constructor's WidgetsBinding.instance.addObserver(this).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSettingsRepository settingsRepository;

  setUp(() {
    settingsRepository = MockSettingsRepository();
    when(
      settingsRepository.isAppSwitcherSnapshotHidingEnabled(),
    ).thenAnswer((_) async => false);
  });

  test('starts locked - cold start always requires unlock', () async {
    final controller = AppLockController(
      settingsRepository: settingsRepository,
    );
    addTearDown(controller.dispose);
    await controller.policy.ensureLoaded();

    expect(controller.isUnlocked, isFalse);
  });

  test('markUnlocked flips isUnlocked and notifies once', () async {
    final controller = AppLockController(
      settingsRepository: settingsRepository,
    );
    addTearDown(controller.dispose);
    await controller.policy.ensureLoaded();
    var notifications = 0;
    controller.addListener(() => notifications++);

    controller.markUnlocked();
    controller.markUnlocked();

    expect(controller.isUnlocked, isTrue);
    expect(notifications, equals(1));
  });

  test('isBackgrounded tracks inactive/paused/hidden vs resumed', () async {
    final controller = AppLockController(
      settingsRepository: settingsRepository,
    );
    addTearDown(controller.dispose);

    expect(controller.isBackgrounded, isFalse);

    controller.didChangeAppLifecycleState(AppLifecycleState.inactive);
    expect(controller.isBackgrounded, isTrue);

    controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
    expect(controller.isBackgrounded, isFalse);
  });

  test(
    'relocks on resume when lock is enabled and the timeout elapsed',
    () async {
      when(settingsRepository.isAppLockEnabled()).thenAnswer((_) async => true);
      when(
        settingsRepository.appLockTimeoutMinutes(),
      ).thenAnswer((_) async => 0);

      final controller = AppLockController(
        settingsRepository: settingsRepository,
      );
      addTearDown(controller.dispose);
      await controller.policy.ensureLoaded();
      controller.markUnlocked();
      expect(controller.isUnlocked, isTrue);

      controller.didChangeAppLifecycleState(AppLifecycleState.paused);
      controller.didChangeAppLifecycleState(AppLifecycleState.resumed);

      // timeoutMinutes 0 means "immediately" - any backgrounding relocks.
      expect(controller.isUnlocked, isFalse);
    },
  );

  test('does not relock on resume when app lock is disabled', () async {
    when(settingsRepository.isAppLockEnabled()).thenAnswer((_) async => false);

    final controller = AppLockController(
      settingsRepository: settingsRepository,
    );
    addTearDown(controller.dispose);
    await controller.policy.ensureLoaded();
    controller.markUnlocked();

    controller.didChangeAppLifecycleState(AppLifecycleState.paused);
    controller.didChangeAppLifecycleState(AppLifecycleState.resumed);

    expect(controller.isUnlocked, isTrue);
  });

  test('setSnapshotHidingEnabled updates the synchronous cache immediately, '
      'before the persisted write resolves', () async {
    when(
      settingsRepository.setAppSwitcherSnapshotHidingEnabled(true),
    ).thenAnswer((_) async {});

    final controller = AppLockController(
      settingsRepository: settingsRepository,
    );
    addTearDown(controller.dispose);
    await Future<void>.delayed(Duration.zero);
    expect(controller.isSnapshotHidingEnabled, isFalse);

    final future = controller.setSnapshotHidingEnabled(true);
    // Cache flips synchronously, before awaiting the repository write -
    // this is what lets didChangeAppLifecycleState decide whether to
    // show the overlay with zero async gap.
    expect(controller.isSnapshotHidingEnabled, isTrue);
    await future;

    verify(
      settingsRepository.setAppSwitcherSnapshotHidingEnabled(true),
    ).called(1);
  });
}
