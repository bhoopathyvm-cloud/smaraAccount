import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smara_accounting/domain/crypto/crypto_backend.dart';
import 'package:smara_accounting/domain/crypto/secure_key_storage.dart';
import 'package:smara_accounting/domain/linked_devices/apple_device_certificate_store.dart';
import 'package:smara_accounting/domain/linked_devices/device_certificate_store.dart';
import 'package:smara_accounting/domain/linked_devices/join_code.dart';
import 'package:smara_accounting/domain/linked_devices/join_code_session.dart';
import 'package:smara_accounting/domain/linked_devices/join_offer_discovery.dart';
import 'package:smara_accounting/domain/linked_devices/reserved_join_identity.dart';
import 'package:smara_accounting/domain/models/join_qr_payload.dart';
import 'package:smara_accounting/domain/models/linked_device_role.dart';
import 'package:smara_accounting/domain/peer_sync/apple_tls_socket_factory.dart';
import 'package:smara_accounting/domain/peer_sync/certificate_pinning.dart';
import 'package:smara_accounting/domain/peer_sync/dart_tls_socket_factory.dart';
import 'package:smara_accounting/domain/peer_sync/sync_payloads.dart';
import 'package:smara_accounting/domain/peer_sync/sync_transport.dart';
import 'package:smara_accounting/domain/peer_sync/tls_socket.dart';
import 'package:smara_accounting/domain/peer_sync/tls_sync_transport.dart';
import 'package:smara_apple_crypto/smara_apple_crypto.dart';

import '../test/fixtures/tls/dart_peers.dart';

/// os-provided-encryption task 6.3 (cross-platform matrix) on one machine:
/// an Apple device's TLS (Network framework, Keychain identity) against the
/// TLS that Android, Windows and Linux use (Dart's BoringSSL `SecureSocket`,
/// PEM identity made by [PersistingDeviceCertificateStore]), in both
/// directions, for sync, unknown-peer refusal and join-by-code.
///
///   flutter test integration_test/cross_stack_tls_test.dart -d macos
///   flutter test integration_test/cross_stack_tls_test.dart -d `<ios sim>`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const apple = AppleTlsSocketFactory();
  const dart = DartTlsSocketFactory();

  late DeviceCertificate appleCert;
  late DeviceCertificate dartCert;
  late DeviceCertificate dartStranger;

  setUpAll(() async {
    expect(isApplePlatform(defaultTargetPlatform), isTrue);
    CryptoBackend.use(selectCryptoBackend());
    final suffix = DateTime.now().millisecondsSinceEpoch;
    appleCert = await AppleDeviceCertificateStore(
      secureStorage: FlutterSecureKeyStorage(
        FlutterSecureStorage(
          iOptions: FlutterSecureKeyStorage.defaultIosOptions,
          mOptions: FlutterSecureKeyStorage.defaultMacOsOptions,
        ),
      ),
    ).localCertificate(deviceId: 'cross-apple-$suffix');
    // The Android/Windows/Linux identity: an RSA key and certificate as PEM,
    // made by the same Dart code those platforms run (test/fixtures/tls).
    dartCert = await _dartPeer(dartPeerACertPem, dartPeerAKeyPem);
    dartStranger = await _dartPeer(dartPeerBCertPem, dartPeerBKeyPem);
    expect(appleCert.privateKeyPem, isNull, reason: 'Keychain key stays put');
    expect(dartCert.privateKeyPem, isNotNull);
  });

  // The Dart side stands in for an Android device inside this Apple test
  // app. Its TLS fingerprints peers with Dart's SHA-256 (correct on
  // Android), which the Apple-platform guard rightly forbids here, so each
  // test reports Android as the platform while the Apple side keeps using
  // CryptoKit and the Network framework. The OS-only guarantee itself is
  // covered by crypto_backend_golden_test and the selection tests.
  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
  });

  tearDownAll(() async {
    await AppleKeychainIdentity.instance.deleteIdentity(
      label: appleCert.keychainIdentityLabel!,
    );
  });

  /// Listener on [serverSockets] as [server], caller on [clientSockets] as
  /// [client]; both pin each other. Returns what each side received.
  Future<void> exchange({
    required TlsSocketFactory serverSockets,
    required DeviceCertificate server,
    required TlsSocketFactory clientSockets,
    required DeviceCertificate client,
  }) async {
    final listener = TlsSyncTransport(
      bindAddress: InternetAddress.loopbackIPv4,
      sockets: serverSockets,
    );
    final caller = TlsSyncTransport(sockets: clientSockets);
    addTearDown(listener.stopListening);
    final pins = {server.fingerprint, client.fingerprint};
    final received = Completer<Map<String, dynamic>>();
    late int port;
    await listener.listen(
      local: SyncPeerIdentity(deviceId: 'server', certificate: server),
      pinnedFingerprints: pins,
      pinnedCertificates: [client],
      onBound: (p) => port = p,
      onSession: (connection) async {
        expect(connection.remote.certificate.fingerprint, client.fingerprint);
        final message = await connection.receive();
        await connection.send({'type': 'ack', 'echo': message['type']});
        received.complete(message);
        await connection.close();
      },
    );
    final connection = await caller.connect(
      local: SyncPeerIdentity(deviceId: 'client', certificate: client),
      remote: SyncPeerIdentity(
        deviceId: 'server',
        certificate: server,
        host: '127.0.0.1',
        port: port,
      ),
      pinnedFingerprints: pins,
      pinnedCertificates: [server],
    );
    // Large enough to span many TLS records and native chunks.
    await connection.send({'type': 'hello', 'payload': 'x' * 100000});
    expect(await connection.receive(), {'type': 'ack', 'echo': 'hello'});
    expect(await received.future, containsPair('type', 'hello'));
    await connection.close();
  }

  test('Apple listener <- Dart (Android) caller: sync exchange', () async {
    await exchange(
      serverSockets: apple,
      server: appleCert,
      clientSockets: dart,
      client: dartCert,
    );
  });

  test('Dart (Android) listener <- Apple caller: sync exchange', () async {
    await exchange(
      serverSockets: dart,
      server: dartCert,
      clientSockets: apple,
      client: appleCert,
    );
  });

  /// [stranger] (not pinned by the listener) talks to a listener that pins
  /// only itself and [allowed]; the exchange must fail with a real error and
  /// open no session. Under TLS 1.3 the refusal can surface on the first
  /// exchange rather than in connect().
  Future<void> refused({
    required TlsSocketFactory serverSockets,
    required DeviceCertificate server,
    required DeviceCertificate allowed,
    required TlsSocketFactory strangerSockets,
    required DeviceCertificate stranger,
  }) async {
    final listener = TlsSyncTransport(
      bindAddress: InternetAddress.loopbackIPv4,
      sockets: serverSockets,
    );
    final caller = TlsSyncTransport(sockets: strangerSockets);
    addTearDown(listener.stopListening);
    var sessions = 0;
    late int port;
    await listener.listen(
      local: SyncPeerIdentity(deviceId: 'server', certificate: server),
      pinnedFingerprints: {server.fingerprint, allowed.fingerprint},
      pinnedCertificates: [allowed],
      onBound: (p) => port = p,
      onSession: (_) async => sessions++,
    );
    Future<void> talk() async {
      final conn = await caller.connect(
        local: SyncPeerIdentity(deviceId: 'stranger', certificate: stranger),
        remote: SyncPeerIdentity(
          deviceId: 'server',
          certificate: server,
          host: '127.0.0.1',
          port: port,
        ),
        pinnedFingerprints: {stranger.fingerprint, server.fingerprint},
        pinnedCertificates: [server],
      );
      try {
        await conn.send(const EntryBatch(entries: []).toJson());
        await conn.receive().timeout(const Duration(seconds: 5));
      } finally {
        await conn.close();
      }
    }

    await expectLater(talk(), throwsA(isNot(isA<TimeoutException>())));
    await Future<void>.delayed(const Duration(milliseconds: 300));
    expect(sessions, 0);
  }

  test('Apple listener refuses an unpinned Dart (Android) device', () async {
    await refused(
      serverSockets: apple,
      server: appleCert,
      allowed: dartCert,
      strangerSockets: dart,
      stranger: dartStranger,
    );
  });

  test('Dart (Android) listener refuses an unpinned Apple device', () async {
    await refused(
      serverSockets: dart,
      server: dartCert,
      allowed: dartStranger,
      strangerSockets: apple,
      stranger: appleCert,
    );
  });

  Future<void> joinByCode({
    required TlsSocketFactory hostSockets,
    required DeviceCertificate hostCert,
    required TlsSocketFactory joinerSockets,
    required DeviceCertificate joinerCert,
  }) async {
    FakeJoinOfferDiscovery.resetAll();
    addTearDown(FakeJoinOfferDiscovery.resetAll);
    final registry = JoinCodeRegistry();
    final host = JoinCodeHost(
      localCertificate: hostCert,
      discovery: FakeJoinOfferDiscovery(networkId: 'cross-join'),
      registry: registry,
      bindAddress: InternetAddress.loopbackIPv4,
      sockets: hostSockets,
    );
    final hostKey = await CryptoBackend.instance.ed25519Generate();
    final joinerKey = await CryptoBackend.instance.ed25519Generate();
    final joinNonce = base64Encode(List<int>.generate(16, (i) => i + 3));
    final payload = JoinQrPayload(
      booksSetId: 'books-cross',
      hostDeviceId: 'host',
      hostDisplayName: 'Host',
      hostIdentityId: 'host-identity',
      signingPublicKey: hostKey.publicKey,
      deviceCertDer: hostCert.derBytes,
      deviceCertFingerprint: hostCert.fingerprint,
      roleOffer: LinkedDeviceRole.owner,
      joinNonce: joinNonce,
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      checkCode: await JoinQrPayload.deriveCheckCode(joinNonce),
    );
    final code = registry.issue();
    await host.start(
      code: code,
      payload: payload,
      inviterPublicKey: hostKey.publicKey,
    );
    addTearDown(host.stop);
    final joiner = SecureJoinCodeLookup(
      discovery: FakeJoinOfferDiscovery(networkId: 'cross-join'),
      localCertificate: joinerCert,
      resolveJoinerIdentity: (booksSetId) async => ReservedJoinIdentity(
        booksSetId: booksSetId,
        identityId: 'joiner-identity',
        publicKey: joinerKey.publicKey,
      ),
      joinerDeviceId: 'joiner',
      joinerDisplayName: 'Joiner',
      joinerCertFingerprint: joinerCert.fingerprint,
      sockets: joinerSockets,
    );
    final result = await joiner.lookup(code.display);
    expect(result.isSuccess, isTrue, reason: '${result.error}');
    final completion = await result.success!.completeJoin!();
    expect(completion.payload.booksSetId, 'books-cross');
    expect(completion.payload.deviceCertFingerprint, hostCert.fingerprint);
  }

  test('join-by-code: Apple host, Dart (Android) joiner', () async {
    await joinByCode(
      hostSockets: apple,
      hostCert: appleCert,
      joinerSockets: dart,
      joinerCert: dartCert,
    );
  });

  test('join-by-code: Dart (Android) host, Apple joiner', () async {
    await joinByCode(
      hostSockets: dart,
      hostCert: dartCert,
      joinerSockets: apple,
      joinerCert: appleCert,
    );
  });
}

/// A Dart-made (BoringSSL) identity from PEM; the fingerprint comes from
/// the platform backend, as an Apple device computes a peer's pin.
Future<DeviceCertificate> _dartPeer(String certPem, String keyPem) async {
  final body = certPem
      .split('\n')
      .where((line) => !line.startsWith('-----'))
      .join();
  final der = base64Decode(body);
  return DeviceCertificate(
    derBytes: der,
    fingerprint: await CertificatePinning.fingerprintOf(der),
    certificatePem: certPem,
    privateKeyPem: keyPem,
  );
}
