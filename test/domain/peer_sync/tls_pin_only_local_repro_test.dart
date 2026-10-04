import 'dart:async';
import 'dart:io';

import 'package:smara_accounting/domain/crypto/secure_key_storage.dart';
import 'package:smara_accounting/domain/linked_devices/device_certificate_store.dart';
import 'package:smara_accounting/domain/linked_devices/persisting_device_certificate_store.dart';
import 'package:smara_accounting/domain/peer_sync/sync_transport.dart';
import 'package:smara_accounting/domain/peer_sync/tls_sync_transport.dart';
import 'package:test/test.dart';

class _MemStore implements SecureKeyStorage {
  final map = <String, String>{};
  @override
  Future<String?> read(String k) async => map[k];
  @override
  Future<void> write(String k, String v) async => map[k] = v;
  @override
  Future<void> delete(String k) async => map.remove(k);
}

void main() {
  test(
    'listen without peer PEM rejects client (CERTIFICATE_VERIFY_FAILED)',
    () async {
      final store = PersistingDeviceCertificateStore(
        secureStorage: _MemStore(),
      );
      final certA = await store.localCertificate(deviceId: 'a');
      final certB = await store.localCertificate(deviceId: 'b');
      final pins = {certA.fingerprint, certB.fingerprint};
      final transportA = TlsSyncTransport(
        bindAddress: InternetAddress.loopbackIPv4,
      );
      final transportB = TlsSyncTransport(
        bindAddress: InternetAddress.loopbackIPv4,
      );
      addTearDown(() async {
        await transportA.stopListening();
        await transportB.stopListening();
      });
      late int port;
      await transportB.listen(
        local: SyncPeerIdentity(deviceId: 'b', certificate: certB),
        pinnedFingerprints: pins,
        // Production bug: PeerSyncService used to pass only the local cert.
        pinnedCertificates: [certB],
        onBound: (p) => port = p,
        onSession: (c) async {
          await c.close();
        },
      );

      // B refuses A's certificate. Depending on the OS and timing, that
      // shows up when A reads the reply (StateError: connection closed) or
      // already while A connects or writes (SocketException: broken pipe,
      // as on Linux CI). Either way no message may get through.
      Future<void> talk() async {
        final conn = await transportA.connect(
          local: SyncPeerIdentity(deviceId: 'a', certificate: certA),
          remote: SyncPeerIdentity(
            deviceId: 'b',
            certificate: DeviceCertificate(
              derBytes: const [],
              fingerprint: certB.fingerprint,
            ),
            host: InternetAddress.loopbackIPv4.address,
            port: port,
          ),
          pinnedFingerprints: pins,
          pinnedCertificates: [certA],
        );
        try {
          await conn.send({'kind': 'tipState'});
          await conn.receive().timeout(const Duration(seconds: 2));
        } finally {
          await conn.close();
        }
      }

      await expectLater(
        talk(),
        throwsA(
          anyOf(isA<StateError>(), isA<SocketException>(), isA<TlsException>()),
        ),
      );
    },
  );

  test('listen with peer PEM remembered at join exchanges messages', () async {
    final store = PersistingDeviceCertificateStore(secureStorage: _MemStore());
    final certA = await store.localCertificate(deviceId: 'a');
    final certB = await store.localCertificate(deviceId: 'b');
    // Join-time remember: host stores joiner DER; joiner stores host DER.
    await store.rememberPeerCertificate(certA);
    await store.rememberPeerCertificate(certB);
    final pins = {certA.fingerprint, certB.fingerprint};
    final pinned = [
      certB,
      (await store.certificateForFingerprint(certA.fingerprint))!,
    ];
    final transportA = TlsSyncTransport(
      bindAddress: InternetAddress.loopbackIPv4,
    );
    final transportB = TlsSyncTransport(
      bindAddress: InternetAddress.loopbackIPv4,
    );
    addTearDown(() async {
      await transportA.stopListening();
      await transportB.stopListening();
    });
    late int port;
    final got = Completer<Map<String, dynamic>>();
    await transportB.listen(
      local: SyncPeerIdentity(deviceId: 'b', certificate: certB),
      pinnedFingerprints: pins,
      pinnedCertificates: pinned,
      onBound: (p) => port = p,
      onSession: (c) async {
        final msg = await c.receive();
        await c.send(msg);
        got.complete(msg);
        await c.close();
      },
    );

    final conn = await transportA.connect(
      local: SyncPeerIdentity(deviceId: 'a', certificate: certA),
      remote: SyncPeerIdentity(
        deviceId: 'b',
        certificate: certB,
        host: InternetAddress.loopbackIPv4.address,
        port: port,
      ),
      pinnedFingerprints: pins,
      pinnedCertificates: [certA, certB],
    );
    await conn.send({'kind': 'tipState', 'ok': true});
    expect(await conn.receive(), {'kind': 'tipState', 'ok': true});
    expect(await got.future.timeout(const Duration(seconds: 2)), {
      'kind': 'tipState',
      'ok': true,
    });
    await conn.close();
  });
}
