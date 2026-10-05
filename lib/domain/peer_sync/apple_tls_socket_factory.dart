import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:smara_apple_crypto/smara_apple_crypto.dart';

import '../linked_devices/device_certificate_store.dart';
import 'tls_socket.dart';

/// [TlsSocketFactory] over Apple's Network framework through the in-repo
/// `smara_apple_crypto` plugin (design D3). TLS 1.2 minimum, the device's
/// Keychain identity as the local identity, client certificates requested
/// by the listener, and a verify block that hands the peer's leaf DER (with
/// its CryptoKit SHA-256 fingerprint) back to Dart's [TlsPeerVerifier].
///
/// The Dart side keeps the framing and the pinning, so an iPhone or Mac
/// syncs with Android, Windows and Linux peers unchanged.
class AppleTlsSocketFactory extends TlsSocketFactory {
  const AppleTlsSocketFactory({AppleTls? tls}) : _tls = tls;

  final AppleTls? _tls;

  AppleTls get _os => _tls ?? AppleTls.instance;

  @override
  String get name => 'apple';

  @override
  Future<TlsByteStream> connect({
    required String host,
    required int port,
    DeviceCertificate? localIdentity,
    List<DeviceCertificate> trustedPeerCertificates = const [],
    required TlsPeerVerifier verifyPeer,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final label = localIdentity?.keychainIdentityLabel;
    if (localIdentity != null && label == null) {
      throw StateError(
        'AppleTlsSocketFactory requires a Keychain identity label on the '
        'local certificate.',
      );
    }
    final connection = await _os.connect(
      host: host,
      port: port,
      identityLabel: label,
      timeout: timeout,
      verifyPeer: (peer) => verifyPeer(_toPeer(peer)),
    );
    return _AppleTlsByteStream(connection);
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
    final label = localIdentity.keychainIdentityLabel;
    if (label == null) {
      throw StateError(
        'AppleTlsSocketFactory requires a Keychain identity label on the '
        'local certificate.',
      );
    }
    final listener = await _os.listen(
      port: port,
      identityLabel: label,
      requestClientCertificate: requestClientCertificate,
      loopbackOnly: bindAddress?.isLoopback ?? false,
      verifyPeer: (peer) => verifyPeer(_toPeer(peer)),
      onConnection: (connection) =>
          onConnection(_AppleTlsByteStream(connection)),
    );
    return _AppleTlsListener(listener);
  }

  static TlsPeerCertificate _toPeer(AppleTlsPeer peer) =>
      TlsPeerCertificate(der: peer.der, fingerprint: peer.fingerprint);
}

class _AppleTlsByteStream implements TlsByteStream {
  _AppleTlsByteStream(this._connection)
    : peerCertificate = _connection.peer == null
          ? null
          : TlsPeerCertificate(
              der: _connection.peer!.der,
              fingerprint: _connection.peer!.fingerprint,
            );

  final AppleTlsConnection _connection;

  @override
  final TlsPeerCertificate? peerCertificate;

  @override
  Stream<Uint8List> get data => _connection.data;

  @override
  String get remoteAddress => _connection.remoteAddress;

  @override
  int get remotePort => _connection.remotePort;

  @override
  Future<void> send(List<int> bytes) =>
      _connection.send(Uint8List.fromList(bytes));

  @override
  Future<void> close() => _connection.close();
}

class _AppleTlsListener implements TlsListenerHandle {
  _AppleTlsListener(this._listener);

  final AppleTlsListener _listener;

  @override
  int get port => _listener.port;

  @override
  Future<void> close() => _listener.close();
}
