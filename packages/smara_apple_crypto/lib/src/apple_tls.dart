import 'dart:async';

import 'package:flutter/services.dart';

/// The certificate a TLS peer presented, as reported by the Network
/// framework's verify block: its leaf DER and the SHA-256 hex fingerprint
/// CryptoKit computed over it.
class AppleTlsPeer {
  const AppleTlsPeer({required this.der, required this.fingerprint});

  final Uint8List der;
  final String fingerprint;
}

/// Decides whether a peer's certificate is acceptable. Runs in Dart while
/// the handshake waits, so pinning stays in the app.
typedef AppleTlsPeerVerifier = bool Function(AppleTlsPeer peer);

/// One TLS byte stream carried by an `NWConnection`.
class AppleTlsConnection {
  AppleTlsConnection._({
    required this.id,
    required this.peer,
    required this.remoteAddress,
    required this.remotePort,
    required AppleTls owner,
  }) : _owner = owner; // ignore: prefer_initializing_formals

  final int id;

  /// The peer's certificate, or null when it presented none (a join-by-code
  /// client, which is trusted through the typed code instead).
  final AppleTlsPeer? peer;
  final String remoteAddress;
  final int remotePort;
  final AppleTls _owner;

  final _controller = StreamController<Uint8List>();
  bool _closed = false;

  /// Bytes from the peer, in order. Closes when the peer closes or fails.
  Stream<Uint8List> get data => _controller.stream;

  Future<void> send(Uint8List bytes) {
    if (_closed) throw StateError('TLS connection is closed.');
    return _owner._ch.invokeMethod<void>('send', {'id': id, 'bytes': bytes});
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    _owner._connections.remove(id);
    try {
      await _owner._ch.invokeMethod<void>('close', {'id': id});
    } catch (_) {}
    // Not awaited: the future completes only once the listener receives the
    // done event, and a paused subscription (a StreamIterator between reads,
    // as the join-code session uses) never does - close() then hung forever.
    unawaited(_controller.close());
  }

  void _onData(Uint8List bytes) {
    if (!_closed) _controller.add(bytes);
  }

  void _onError(Object error) {
    if (!_closed) _controller.addError(error);
  }

  Future<void> _onClosed() async {
    if (_closed) return;
    _closed = true;
    _owner._connections.remove(id);
    unawaited(_controller.close()); // See close().
  }
}

/// A listening `NWListener`.
class AppleTlsListener {
  AppleTlsListener._({
    required this.id,
    required this.port,
    required AppleTls owner,
  }) : _owner = owner; // ignore: prefer_initializing_formals

  final int id;
  final int port;
  final AppleTls _owner;

  Future<void> close() async {
    _owner._listeners.remove(id);
    _owner._onConnection.remove(id);
    final handle = _owner._listenerHandles.remove(id);
    if (handle != null) _owner._verifiers.remove(handle);
    try {
      await _owner._ch.invokeMethod<void>('stopListening', {'id': id});
    } catch (_) {}
  }
}

/// Network-framework TLS over the `smara_apple_crypto/tls` method channel
/// and the `smara_apple_crypto/tls_events` event channel.
///
/// TLS 1.2 is the minimum so Dart's BoringSSL peers interoperate. The local
/// identity is the Keychain identity created by `AppleKeychainIdentity`.
class AppleTls {
  AppleTls({MethodChannel? channel, EventChannel? events})
    : _ch = channel ?? defaultChannel,
      _events = events ?? defaultEvents {
    _ch.setMethodCallHandler(_handleCall);
  }

  static AppleTls? _instance;

  static AppleTls get instance => _instance ??= AppleTls();

  static const MethodChannel defaultChannel = MethodChannel(
    'smara_apple_crypto/tls',
  );
  static const EventChannel defaultEvents = EventChannel(
    'smara_apple_crypto/tls_events',
  );

  final MethodChannel _ch;
  final EventChannel _events;
  StreamSubscription<Object?>? _eventSub;

  final _connections = <int, AppleTlsConnection>{};

  /// Events for a connection whose `connect` reply has not reached Dart yet.
  /// The reply (method channel) and the first bytes (event channel) are not
  /// ordered against each other, so a peer that speaks first (the join-code
  /// host does) could have its first message dropped; they are replayed when
  /// the connection is registered.
  final _early = <int, List<Map<Object?, Object?>>>{};

  /// Ids that have been registered; a late event for one that is already
  /// closed is dropped rather than held in [_early].
  final _registeredIds = <int>{};
  final _listeners = <int, AppleTlsListener>{};
  final _verifiers = <int, AppleTlsPeerVerifier>{};
  final _onConnection = <int, void Function(AppleTlsConnection)>{};

  /// Listener id -> its verifier handle (see [_nextHandle]).
  final _listenerHandles = <int, int>{};

  /// One counter for every verifier handle, connect and listen alike. The
  /// native side echoes the handle back in `verifyPeer`. Listener ids come
  /// from a separate native counter, so keying a listener's verifier by its
  /// id collided with connect handles (both start at 1): the server then
  /// checked the client's certificate with the client's verifier and every
  /// handshake was refused.
  int _nextHandle = 1;

  void _ensureEvents() {
    _eventSub ??= _events.receiveBroadcastStream().listen(
      _handleEvent,
      onError: (Object e) {},
    );
  }

  /// Opens a TLS connection to [host]:[port]. The peer's certificate is
  /// handed to [verifyPeer] during the handshake; returning false aborts it.
  Future<AppleTlsConnection> connect({
    required String host,
    required int port,
    String? identityLabel,
    required AppleTlsPeerVerifier verifyPeer,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    _ensureEvents();
    final handle = _nextHandle++;
    _verifiers[handle] = verifyPeer;
    try {
      final result = await _ch.invokeMapMethod<Object?, Object?>('connect', {
        'handle': handle,
        'host': host,
        'port': port,
        'identityLabel': ?identityLabel,
        'timeoutMs': timeout.inMilliseconds,
      });
      if (result == null) throw StateError('connect returned nothing');
      return _registerConnection(result);
    } finally {
      _verifiers.remove(handle);
    }
  }

  /// Listens on [port] (0 for ephemeral) on every interface, IPv4 and IPv6.
  /// With [requestClientCertificate] the peer is asked for a certificate and
  /// [verifyPeer] decides; without it the peer's certificate is not
  /// requested and [verifyPeer] is only consulted when one is sent anyway.
  Future<AppleTlsListener> listen({
    required int port,
    required String identityLabel,
    required bool requestClientCertificate,
    required AppleTlsPeerVerifier verifyPeer,
    required void Function(AppleTlsConnection connection) onConnection,
    bool loopbackOnly = false,
  }) async {
    _ensureEvents();
    // Registered before the native listener starts, so an early handshake
    // already finds its verifier.
    final handle = _nextHandle++;
    _verifiers[handle] = verifyPeer;
    final Map<Object?, Object?>? result;
    try {
      result = await _ch.invokeMapMethod<Object?, Object?>('listen', {
        'handle': handle,
        'port': port,
        'identityLabel': identityLabel,
        'requestClientCertificate': requestClientCertificate,
        'loopbackOnly': loopbackOnly,
      });
    } catch (_) {
      _verifiers.remove(handle);
      rethrow;
    }
    if (result == null) {
      _verifiers.remove(handle);
      throw StateError('listen returned nothing');
    }
    final id = result['id'] as int;
    final boundPort = result['port'] as int;
    final listener = AppleTlsListener._(id: id, port: boundPort, owner: this);
    _listeners[id] = listener;
    _listenerHandles[id] = handle;
    _onConnection[id] = onConnection;
    return listener;
  }

  AppleTlsConnection _registerConnection(Map<Object?, Object?> info) {
    final id = info['id'] as int;
    final der = info['peerDer'] as Uint8List?;
    final fingerprint = info['peerFingerprint'] as String?;
    final connection = AppleTlsConnection._(
      id: id,
      peer: der == null || fingerprint == null
          ? null
          : AppleTlsPeer(der: der, fingerprint: fingerprint),
      remoteAddress: info['remoteAddress'] as String? ?? '',
      remotePort: info['remotePort'] as int? ?? 0,
      owner: this,
    );
    _connections[id] = connection;
    _registeredIds.add(id);
    final early = _early.remove(id);
    if (early != null) {
      // Replay after the caller has the connection (same microtask order as
      // live events, which also arrive asynchronously).
      scheduleMicrotask(() {
        for (final event in early) {
          _deliver(event);
        }
      });
    }
    return connection;
  }

  Future<Object?> _handleCall(MethodCall call) async {
    switch (call.method) {
      case 'verifyPeer':
        final args = Map<Object?, Object?>.from(call.arguments as Map);
        final handle = args['handle'] as int;
        final verifier = _verifiers[handle];
        if (verifier == null) return false;
        final peer = AppleTlsPeer(
          der: args['der'] as Uint8List,
          fingerprint: args['fingerprint'] as String,
        );
        try {
          return verifier(peer);
        } catch (_) {
          return false;
        }
      default:
        throw MissingPluginException('AppleTls has no ${call.method}');
    }
  }

  void _handleEvent(Object? raw) {
    if (raw is! Map) return;
    final event = Map<Object?, Object?>.from(raw);
    switch (event['type']) {
      case 'connection':
        final listenerId = event['listenerId'] as int;
        final callback = _onConnection[listenerId];
        final connection = _registerConnection(event);
        if (callback == null) {
          unawaited(connection.close());
          return;
        }
        callback(connection);
      case 'data' || 'error' || 'closed':
        final id = event['id'] as int;
        if (!_connections.containsKey(id)) {
          if (!_registeredIds.contains(id)) (_early[id] ??= []).add(event);
          return;
        }
        _deliver(event);
    }
  }

  void _deliver(Map<Object?, Object?> event) {
    final connection = _connections[event['id'] as int];
    if (connection == null) return;
    switch (event['type']) {
      case 'data':
        connection._onData(event['bytes'] as Uint8List);
      case 'error':
        connection._onError(
          AppleTlsException(event['message'] as String? ?? 'TLS error'),
        );
        unawaited(connection._onClosed());
      case 'closed':
        unawaited(connection._onClosed());
    }
  }
}

/// A Network-framework connection failure reported by the plugin.
class AppleTlsException implements Exception {
  const AppleTlsException(this.message);

  final String message;

  @override
  String toString() => 'AppleTlsException: $message';
}
