import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smara_accounting/domain/backup/books_copy_file.dart';
import 'package:smara_accounting/domain/crypto/apple_crypto_backend.dart';
import 'package:smara_accounting/domain/crypto/crypto_backend.dart';
import 'package:smara_accounting/domain/crypto/dart_crypto_backend.dart';

import '../test/domain/crypto/crypto_backend_golden_suite.dart';

/// os-provided-encryption task 2.2: the golden-vector suite shared with
/// `test/domain/crypto/crypto_backend_golden_test.dart`, run against the
/// Apple backend (CryptoKit / CommonCrypto through `smara_apple_crypto`).
///
/// Run on a simulator or device (the Books Copy fixture is embedded, so no
/// repository files are needed):
///   flutter test integration_test/crypto_backend_golden_test.dart -d macos
///   flutter test integration_test/crypto_backend_golden_test.dart -d `<ios sim>`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  test('the Apple backend is selected on this platform', () {
    expect(
      isApplePlatform(defaultTargetPlatform),
      isTrue,
      reason: 'This suite targets iOS and macOS simulators.',
    );
    expect(selectCryptoBackend(), isA<AppleCryptoBackend>());
  });

  runCryptoBackendGoldenSuite('apple', () => const AppleCryptoBackend());

  // Task 6.6 across backends: a Books Copy saved on an iPhone or Mac must
  // restore on Android/Windows/Linux (the Dart backend), and the other way
  // round; a wrong passphrase fails the same on both. The Dart side runs with
  // Android reported as the platform so the Apple-platform guard allows it.
  Future<T> asAndroid<T>(Future<T> Function() body) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    try {
      return await body();
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }

  const apple = AppleCryptoBackend();
  const dart = DartCryptoBackend();
  final receipts = {
    'r1': [1, 2, 3],
  };

  test('Books Copy saved on Apple restores on Android (Dart)', () async {
    final copy = await BooksCopyFile.encrypt(
      databaseBytes: booksCopyFixtureDatabaseBytes,
      settings: booksCopyFixtureSettings,
      passphrase: booksCopyFixturePassphrase,
      receiptsById: receipts,
      backend: apple,
    );
    final restored = await asAndroid(
      () => BooksCopyFile.decrypt(
        fileContents: copy,
        passphrase: booksCopyFixturePassphrase,
        backend: dart,
      ),
    );
    expect(restored.databaseBytes, equals(booksCopyFixtureDatabaseBytes));
    expect(restored.settings, equals(booksCopyFixtureSettings));
    expect(restored.receiptsById['r1'], equals([1, 2, 3]));
    await expectLater(
      asAndroid(
        () => BooksCopyFile.decrypt(
          fileContents: copy,
          passphrase: 'not the passphrase',
          backend: dart,
        ),
      ),
      throwsA(isA<CryptoAuthenticationException>()),
    );
  });

  test('Books Copy saved on Android (Dart) restores on Apple', () async {
    final copy = await asAndroid(
      () => BooksCopyFile.encrypt(
        databaseBytes: booksCopyFixtureDatabaseBytes,
        settings: booksCopyFixtureSettings,
        passphrase: booksCopyFixturePassphrase,
        receiptsById: receipts,
        backend: dart,
      ),
    );
    final restored = await BooksCopyFile.decrypt(
      fileContents: copy,
      passphrase: booksCopyFixturePassphrase,
      backend: apple,
    );
    expect(restored.databaseBytes, equals(booksCopyFixtureDatabaseBytes));
    expect(restored.receiptsById['r1'], equals([1, 2, 3]));
    await expectLater(
      BooksCopyFile.decrypt(
        fileContents: copy,
        passphrase: 'not the passphrase',
        backend: apple,
      ),
      throwsA(isA<CryptoAuthenticationException>()),
    );
  });

  test('ledger signatures verify across backends', () async {
    final message = List<int>.generate(32, (i) => i);
    final appleKey = await apple.ed25519Generate();
    final appleSig = await apple.ed25519Sign(
      seed: appleKey.privateKeySeed,
      message: message,
    );
    expect(
      await asAndroid(
        () => dart.ed25519Verify(
          publicKey: appleKey.publicKey,
          message: message,
          signature: appleSig,
        ),
      ),
      isTrue,
    );
    final dartKey = await asAndroid(dart.ed25519Generate);
    final dartSig = await asAndroid(
      () => dart.ed25519Sign(seed: dartKey.privateKeySeed, message: message),
    );
    expect(
      await apple.ed25519Verify(
        publicKey: dartKey.publicKey,
        message: message,
        signature: dartSig,
      ),
      isTrue,
    );
  });
}
