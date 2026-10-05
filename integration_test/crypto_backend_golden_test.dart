import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smara_accounting/domain/crypto/apple_crypto_backend.dart';
import 'package:smara_accounting/domain/crypto/crypto_backend.dart';

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
}
