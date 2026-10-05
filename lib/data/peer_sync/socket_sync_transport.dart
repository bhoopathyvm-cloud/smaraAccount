/// Data-layer TLS adapters for peer sync (real-sync design Decision 1).
///
/// The implementation lives with the peer-sync domain types as
/// [TlsSyncTransport]; this library is the stable import path named in the
/// OpenSpec tasks (`SocketSyncTransport`) and the place where the platform
/// picks its socket.
library;

import 'package:flutter/foundation.dart';

import '../../domain/crypto/crypto_backend.dart';
import '../../domain/peer_sync/apple_tls_socket_factory.dart';
import '../../domain/peer_sync/dart_tls_socket_factory.dart';
import '../../domain/peer_sync/sync_transport.dart';
import '../../domain/peer_sync/tls_sync_transport.dart';

export '../../domain/peer_sync/tls_sync_transport.dart' show TlsSyncTransport;

/// Alias used by tasks / docs for the real [SyncTransport] over
/// `dart:io`'s SecureSocket (Android, Windows, Linux).
class SocketSyncTransport extends TlsSyncTransport {
  SocketSyncTransport({super.bindAddress})
    : super(sockets: const DartTlsSocketFactory());
}

/// The real [SyncTransport] on iOS and macOS: the same framing and pinning
/// as [SocketSyncTransport] over the Network framework (os-provided-
/// encryption task 3.2).
class AppleTlsSyncTransport extends TlsSyncTransport {
  AppleTlsSyncTransport({super.bindAddress})
    : super(sockets: const AppleTlsSocketFactory());
}

/// The sync transport for [platform] (default: the running platform):
/// [AppleTlsSyncTransport] on iOS and macOS, [SocketSyncTransport] elsewhere.
TlsSyncTransport createPlatformSyncTransport({TargetPlatform? platform}) {
  final target = platform ?? defaultTargetPlatform;
  if (!kIsWeb && isApplePlatform(target)) {
    return AppleTlsSyncTransport();
  }
  return SocketSyncTransport();
}
