import 'dart:io';
import 'dart:math';

import 'package:smara_accounting/domain/linked_devices/device_certificate_store.dart';
import 'package:smara_accounting/domain/linked_devices/join_code.dart';
import 'package:smara_accounting/domain/linked_devices/join_code_lookup.dart';
import 'package:smara_accounting/domain/linked_devices/join_code_session.dart';
import 'package:smara_accounting/domain/linked_devices/join_offer_discovery.dart';
import 'package:smara_accounting/domain/linked_devices/reserved_join_identity.dart';
import 'package:smara_accounting/domain/models/join_qr_payload.dart';
import 'package:smara_accounting/domain/peer_sync/tls_sync_transport.dart';
import 'package:test/test.dart';

import '../../harness/dual_device_harness.dart';

DeviceCertificate _loadPeer(String id) {
  final dir = Directory('test/fixtures/tls');
  final der = File('${dir.path}/$id-cert.der').readAsBytesSync();
  final pem = File('${dir.path}/$id-cert.pem').readAsStringSync();
  final key = File('${dir.path}/$id-key.pem').readAsStringSync();
  final fingerprint = TlsSyncTransport.fingerprintOfDer(der);
  return DeviceCertificate(
    derBytes: der,
    fingerprint: fingerprint,
    certificatePem: pem,
    privateKeyPem: key,
  );
}

void main() {
  late DualDeviceHarness harness;

  setUp(() async {
    FakeJoinOfferDiscovery.resetAll();
    harness = DualDeviceHarness(networkId: 'join-code-lan');
    await harness.setUp();
  });

  tearDown(() async {
    await harness.tearDown();
    FakeJoinOfferDiscovery.resetAll();
  });

  test(
    'code join yields same host cert pin and books as QR, no private key sent',
    () async {
      final tlsHost = _loadPeer('a');
      final tlsJoiner = _loadPeer('b');
      final hostDiscovery = FakeJoinOfferDiscovery(networkId: 'join-code-lan');
      final joinerDiscovery = FakeJoinOfferDiscovery(
        networkId: 'join-code-lan',
      );
      final registry = JoinCodeRegistry();
      final host = JoinCodeHost(
        localCertificate: tlsHost,
        discovery: hostDiscovery,
        registry: registry,
        bindAddress: InternetAddress.loopbackIPv4,
      );

      final qr = await harness.a.membership.buildJoinQrPayload(
        hostDeviceId: harness.a.deviceId,
        hostDisplayName: harness.a.displayName,
        booksSetId: harness.booksSetId,
      );
      final code = registry.issue(random: Random(42));
      final hostIdentity = await harness.a.identity.currentIdentity();
      expect(hostIdentity, isNotNull);

      await host.start(
        code: code,
        payload: qr,
        inviterPublicKey: hostIdentity!.publicKey,
      );
      addTearDown(host.stop);

      final joinerIdentity = await harness.b.identity.currentIdentity();
      expect(joinerIdentity, isNotNull);
      ReservedJoinIdentity? helloIdentity;

      final lookup = SecureJoinCodeLookup(
        discovery: joinerDiscovery,
        localCertificate: tlsJoiner,
        resolveJoinerIdentity: (booksSetId) async {
          expect(booksSetId, qr.booksSetId);
          helloIdentity = ReservedJoinIdentity(
            booksSetId: booksSetId,
            identityId: joinerIdentity!.identityId,
            publicKey: joinerIdentity.publicKey,
          );
          return helloIdentity!;
        },
        joinerDeviceId: harness.b.deviceId,
        joinerDisplayName: harness.b.displayName,
        joinerCertFingerprint: harness.b.certificate.fingerprint,
        browseTimeout: const Duration(milliseconds: 200),
      );

      final result = await lookup.lookup(code.display.toLowerCase());
      expect(result.isSuccess, isTrue, reason: '${result.error}');
      expect(result.success!.checkCode.length, 6);
      expect(helloIdentity, isNotNull);

      final completion = await result.success!.completeJoin!();
      final payload = completion.payload;
      expect(payload.hostDeviceId, qr.hostDeviceId);
      expect(payload.deviceCertFingerprint, qr.deviceCertFingerprint);
      expect(payload.booksSetId, qr.booksSetId);
      expect(payload.encode(), isNot(contains('privateKey')));
      expect(
        JoinQrPayload.containsPrivateKeyMaterial(payload.encode()),
        isFalse,
      );

      // Same membership outcome as QR harness link().
      await harness.b.membership.prepareJoinerFromScannedQr(payload);
      await harness.a.membership.acceptJoinFromQr(
        actorDeviceId: harness.a.deviceId,
        payload: payload,
        joinerDeviceId: harness.b.deviceId,
        joinerDisplayName: harness.b.displayName,
        joinerSigningPublicKey: helloIdentity!.publicKey,
        joinerDeviceCertFingerprint: harness.b.certificate.fingerprint,
        joinerIdentityId: helloIdentity!.identityId,
      );

      final onA = await harness.a.membership.listActiveDevices();
      expect(
        onA.map((d) => d.deviceId),
        containsAll([harness.a.deviceId, harness.b.deviceId]),
      );
      final pinned = onA.firstWhere((d) => d.deviceId == harness.b.deviceId);
      expect(pinned.deviceCertFingerprint, harness.b.certificate.fingerprint);
      expect(pinned.signingIdentityId, helloIdentity!.identityId);

      // Reused code is refused.
      final again = await lookup.lookup(code.raw);
      expect(again.error, JoinCodeLookupError.alreadyUsed);
    },
  );

  test(
    'plain TCP probe does not kill JoinCodeHost for a later real join',
    () async {
      final tlsHost = _loadPeer('a');
      final tlsJoiner = _loadPeer('b');
      final hostDiscovery = FakeJoinOfferDiscovery(networkId: 'join-probe-lan');
      final joinerDiscovery = FakeJoinOfferDiscovery(
        networkId: 'join-probe-lan',
      );
      final registry = JoinCodeRegistry();
      final host = JoinCodeHost(
        localCertificate: tlsHost,
        discovery: hostDiscovery,
        registry: registry,
        bindAddress: InternetAddress.loopbackIPv4,
      );

      final qr = await harness.a.membership.buildJoinQrPayload(
        hostDeviceId: harness.a.deviceId,
        hostDisplayName: harness.a.displayName,
        booksSetId: harness.booksSetId,
      );
      final code = registry.issue(random: Random(7));
      final hostIdentity = await harness.a.identity.currentIdentity();
      expect(hostIdentity, isNotNull);

      await host.start(
        code: code,
        payload: qr,
        inviterPublicKey: hostIdentity!.publicKey,
      );
      addTearDown(host.stop);

      // Bonjour / scanners open TCP without TLS — must not fail the host.
      final probe = await Socket.connect('127.0.0.1', host.port!);
      probe.destroy();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final joinerIdentity = await harness.b.identity.currentIdentity();
      final lookup = SecureJoinCodeLookup(
        discovery: joinerDiscovery,
        localCertificate: tlsJoiner,
        resolveJoinerIdentity: (booksSetId) async => ReservedJoinIdentity(
          booksSetId: booksSetId,
          identityId: joinerIdentity!.identityId,
          publicKey: joinerIdentity.publicKey,
        ),
        joinerDeviceId: harness.b.deviceId,
        joinerDisplayName: harness.b.displayName,
        joinerCertFingerprint: harness.b.certificate.fingerprint,
        browseTimeout: const Duration(milliseconds: 200),
      );

      final result = await lookup.lookup(code.raw);
      expect(result.isSuccess, isTrue, reason: '${result.error}');
    },
  );
}
