import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/domain/linked_devices/device_certificate_store.dart';
import 'package:smara_accounting/domain/peer_sync/apple_tls_socket_factory.dart';
import 'package:smara_accounting/domain/peer_sync/sync_transport.dart';
import 'package:smara_accounting/domain/peer_sync/tls_sync_transport.dart';
import 'package:smara_apple_crypto/smara_apple_crypto.dart';

/// The Dart half of the Network-framework transport, driven through mocked
/// method and event channels: pinning decisions stay in Dart and the
/// transport keeps its refusal reasons (os-provided-encryption task 3.2).
/// The Swift half runs in `integration_test/apple_tls_loopback_test.dart`
/// on the macOS and iOS simulators.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('smara_apple_crypto/tls_test');
  const events = EventChannel('smara_apple_crypto/tls_events_test');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  final peerDer = Uint8List.fromList(List<int>.generate(40, (i) => i));
  final peerFingerprint = 'ab' * 32;
  late List<MethodCall> calls;
  late StreamController<Object?> eventSink;
  late AppleTls tls;

  Future<bool?> askDartToVerify(int handle) async {
    final completer = Completer<bool?>();
    await messenger.handlePlatformMessage(
      channel.name,
      channel.codec.encodeMethodCall(
        MethodCall('verifyPeer', {
          'handle': handle,
          'der': peerDer,
          'fingerprint': peerFingerprint,
        }),
      ),
      (reply) => completer.complete(
        reply == null ? null : channel.codec.decodeEnvelope(reply) as bool?,
      ),
    );
    return completer.future;
  }

  setUp(() {
    calls = [];
    eventSink = StreamController<Object?>.broadcast();
    messenger.setMockStreamHandler(
      events,
      MockStreamHandler.inline(
        onListen: (_, sink) {
          eventSink.stream.listen(sink.success);
        },
      ),
    );
    tls = AppleTls(channel: channel, events: events);
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    messenger.setMockStreamHandler(events, null);
    eventSink.close();
  });

  test('connect hands the peer certificate to Dart and reports it', () async {
    final verified = <String>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (call.method == 'connect') {
        final handle = (call.arguments as Map)['handle'] as int;
        expect(await askDartToVerify(handle), isTrue);
        return {
          'id': 7,
          'peerDer': peerDer,
          'peerFingerprint': peerFingerprint,
          'remoteAddress': '192.168.1.20',
          'remotePort': 5555,
        };
      }
      return null;
    });

    final connection = await tls.connect(
      host: '192.168.1.20',
      port: 5555,
      identityLabel: 'smara-device-tls:me',
      verifyPeer: (peer) {
        verified.add(peer.fingerprint);
        return true;
      },
    );
    expect(verified, [peerFingerprint]);
    expect(connection.peer!.fingerprint, peerFingerprint);
    expect(connection.peer!.der, equals(peerDer));
    expect(connection.remoteAddress, '192.168.1.20');
    expect(connection.remotePort, 5555);
    final connectArgs = calls.single.arguments as Map;
    expect(connectArgs['identityLabel'], 'smara-device-tls:me');
    expect(connectArgs['port'], 5555);

    // Data flows through the event channel, in order, until closed.
    final received = <String>[];
    final done = Completer<void>();
    connection.data.listen(
      (bytes) => received.add(utf8.decode(bytes)),
      onDone: done.complete,
    );
    eventSink.add({'type': 'data', 'id': 7, 'bytes': utf8.encode('one')});
    eventSink.add({'type': 'data', 'id': 7, 'bytes': utf8.encode('two')});
    eventSink.add({'type': 'data', 'id': 99, 'bytes': utf8.encode('other')});
    eventSink.add({'type': 'closed', 'id': 7});
    await done.future;
    expect(received, ['one', 'two']);
  });

  test('a verifier that refuses makes the native handshake fail', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'connect') {
        final handle = (call.arguments as Map)['handle'] as int;
        final accepted = await askDartToVerify(handle);
        if (accepted != true) {
          throw PlatformException(code: 'connect_failed', message: 'refused');
        }
      }
      return null;
    });
    await expectLater(
      tls.connect(host: 'h', port: 1, verifyPeer: (_) => false),
      throwsA(isA<PlatformException>()),
    );
    // A verifier handle that is no longer pending answers false.
    expect(await askDartToVerify(12345), isFalse);
  });

  test(
    'TlsSyncTransport over the Apple socket refuses an unpinned peer',
    () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'connect') {
          final handle = (call.arguments as Map)['handle'] as int;
          if (await askDartToVerify(handle) != true) {
            throw PlatformException(code: 'connect_failed', message: 'refused');
          }
          return {
            'id': 1,
            'peerDer': peerDer,
            'peerFingerprint': peerFingerprint,
            'remoteAddress': '10.0.0.2',
            'remotePort': 4000,
          };
        }
        if (call.method == 'close') return null;
        return null;
      });
      final transport = TlsSyncTransport(
        sockets: AppleTlsSocketFactory(tls: tls),
      );
      final local = DeviceCertificate(
        derBytes: const [1, 2, 3],
        fingerprint: 'local',
        keychainIdentityLabel: 'smara-device-tls:me',
      );
      final remote = SyncPeerIdentity(
        deviceId: 'peer',
        certificate: const DeviceCertificate(derBytes: [], fingerprint: ''),
        host: '10.0.0.2',
        port: 4000,
      );

      await expectLater(
        transport.connect(
          local: SyncPeerIdentity(deviceId: 'me', certificate: local),
          remote: remote,
          pinnedFingerprints: {'somebody-else'},
        ),
        throwsA(
          isA<UnknownCertificateException>().having(
            (e) => e.fingerprint,
            'fingerprint',
            peerFingerprint,
          ),
        ),
      );

      final connection = await transport.connect(
        local: SyncPeerIdentity(deviceId: 'me', certificate: local),
        remote: remote,
        pinnedFingerprints: {peerFingerprint},
      );
      expect(connection.remote.host, '10.0.0.2');
      await connection.close();
    },
  );

  test(
    'listen reports the bound port and delivers accepted connections',
    () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        if (call.method == 'listen') return {'id': 3, 'port': 48123};
        return null;
      });
      final accepted = Completer<AppleTlsConnection>();
      final listener = await tls.listen(
        port: 0,
        identityLabel: 'smara-device-tls:me',
        requestClientCertificate: true,
        verifyPeer: (peer) => peer.fingerprint == peerFingerprint,
        onConnection: accepted.complete,
      );
      expect(listener.port, 48123);
      expect(
        (calls.single.arguments as Map)['requestClientCertificate'],
        isTrue,
      );
      expect(await askDartToVerify(3), isTrue);

      eventSink.add({
        'type': 'connection',
        'listenerId': 3,
        'id': 11,
        'peerDer': peerDer,
        'peerFingerprint': peerFingerprint,
        'remoteAddress': 'fe80::1',
        'remotePort': 50000,
      });
      final connection = await accepted.future;
      expect(connection.id, 11);
      expect(connection.peer!.fingerprint, peerFingerprint);
      await listener.close();
      expect(calls.last.method, 'stopListening');
    },
  );
}
