import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../crypto/crypto_backend.dart';
import '../linked_devices/device_certificate_store.dart';
import 'apple_tls_socket_factory.dart';
import 'dart_tls_socket_factory.dart';

/// The certificate a TLS peer presented: its leaf DER and the SHA-256 hex
/// fingerprint, which is the pin format every platform shares.
class TlsPeerCertificate {
  const TlsPeerCertificate({required this.der, required this.fingerprint});

  final Uint8List der;
  final String fingerprint;
}

/// Decides during the handshake whether a peer's certificate is acceptable.
/// Pinning logic lives in Dart on every platform (design D3), so the
/// refusal reasons stay the same whichever socket is underneath.
typedef TlsPeerVerifier = bool Function(TlsPeerCertificate peer);

/// One TLS byte stream. [TlsSyncTransport] and the join-by-code session put
/// their length-prefixed JSON framing on top of this.
abstract class TlsByteStream {
  /// Bytes from the peer, in order. Done when the peer closes.
  Stream<Uint8List> get data;

  /// The peer's certificate, or null when it presented none.
  TlsPeerCertificate? get peerCertificate;

  String get remoteAddress;
  int get remotePort;

  /// Writes [bytes] and flushes them to the wire.
  Future<void> send(List<int> bytes);

  Future<void> close();
}

/// A bound TLS listener.
abstract class TlsListenerHandle {
  int get port;
  Future<void> close();
}

/// The socket under the sync transport and the join session. Two
/// implementations: [DartTlsSocketFactory] over `dart:io`'s SecureSocket
/// (BoringSSL) for Android, Windows and Linux, and [AppleTlsSocketFactory]
/// over the Network framework for iOS and macOS. Framing, pinning and the
/// wire format are identical, so every platform talks to every other.
abstract class TlsSocketFactory {
  const TlsSocketFactory();

  /// Short identifier for diagnostics: `dart` or `apple`.
  String get name;

  /// Chooses the factory for [platform] (default: the running platform).
  static TlsSocketFactory forPlatform({TargetPlatform? platform}) {
    final target = platform ?? defaultTargetPlatform;
    if (!kIsWeb && isApplePlatform(target)) {
      return const AppleTlsSocketFactory();
    }
    return const DartTlsSocketFactory();
  }

  /// Opens a TLS connection to [host]:[port], presenting [localIdentity]
  /// when given. [verifyPeer] decides about the server's certificate.
  /// [trustedPeerCertificates] is extra public material a backend may need
  /// to complete verification; it never widens what [verifyPeer] accepts.
  Future<TlsByteStream> connect({
    required String host,
    required int port,
    DeviceCertificate? localIdentity,
    List<DeviceCertificate> trustedPeerCertificates = const [],
    required TlsPeerVerifier verifyPeer,
    Duration timeout = const Duration(seconds: 8),
  });

  /// Listens with [localIdentity]. [bindAddress] null means every interface
  /// over both IPv4 and IPv6 (#226). With [requestClientCertificate] peers
  /// are asked for a certificate and [verifyPeer] decides; without it a
  /// peer's certificate is not requested. Established connections reach
  /// [onConnection]; failed handshakes never do.
  Future<TlsListenerHandle> listen({
    required DeviceCertificate localIdentity,
    int port = 0,
    InternetAddress? bindAddress,
    required bool requestClientCertificate,
    List<DeviceCertificate> trustedPeerCertificates = const [],
    required TlsPeerVerifier verifyPeer,
    required void Function(TlsByteStream connection) onConnection,
  });
}
