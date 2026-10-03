import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../linked_devices/device_certificate_store.dart';
import 'certificate_pinning.dart';
import 'sync_payloads.dart';
import 'sync_transport.dart';

/// Length-prefixed JSON over [SecureSocket] with certificate pinning
/// (linked-devices task 12.1 / design Decision 2).
class TlsSyncTransport implements SyncTransport {
  TlsSyncTransport({InternetAddress? bindAddress})
    : bindAddress = bindAddress ?? InternetAddress.anyIPv4;

  final InternetAddress bindAddress;

  SecureServerSocket? _server;
  StreamSubscription<SecureSocket>? _acceptSub;

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

    // Trust anchors are optional: [onBadCertificate] enforces the pin set so
    // Sync now can connect using only fingerprints from membership.
    final context = _securityContext(
      local.certificate,
      pinnedCertificates: [
        ...pinnedCertificates,
        if (remote.certificate.derBytes.isNotEmpty ||
            remote.certificate.certificatePem != null)
          remote.certificate,
        local.certificate,
      ],
    );
    final socket = await SecureSocket.connect(
      host,
      port,
      context: context,
      onBadCertificate: (X509Certificate cert) {
        final fp = fingerprintOfDer(cert.der);
        return pinning.checkFingerprint(fp) == PinCheckResult.accepted;
      },
    );

    final peerCert = socket.peerCertificate;
    if (peerCert == null) {
      await socket.close();
      throw StateError('TLS peer presented no certificate.');
    }
    final peerFp = fingerprintOfDer(peerCert.der);
    if (pinning.checkFingerprint(peerFp) != PinCheckResult.accepted) {
      await socket.close();
      throw UnknownCertificateException(peerFp);
    }

    return _TlsSyncConnection(socket: socket, remote: remote);
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
    // Request (but do not require) a client cert so peers that only have
    // fingerprints in membership still pin-check after the handshake —
    // OS TLS would refuse unknown client certs if requireClientCertificate
    // were true without peer PEMs in the trust store.
    final context = _securityContext(
      local.certificate,
      pinnedCertificates: [...pinnedCertificates, local.certificate],
    );
    final pinning = CertificatePinning(pinnedFingerprints: pinnedFingerprints);

    _server = await SecureServerSocket.bind(
      bindAddress,
      bindPort ?? 0,
      context,
      requestClientCertificate: true,
      requireClientCertificate: false,
    );
    onBound?.call(_server!.port);

    _acceptSub = _server!.listen((socket) async {
      try {
        final peerCert = socket.peerCertificate;
        if (peerCert == null) {
          await socket.close();
          return;
        }
        final fp = fingerprintOfDer(peerCert.der);
        if (pinning.checkFingerprint(fp) != PinCheckResult.accepted) {
          await socket.close();
          return;
        }
        final remote = SyncPeerIdentity(
          deviceId: 'peer-$fp',
          certificate: DeviceCertificate(
            derBytes: peerCert.der,
            fingerprint: fp,
          ),
          host: socket.remoteAddress.address,
          port: socket.remotePort,
        );
        await onSession(_TlsSyncConnection(socket: socket, remote: remote));
      } catch (_) {
        try {
          await socket.close();
        } catch (_) {}
      }
    });
  }

  @override
  Future<void> stopListening() async {
    await _acceptSub?.cancel();
    _acceptSub = null;
    await _server?.close();
    _server = null;
  }

  static SecurityContext _securityContext(
    DeviceCertificate cert, {
    required List<DeviceCertificate> pinnedCertificates,
  }) {
    final pem = cert.certificatePem;
    final key = cert.privateKeyPem;
    if (pem == null || key == null) {
      throw StateError(
        'TlsSyncTransport requires local certificatePem and privateKeyPem.',
      );
    }
    final context = SecurityContext(withTrustedRoots: false);
    context.useCertificateChainBytes(utf8.encode(pem));
    context.usePrivateKeyBytes(utf8.encode(key));
    final seen = <String>{};
    for (final peer in pinnedCertificates) {
      final peerPem = peer.certificatePem ?? derToPem(peer.derBytes);
      if (!seen.add(peerPem)) continue;
      try {
        context.setTrustedCertificatesBytes(utf8.encode(peerPem));
      } catch (_) {
        // Duplicate / already-trusted certs can throw; safe to ignore.
      }
    }
    return context;
  }

  /// PEM-encode DER certificate bytes for [SecurityContext] trust anchors.
  static String derToPem(List<int> derBytes) {
    final b64 = base64Encode(derBytes);
    final buffer = StringBuffer('-----BEGIN CERTIFICATE-----\n');
    for (var i = 0; i < b64.length; i += 64) {
      final end = (i + 64 < b64.length) ? i + 64 : b64.length;
      buffer.writeln(b64.substring(i, end));
    }
    buffer.write('-----END CERTIFICATE-----\n');
    return buffer.toString();
  }

  /// SHA-256 hex of DER bytes — same format as [CertificatePinning.fingerprintOf].
  static String fingerprintOfDer(List<int> derBytes) {
    return sha256.convert(derBytes).toString();
  }
}

class _TlsSyncConnection implements SyncConnection {
  _TlsSyncConnection({required this.socket, required this.remote}) {
    _subscription = socket.listen(
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

  final SecureSocket socket;

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
    socket.add(header.buffer.asUint8List());
    socket.add(body);
    await socket.flush();
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
    try {
      await socket.close();
    } catch (_) {}
  }
}
