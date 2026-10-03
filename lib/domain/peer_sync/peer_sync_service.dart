import 'dart:async';
import 'dart:io';

import '../../data/repositories/membership_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/sync_merge_repository.dart';
import '../linked_devices/device_certificate_store.dart';
import '../linked_devices/local_network_reachability.dart';
import 'peer_discovery.dart';
import 'direct_address_peer_discovery.dart';
import 'peer_sync_session.dart';
import 'sync_transport.dart';

/// Wires discovery + TLS transport + [PeerSyncSession] for Sync now and
/// automatic catch-up while the app is foregrounded (task 12.4 / real-sync 3.2).
class PeerSyncService {
  PeerSyncService({
    required SyncTransport transport,
    required PeerDiscovery discovery,
    required MembershipRepository membership,
    required SyncMergeRepository merge,
    required DeviceCertificateStore certificates,
    required SettingsRepository settings,
    required LocalNetworkReachability reachability,
    required Future<String?> Function() activeBooksSetId,
    DirectAddressPeerDiscovery? directDiscovery,
    this.browseTimeout = const Duration(seconds: 3),
  }) : _transport = transport,
       _discovery = discovery,
       _membership = membership,
       _merge = merge,
       _certificates = certificates,
       _settings = settings,
       _reachability = reachability,
       _activeBooksSetId = activeBooksSetId,
       _direct = directDiscovery ?? _extractDirect(discovery);

  final SyncTransport _transport;
  final PeerDiscovery _discovery;
  final MembershipRepository _membership;
  final SyncMergeRepository _merge;
  final DeviceCertificateStore _certificates;
  final SettingsRepository _settings;
  final LocalNetworkReachability _reachability;
  final Future<String?> Function() _activeBooksSetId;
  final DirectAddressPeerDiscovery? _direct;

  static DirectAddressPeerDiscovery? _extractDirect(PeerDiscovery discovery) {
    if (discovery is DirectAddressPeerDiscovery) return discovery;
    if (discovery is CompositePeerDiscovery) return discovery.direct;
    if (discovery is PermissionGatedPeerDiscovery) {
      return _extractDirect(discovery.inner);
    }
    return null;
  }

  /// How long Sync now waits for mDNS / direct peers before connecting.
  final Duration browseTimeout;

  bool _listening = false;
  int? _boundPort;
  String? _listeningDeviceId;

  bool get isListening => _listening;

  /// Starts accepting inbound sync sessions and advertising on `_smara._tcp`.
  Future<void> startForeground() async {
    final localDeviceId = await _settings.localDeviceId();
    if (localDeviceId == null || localDeviceId.isEmpty) return;

    final booksSetId = await _activeBooksSetId();
    if (booksSetId == null || booksSetId.isEmpty) return;

    final devices = await _membership.listActiveDevices();
    if (devices.length < 2) {
      // Nothing to sync with — still fine to skip listen/advertise.
      return;
    }

    final localCert = await _certificates.localCertificate(
      deviceId: localDeviceId,
    );
    final pins = {
      for (final d in devices) d.deviceCertFingerprint,
      localCert.fingerprint,
    };
    final localIdentity = SyncPeerIdentity(
      deviceId: localDeviceId,
      certificate: localCert,
    );

    final session = PeerSyncSession(
      transport: _transport,
      ledger: _merge,
      reachability: _reachability,
      localIdentity: localIdentity,
      pinnedFingerprints: pins,
      pinnedCertificates: [localCert],
    );

    if (_listening && _listeningDeviceId == localDeviceId) {
      await _advertise(
        booksSetId: booksSetId,
        localDeviceId: localDeviceId,
        port: _boundPort ?? 0,
      );
      return;
    }

    await stop();
    await session.startListening(
      onCompleted: (_) {},
      onBound: (port) => _boundPort = port,
    );
    _listening = true;
    _listeningDeviceId = localDeviceId;
    await _advertise(
      booksSetId: booksSetId,
      localDeviceId: localDeviceId,
      port: _boundPort ?? 0,
    );
  }

  Future<void> stop() async {
    try {
      await _discovery.stopAdvertising();
    } catch (_) {}
    try {
      await _transport.stopListening();
    } catch (_) {}
    _listening = false;
    _boundPort = null;
    _listeningDeviceId = null;
  }

  /// Finds linked peers on the LAN and exchanges missing journal entries.
  Future<List<SyncSessionResult>> syncNow() async {
    final localDeviceId = await _settings.localDeviceId();
    if (localDeviceId == null || localDeviceId.isEmpty) {
      return const [];
    }
    final booksSetId = await _activeBooksSetId();
    if (booksSetId == null || booksSetId.isEmpty) {
      return const [];
    }

    await startForeground();

    final devices = await _membership.listActiveDevices();
    final peersById = {
      for (final d in devices)
        if (d.deviceId != localDeviceId) d.deviceId: d,
    };
    if (peersById.isEmpty) return const [];

    final localCert = await _certificates.localCertificate(
      deviceId: localDeviceId,
    );
    final pins = {
      for (final d in devices) d.deviceCertFingerprint,
      localCert.fingerprint,
    };
    final hash = await booksSetIdHash(booksSetId);

    final found = <String, DiscoveredPeer>{};
    final sub = _discovery.browse(booksSetIdHash: hash).listen((peer) {
      if (peersById.containsKey(peer.deviceId)) {
        found[peer.deviceId] = peer;
      }
    });
    await Future<void>.delayed(browseTimeout);
    await sub.cancel();

    if (found.isEmpty) {
      return [
        const SyncSessionResult(
          connected: false,
          entriesSent: 0,
          entriesReceived: 0,
          refusedReason:
              'No linked device found on this Wi-Fi. Open Smara on the '
              'other device and try Sync now again.',
        ),
      ];
    }

    final session = PeerSyncSession(
      transport: _transport,
      ledger: _merge,
      reachability: _reachability,
      localIdentity: SyncPeerIdentity(
        deviceId: localDeviceId,
        certificate: localCert,
      ),
      pinnedFingerprints: pins,
      pinnedCertificates: [localCert],
    );

    final results = <SyncSessionResult>[];
    for (final peer in found.values) {
      final membership = peersById[peer.deviceId]!;
      try {
        final result = await session.syncNow(
          remote: SyncPeerIdentity(
            deviceId: peer.deviceId,
            certificate: DeviceCertificate(
              derBytes: const [],
              fingerprint: membership.deviceCertFingerprint,
            ),
            host: peer.host,
            port: peer.port,
          ),
          peerHint: peer.host,
        );
        results.add(result);
      } on SocketException catch (e) {
        results.add(
          SyncSessionResult(
            connected: false,
            entriesSent: 0,
            entriesReceived: 0,
            refusedReason: 'Could not reach ${peer.deviceDisplayName}: $e',
          ),
        );
      } on UnknownCertificateException catch (e) {
        results.add(
          SyncSessionResult(
            connected: false,
            entriesSent: 0,
            entriesReceived: 0,
            refusedReason: e.toString(),
          ),
        );
      }
    }
    return results;
  }

  /// Automatic catch-up when the app returns to the foreground.
  Future<List<SyncSessionResult>> onAppResumed() => syncNow();

  /// Registers a linked peer at [host]:[port] when mDNS is blocked (task 2.3).
  Future<void> connectByAddress({
    required String peerDeviceId,
    required String host,
    required int port,
  }) async {
    final direct = _direct;
    if (direct == null) {
      throw StateError('Direct-address discovery is not available.');
    }
    final booksSetId = await _activeBooksSetId();
    if (booksSetId == null || booksSetId.isEmpty) {
      throw StateError('No active books set.');
    }
    final devices = await _membership.listActiveDevices();
    final peer = devices.where((d) => d.deviceId == peerDeviceId && d.isActive);
    if (peer.isEmpty) {
      throw StateError('Unknown linked device: $peerDeviceId');
    }
    final hash = await booksSetIdHash(booksSetId);
    direct.addDirectPeer(
      DiscoveredPeer(
        booksSetIdHash: hash,
        deviceDisplayName: peer.first.displayName,
        deviceId: peerDeviceId,
        host: host.trim(),
        port: port,
      ),
    );
  }

  Future<void> _advertise({
    required String booksSetId,
    required String localDeviceId,
    required int port,
  }) async {
    final displayName =
        await _settings.localDeviceDisplayName() ?? 'This device';
    final hash = await booksSetIdHash(booksSetId);
    await _discovery.startAdvertising(
      PeerAdvertisement(
        booksSetIdHash: hash,
        deviceDisplayName: displayName,
        deviceId: localDeviceId,
        port: port,
      ),
    );
  }
}
