import 'dart:async';

import 'package:smara_accounting/domain/peer_sync/direct_address_peer_discovery.dart';
import 'package:smara_accounting/domain/peer_sync/peer_discovery.dart';
import 'package:test/test.dart';

void main() {
  test('DirectAddressPeerDiscovery emits matching peers', () async {
    final discovery = DirectAddressPeerDiscovery();
    addTearDown(discovery.dispose);

    final hash = await booksSetIdHash('books-1');
    final found = <DiscoveredPeer>[];
    final sub = discovery.browse(booksSetIdHash: hash).listen(found.add);

    await discovery.startAdvertising(
      PeerAdvertisement(
        booksSetIdHash: hash,
        deviceDisplayName: 'Local',
        deviceId: 'local',
        port: 9000,
      ),
    );
    discovery.addDirectPeer(
      DiscoveredPeer(
        booksSetIdHash: hash,
        deviceDisplayName: 'Remote',
        deviceId: 'remote',
        host: '192.168.1.20',
        port: 9001,
      ),
    );
    discovery.addDirectPeer(
      DiscoveredPeer(
        booksSetIdHash: await booksSetIdHash('other'),
        deviceDisplayName: 'Other',
        deviceId: 'other',
        host: '192.168.1.30',
        port: 9002,
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 20));
    await sub.cancel();

    expect(found.map((p) => p.deviceId), contains('remote'));
    expect(found.map((p) => p.deviceId), isNot(contains('other')));
    expect(
      found.singleWhere((p) => p.deviceId == 'remote').host,
      '192.168.1.20',
    );
  });

  test('CompositePeerDiscovery merges primary and direct peers', () async {
    final fake = FakePeerDiscovery(networkId: 'lan');
    final direct = DirectAddressPeerDiscovery();
    final composite = CompositePeerDiscovery(primary: fake, direct: direct);
    addTearDown(() async {
      await fake.dispose();
      await direct.dispose();
    });

    final hash = await booksSetIdHash('books-1');
    final found = <DiscoveredPeer>[];
    final sub = composite.browse(booksSetIdHash: hash).listen(found.add);

    await fake.startAdvertising(
      PeerAdvertisement(
        booksSetIdHash: hash,
        deviceDisplayName: 'A',
        deviceId: 'a',
        port: 1,
      ),
    );
    final other = FakePeerDiscovery(networkId: 'lan');
    addTearDown(other.dispose);
    await other.startAdvertising(
      PeerAdvertisement(
        booksSetIdHash: hash,
        deviceDisplayName: 'B',
        deviceId: 'b',
        port: 2,
      ),
    );
    direct.addDirectPeer(
      DiscoveredPeer(
        booksSetIdHash: hash,
        deviceDisplayName: 'C',
        deviceId: 'c',
        host: '10.0.0.3',
        port: 3,
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 30));
    await sub.cancel();

    expect(found.map((p) => p.deviceId).toSet(), containsAll(['b', 'c']));
  });
}
