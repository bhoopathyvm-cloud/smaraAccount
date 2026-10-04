import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smara_accounting/data/repositories/settings_repository.dart';
import 'package:smara_accounting/domain/peer_sync/direct_address_peer_discovery.dart';
import 'package:smara_accounting/domain/peer_sync/peer_discovery.dart';
import 'package:smara_accounting/domain/peer_sync/peer_sync_service.dart';
import 'package:test/test.dart';

import '../../harness/dual_device_harness.dart';

void main() {
  late DualDeviceHarness harness;
  late SettingsRepository settings;
  late DirectAddressPeerDiscovery direct;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    FakePeerDiscovery.resetAll();
    harness = DualDeviceHarness(networkId: 'direct-addr');
    await harness.setUp();
    await harness.link();
    settings = SettingsRepository();
    await settings.setLocalDeviceId(harness.a.deviceId);
    direct = DirectAddressPeerDiscovery();
  });

  tearDown(() async {
    FakePeerDiscovery.resetAll();
    await harness.tearDown();
  });

  test('connectByAddress registers a peer for Sync now browse', () async {
    final discovery = CompositePeerDiscovery(
      primary: FakePeerDiscovery(networkId: 'unused-direct'),
      direct: direct,
    );
    final service = PeerSyncService(
      transport: harness.a.transport,
      discovery: discovery,
      membership: harness.a.membership,
      merge: harness.a.merge,
      certificates: harness.a.certs,
      settings: settings,
      reachability: harness.reachability,
      activeBooksSetId: () async => harness.booksSetId,
      browseTimeout: const Duration(milliseconds: 50),
    );

    await service.connectByAddress(
      peerDeviceId: harness.b.deviceId,
      host: '127.0.0.1',
      port: 9443,
    );

    final hash = await booksSetIdHash(harness.booksSetId);
    final found = <DiscoveredPeer>[];
    final sub = discovery.browse(booksSetIdHash: hash).listen(found.add);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    await sub.cancel();

    expect(found, isNotEmpty);
    expect(found.first.deviceId, harness.b.deviceId);
    expect(found.first.host, '127.0.0.1');
    expect(found.first.port, 9443);
    await service.stop();
  });
}
