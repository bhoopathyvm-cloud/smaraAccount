import 'dart:async';

import 'package:smara_accounting/domain/linked_devices/local_network_permission.dart';
import 'package:smara_accounting/domain/peer_sync/peer_discovery.dart';
import 'package:test/test.dart';

void main() {
  late FakePeerDiscovery deviceA;
  late FakePeerDiscovery deviceB;
  late FakePeerDiscovery deviceOtherSet;

  setUp(() {
    FakePeerDiscovery.resetAll();
    deviceA = FakePeerDiscovery(networkId: 'home-wifi');
    deviceB = FakePeerDiscovery(networkId: 'home-wifi');
    deviceOtherSet = FakePeerDiscovery(networkId: 'home-wifi');
  });

  tearDown(() async {
    await deviceA.dispose();
    await deviceB.dispose();
    await deviceOtherSet.dispose();
    FakePeerDiscovery.resetAll();
  });

  test('booksSetIdHash is stable and non-secret length', () async {
    final a = await booksSetIdHash('books-set-1');
    final b = await booksSetIdHash('books-set-1');
    final c = await booksSetIdHash('books-set-2');
    expect(a, equals(b));
    expect(a, isNot(equals(c)));
    expect(a.length, equals(64));
  });

  test(
    'two peers on same books set discover each other; other set ignored',
    () async {
      final hashHousehold = await booksSetIdHash('household');
      final hashOther = await booksSetIdHash('other-books');

      final foundOnA = <DiscoveredPeer>[];
      final sub = deviceA
          .browse(booksSetIdHash: hashHousehold)
          .listen(foundOnA.add);

      await deviceA.startAdvertising(
        PeerAdvertisement(
          booksSetIdHash: hashHousehold,
          deviceDisplayName: 'Phone A',
          deviceId: 'a',
          port: 7100,
        ),
      );
      await deviceB.startAdvertising(
        PeerAdvertisement(
          booksSetIdHash: hashHousehold,
          deviceDisplayName: 'Phone B',
          deviceId: 'b',
          port: 7101,
        ),
      );
      await deviceOtherSet.startAdvertising(
        PeerAdvertisement(
          booksSetIdHash: hashOther,
          deviceDisplayName: 'Other',
          deviceId: 'c',
          port: 7102,
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));
      await sub.cancel();

      expect(foundOnA.map((p) => p.deviceId), contains('b'));
      expect(foundOnA.map((p) => p.deviceId), isNot(contains('c')));
      expect(foundOnA.map((p) => p.deviceId), isNot(contains('a')));
      expect(
        foundOnA.where((p) => p.deviceId == 'b').single.deviceDisplayName,
        'Phone B',
      );
      expect(
        foundOnA.where((p) => p.deviceId == 'b').single.protocolVersion,
        smaraPeerSyncProtocolVersion,
      );
      expect(smaraMdnsServiceType, '_smara._tcp');
    },
  );

  test('discovery is gated on local-network permission', () async {
    final permission = FakeLocalNetworkPermission(granted: false);
    final gated = PermissionGatedPeerDiscovery(
      inner: deviceA,
      permission: permission,
    );
    final hash = await booksSetIdHash('household');

    await expectLater(
      gated.startAdvertising(
        PeerAdvertisement(
          booksSetIdHash: hash,
          deviceDisplayName: 'A',
          deviceId: 'a',
        ),
      ),
      throwsStateError,
    );

    final events = <DiscoveredPeer>[];
    final sub = gated.browse(booksSetIdHash: hash).listen(events.add);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await sub.cancel();
    expect(events, isEmpty);
    expect(deviceA.isAdvertising, isFalse);

    permission.grantOnRequest;
    await permission.requestPermission();
    expect(await permission.isGranted(), isTrue);

    await gated.startAdvertising(
      PeerAdvertisement(
        booksSetIdHash: hash,
        deviceDisplayName: 'A',
        deviceId: 'a',
      ),
    );
    expect(deviceA.isAdvertising, isTrue);
  });

  test('peers on different networks never discover each other', () async {
    final remote = FakePeerDiscovery(networkId: 'coffee-shop');
    addTearDown(() async {
      await remote.dispose();
    });

    final hash = await booksSetIdHash('household');
    final found = <DiscoveredPeer>[];
    final sub = deviceA.browse(booksSetIdHash: hash).listen(found.add);

    await deviceA.startAdvertising(
      PeerAdvertisement(
        booksSetIdHash: hash,
        deviceDisplayName: 'A',
        deviceId: 'a',
      ),
    );
    await remote.startAdvertising(
      PeerAdvertisement(
        booksSetIdHash: hash,
        deviceDisplayName: 'Remote',
        deviceId: 'remote',
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 20));
    await sub.cancel();
    expect(found, isEmpty);
  });
}
