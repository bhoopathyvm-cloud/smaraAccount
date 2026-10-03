import 'dart:async';
import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import '../linked_devices/local_network_permission.dart';

/// Bonjour / mDNS service type for Smara peer discovery (design Decision 1).
const smaraMdnsServiceType = '_smara._tcp';

/// Current peer-sync protocol version advertised in TXT records.
const smaraPeerSyncProtocolVersion = 1;

/// Non-secret hash of a books-set id for TXT filtering (design Decision 1).
Future<String> booksSetIdHash(String booksSetId) async {
  final digest = await Sha256().hash(
    utf8.encode('smara-books-set:$booksSetId'),
  );
  return digest.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

/// What this device advertises on `_smara._tcp`.
class PeerAdvertisement {
  const PeerAdvertisement({
    required this.booksSetIdHash,
    required this.deviceDisplayName,
    required this.deviceId,
    this.protocolVersion = smaraPeerSyncProtocolVersion,
    this.port = 0,
  });

  final String booksSetIdHash;
  final String deviceDisplayName;
  final String deviceId;
  final int protocolVersion;
  final int port;
}

/// A peer found while browsing the local link.
class DiscoveredPeer {
  const DiscoveredPeer({
    required this.booksSetIdHash,
    required this.deviceDisplayName,
    required this.deviceId,
    required this.host,
    required this.port,
    this.protocolVersion = smaraPeerSyncProtocolVersion,
  });

  final String booksSetIdHash;
  final String deviceDisplayName;
  final String deviceId;
  final String host;
  final int port;
  final int protocolVersion;
}

/// mDNS advertise/browse seam. Production uses [BonsoirPeerDiscovery];
/// [DirectAddressPeerDiscovery] covers blocked discovery; tests use
/// [FakePeerDiscovery].
abstract class PeerDiscovery {
  /// Starts advertising [advertisement] on the local link.
  Future<void> startAdvertising(PeerAdvertisement advertisement);

  Future<void> stopAdvertising();

  /// Browses for peers whose TXT books-set hash equals [booksSetIdHash].
  /// Peers for other books sets are never emitted.
  Stream<DiscoveredPeer> browse({required String booksSetIdHash});
}

/// Permission-gated discovery: no advertise/browse until local-network
/// permission is granted (task 5.1).
class PermissionGatedPeerDiscovery implements PeerDiscovery {
  PermissionGatedPeerDiscovery({
    required PeerDiscovery inner,
    required LocalNetworkPermission permission,
  }) : _inner = inner,
       _permission = permission;

  final PeerDiscovery _inner;
  final LocalNetworkPermission _permission;

  /// Underlying discovery (for adapters that need the direct-address path).
  PeerDiscovery get inner => _inner;

  @override
  Future<void> startAdvertising(PeerAdvertisement advertisement) async {
    if (!await _permission.isGranted()) {
      throw StateError(
        'Local-network permission is required before advertising '
        '$smaraMdnsServiceType.',
      );
    }
    return _inner.startAdvertising(advertisement);
  }

  @override
  Future<void> stopAdvertising() => _inner.stopAdvertising();

  @override
  Stream<DiscoveredPeer> browse({required String booksSetIdHash}) async* {
    if (!await _permission.isGranted()) {
      return;
    }
    yield* _inner.browse(booksSetIdHash: booksSetIdHash);
  }
}

/// In-process discovery bus for unit/integration tests (no real Bonjour).
class FakePeerDiscovery implements PeerDiscovery {
  FakePeerDiscovery({this.networkId = 'lan'});

  /// Peers only see each other when [networkId] matches.
  final String networkId;

  static final Map<String, Set<FakePeerDiscovery>> _networks = {};

  PeerAdvertisement? _advertisement;
  final _controller = StreamController<DiscoveredPeer>.broadcast();
  bool _advertising = false;

  PeerAdvertisement? get currentAdvertisement => _advertisement;

  bool get isAdvertising => _advertising;

  @override
  Future<void> startAdvertising(PeerAdvertisement advertisement) async {
    _advertisement = advertisement;
    _advertising = true;
    _networks.putIfAbsent(networkId, () => {}).add(this);
    _notifyPeers();
  }

  @override
  Future<void> stopAdvertising() async {
    _advertising = false;
    _networks[networkId]?.remove(this);
  }

  @override
  Stream<DiscoveredPeer> browse({required String booksSetIdHash}) {
    // Emit current matches, then continue listening for new advertisements.
    scheduleMicrotask(() {
      for (final peer in _peersOnNetwork()) {
        final ad = peer._advertisement;
        if (ad == null || !peer._advertising) continue;
        if (ad.booksSetIdHash != booksSetIdHash) continue;
        if (identical(peer, this)) continue;
        if (!_controller.isClosed) {
          _controller.add(_toDiscovered(ad));
        }
      }
    });
    return _controller.stream.where((p) => p.booksSetIdHash == booksSetIdHash);
  }

  void _notifyPeers() {
    final ad = _advertisement;
    if (ad == null || !_advertising) return;
    for (final peer in _peersOnNetwork()) {
      if (identical(peer, this)) continue;
      if (!peer._controller.isClosed) {
        peer._controller.add(_toDiscovered(ad));
      }
    }
  }

  Iterable<FakePeerDiscovery> _peersOnNetwork() =>
      _networks[networkId] ?? const {};

  DiscoveredPeer _toDiscovered(PeerAdvertisement ad) {
    return DiscoveredPeer(
      booksSetIdHash: ad.booksSetIdHash,
      deviceDisplayName: ad.deviceDisplayName,
      deviceId: ad.deviceId,
      host: 'fake-${ad.deviceId}.local',
      port: ad.port,
      protocolVersion: ad.protocolVersion,
    );
  }

  /// Test helper: tear down all in-process discovery buses.
  static void resetAll() {
    for (final set in _networks.values) {
      for (final peer in set) {
        peer._advertising = false;
        if (!peer._controller.isClosed) {
          // Leave controllers open for reuse within a test file.
        }
      }
    }
    _networks.clear();
  }

  Future<void> dispose() async {
    await stopAdvertising();
    await _controller.close();
  }
}
