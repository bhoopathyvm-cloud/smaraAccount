import 'dart:async';

import 'peer_discovery.dart';

/// Manual host:port peers when mDNS is blocked (task 12.2 direct-address
/// fallback). Peers are filtered by [booksSetIdHash] like mDNS TXT records.
class DirectAddressPeerDiscovery implements PeerDiscovery {
  PeerAdvertisement? _advertisement;
  final _peers = <DiscoveredPeer>[];
  final _controllers = <String, StreamController<DiscoveredPeer>>{};

  /// Registers a peer reachable at [host]:[port] for [booksSetIdHash].
  void addDirectPeer(DiscoveredPeer peer) {
    _peers.removeWhere((p) => p.deviceId == peer.deviceId);
    _peers.add(peer);
    final controller = _controllers[peer.booksSetIdHash];
    if (controller != null && !controller.isClosed) {
      controller.add(peer);
    }
  }

  void removeDirectPeer(String deviceId) {
    _peers.removeWhere((p) => p.deviceId == deviceId);
  }

  @override
  Future<void> startAdvertising(PeerAdvertisement advertisement) async {
    _advertisement = advertisement;
  }

  @override
  Future<void> stopAdvertising() async {
    _advertisement = null;
  }

  PeerAdvertisement? get currentAdvertisement => _advertisement;

  @override
  Stream<DiscoveredPeer> browse({required String booksSetIdHash}) {
    final controller = _controllers.putIfAbsent(
      booksSetIdHash,
      () => StreamController<DiscoveredPeer>.broadcast(),
    );
    scheduleMicrotask(() {
      for (final peer in _peers) {
        if (peer.booksSetIdHash != booksSetIdHash) continue;
        if (_advertisement?.deviceId == peer.deviceId) continue;
        if (!controller.isClosed) controller.add(peer);
      }
    });
    return controller.stream;
  }

  Future<void> dispose() async {
    for (final c in _controllers.values) {
      await c.close();
    }
    _controllers.clear();
    _peers.clear();
  }
}

/// Merges mDNS discovery with [DirectAddressPeerDiscovery] so either path can
/// surface peers for Sync now (task 12.2).
class CompositePeerDiscovery implements PeerDiscovery {
  CompositePeerDiscovery({
    required PeerDiscovery primary,
    required DirectAddressPeerDiscovery direct,
  }) : _primary = primary,
       _direct = direct;

  final PeerDiscovery _primary;
  final DirectAddressPeerDiscovery _direct;

  DirectAddressPeerDiscovery get direct => _direct;

  @override
  Future<void> startAdvertising(PeerAdvertisement advertisement) async {
    await _primary.startAdvertising(advertisement);
    await _direct.startAdvertising(advertisement);
  }

  @override
  Future<void> stopAdvertising() async {
    await _primary.stopAdvertising();
    await _direct.stopAdvertising();
  }

  @override
  Stream<DiscoveredPeer> browse({required String booksSetIdHash}) {
    return Stream<DiscoveredPeer>.multi((multi) {
      final seen = <String>{};
      void forward(DiscoveredPeer peer) {
        if (!seen.add(peer.deviceId)) return;
        multi.add(peer);
      }

      final a = _primary.browse(booksSetIdHash: booksSetIdHash).listen(forward);
      final b = _direct.browse(booksSetIdHash: booksSetIdHash).listen(forward);
      multi.onCancel = () async {
        await a.cancel();
        await b.cancel();
      };
    });
  }
}
