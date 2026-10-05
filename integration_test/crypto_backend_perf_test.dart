import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smara_accounting/domain/crypto/apple_crypto_backend.dart';
import 'package:smara_accounting/domain/crypto/crypto_backend.dart';
import 'package:smara_accounting/domain/crypto/dart_crypto_backend.dart';

/// os-provided-encryption task 2.4: the cryptographic work of verifying a
/// 10,000-entry chain - one batched SHA-256 over the canonical entry bytes
/// plus one Ed25519 verification per entry, as `LedgerChainVerifier` does -
/// on the Apple backend must take no more than 2x the Dart backend's time.
/// The database reads around it are the same for both backends.
///
///   flutter test integration_test/crypto_backend_perf_test.dart -d macos
///   flutter test integration_test/crypto_backend_perf_test.dart -d `<ios sim>`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const entries = 10000;
  // A typical canonical entry: ~400 bytes.
  final canonical = [
    for (var i = 0; i < entries; i++)
      Uint8List.fromList(List<int>.generate(400, (b) => (b * 31 + i) & 0xff)),
  ];

  Future<Duration> verifyChainCrypto(CryptoBackend backend) async {
    final key = await backend.ed25519Generate();
    // Signatures are made outside the timed section.
    final hashes = await backend.sha256Many(canonical);
    final signatures = [
      for (final h in hashes)
        await backend.ed25519Sign(seed: key.privateKeySeed, message: h),
    ];
    final watch = Stopwatch()..start();
    final recomputed = await backend.sha256Many(canonical);
    for (var i = 0; i < entries; i++) {
      final ok = await backend.ed25519Verify(
        message: recomputed[i],
        signature: signatures[i],
        publicKey: key.publicKey,
      );
      if (!ok) fail('signature $i did not verify');
    }
    watch.stop();
    return watch.elapsed;
  }

  test('Apple chain-verification crypto is within 2x of Dart', () async {
    expect(isApplePlatform(defaultTargetPlatform), isTrue);
    final apple = await verifyChainCrypto(const AppleCryptoBackend());

    // Today's backend, measured in the same process: report Android so the
    // Apple-platform guard lets the Dart backend run for the comparison.
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final Duration dart;
    try {
      dart = await verifyChainCrypto(const DartCryptoBackend());
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }

    final ratio = apple.inMicroseconds / dart.inMicroseconds;
    // ignore: avoid_print
    print(
      'PERF $entries entries: apple=${apple.inMilliseconds} ms '
      'dart=${dart.inMilliseconds} ms ratio=${ratio.toStringAsFixed(2)}',
    );
    expect(ratio, lessThanOrEqualTo(2.0));
  }, timeout: const Timeout(Duration(minutes: 10)));
}
