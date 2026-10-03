import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/domain/linked_devices/join_code.dart';
import 'package:smara_accounting/domain/linked_devices/join_code_session.dart';
import 'package:smara_accounting/domain/linked_devices/join_offer_discovery.dart';
import 'package:smara_accounting/domain/linked_devices/persisting_device_certificate_store.dart';

import '../../domain/crypto/in_memory_secure_key_storage.dart';
import '../../harness/dual_device_harness.dart';

void main() {
  test(
    'join succeeds after a TLS connect/close probe (company-sync style)',
    () async {
      final harness = DualDeviceHarness(networkId: 'probe-then-join');
      await harness.setUp();
      addTearDown(harness.tearDown);

      final hostStore = PersistingDeviceCertificateStore(
        secureStorage: InMemorySecureKeyStorage(),
      );
      final joinerStore = PersistingDeviceCertificateStore(
        secureStorage: InMemorySecureKeyStorage(),
      );
      final tlsHost = await hostStore.localCertificate(deviceId: 'host');
      final tlsJoiner = await joinerStore.localCertificate(deviceId: 'joiner');

      FakeJoinOfferDiscovery.resetAll();
      addTearDown(FakeJoinOfferDiscovery.resetAll);
      final hostDiscovery = FakeJoinOfferDiscovery(
        networkId: 'probe-then-join',
      );
      final joinerDiscovery = FakeJoinOfferDiscovery(
        networkId: 'probe-then-join',
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
      final hostIdentity = (await harness.a.identity.currentIdentity())!;
      await host.start(
        code: code,
        payload: qr,
        inviterPublicKey: hostIdentity.publicKey,
      );
      addTearDown(host.stop);

      // Probe: connect + close (like company_sync_test TLS probe).
      final probe = await SecureSocket.connect(
        '127.0.0.1',
        host.port!,
        onBadCertificate: (_) => true,
        timeout: const Duration(seconds: 3),
      );
      await probe.close();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      final joinerIdentity = (await harness.b.identity.currentIdentity())!;
      final lookup = SecureJoinCodeLookup(
        discovery: joinerDiscovery,
        localCertificate: tlsJoiner,
        joinerPublicKey: joinerIdentity.publicKey,
        joinerDeviceId: harness.b.deviceId,
        joinerDisplayName: harness.b.displayName,
        joinerCertFingerprint: tlsJoiner.fingerprint,
        joinerIdentityId: joinerIdentity.identityId,
        browseTimeout: const Duration(milliseconds: 200),
      );
      final result = await lookup.lookup(code.display);
      expect(
        result.isSuccess,
        isTrue,
        reason:
            '${result.error} errors=${SecureJoinCodeLookup.lastOfferErrors}',
      );
    },
  );
}
