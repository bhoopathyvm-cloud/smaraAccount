import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../crypto/dart_crypto_backend.dart';
import '../linked_devices/device_certificate_store.dart';
import 'tls_socket.dart';

/// Optional diagnostic sink for company-sync / integration debugging.
void Function(String message)? tlsSyncDebugLog;

/// [TlsSocketFactory] over `dart:io`'s [SecureSocket] / [SecureServerSocket]
/// (BoringSSL) for Android, Windows and Linux. Not used on iOS or macOS,
/// where [AppleTlsSocketFactory] speaks the same TLS from the Network
/// framework.
class DartTlsSocketFactory extends TlsSocketFactory {
  const DartTlsSocketFactory();

  @override
  String get name => 'dart';

  @override
  Future<TlsByteStream> connect({
    required String host,
    required int port,
    DeviceCertificate? localIdentity,
    List<DeviceCertificate> trustedPeerCertificates = const [],
    required TlsPeerVerifier verifyPeer,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    // Use the platform default SecurityContext when there is nothing to
    // present or trust (join-by-code joiner). An empty custom context broke
    // TLS from the iOS Simulator to the macOS host (handshake never
    // completed); onBadCertificate still lets [verifyPeer] decide.
    final context = localIdentity == null && trustedPeerCertificates.isEmpty
        ? null
        : securityContext(
            localIdentity,
            trustedPeerCertificates: trustedPeerCertificates,
          );
    final socket = await SecureSocket.connect(
      host,
      port,
      context: context,
      // Bounded so one unreachable peer (asleep, off the Wi-Fi, or listed
      // at a cellular address) can't freeze Sync now for over a minute.
      timeout: timeout,
      onBadCertificate: (X509Certificate cert) =>
          verifyPeer(peerCertificateOf(cert)),
    );
    final peer = socket.peerCertificate;
    final stream = _DartTlsByteStream(
      socket,
      peer == null ? null : peerCertificateOf(peer),
    );
    // The handshake only consulted [verifyPeer] for an untrusted chain;
    // ask once more so a certificate BoringSSL trusted on its own is held
    // to the same pin.
    if (stream.peerCertificate != null &&
        !verifyPeer(stream.peerCertificate!)) {
      await stream.close();
      throw const HandshakeException('Peer certificate refused by pin check.');
    }
    return stream;
  }

  @override
  Future<TlsListenerHandle> listen({
    required DeviceCertificate localIdentity,
    int port = 0,
    InternetAddress? bindAddress,
    required bool requestClientCertificate,
    List<DeviceCertificate> trustedPeerCertificates = const [],
    required TlsPeerVerifier verifyPeer,
    required void Function(TlsByteStream connection) onConnection,
  }) async {
    // Peer PEMs must be in the trust store: BoringSSL verifies presented
    // client certificates against it even when they are not required.
    final context = securityContext(
      localIdentity,
      trustedPeerCertificates: [...trustedPeerCertificates, localIdentity],
    );
    Future<SecureServerSocket> bind(InternetAddress address) =>
        SecureServerSocket.bind(
          address,
          port,
          context,
          requestClientCertificate: requestClientCertificate,
          requireClientCertificate: false,
        );
    SecureServerSocket server;
    if (bindAddress != null) {
      server = await bind(bindAddress);
    } else {
      try {
        server = await bind(InternetAddress.anyIPv6);
      } on SocketException {
        server = await bind(InternetAddress.anyIPv4);
      }
    }
    final subscription = server.listen(
      (socket) {
        final peer = socket.peerCertificate;
        final peerCert = peer == null ? null : peerCertificateOf(peer);
        if (peerCert != null && !verifyPeer(peerCert)) {
          tlsSyncDebugLog?.call(
            'inbound TLS rejected: unknown fingerprint ${peerCert.fingerprint}',
          );
          socket.close().ignore();
          return;
        }
        onConnection(_DartTlsByteStream(socket, peerCert));
      },
      // Failed TLS handshakes (stale pins, wrong peer, port scanners) must
      // not escape as unhandled async errors — they abort Flutter
      // integration tests and kill the inviting app mid-join.
      onError: (Object e, StackTrace st) {
        tlsSyncDebugLog?.call('inbound TLS handshake error: $e\n$st');
      },
      cancelOnError: false,
    );
    return _DartTlsListener(server, subscription);
  }

  /// Fingerprint via the Dart backend's synchronous SHA-256: BoringSSL's
  /// certificate callback cannot await. Never reached on Apple platforms.
  static TlsPeerCertificate peerCertificateOf(X509Certificate certificate) {
    final der = Uint8List.fromList(certificate.der);
    return TlsPeerCertificate(
      der: der,
      fingerprint: DartCryptoBackend.sha256HexSync(der),
    );
  }

  static SecurityContext securityContext(
    DeviceCertificate? local, {
    required List<DeviceCertificate> trustedPeerCertificates,
  }) {
    final context = SecurityContext(withTrustedRoots: false);
    if (local != null) {
      final pem = local.certificatePem;
      final key = local.privateKeyPem;
      if (pem == null || key == null) {
        throw StateError(
          'DartTlsSocketFactory requires local certificatePem and '
          'privateKeyPem.',
        );
      }
      context.useCertificateChainBytes(utf8.encode(pem));
      context.usePrivateKeyBytes(utf8.encode(key));
    }
    final seen = <String>{};
    for (final peer in trustedPeerCertificates) {
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
}

class _DartTlsByteStream implements TlsByteStream {
  _DartTlsByteStream(this._socket, this.peerCertificate);

  final SecureSocket _socket;

  @override
  final TlsPeerCertificate? peerCertificate;

  @override
  Stream<Uint8List> get data => _socket;

  @override
  String get remoteAddress => _socket.remoteAddress.address;

  @override
  int get remotePort => _socket.remotePort;

  @override
  Future<void> send(List<int> bytes) async {
    _socket.add(bytes);
    await _socket.flush();
  }

  @override
  Future<void> close() async {
    try {
      await _socket.close();
    } catch (_) {}
  }
}

class _DartTlsListener implements TlsListenerHandle {
  _DartTlsListener(this._server, this._subscription);

  final SecureServerSocket _server;
  final StreamSubscription<SecureSocket> _subscription;

  @override
  int get port => _server.port;

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await _server.close();
  }
}
