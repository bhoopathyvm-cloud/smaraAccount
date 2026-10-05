import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/data/http/platform_http_client.dart';
import 'package:smara_accounting/data/peer_sync/socket_sync_transport.dart';
import 'package:smara_accounting/domain/crypto/apple_crypto_backend.dart';
import 'package:smara_accounting/domain/crypto/crypto_backend.dart';
import 'package:smara_accounting/domain/crypto/dart_crypto_backend.dart';
import 'package:smara_accounting/domain/linked_devices/apple_device_certificate_store.dart';
import 'package:smara_accounting/domain/linked_devices/persisting_device_certificate_store.dart';
import 'package:smara_accounting/domain/linked_devices/platform_device_certificate_store.dart';
import 'package:smara_accounting/domain/peer_sync/apple_tls_socket_factory.dart';
import 'package:smara_accounting/domain/peer_sync/dart_tls_socket_factory.dart';
import 'package:smara_accounting/domain/peer_sync/tls_socket.dart';

import 'in_memory_secure_key_storage.dart';

/// os-provided-encryption design D6: the Apple backend is selected for iOS
/// and macOS, the Dart implementation fails loudly there, and no `lib/` file
/// outside the Dart backend reaches a Dart crypto library.
void main() {
  final root = Directory.current.path.endsWith('/test')
      ? Directory.current.parent.path
      : Directory.current.path;

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    CryptoBackend.reset();
  });

  group('selection', () {
    const apple = [TargetPlatform.iOS, TargetPlatform.macOS];
    const others = [
      TargetPlatform.android,
      TargetPlatform.linux,
      TargetPlatform.windows,
      TargetPlatform.fuchsia,
    ];

    test('CryptoBackend: Apple on iOS and macOS, Dart elsewhere', () {
      for (final platform in apple) {
        expect(
          selectCryptoBackend(platform: platform),
          isA<AppleCryptoBackend>(),
          reason: '$platform',
        );
      }
      for (final platform in others) {
        expect(
          selectCryptoBackend(platform: platform),
          isA<DartCryptoBackend>(),
          reason: '$platform',
        );
      }
    });

    test('TlsSocketFactory and SyncTransport follow the platform', () {
      for (final platform in apple) {
        expect(
          TlsSocketFactory.forPlatform(platform: platform),
          isA<AppleTlsSocketFactory>(),
        );
        expect(
          createPlatformSyncTransport(platform: platform),
          isA<AppleTlsSyncTransport>(),
        );
      }
      for (final platform in others) {
        expect(
          TlsSocketFactory.forPlatform(platform: platform),
          isA<DartTlsSocketFactory>(),
        );
        expect(
          createPlatformSyncTransport(platform: platform),
          isA<SocketSyncTransport>(),
        );
      }
    });

    test('DeviceCertificateStore follows the platform', () {
      for (final platform in apple) {
        expect(
          createPlatformDeviceCertificateStore(
            secureStorage: InMemorySecureKeyStorage(),
            platform: platform,
          ),
          isA<AppleDeviceCertificateStore>(),
        );
      }
      for (final platform in others) {
        expect(
          createPlatformDeviceCertificateStore(
            secureStorage: InMemorySecureKeyStorage(),
            platform: platform,
          ),
          isA<PersistingDeviceCertificateStore>(),
        );
      }
    });

    test('HTTPS client kind follows the platform', () {
      for (final platform in apple) {
        expect(
          platformHttpClientKindFor(platform),
          PlatformHttpClientKind.appleUrlSession,
        );
      }
      for (final platform in others) {
        expect(
          platformHttpClientKindFor(platform),
          PlatformHttpClientKind.dartIo,
        );
      }
    });

    test('the process-wide instance is the platform selection', () {
      CryptoBackend.reset();
      // Unit tests report Android as the target platform.
      expect(CryptoBackend.instance, isA<DartCryptoBackend>());
      CryptoBackend.use(const AppleCryptoBackend());
      expect(CryptoBackend.instance, isA<AppleCryptoBackend>());
    });
  });

  group('debug guard (D6)', () {
    test('the Dart backend throws when reached on iOS or macOS', () async {
      const backend = DartCryptoBackend();
      for (final platform in [TargetPlatform.iOS, TargetPlatform.macOS]) {
        debugDefaultTargetPlatformOverride = platform;
        await expectLater(
          backend.sha256(const [1, 2, 3]),
          throwsA(isA<DartCryptoOnApplePlatformError>()),
          reason: '$platform',
        );
        expect(
          () => DartCryptoBackend.sha256HexSync(const [1]),
          throwsA(isA<DartCryptoOnApplePlatformError>()),
        );
        await expectLater(
          backend.ed25519Generate(),
          throwsA(isA<DartCryptoOnApplePlatformError>()),
        );
        await expectLater(
          backend.pbkdf2HmacSha256(
            password: const [1],
            salt: const [2],
            iterations: 1,
          ),
          throwsA(isA<DartCryptoOnApplePlatformError>()),
        );
      }
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(await backend.sha256(const [1, 2, 3]), hasLength(32));
    });

    test('startup check fails loudly when the wrong backend is installed', () {
      CryptoBackend.use(const DartCryptoBackend());
      expect(
        () => debugCheckCryptoBackendMatchesPlatform(
          platform: TargetPlatform.iOS,
        ),
        throwsA(isA<DartCryptoOnApplePlatformError>()),
      );
      expect(
        () => debugCheckCryptoBackendMatchesPlatform(
          platform: TargetPlatform.android,
        ),
        returnsNormally,
      );
      CryptoBackend.use(const AppleCryptoBackend());
      expect(
        () => debugCheckCryptoBackendMatchesPlatform(
          platform: TargetPlatform.macOS,
        ),
        returnsNormally,
      );
    });
  });

  group('no app-provided crypto outside the Dart backend', () {
    final libFiles = Directory('$root/lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();

    test('only dart_crypto_backend.dart imports a Dart crypto library', () {
      const allowed = 'lib/domain/crypto/dart_crypto_backend.dart';
      final offenders = <String>[];
      for (final file in libFiles) {
        final text = file.readAsStringSync();
        if (text.contains("import 'package:cryptography/") ||
            text.contains("import 'package:crypto/") ||
            text.contains("import 'package:pointycastle/")) {
          final relative = file.path.substring(root.length + 1);
          if (relative != allowed) offenders.add(relative);
        }
      }
      expect(offenders, isEmpty);
    });

    test('only the Dart identity store imports basic_utils', () {
      const allowed =
          'lib/domain/linked_devices/persisting_device_certificate_store.dart';
      final offenders = <String>[];
      for (final file in libFiles) {
        if (file.readAsStringSync().contains("import 'package:basic_utils/")) {
          final relative = file.path.substring(root.length + 1);
          if (relative != allowed) offenders.add(relative);
        }
      }
      expect(offenders, isEmpty);
    });

    test('only the Dart socket factory opens SecureSocket', () {
      const allowed = 'lib/domain/peer_sync/dart_tls_socket_factory.dart';
      final offenders = <String>[];
      for (final file in libFiles) {
        final text = file.readAsStringSync();
        if (text.contains('SecureSocket.connect') ||
            text.contains('SecureServerSocket.bind')) {
          final relative = file.path.substring(root.length + 1);
          if (relative != allowed) offenders.add(relative);
        }
      }
      expect(offenders, isEmpty);
    });
  });
}
