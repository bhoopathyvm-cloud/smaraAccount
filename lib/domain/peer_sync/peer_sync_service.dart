import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';

import '../../data/repositories/membership_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/sync_merge_repository.dart';
import '../linked_devices/device_certificate_store.dart';
import '../linked_devices/erase_on_contact.dart';
import '../linked_devices/local_network_reachability.dart';
import '../models/linked_device.dart';
import 'claim_sync_payloads.dart';
import 'peer_discovery.dart';
import 'direct_address_peer_discovery.dart';
import 'peer_sync_session.dart';
import 'sync_payloads.dart';
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
    Future<void> Function()? wipeActiveBooksCopy,
    this.browseTimeout = const Duration(seconds: 3),
  }) : _transport = transport,
       _discovery = discovery,
       _membership = membership,
       _merge = merge,
       _certificates = certificates,
       _settings = settings,
       _reachability = reachability,
       _activeBooksSetId = activeBooksSetId,
       _wipeActiveBooksCopy = wipeActiveBooksCopy,
       _direct = directDiscovery ?? _extractDirect(discovery);

  final SyncTransport _transport;
  final PeerDiscovery _discovery;
  final MembershipRepository _membership;
  final SyncMergeRepository _merge;
  final DeviceCertificateStore _certificates;
  final SettingsRepository _settings;
  final LocalNetworkReachability _reachability;
  final Future<String?> Function() _activeBooksSetId;
  final Future<void> Function()? _wipeActiveBooksCopy;
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
  String? _listeningPinSet;

  bool get isListening => _listening;

  /// Upper bound for one peer's whole sync session (handshake plus exchange).
  /// A peer that stops answering mid-exchange, or never completes the TLS
  /// handshake (e.g. a just-removed device), must not block syncing with
  /// every other peer; a real-device run froze here for 14 minutes.
  static const peerSessionTimeout = Duration(seconds: 60);

  /// Port last bound by [startForeground] / [startListening], if any.
  /// Used by company-sync to publish a direct-address fallback when mDNS
  /// between simulators and the host is unreliable.
  int? get boundPort => _boundPort;

  /// Active members plus erase-pending devices (still need one contact).
  Future<List<LinkedDevice>> _syncEligibleDevices() async {
    final all = await _membership.listDevices();
    return all
        .where((d) => d.isActive || d.isErasePending)
        .toList(growable: false);
  }

  PeerSyncSessionHooks _hooks() {
    return PeerSyncSessionHooks(
      filterOutboundEntries: _filterOutboundEntries,
      filterOutboundClaims: _filterOutboundClaims,
      filterOutboundMetadata: _filterOutboundMetadata,
      afterPeerMetadataApplied: _afterPeerMetadataApplied,
    );
  }

  Future<EntryBatch> _filterOutboundEntries(
    EntryBatch batch,
    String remoteDeviceId,
  ) async {
    final remote = await _membership.findByDeviceId(remoteDeviceId);
    if (remote == null || !remote.isClaimantOnly) return batch;
    final allowed = await _merge.allowedAccountIdsForClaimant(remoteDeviceId);
    return ClaimantSyncFilter.filterEntryBatch(
      batch: batch,
      allowedAccountIds: allowed,
    );
  }

  Future<ClaimBatch> _filterOutboundClaims(
    ClaimBatch batch,
    String remoteDeviceId,
  ) async {
    final remote = await _membership.findByDeviceId(remoteDeviceId);
    if (remote == null || !remote.isClaimantOnly) return batch;
    return ClaimantSyncFilter.filterClaims(
      batch: batch,
      claimantDeviceId: remoteDeviceId,
    );
  }

  Future<List<MetadataOperation>> _filterOutboundMetadata(
    List<MetadataOperation> ops,
    String remoteDeviceId,
  ) async {
    final remote = await _membership.findByDeviceId(remoteDeviceId);
    if (remote == null || !remote.isClaimantOnly) return ops;
    // Claimant: self membership + allowlist/hints + lifecycle for self, and
    // only categories plus its own Owed-to account (never the bank).
    final visibleAccounts = await _merge.accountIdsVisibleToClaimant(
      owedToAccountId: remote.owedToAccountId,
    );
    return ops.where((op) {
      if (op.entityType == 'account') {
        return visibleAccounts.contains(op.entityId);
      }
      if (op.entityType == 'linked_device') {
        return op.entityId == remoteDeviceId;
      }
      if (op.entityType == 'personal_claim_limit') {
        return op.entityId == remoteDeviceId ||
            (op.value is Map &&
                (op.value as Map)['personDeviceId'] == remoteDeviceId);
      }
      if (op.entityType == 'claim_category_allowlist' ||
          op.entityType == 'category' ||
          op.entityType == 'settings') {
        return true;
      }
      return true;
    }).toList();
  }

  Future<List<MetadataOperation>> _afterPeerMetadataApplied() async {
    final localDeviceId = await _settings.localDeviceId();
    if (localDeviceId == null || localDeviceId.isEmpty) {
      return const [];
    }
    // Ensure Claimant-only merge can accept further scoped gaps even when
    // the batch omits per-entry anchors after the first.
    _merge.localDeviceIdResolver = () async => localDeviceId;

    final wipe = _wipeActiveBooksCopy;
    final erasedAt = await EraseOnContact.maybeEraseLocalCopy(
      membership: _membership,
      localDeviceId: localDeviceId,
      wipeLocalBooksCopy: () async {
        if (wipe != null) {
          await wipe();
        } else {
          // Harness / tests without a books-set wipe: clear ledger tables.
          await _merge.wipeLocalLedgerForErase();
        }
      },
    );
    if (erasedAt == null) return const [];

    await EraseOnContact.acknowledgeErased(
      membership: _membership,
      targetDeviceId: localDeviceId,
      erasedAt: erasedAt,
    );

    final identity = await _merge.pendingMetadataOperations();
    // Prefer a fresh erasedAt op for self from synthesized lifecycle.
    return identity
        .where(
          (op) =>
              op.entityType == 'linked_device' &&
              op.entityId == localDeviceId &&
              (op.field == 'erasedAt' ||
                  op.field == 'erasePendingAt' ||
                  op.field == 'removedAt'),
        )
        .toList();
  }

  /// Starts accepting inbound sync sessions and advertising on `_smara._tcp`.
  Future<void> startForeground() async {
    final localDeviceId = await _settings.localDeviceId();
    if (localDeviceId == null || localDeviceId.isEmpty) return;

    final booksSetId = await _activeBooksSetId();
    if (booksSetId == null || booksSetId.isEmpty) return;

    final devices = await _syncEligibleDevices();
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
    final pinnedCerts = await _pinnedCertificates(localCert, devices);
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
      pinnedCertificates: pinnedCerts,
      hooks: _hooks(),
    );

    final pinSet =
        '${(pins.toList()..sort()).join('|')}|certs:${pinnedCerts.length}';
    // Keep the bound port stable when membership (pin set) is unchanged so
    // peers that already cached our direct-address port can still connect.
    // Re-bind only when pins grow (new Claimant/Approver) so TLS accepts them.
    if (_listening && _listeningPinSet == pinSet && _boundPort != null) {
      try {
        await _advertise(
          booksSetId: booksSetId,
          localDeviceId: localDeviceId,
          port: _boundPort!,
        );
      } catch (_) {
        await _advertiseDirectOnly(
          booksSetId: booksSetId,
          localDeviceId: localDeviceId,
          port: _boundPort!,
        );
      }
      return;
    }

    await stop();
    await session.startListening(
      onCompleted: (_) {},
      onBound: (port) => _boundPort = port,
    );
    _listening = true;
    _listeningPinSet = pinSet;
    try {
      await _advertise(
        booksSetId: booksSetId,
        localDeviceId: localDeviceId,
        port: _boundPort ?? 0,
      );
    } catch (_) {
      await _advertiseDirectOnly(
        booksSetId: booksSetId,
        localDeviceId: localDeviceId,
        port: _boundPort ?? 0,
      );
    }
  }

  Future<void> _advertiseDirectOnly({
    required String booksSetId,
    required String localDeviceId,
    required int port,
  }) async {
    final direct = _direct;
    if (direct == null) return;
    final displayName =
        await _settings.localDeviceDisplayName() ?? 'This device';
    final hash = await booksSetIdHash(booksSetId);
    await direct.startAdvertising(
      PeerAdvertisement(
        booksSetIdHash: hash,
        deviceDisplayName: displayName,
        deviceId: localDeviceId,
        port: port,
      ),
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
    _listeningPinSet = null;
  }

  /// Finds linked peers on the LAN and exchanges missing journal entries.
  Future<List<SyncSessionResult>> syncNow() async {
    final localDeviceId = await _settings.localDeviceId();
    if (localDeviceId == null || localDeviceId.isEmpty) {
      return const [];
    }
    _merge.localDeviceIdResolver = () async => localDeviceId;
    final booksSetId = await _activeBooksSetId();
    if (booksSetId == null || booksSetId.isEmpty) {
      return const [];
    }

    await startForeground();

    final devices = await _syncEligibleDevices();
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
    final pinnedCerts = await _pinnedCertificates(localCert, devices);
    final hash = await booksSetIdHash(booksSetId);

    final found = <String, DiscoveredPeer>{};
    final sub = _discovery.browse(booksSetIdHash: hash).listen((peer) {
      if (peersById.containsKey(peer.deviceId)) {
        found[peer.deviceId] = peer;
      }
    });
    await Future<void>.delayed(browseTimeout);
    await sub.cancel();

    // Permission-gated Bonjour browse yields nothing when local-network
    // permission is denied; still surface connect-by-address peers.
    final direct = _direct;
    if (direct != null) {
      final directSeen = <DiscoveredPeer>[];
      final directSub = direct
          .browse(booksSetIdHash: hash)
          .listen(directSeen.add);
      await Future<void>.delayed(Duration.zero);
      await directSub.cancel();
      for (final peer in directSeen) {
        if (peersById.containsKey(peer.deviceId)) {
          found[peer.deviceId] = peer;
        }
      }
    }

    if (kDebugMode) {
      debugPrint(
        '[PeerSync] syncNow: linked=${peersById.keys.toList()} '
        'found on Wi-Fi=${found.values.map((p) => '${p.deviceId}@${p.host}:${p.port}').toList()}',
      );
    }
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
      pinnedCertificates: pinnedCerts,
      hooks: _hooks(),
    );

    final results = <SyncSessionResult>[];
    for (final peer in found.values) {
      final membership = peersById[peer.deviceId]!;
      final remoteCert =
          await _certificates.certificateForFingerprint(
            membership.deviceCertFingerprint,
          ) ??
          DeviceCertificate(
            derBytes: const [],
            fingerprint: membership.deviceCertFingerprint,
          );
      try {
        final result = await session
            .syncNow(
              remote: SyncPeerIdentity(
                deviceId: peer.deviceId,
                certificate: remoteCert,
                host: peer.host,
                port: peer.port,
              ),
              peerHint: peer.host,
            )
            .timeout(peerSessionTimeout);
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
      } catch (e) {
        // Mid-exchange disconnects ("Sync connection is closed") must not
        // escape as unhandled async errors during Flutter tests.
        results.add(
          SyncSessionResult(
            connected: false,
            entriesSent: 0,
            entriesReceived: 0,
            refusedReason: 'Sync with ${peer.deviceDisplayName} failed: $e',
          ),
        );
      }
    }
    if (kDebugMode) {
      for (final r in results) {
        debugPrint(
          '[PeerSync] result: connected=${r.connected} '
          'sent=${r.entriesSent} received=${r.entriesReceived} '
          'reason=${r.refusedReason}',
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
    final devices = await _syncEligibleDevices();
    final peer = devices.where((d) => d.deviceId == peerDeviceId);
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

  /// Local cert plus peer public certs remembered at join. BoringSSL rejects
  /// inbound client certs that are not in the server trust store even when
  /// [SecureServerSocket.requireClientCertificate] is false.
  Future<List<DeviceCertificate>> _pinnedCertificates(
    DeviceCertificate localCert,
    List<LinkedDevice> devices,
  ) async {
    final out = <DeviceCertificate>[localCert];
    final seen = <String>{localCert.fingerprint};
    for (final device in devices) {
      final fp = device.deviceCertFingerprint;
      if (!seen.add(fp)) continue;
      final peer = await _certificates.certificateForFingerprint(fp);
      if (peer != null) out.add(peer);
    }
    return out;
  }
}
