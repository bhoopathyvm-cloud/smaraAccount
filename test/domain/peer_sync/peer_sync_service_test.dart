import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smara_accounting/data/repositories/settings_repository.dart';
import 'package:smara_accounting/domain/peer_sync/peer_discovery.dart';
import 'package:smara_accounting/domain/peer_sync/peer_sync_service.dart';
import 'package:test/test.dart';

import '../../harness/dual_device_harness.dart';

void main() {
  late DualDeviceHarness harness;
  late FakePeerDiscovery discoveryA;
  late FakePeerDiscovery discoveryB;
  late SettingsRepository settings;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    FakePeerDiscovery.resetAll();
    harness = DualDeviceHarness(networkId: 'peer-sync-svc');
    await harness.setUp();
    await harness.link();
    discoveryA = FakePeerDiscovery(networkId: 'peer-sync-svc');
    discoveryB = FakePeerDiscovery(networkId: 'peer-sync-svc');
    settings = SettingsRepository();
  });

  tearDown(() async {
    await discoveryA.stopAdvertising();
    await discoveryB.stopAdvertising();
    FakePeerDiscovery.resetAll();
    await harness.tearDown();
  });

  test(
    'Sync now finds a linked peer via discovery and exchanges entries',
    () async {
      final serviceB = PeerSyncService(
        transport: harness.b.transport,
        discovery: discoveryB,
        membership: harness.b.membership,
        merge: harness.b.merge,
        certificates: harness.b.certs,
        settings: settings,
        reachability: harness.reachability,
        activeBooksSetId: () async => harness.booksSetId,
        browseTimeout: const Duration(milliseconds: 100),
      );
      final serviceA = PeerSyncService(
        transport: harness.a.transport,
        discovery: discoveryA,
        membership: harness.a.membership,
        merge: harness.a.merge,
        certificates: harness.a.certs,
        settings: settings,
        reachability: harness.reachability,
        activeBooksSetId: () async => harness.booksSetId,
        browseTimeout: const Duration(milliseconds: 200),
      );

      await settings.setLocalDeviceId(harness.b.deviceId);
      await settings.setLocalDeviceDisplayName(harness.b.displayName);
      await serviceB.startForeground();

      await harness.a.recordSpend(amountMinor: 2500, description: 'lunch');

      await settings.setLocalDeviceId(harness.a.deviceId);
      await settings.setLocalDeviceDisplayName(harness.a.displayName);
      final results = await serviceA.syncNow();
      expect(results, isNotEmpty);
      expect(results.any((r) => r.connected && r.entriesSent > 0), isTrue);

      final onB = await harness.b.ledger.watchEntries().first;
      expect(onB, isNotEmpty);

      await serviceA.stop();
      await serviceB.stop();
    },
  );
}
