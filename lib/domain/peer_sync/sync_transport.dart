import 'dart:async';
import 'dart:convert';

import '../linked_devices/device_certificate_store.dart';
import 'certificate_pinning.dart';
import 'sync_payloads.dart';

/// Peer identity presented when opening a sync session.
class SyncPeerIdentity {
  const SyncPeerIdentity({
    required this.deviceId,
    required this.certificate,
    this.host,
    this.port,
  });

  final String deviceId;
  final DeviceCertificate certificate;

  /// LAN address for [TlsSyncTransport.connect]. Ignored by in-process.
  final String? host;

  /// LAN port for [TlsSyncTransport.connect]. Ignored by in-process.
  final int? port;
}

/// One direction of a pinned sync session (design Decision 2).
abstract class SyncConnection {
  SyncPeerIdentity get remote;

  Future<void> send(Map<String, Object?> message);

  /// Next message from the peer (ordered, buffered). Prefer this over a raw
  /// stream so tip/batch exchanges can await sequentially.
  Future<Map<String, dynamic>> receive();

  Future<void> close();
}

/// TLS sync transport with certificate pinning. [InProcessSyncTransport]
/// covers CI without sockets; [TlsSyncTransport] uses SecureSocket on the LAN.
abstract class SyncTransport {
  /// Connects to [remote], presenting [local] and requiring [remote]'s
  /// certificate fingerprint to be in [pinnedFingerprints].
  ///
  /// Real transports also require [remote.host] and [remote.port].
  /// [pinnedCertificates] supplies PEM/DER material so TLS can trust peers
  /// without a public CA (task 12.1).
  Future<SyncConnection> connect({
    required SyncPeerIdentity local,
    required SyncPeerIdentity remote,
    required Set<String> pinnedFingerprints,
    List<DeviceCertificate> pinnedCertificates = const [],
  });

  /// Accepts inbound sessions from peers whose certs are pinned.
  ///
  /// When [bindPort] is null, the implementation picks an ephemeral port.
  /// [onBound] receives the actual listening port (for mDNS advertising).
  /// Implementations MUST await [onSession] so the peer's exchange finishes
  /// before the connector's session completes.
  Future<void> listen({
    required SyncPeerIdentity local,
    required Set<String> pinnedFingerprints,
    required Future<void> Function(SyncConnection connection) onSession,
    int? bindPort,
    void Function(int port)? onBound,
    List<DeviceCertificate> pinnedCertificates = const [],
  });

  Future<void> stopListening();
}

/// Thrown when a peer presents a certificate that was not exchanged at join.
class UnknownCertificateException implements Exception {
  UnknownCertificateException(this.fingerprint);

  final String fingerprint;

  @override
  String toString() =>
      'UnknownCertificateException: refused fingerprint $fingerprint';
}

/// In-process duplex transport for unit tests. No internet; peers must share
/// the same [networkId] (remote-network fakes use a different id).
class InProcessSyncTransport implements SyncTransport {
  InProcessSyncTransport({this.networkId = 'lan'});

  final String networkId;

  /// networkId → deviceId → listening endpoint.
  static final Map<String, Map<String, _ListeningEndpoint>> _listeners = {};

  String? _listeningDeviceId;

  @override
  Future<SyncConnection> connect({
    required SyncPeerIdentity local,
    required SyncPeerIdentity remote,
    required Set<String> pinnedFingerprints,
    List<DeviceCertificate> pinnedCertificates = const [],
  }) async {
    final pinning = CertificatePinning(pinnedFingerprints: pinnedFingerprints);
    final remoteCheck = await _pinCheck(pinning, remote.certificate);
    if (remoteCheck == PinCheckResult.refusedUnknown) {
      throw UnknownCertificateException(remote.certificate.fingerprint);
    }

    final onNetwork = _listeners[networkId];
    final listener = onNetwork?[remote.deviceId];
    if (listener == null) {
      throw StateError(
        'No peer listening for device "${remote.deviceId}" on network '
        '"$networkId" — devices must be on the same local network '
        '(no internet relay).',
      );
    }

    final listenerPinning = CertificatePinning(
      pinnedFingerprints: listener.pinnedFingerprints,
    );
    final localCheck = await _pinCheck(listenerPinning, local.certificate);
    if (localCheck == PinCheckResult.refusedUnknown) {
      throw UnknownCertificateException(local.certificate.fingerprint);
    }

    final callerSide = _InProcessConnection(remote: remote);
    final listenerSide = _InProcessConnection(remote: local);
    callerSide._peer = listenerSide;
    listenerSide._peer = callerSide;

    // Run the listener exchange concurrently so tip/batch handshakes can
    // proceed, but wait until it settles once the caller finishes.
    final listenerDone = listener.onSession(listenerSide);
    return callerSide.._listenerDone = listenerDone;
  }

  /// Fingerprint-only pins (empty DER) are used by Sync now when peer PEM
  /// material is not stored locally; otherwise hash the DER as usual.
  static Future<PinCheckResult> _pinCheck(
    CertificatePinning pinning,
    DeviceCertificate certificate,
  ) {
    if (certificate.derBytes.isEmpty && certificate.fingerprint.isNotEmpty) {
      return Future.value(pinning.checkFingerprint(certificate.fingerprint));
    }
    return pinning.checkCertificate(certificate);
  }

  @override
  Future<void> listen({
    required SyncPeerIdentity local,
    required Set<String> pinnedFingerprints,
    required Future<void> Function(SyncConnection connection) onSession,
    int? bindPort,
    void Function(int port)? onBound,
    List<DeviceCertificate> pinnedCertificates = const [],
  }) async {
    await stopListening();
    _listeningDeviceId = local.deviceId;
    _listeners.putIfAbsent(
      networkId,
      () => {},
    )[local.deviceId] = _ListeningEndpoint(
      local: local,
      pinnedFingerprints: pinnedFingerprints,
      onSession: onSession,
    );
    onBound?.call(bindPort ?? 0);
  }

  @override
  Future<void> stopListening() async {
    final deviceId = _listeningDeviceId;
    if (deviceId != null) {
      _listeners[networkId]?.remove(deviceId);
      if (_listeners[networkId]?.isEmpty ?? false) {
        _listeners.remove(networkId);
      }
    }
    _listeningDeviceId = null;
  }

  /// Test helper: clear all in-process listeners.
  static void resetAll() {
    _listeners.clear();
  }
}

class _ListeningEndpoint {
  _ListeningEndpoint({
    required this.local,
    required this.pinnedFingerprints,
    required this.onSession,
  });

  final SyncPeerIdentity local;
  final Set<String> pinnedFingerprints;
  final Future<void> Function(SyncConnection connection) onSession;
}

class _InProcessConnection implements SyncConnection {
  _InProcessConnection({required this.remote});

  @override
  final SyncPeerIdentity remote;

  _InProcessConnection? _peer;
  Future<void>? _listenerDone;
  final _pending = <Map<String, dynamic>>[];
  final _waiters = <Completer<Map<String, dynamic>>>[];
  bool _closed = false;

  void _deliver(Map<String, dynamic> message) {
    if (_waiters.isNotEmpty) {
      _waiters.removeAt(0).complete(message);
    } else {
      _pending.add(message);
    }
  }

  @override
  Future<Map<String, dynamic>> receive() async {
    if (_closed) {
      throw StateError('Sync connection is closed.');
    }
    if (_pending.isNotEmpty) {
      return _pending.removeAt(0);
    }
    final waiter = Completer<Map<String, dynamic>>();
    _waiters.add(waiter);
    return waiter.future;
  }

  @override
  Future<void> send(Map<String, Object?> message) async {
    if (_closed) {
      throw StateError('Sync connection is closed.');
    }
    final peer = _peer;
    if (peer == null || peer._closed) {
      throw StateError('Peer sync connection is closed.');
    }
    // Round-trip through JSON to catch non-encodable private-key types early
    // and to match on-wire shape.
    final encoded = jsonEncode(message);
    if (syncPayloadContainsPrivateKeyMaterial(encoded)) {
      throw FormatException(
        'Sync payload must not include private key material.',
      );
    }
    final decoded = Map<String, dynamic>.from(jsonDecode(encoded) as Map);
    peer._deliver(decoded);
  }

  @override
  Future<void> close() async {
    _closed = true;
    for (final waiter in _waiters) {
      if (!waiter.isCompleted) {
        waiter.completeError(StateError('Sync connection is closed.'));
      }
    }
    _waiters.clear();
    final listenerDone = _listenerDone;
    if (listenerDone != null) {
      await listenerDone;
    }
  }
}
