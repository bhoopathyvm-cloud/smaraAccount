import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import '../models/join_qr_payload.dart';
import '../peer_sync/sync_payloads.dart';
import '../peer_sync/tls_socket.dart';
import 'device_certificate_store.dart';
import 'join_code.dart';
import 'join_code_crypto.dart';
import 'join_code_lookup.dart';
import 'join_completion.dart';
import 'join_offer_discovery.dart';
import 'reserved_join_identity.dart';

/// Length-prefixed JSON frames for join-by-code over unpinned TLS (task 4.4).
/// The byte stream comes from a [TlsSocketFactory], so the join session is
/// the same on every platform whichever TLS implementation is underneath.
class _JoinFrame {
  static Future<void> send(
    TlsByteStream socket,
    Map<String, Object?> map,
  ) async {
    final encoded = jsonEncode(map);
    if (syncPayloadContainsPrivateKeyMaterial(encoded)) {
      throw const FormatException(
        'Join frame must not include private key material.',
      );
    }
    final body = utf8.encode(encoded);
    final header = ByteData(4)..setUint32(0, body.length, Endian.big);
    await socket.send([...header.buffer.asUint8List(), ...body]);
  }

  static Future<Map<String, dynamic>> receive(
    StreamIterator<List<int>> chunks,
    BytesBuilder buffer,
  ) async {
    while (true) {
      final bytes = buffer.toBytes();
      if (bytes.length >= 4) {
        final length = ByteData.sublistView(
          Uint8List.fromList(bytes),
        ).getUint32(0, Endian.big);
        if (bytes.length >= 4 + length) {
          final payload = utf8.decode(bytes.sublist(4, 4 + length));
          final remaining = bytes.sublist(4 + length);
          buffer.clear();
          if (remaining.isNotEmpty) buffer.add(remaining);
          if (syncPayloadContainsPrivateKeyMaterial(payload)) {
            throw const FormatException(
              'Join frame must not include private key material.',
            );
          }
          final decoded = jsonDecode(payload);
          if (decoded is! Map) {
            throw const FormatException('Join frame must be a JSON object.');
          }
          return Map<String, dynamic>.from(decoded);
        }
      }
      if (!await chunks.moveNext()) {
        throw StateError('Join connection closed.');
      }
      buffer.add(chunks.current);
    }
  }
}

List<int> _randomNonce([Random? random]) {
  final rng = random ?? Random.secure();
  return List<int>.generate(16, (_) => rng.nextInt(256));
}

/// Host-side outcome after both devices confirm the join-code check code.
class JoinCodeHostAccepted {
  const JoinCodeHostAccepted({
    required this.payload,
    required this.joinerDeviceId,
    required this.joinerDisplayName,
    required this.joinerSigningPublicKey,
    required this.joinerDeviceCertFingerprint,
    this.joinerDeviceCertDer = const [],
    this.joinerIdentityId,
  });

  final JoinQrPayload payload;
  final String joinerDeviceId;
  final String joinerDisplayName;
  final List<int> joinerSigningPublicKey;
  final String joinerDeviceCertFingerprint;

  /// Joiner TLS certificate DER (public) so the host can trust Sync now.
  final List<int> joinerDeviceCertDer;
  final String? joinerIdentityId;
}

/// Host side: advertise offer + accept unpinned TLS join sessions.
class JoinCodeHost {
  JoinCodeHost({
    required this.localCertificate,
    required this.discovery,
    required this.registry,
    InternetAddress? bindAddress,
    TlsSocketFactory? sockets,
    this.confirmCheckCode,
    this.onJoinAccepted,
    this.loadBootstrapMetadata,
  }) : bindAddress = bindAddress ?? InternetAddress.anyIPv4,
       _sockets = sockets;

  final DeviceCertificate localCertificate;
  final JoinOfferDiscovery discovery;
  final JoinCodeRegistry registry;
  final InternetAddress bindAddress;
  final TlsSocketFactory? _sockets;

  TlsSocketFactory get sockets => _sockets ?? TlsSocketFactory.forPlatform();

  /// When set, host UI must confirm [checkCode] before the payload is sent.
  /// Null auto-confirms (harness / unit tests).
  final Future<bool> Function(String checkCode)? confirmCheckCode;

  /// Called after both sides confirm, before the payload frame is sent, so
  /// the host can [MembershipRepository.acceptJoinFromQr].
  final Future<void> Function(JoinCodeHostAccepted accepted)? onJoinAccepted;

  /// Optional snapshot of host MetadataOps sent after the payload so the
  /// joiner receives categories/accounts without a separate Sync now.
  final Future<List<MetadataOperation>> Function()? loadBootstrapMetadata;

  JoinQrPayload? _payload;
  List<int>? _inviterPublicKey;
  TlsListenerHandle? _server;
  int? _port;

  int? get port => _port;

  /// Starts listening and advertising [code]'s offer id. [payload] is sent
  /// only after both sides confirm matching check codes.
  Future<void> start({
    required JoinCode code,
    required JoinQrPayload payload,
    required List<int> inviterPublicKey,
  }) async {
    await stop();
    _payload = payload;
    _inviterPublicKey = inviterPublicKey;
    if (!localCertificate.hasLocalIdentity) {
      throw StateError(
        'Join-by-code TLS requires a local TLS identity (certificate and '
        'private key, or a Keychain identity).',
      );
    }
    // Bonjour / port scanners can open TCP without completing TLS; the
    // socket factory drops failed handshakes before they reach here, so
    // they cannot escape into the Flutter test zone or kill the inviting
    // app (and company-sync Owner) mid-join.
    _server = await sockets.listen(
      localIdentity: localCertificate,
      bindAddress: bindAddress,
      // Join-only: trust is the typed code + check-code confirm, not pins.
      requestClientCertificate: false,
      verifyPeer: (_) => true,
      onConnection: (socket) {
        unawaited(_handleClient(socket));
      },
    );
    _port = _server!.port;
    await discovery.startAdvertising(
      JoinOfferAdvertisement(
        offerId: code.offerId,
        port: _port!,
        booksSetId: payload.booksSetId,
      ),
    );
  }

  Future<void> stop() async {
    await _server?.close();
    _server = null;
    _port = null;
    await discovery.stopAdvertising();
  }

  Future<void> _handleClient(TlsByteStream socket) async {
    final buffer = BytesBuilder(copy: false);
    final chunks = StreamIterator<List<int>>(socket.data);
    try {
      final hello = await _JoinFrame.receive(chunks, buffer);
      if (hello['type'] != 'hello') {
        await socket.close();
        return;
      }
      final joinerNonce = base64Decode(hello['joinerNonce'] as String);
      final joinerPublicKey = base64Decode(hello['joinerPublicKey'] as String);
      final joinerDeviceId = hello['joinerDeviceId'] as String? ?? '';
      final joinerDisplayName =
          hello['joinerDisplayName'] as String? ?? 'Joining device';
      final joinerCertFingerprint =
          hello['joinerCertFingerprint'] as String? ?? '';
      final joinerCertDerB64 = hello['joinerCertDer'] as String?;
      final joinerCertDer = joinerCertDerB64 == null || joinerCertDerB64.isEmpty
          ? const <int>[]
          : base64Decode(joinerCertDerB64);
      final joinerIdentityId = hello['joinerIdentityId'] as String?;
      final inviterNonce = _randomNonce();
      final inviterPublicKey = _inviterPublicKey!;
      await _JoinFrame.send(socket, {
        'type': 'challenge',
        'inviterNonce': base64Encode(inviterNonce),
        'inviterPublicKey': base64Encode(inviterPublicKey),
      });

      final proofMsg = await _JoinFrame.receive(chunks, buffer);
      if (proofMsg['type'] != 'proof') {
        await socket.close();
        return;
      }
      final typedCode = proofMsg['code'] as String? ?? '';
      final proof = base64Decode(proofMsg['proof'] as String);
      final active = registry.active;
      if (active == null) {
        await _JoinFrame.send(socket, {
          'type': 'error',
          'error': JoinCodeValidation.mismatch.name,
        });
        await socket.close();
        return;
      }
      final validation = active.validateTyped(typedCode);
      if (validation != JoinCodeValidation.ok) {
        if (validation == JoinCodeValidation.mismatch) {
          final rotated = active.recordWrongAttempt();
          if (rotated) registry.issue();
        }
        await _JoinFrame.send(socket, {
          'type': 'error',
          'error': validation.name,
        });
        await socket.close();
        return;
      }
      final expected = await JoinCodeCrypto.codeProof(
        code: active.raw,
        inviterNonce: inviterNonce,
        joinerNonce: joinerNonce,
      );
      if (!_bytesEqual(proof, expected)) {
        final rotated = active.recordWrongAttempt();
        if (rotated) registry.issue();
        await _JoinFrame.send(socket, {
          'type': 'error',
          'error': JoinCodeValidation.mismatch.name,
        });
        await socket.close();
        return;
      }

      final check = await JoinCodeCrypto.checkCode(
        code: active.raw,
        inviterPublicKey: inviterPublicKey,
        joinerPublicKey: joinerPublicKey,
        inviterNonce: inviterNonce,
        joinerNonce: joinerNonce,
      );
      await _JoinFrame.send(socket, {'type': 'check', 'checkCode': check});

      final hostOk = confirmCheckCode == null
          ? true
          : await confirmCheckCode!(check);
      if (!hostOk) {
        active.markUsed();
        try {
          await _JoinFrame.send(socket, {'type': 'confirm', 'matched': false});
        } catch (_) {}
        await socket.close();
        return;
      }

      final confirm = await _JoinFrame.receive(chunks, buffer);
      if (confirm['type'] != 'confirm' || confirm['matched'] != true) {
        active.markUsed();
        await socket.close();
        return;
      }

      active.markUsed();
      final payload = _payload;
      if (payload == null) {
        await socket.close();
        return;
      }
      if (joinerDeviceId.isNotEmpty &&
          joinerCertFingerprint.isNotEmpty &&
          onJoinAccepted != null) {
        await onJoinAccepted!(
          JoinCodeHostAccepted(
            payload: payload,
            joinerDeviceId: joinerDeviceId,
            joinerDisplayName: joinerDisplayName,
            joinerSigningPublicKey: joinerPublicKey,
            joinerDeviceCertFingerprint: joinerCertFingerprint,
            joinerDeviceCertDer: joinerCertDer,
            joinerIdentityId: joinerIdentityId,
          ),
        );
      }
      final encoded = payload.encode();
      if (syncPayloadContainsPrivateKeyMaterial(encoded) ||
          JoinQrPayload.containsPrivateKeyMaterial(encoded)) {
        throw StateError('Join payload must not include private keys.');
      }
      await _JoinFrame.send(socket, {
        'type': 'payload',
        'payload': jsonDecode(encoded),
      });
      final loadBootstrap = loadBootstrapMetadata;
      final bootstrap = loadBootstrap == null
          ? const <MetadataOperation>[]
          : await loadBootstrap();
      await _JoinFrame.send(socket, {
        'type': 'bootstrap_meta',
        'operations': bootstrap.map((o) => o.toJson()).toList(),
      });
      await socket.close();
    } catch (_) {
      try {
        await socket.close();
      } catch (_) {}
    } finally {
      await chunks.cancel();
    }
  }

  static bool _bytesEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}

/// Joiner-side LAN lookup: browse offers, prove the code, return check code
/// and a completer that fetches the same [JoinQrPayload] the QR path uses.
class SecureJoinCodeLookup implements JoinCodeLookup {
  SecureJoinCodeLookup({
    required this.discovery,
    required this.localCertificate,
    required this.resolveJoinerIdentity,
    required this.joinerDeviceId,
    required this.joinerDisplayName,
    required this.joinerCertFingerprint,
    this.browseTimeout = const Duration(seconds: 3),
    this.bindAddress,
    TlsSocketFactory? sockets,
  }) : _sockets = sockets;

  /// Last per-offer errors from the most recent [lookup] (company-sync debug).
  static String lastOfferErrors = '';

  final JoinOfferDiscovery discovery;
  final DeviceCertificate localCertificate;

  /// Reserves (or loads) this device's Signing Identity for the books set
  /// named in the host's welcome frame — before hello is sent.
  final Future<ReservedJoinIdentity> Function(String booksSetId)
  resolveJoinerIdentity;
  final String joinerDeviceId;
  final String joinerDisplayName;
  final String joinerCertFingerprint;
  final Duration browseTimeout;
  final InternetAddress? bindAddress;
  final TlsSocketFactory? _sockets;

  TlsSocketFactory get sockets => _sockets ?? TlsSocketFactory.forPlatform();

  @override
  Future<JoinCodeLookupResult> lookup(String typedCode) async {
    final normalized = JoinCode.normalize(typedCode);
    if (!JoinCode.isWellFormed(normalized)) {
      return const JoinCodeLookupResult.failure(JoinCodeLookupError.malformed);
    }

    // Try each offer as it arrives. Waiting a fixed browseTimeout before any
    // attempt broke company-sync on IntegrationTestWidgetsFlutterBinding:
    // Stream.fromIterable events were easy to miss with listen+delay+cancel,
    // and the joiner always burned the full timeout even for a fixed offer.
    Object? lastError;
    final errors = <String>[];
    var sawOffer = false;
    try {
      await for (final offer in discovery.browse().timeout(
        browseTimeout,
        onTimeout: (EventSink<DiscoveredJoinOffer> sink) => sink.close(),
      )) {
        sawOffer = true;
        try {
          lastOfferErrors = '';
          return await _tryOffer(offer, typedCode, normalized);
        } catch (e) {
          lastError = e;
          errors.add('${offer.host}:${offer.port}=$e');
        }
      }
    } on TimeoutException {
      // No offers within [browseTimeout].
    }
    lastOfferErrors = errors.isEmpty
        ? (sawOffer ? 'all_offers_failed' : 'no_offers')
        : errors.join(' | ');
    // ignore: avoid_print — company-sync / simulator diagnosis
    print('SecureJoinCodeLookup failed: $lastOfferErrors');
    if (lastError is _JoinLookupException) {
      return JoinCodeLookupResult.failure(lastError.error);
    }
    return const JoinCodeLookupResult.failure(JoinCodeLookupError.notFound);
  }

  Future<JoinCodeLookupResult> _tryOffer(
    DiscoveredJoinOffer offer,
    String typedCode,
    String normalized,
  ) async {
    // The joiner presents no certificate and accepts the host's self-signed
    // one: trust comes from the typed code and the check-code confirm.
    final socket = await sockets.connect(
      host: offer.host,
      port: offer.port,
      verifyPeer: (_) => true,
      timeout: const Duration(seconds: 5),
    );
    final buffer = BytesBuilder(copy: false);
    final chunks = StreamIterator<List<int>>(socket.data);
    Future<Map<String, dynamic>> receiveFrame() =>
        _JoinFrame.receive(chunks, buffer).timeout(
          const Duration(seconds: 8),
          onTimeout: () => throw TimeoutException(
            'join frame timeout from ${offer.host}:${offer.port}',
          ),
        );
    try {
      // Reserve this books set's Signing Identity before hello so the host
      // pins the key that will sign the joined set (never the household key).
      if (offer.booksSetId.isEmpty) {
        throw const _JoinLookupException(JoinCodeLookupError.notFound);
      }
      final reserved = await resolveJoinerIdentity(offer.booksSetId);
      final joinerPublicKey = reserved.publicKey;
      final joinerIdentityId = reserved.identityId;

      final joinerNonce = _randomNonce();
      await _JoinFrame.send(socket, {
        'type': 'hello',
        'joinerNonce': base64Encode(joinerNonce),
        'joinerPublicKey': base64Encode(joinerPublicKey),
        'joinerDeviceId': joinerDeviceId,
        'joinerDisplayName': joinerDisplayName,
        'joinerCertFingerprint': joinerCertFingerprint,
        if (localCertificate.derBytes.isNotEmpty)
          'joinerCertDer': base64Encode(localCertificate.derBytes),
        'joinerIdentityId': joinerIdentityId,
      });
      final challenge = await receiveFrame();
      if (challenge['type'] == 'error') {
        throw _JoinLookupException(_mapError(challenge['error'] as String?));
      }
      if (challenge['type'] != 'challenge') {
        throw const _JoinLookupException(JoinCodeLookupError.notFound);
      }
      final inviterNonce = base64Decode(challenge['inviterNonce'] as String);
      final inviterPublicKey = base64Decode(
        challenge['inviterPublicKey'] as String,
      );
      final proof = await JoinCodeCrypto.codeProof(
        code: normalized,
        inviterNonce: inviterNonce,
        joinerNonce: joinerNonce,
      );
      await _JoinFrame.send(socket, {
        'type': 'proof',
        'code': normalized,
        'proof': base64Encode(proof),
      });
      final checkMsg = await receiveFrame();
      if (checkMsg['type'] == 'error') {
        throw _JoinLookupException(_mapError(checkMsg['error'] as String?));
      }
      if (checkMsg['type'] != 'check') {
        throw const _JoinLookupException(JoinCodeLookupError.notFound);
      }
      final checkCode = checkMsg['checkCode'] as String;
      final expected = await JoinCodeCrypto.checkCode(
        code: normalized,
        inviterPublicKey: inviterPublicKey,
        joinerPublicKey: joinerPublicKey,
        inviterNonce: inviterNonce,
        joinerNonce: joinerNonce,
      );
      if (checkCode != expected) {
        await socket.close();
        throw const _JoinLookupException(JoinCodeLookupError.notFound);
      }

      return JoinCodeLookupResult.success(
        JoinCodeLookupSuccess(
          checkCode: checkCode,
          offer: offer,
          normalizedCode: normalized,
          completeJoin: () async {
            await _JoinFrame.send(socket, {'type': 'confirm', 'matched': true});
            final payloadMsg = await _JoinFrame.receive(chunks, buffer);
            if (payloadMsg['type'] == 'confirm' &&
                payloadMsg['matched'] == false) {
              throw StateError('Host rejected check code.');
            }
            if (payloadMsg['type'] != 'payload') {
              throw StateError('Expected join payload.');
            }
            final raw = jsonEncode(payloadMsg['payload']);
            if (syncPayloadContainsPrivateKeyMaterial(raw) ||
                JoinQrPayload.containsPrivateKeyMaterial(raw)) {
              throw StateError('Join payload contained private key material.');
            }
            final payload = JoinQrPayload.decode(raw);
            var bootstrap = const <MetadataOperation>[];
            try {
              final bootMsg = await _JoinFrame.receive(
                chunks,
                buffer,
              ).timeout(const Duration(seconds: 5));
              if (bootMsg['type'] == 'bootstrap_meta') {
                final opsRaw = bootMsg['operations'];
                if (opsRaw is List) {
                  bootstrap = [
                    for (final o in opsRaw)
                      MetadataOperation.fromJson(
                        Map<String, dynamic>.from(o as Map),
                      ),
                  ];
                }
              }
            } on TimeoutException {
              // Older hosts omit bootstrap; Sync now remains the fallback.
            }
            await socket.close();
            await chunks.cancel();
            return JoinCompletion(
              payload: payload,
              bootstrapMetadata: bootstrap,
            );
          },
          cancelJoin: () async {
            try {
              await _JoinFrame.send(socket, {
                'type': 'confirm',
                'matched': false,
              });
            } catch (_) {}
            try {
              await socket.close();
            } catch (_) {}
            await chunks.cancel();
          },
        ),
      );
    } catch (e) {
      try {
        await socket.close();
      } catch (_) {}
      await chunks.cancel();
      rethrow;
    }
  }

  JoinCodeLookupError _mapError(String? name) {
    return switch (name) {
      'expired' => JoinCodeLookupError.expired,
      'alreadyUsed' => JoinCodeLookupError.alreadyUsed,
      'mismatch' || 'malformed' => JoinCodeLookupError.notFound,
      _ => JoinCodeLookupError.notFound,
    };
  }
}

class _JoinLookupException implements Exception {
  const _JoinLookupException(this.error);
  final JoinCodeLookupError error;
}
