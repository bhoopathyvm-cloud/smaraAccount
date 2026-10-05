import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../crypto/dart_crypto_backend.dart';
import '../linked_devices/device_certificate_store.dart';
import 'certificate_pinning.dart';
import 'dart_tls_socket_factory.dart';
import 'sync_payloads.dart';
import 'sync_transport.dart';
import 'tls_socket.dart';

export 'dart_tls_socket_factory.dart' show tlsSyncDebugLog;

/// Length-prefixed JSON over a pinned TLS byte stream (linked-devices task
/// 12.1 / design Decision 2).
///
/// The socket underneath comes from a [TlsSocketFactory]: BoringSSL through
/// `dart:io` on Android, Windows and Linux, the Network framework on iOS and
/// macOS. Framing, the fingerprint pin check and its refusal reasons are
/// the same on every platform, so any device syncs with any other.
class TlsSyncTransport implements SyncTransport {
  TlsSyncTransport({this.bindAddress, TlsSocketFactory? sockets})
    : _sockets = sockets;

  /// Where to listen. When null the listener is dual-stack (IPv6 and IPv4),
  /// because mDNS often resolves a peer to its IPv6 link-local address first;
  /// it falls back to IPv4 only where IPv6 is unavailable.
  final InternetAddress? bindAddress;

  final TlsSocketFactory? _sockets;

  TlsSocketFactory get sockets => _sockets ?? TlsSocketFactory.forPlatform();

  TlsListenerHandle? _listener;

  @override
  Future<SyncConnection> connect({
    required SyncPeerIdentity local,
    required SyncPeerIdentity remote,
    required Set<String> pinnedFingerprints,
    List<DeviceCertificate> pinnedCertificates = const [],
  }) async {
    final host = remote.host;
    final port = remote.port;
    if (host == null || port == null) {
      throw StateError(
        'TlsSyncTransport.connect requires remote.host and remote.port.',
      );
    }

    final pinning = CertificatePinning(pinnedFingerprints: pinnedFingerprints);
    if (remote.certificate.fingerprint.isNotEmpty &&
        pinning.checkFingerprint(remote.certificate.fingerprint) ==
            PinCheckResult.refusedUnknown) {
      throw UnknownCertificateException(remote.certificate.fingerprint);
    }

    // Prefer peer PEMs in the trust store when known (from join). The
    // verifier still enforces the fingerprint pin set so connect works when
    // only the remote fingerprint is known.
    String? refused;
    final stream = await sockets
        .connect(
          host: host,
          port: port,
          localIdentity: local.certificate,
          trustedPeerCertificates: [
            ...pinnedCertificates,
            if (remote.certificate.derBytes.isNotEmpty ||
                remote.certificate.certificatePem != null)
              remote.certificate,
            local.certificate,
          ],
          verifyPeer: (peer) {
            final ok =
                pinning.checkFingerprint(peer.fingerprint) ==
                PinCheckResult.accepted;
            if (!ok) refused = peer.fingerprint;
            return ok;
          },
        )
        .catchError((Object e) {
          final fingerprint = refused;
          if (fingerprint != null) {
            throw UnknownCertificateException(fingerprint);
          }
          throw e;
        });

    final peer = stream.peerCertificate;
    if (peer == null) {
      await stream.close();
      throw StateError('TLS peer presented no certificate.');
    }
    if (pinning.checkFingerprint(peer.fingerprint) != PinCheckResult.accepted) {
      await stream.close();
      throw UnknownCertificateException(peer.fingerprint);
    }

    return _TlsSyncConnection(stream: stream, remote: remote);
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
    final pinning = CertificatePinning(pinnedFingerprints: pinnedFingerprints);
    _listener = await sockets.listen(
      localIdentity: local.certificate,
      port: bindPort ?? 0,
      bindAddress: bindAddress,
      // Request a client cert and pin-check it; peer PEMs come from
      // [pinnedCertificates] (remembered at join).
      requestClientCertificate: true,
      trustedPeerCertificates: pinnedCertificates,
      verifyPeer: (peer) {
        final ok =
            pinning.checkFingerprint(peer.fingerprint) ==
            PinCheckResult.accepted;
        if (!ok) {
          tlsSyncDebugLog?.call(
            'inbound TLS rejected: unknown fingerprint ${peer.fingerprint} '
            '(pins=${pinnedFingerprints.length})',
          );
        }
        return ok;
      },
      onConnection: (stream) async {
        try {
          final peer = stream.peerCertificate;
          if (peer == null) {
            tlsSyncDebugLog?.call(
              'inbound TLS rejected: no client certificate',
            );
            await stream.close();
            return;
          }
          if (pinning.checkFingerprint(peer.fingerprint) !=
              PinCheckResult.accepted) {
            tlsSyncDebugLog?.call(
              'inbound TLS rejected: unknown fingerprint ${peer.fingerprint} '
              '(pins=${pinnedFingerprints.length})',
            );
            await stream.close();
            return;
          }
          final remote = SyncPeerIdentity(
            deviceId: 'peer-${peer.fingerprint}',
            certificate: DeviceCertificate(
              derBytes: peer.der,
              fingerprint: peer.fingerprint,
            ),
            host: stream.remoteAddress,
            port: stream.remotePort,
          );
          await onSession(_TlsSyncConnection(stream: stream, remote: remote));
        } catch (e, st) {
          tlsSyncDebugLog?.call('inbound TLS session error: $e\n$st');
          await stream.close();
        }
      },
    );
    onBound?.call(_listener!.port);
  }

  @override
  Future<void> stopListening() async {
    final listener = _listener;
    _listener = null;
    await listener?.close();
  }

  /// PEM-encode DER certificate bytes for [SecurityContext] trust anchors.
  static String derToPem(List<int> derBytes) =>
      DartTlsSocketFactory.derToPem(derBytes);

  /// Synchronous SHA-256 hex of DER bytes — same format as
  /// [CertificatePinning.fingerprintOf]. Dart-backend only (tests and the
  /// Dart identity store); on Apple platforms fingerprints come from the
  /// Network-framework socket or [CertificatePinning.fingerprintOf].
  static String fingerprintOfDer(List<int> derBytes) =>
      DartCryptoBackend.sha256HexSync(derBytes);
}

class _TlsSyncConnection implements SyncConnection {
  _TlsSyncConnection({required this.stream, required this.remote}) {
    _subscription = stream.data.listen(
      _onData,
      onError: (Object error, StackTrace st) {
        if (!_closed) {
          for (final waiter in _waiters) {
            if (!waiter.isCompleted) waiter.completeError(error, st);
          }
          _waiters.clear();
        }
      },
      onDone: () {
        _closed = true;
        for (final waiter in _waiters) {
          if (!waiter.isCompleted) {
            waiter.completeError(StateError('Sync connection is closed.'));
          }
        }
        _waiters.clear();
      },
      cancelOnError: false,
    );
  }

  final TlsByteStream stream;

  @override
  final SyncPeerIdentity remote;

  final _pending = <Map<String, dynamic>>[];
  final _waiters = <Completer<Map<String, dynamic>>>[];
  final _buffer = BytesBuilder(copy: false);
  StreamSubscription<List<int>>? _subscription;
  bool _closed = false;

  void _onData(List<int> chunk) {
    _buffer.add(chunk);
    while (true) {
      final bytes = _buffer.toBytes();
      if (bytes.length < 4) return;
      final length = ByteData.sublistView(
        Uint8List.fromList(bytes),
      ).getUint32(0, Endian.big);
      if (bytes.length < 4 + length) return;
      final payload = utf8.decode(bytes.sublist(4, 4 + length));
      final remaining = bytes.sublist(4 + length);
      _buffer.clear();
      if (remaining.isNotEmpty) _buffer.add(remaining);

      if (syncPayloadContainsPrivateKeyMaterial(payload)) {
        for (final waiter in _waiters) {
          if (!waiter.isCompleted) {
            waiter.completeError(
              const FormatException(
                'Sync payload must not include private key material.',
              ),
            );
          }
        }
        _waiters.clear();
        return;
      }
      final decoded = Map<String, dynamic>.from(jsonDecode(payload) as Map);
      if (_waiters.isNotEmpty) {
        _waiters.removeAt(0).complete(decoded);
      } else {
        _pending.add(decoded);
      }
    }
  }

  @override
  Future<Map<String, dynamic>> receive() async {
    if (_closed && _pending.isEmpty) {
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
    final encoded = jsonEncode(message);
    if (syncPayloadContainsPrivateKeyMaterial(encoded)) {
      throw const FormatException(
        'Sync payload must not include private key material.',
      );
    }
    final body = utf8.encode(encoded);
    final header = ByteData(4)..setUint32(0, body.length, Endian.big);
    await stream.send([...header.buffer.asUint8List(), ...body]);
  }

  @override
  Future<void> close() async {
    _closed = true;
    await _subscription?.cancel();
    _subscription = null;
    for (final waiter in _waiters) {
      if (!waiter.isCompleted) {
        waiter.completeError(StateError('Sync connection is closed.'));
      }
    }
    _waiters.clear();
    await stream.close();
  }
}
