import 'dart:async';
import 'dart:io';

import 'package:bonsoir/bonsoir.dart';

import 'peer_discovery.dart';

/// Bonjour/NSD adapter for `_smara._tcp` (linked-devices task 12.2).
class BonsoirPeerDiscovery implements PeerDiscovery {
  BonsoirBroadcast? _broadcast;
  PeerAdvertisement? _advertisement;

  static const _attrBooksHash = 'bsh';
  static const _attrDeviceId = 'did';
  static const _attrDisplayName = 'name';
  static const _attrProtocol = 'pv';

  @override
  Future<void> startAdvertising(PeerAdvertisement advertisement) async {
    await stopAdvertising();
    _advertisement = advertisement;
    final service = BonsoirService(
      name: 'smara-${advertisement.deviceId}',
      type: smaraMdnsServiceType,
      port: advertisement.port,
      attributes: {
        _attrBooksHash: advertisement.booksSetIdHash,
        _attrDeviceId: advertisement.deviceId,
        _attrDisplayName: advertisement.deviceDisplayName,
        _attrProtocol: '${advertisement.protocolVersion}',
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
  Stream<DiscoveredPeer> browse({required String booksSetIdHash}) {
    final controller = StreamController<DiscoveredPeer>.broadcast();
    BonsoirDiscovery? discovery;
    StreamSubscription<BonsoirDiscoveryEvent>? sub;

    Future<void> start() async {
      discovery = BonsoirDiscovery(type: smaraMdnsServiceType);
      await discovery!.initialize();
      sub = discovery!.eventStream!.listen((event) {
        switch (event) {
          case BonsoirDiscoveryServiceFoundEvent(:final service):
            service.resolve(discovery!.serviceResolver);
          case BonsoirDiscoveryServiceResolvedEvent(:final service):
            final attrs = service.attributes;
            final hash = attrs[_attrBooksHash];
            final deviceId = attrs[_attrDeviceId];
            final displayName = attrs[_attrDisplayName];
            if (hash == null ||
                hash != booksSetIdHash ||
                deviceId == null ||
                displayName == null) {
              return;
            }
            if (_advertisement?.deviceId == deviceId) return;
            final host =
                preferredPeerHost(service.hostAddresses) ??
                (service.hostname ?? '');
            if (host.isEmpty) return;
            final pv =
                int.tryParse(attrs[_attrProtocol] ?? '') ??
                smaraPeerSyncProtocolVersion;
            if (!controller.isClosed) {
              controller.add(
                DiscoveredPeer(
                  booksSetIdHash: hash,
                  deviceDisplayName: displayName,
                  deviceId: deviceId,
                  host: host,
                  port: service.port,
                  protocolVersion: pv,
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
}

/// Picks the address to dial from an mDNS resolve: an IPv4 address when there
/// is one (it needs no interface scope and every listener accepts it), else
/// the first address given.
String? preferredPeerHost(List<String> addresses) {
  for (final a in addresses) {
    if (InternetAddress.tryParse(a)?.type == InternetAddressType.IPv4) {
      return a;
    }
  }
  return addresses.isEmpty ? null : addresses.first;
}
