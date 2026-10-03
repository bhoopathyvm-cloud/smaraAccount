import 'dart:async';
import 'dart:io';

import 'package:bonsoir/bonsoir.dart';

/// Bonjour service type for join-by-code offers (real-sync design Decision 3).
/// TXT carries only an offer id — never the code or a hash of it.
const smaraJoinMdnsServiceType = '_smara-join._tcp';

/// What the inviting device advertises while a join code is live.
class JoinOfferAdvertisement {
  const JoinOfferAdvertisement({required this.offerId, required this.port});

  final String offerId;
  final int port;
}

/// A nearby join offer found while browsing `_smara-join._tcp`.
class DiscoveredJoinOffer {
  const DiscoveredJoinOffer({
    required this.offerId,
    required this.host,
    required this.port,
  });

  final String offerId;
  final String host;
  final int port;
}

/// Advertise / browse join offers. Production uses [BonsoirJoinOfferDiscovery];
/// tests use [FakeJoinOfferDiscovery].
abstract class JoinOfferDiscovery {
  Future<void> startAdvertising(JoinOfferAdvertisement advertisement);

  Future<void> stopAdvertising();

  Stream<DiscoveredJoinOffer> browse();
}

/// Bonsoir adapter for `_smara-join._tcp` (task 4.2).
class BonsoirJoinOfferDiscovery implements JoinOfferDiscovery {
  BonsoirBroadcast? _broadcast;
  JoinOfferAdvertisement? _advertisement;

  static const _attrOfferId = 'oid';

  @override
  Future<void> startAdvertising(JoinOfferAdvertisement advertisement) async {
    await stopAdvertising();
    _advertisement = advertisement;
    final service = BonsoirService(
      name: 'smara-join-${advertisement.offerId}',
      type: smaraJoinMdnsServiceType,
      port: advertisement.port,
      attributes: {
        _attrOfferId: advertisement.offerId,
        ...BonsoirService.defaultAttributes,
      },
    );
    _broadcast = BonsoirBroadcast(service: service);
    await _broadcast!.initialize();
    await _broadcast!.start();
  }

  @override
  Future<void> stopAdvertising() async {
    final broadcast = _broadcast;
    _broadcast = null;
    _advertisement = null;
    if (broadcast == null) return;
    try {
      await broadcast.stop();
    } catch (_) {}
  }

  @override
  Stream<DiscoveredJoinOffer> browse() {
    final controller = StreamController<DiscoveredJoinOffer>.broadcast();
    BonsoirDiscovery? discovery;
    StreamSubscription<BonsoirDiscoveryEvent>? sub;

    Future<void> start() async {
      discovery = BonsoirDiscovery(type: smaraJoinMdnsServiceType);
      await discovery!.initialize();
      sub = discovery!.eventStream!.listen((event) {
        switch (event) {
          case BonsoirDiscoveryServiceFoundEvent(:final service):
            service.resolve(discovery!.serviceResolver);
          case BonsoirDiscoveryServiceResolvedEvent(:final service):
            final offerId = service.attributes[_attrOfferId];
            if (offerId == null || offerId.isEmpty) return;
            if (_advertisement?.offerId == offerId) return;
            final host = _preferredHost(service);
            if (host == null || host.isEmpty) return;
            if (!controller.isClosed) {
              controller.add(
                DiscoveredJoinOffer(
                  offerId: offerId,
                  host: host,
                  port: service.port,
                ),
              );
            }
          default:
            break;
        }
      });
      await discovery!.start();
    }

    controller.onListen = start;
    controller.onCancel = () async {
      await sub?.cancel();
      try {
        await discovery?.stop();
      } catch (_) {}
    };
    return controller.stream;
  }

  /// Prefer a non-loopback IPv4 address; fall back to hostname.
  ///
  /// iOS Simulator ↔ macOS Bonjour often resolves to IPv6 link-local or
  /// loopback first; those break join-by-code TCP from the simulator.
  static String? _preferredHost(BonsoirService service) {
    final addresses = service.hostAddresses;
    for (final address in addresses) {
      final uriHost = address.contains(':') && !address.startsWith('[')
          ? '[$address]'
          : address;
      final parsed = Uri.parse('tcp://$uriHost').host;
      final ip = InternetAddress.tryParse(parsed);
      if (ip != null &&
          ip.type == InternetAddressType.IPv4 &&
          !ip.isLoopback &&
          !ip.isLinkLocal) {
        return ip.address;
      }
    }
    for (final address in addresses) {
      final ip = InternetAddress.tryParse(address);
      if (ip != null && ip.type == InternetAddressType.IPv4) {
        return ip.address;
      }
    }
    if (addresses.isNotEmpty) return addresses.first;
    return service.hostname;
  }
}

/// In-process join-offer bus for unit tests (no real Bonjour).
class FakeJoinOfferDiscovery implements JoinOfferDiscovery {
  FakeJoinOfferDiscovery({
    this.networkId = 'lan',
    this.advertiseHost = '127.0.0.1',
  });

  final String networkId;

  /// Host reported to browsers (loopback for harness tests).
  final String advertiseHost;

  static final Map<String, Set<FakeJoinOfferDiscovery>> _networks = {};

  JoinOfferAdvertisement? _advertisement;
  final _controller = StreamController<DiscoveredJoinOffer>.broadcast();
  bool _advertising = false;

  @override
  Future<void> startAdvertising(JoinOfferAdvertisement advertisement) async {
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
  Stream<DiscoveredJoinOffer> browse() {
    scheduleMicrotask(() {
      for (final peer in _peersOnNetwork()) {
        final ad = peer._advertisement;
        if (ad == null || !peer._advertising) continue;
        if (identical(peer, this)) continue;
        if (!_controller.isClosed) {
          _controller.add(_toDiscovered(ad));
        }
      }
    });
    return _controller.stream;
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

  Iterable<FakeJoinOfferDiscovery> _peersOnNetwork() =>
      _networks[networkId] ?? const {};

  DiscoveredJoinOffer _toDiscovered(JoinOfferAdvertisement ad) {
    return DiscoveredJoinOffer(
      offerId: ad.offerId,
      host: advertiseHost,
      port: ad.port,
    );
  }

  static void resetAll() {
    for (final set in _networks.values) {
      for (final peer in set) {
        peer._advertising = false;
      }
    }
    _networks.clear();
  }

  Future<void> dispose() async {
    await stopAdvertising();
    await _controller.close();
  }
}
