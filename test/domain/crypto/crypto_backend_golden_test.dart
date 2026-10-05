import 'dart:io';

import 'package:smara_accounting/domain/crypto/dart_crypto_backend.dart';

import 'crypto_backend_golden_suite.dart';

void main() {
  final root = Directory.current.path.endsWith('/test')
      ? Directory.current.parent.path
      : Directory.current.path;
  runCryptoBackendGoldenSuite(
    'dart',
    () => const DartCryptoBackend(),
    repoRoot: root,
  );
}
