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
import 'package:smara_accounting/domain/peer_sync/sync_transport.dart';
import 'package:smara_accounting/domain/peer_sync/tls_sync_transport.dart';
import 'package:smara_apple_crypto/smara_apple_crypto.dart';

/// os-provided-encryption tasks 2.1, 3.1, 3.3 and 4.1 on a macOS or iOS
/// simulator: Keychain identities created by the Security framework, a
/// Network-framework TLS loopback exchange between two of them through the
/// unchanged [TlsSyncTransport], refusal of an identity that isn't pinned,
/// and a join-by-code session over the same socket.
///
///   flutter test integration_test/apple_tls_loopback_test.dart -d macos
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AppleDeviceCertificateStore store;
  late DeviceCertificate certA;
  late DeviceCertificate certB;
  late DeviceCertificate certStranger;

  setUpAll(() async {
    expect(isApplePlatform(defaultTargetPlatform), isTrue);
    CryptoBackend.use(selectCryptoBackend());
    final storage = FlutterSecureKeyStorage(
      FlutterSecureStorage(
        iOptions: FlutterSecureKeyStorage.defaultIosOptions,
        mOptions: FlutterSecureKeyStorage.defaultMacOsOptions,
      ),
    );
    store = AppleDeviceCertificateStore(secureStorage: storage);
    final suffix = DateTime.now().millisecondsSinceEpoch;
    certA = await store.localCertificate(deviceId: 'loop-a-$suffix');
    certB = await store.localCertificate(deviceId: 'loop-b-$suffix');
    certStranger = await store.localCertificate(deviceId: 'loop-x-$suffix');
  });

  tearDownAll(() async {
    for (final cert in [certA, certB, certStranger]) {
      await AppleKeychainIdentity.instance.deleteIdentity(
        label: cert.keychainIdentityLabel!,
      );
    }
  });

  test('Keychain identities are OS-made and never expose a key', () async {
    for (final cert in [certA, certB]) {
      expect(cert.keychainIdentityLabel, isNotNull);
      expect(cert.privateKeyPem, isNull);
      expect(cert.derBytes, isNotEmpty);
      expect(
        await AppleKeychainIdentity.instance.hasIdentity(
          label: cert.keychainIdentityLabel!,
        ),
        isTrue,
      );
    }
    expect(certA.fingerprint, isNot(certB.fingerprint));
  });

  test(
    'two pinned Apple identities exchange a message over loopback',
    () async {
      final listener = TlsSyncTransport(
        bindAddress: InternetAddress.loopbackIPv4,
        sockets: const AppleTlsSocketFactory(),
      );
      final caller = TlsSyncTransport(sockets: const AppleTlsSocketFactory());
      addTearDown(listener.stopListening);
      final pins = {certA.fingerprint, certB.fingerprint};
      final received = Completer<Map<String, dynamic>>();
      late int port;
      await listener.listen(
        local: SyncPeerIdentity(deviceId: 'b', certificate: certB),
        pinnedFingerprints: pins,
        onBound: (p) => port = p,
        onSession: (connection) async {
          expect(connection.remote.certificate.fingerprint, certA.fingerprint);
          final message = await connection.receive();
          await connection.send({'type': 'ack', 'echo': message['type']});
          received.complete(message);
          await connection.close();
        },
      );
      final connection = await caller.connect(
        local: SyncPeerIdentity(deviceId: 'a', certificate: certA),
        remote: SyncPeerIdentity(
          deviceId: 'b',
          certificate: certB,
          host: '127.0.0.1',
          port: port,
        ),
        pinnedFingerprints: pins,
      );
      await connection.send({'type': 'hello', 'payload': 'x' * 100000});
      final ack = await connection.receive();
      expect(ack, {'type': 'ack', 'echo': 'hello'});
      expect(await received.future, containsPair('type', 'hello'));
      await connection.close();
    },
  );

  test(
    'an identity that is not pinned is refused in both directions',
    () async {
      final listener = TlsSyncTransport(
        bindAddress: InternetAddress.loopbackIPv4,
        sockets: const AppleTlsSocketFactory(),
      );
      final stranger = TlsSyncTransport(sockets: const AppleTlsSocketFactory());
      addTearDown(listener.stopListening);
      var sessions = 0;
      late int port;
      await listener.listen(
        local: SyncPeerIdentity(deviceId: 'b', certificate: certB),
        pinnedFingerprints: {certA.fingerprint, certB.fingerprint},
        onBound: (p) => port = p,
        onSession: (_) async => sessions++,
      );
      // Listener refuses the stranger's client certificate.
      await expectLater(
        stranger.connect(
          local: SyncPeerIdentity(deviceId: 'x', certificate: certStranger),
          remote: SyncPeerIdentity(
            deviceId: 'b',
            certificate: certB,
            host: '127.0.0.1',
            port: port,
          ),
          pinnedFingerprints: {certStranger.fingerprint, certB.fingerprint},
        ),
        throwsA(anything),
      );
      // Caller refuses a listener it has not pinned.
      await expectLater(
        stranger.connect(
          local: SyncPeerIdentity(deviceId: 'x', certificate: certStranger),
          remote: SyncPeerIdentity(
            deviceId: 'b',
            certificate: const DeviceCertificate(derBytes: [], fingerprint: ''),
            host: '127.0.0.1',
            port: port,
          ),
          pinnedFingerprints: {certStranger.fingerprint},
        ),
        throwsA(isA<UnknownCertificateException>()),
      );
      await Future<void>.delayed(const Duration(milliseconds: 300));
      expect(sessions, 0);
    },
  );

  test('join-by-code completes over the Apple socket', () async {
    FakeJoinOfferDiscovery.resetAll();
    addTearDown(FakeJoinOfferDiscovery.resetAll);
    final hostDiscovery = FakeJoinOfferDiscovery(networkId: 'apple-join');
    final joinerDiscovery = FakeJoinOfferDiscovery(networkId: 'apple-join');
    final registry = JoinCodeRegistry();
    final host = JoinCodeHost(
      localCertificate: certA,
      discovery: hostDiscovery,
      registry: registry,
      bindAddress: InternetAddress.loopbackIPv4,
      sockets: const AppleTlsSocketFactory(),
    );
    final hostKey = await CryptoBackend.instance.ed25519Generate();
    final joinerKey = await CryptoBackend.instance.ed25519Generate();
    final joinNonce = base64Encode(List<int>.generate(16, (i) => i));
    final payload = JoinQrPayload(
      booksSetId: 'books-apple',
      hostDeviceId: 'a',
      hostDisplayName: 'Host',
      hostIdentityId: 'host-identity',
      signingPublicKey: hostKey.publicKey,
      deviceCertDer: certA.derBytes,
      deviceCertFingerprint: certA.fingerprint,
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
      discovery: joinerDiscovery,
      localCertificate: certB,
      resolveJoinerIdentity: (booksSetId) async => ReservedJoinIdentity(
        booksSetId: booksSetId,
        identityId: 'joiner-identity',
        publicKey: joinerKey.publicKey,
      ),
      joinerDeviceId: 'b',
      joinerDisplayName: 'Joiner',
      joinerCertFingerprint: certB.fingerprint,
      sockets: const AppleTlsSocketFactory(),
    );
    final result = await joiner.lookup(code.display);
    expect(result.isSuccess, isTrue, reason: '${result.error}');
    final completion = await result.success!.completeJoin!();
    expect(completion.payload.booksSetId, 'books-apple');
    expect(completion.payload.deviceCertFingerprint, certA.fingerprint);
  });
}
