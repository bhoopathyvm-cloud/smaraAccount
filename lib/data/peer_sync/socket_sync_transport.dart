/// Data-layer TLS adapter for peer sync (real-sync design Decision 1).
///
/// The implementation lives with the peer-sync domain types as
/// [TlsSyncTransport]; this library is the stable import path named in the
/// OpenSpec tasks (`SocketSyncTransport`).
library;

import '../../domain/peer_sync/tls_sync_transport.dart';

export '../../domain/peer_sync/tls_sync_transport.dart' show TlsSyncTransport;

/// Alias used by tasks / docs for the real [SyncTransport] over SecureSocket.
class SocketSyncTransport extends TlsSyncTransport {
  SocketSyncTransport({super.bindAddress});
}
