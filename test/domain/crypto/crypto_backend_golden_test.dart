import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/domain/crypto/dart_crypto_backend.dart';

import '../../fixtures/books_copy/dart_backend_v1.dart';
import 'crypto_backend_golden_suite.dart';

void main() {
  runCryptoBackendGoldenSuite('dart', () => const DartCryptoBackend());

  test('the embedded Books Copy fixture matches dart_backend_v1.json', () {
    final root = Directory.current.path.endsWith('/test')
        ? Directory.current.parent.path
        : Directory.current.path;
    final json = File(
      '$root/test/fixtures/books_copy/dart_backend_v1.json',
    ).readAsStringSync().trimRight();
    expect(booksCopyDartBackendV1, json);
  });
}
