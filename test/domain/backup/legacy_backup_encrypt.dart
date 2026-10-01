import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:smara_accounting/domain/backup/books_copy_file.dart';

/// Test-only helpers that produce retired file kinds so [BooksCopyFile]
/// can prove it still reads them. Production code never writes these.
Future<String> encryptLegacyLedgerBackup({
  required List<int> databaseBytes,
  required String passphrase,
}) {
  return _encryptRaw(
    kind: BooksCopyFile.legacyLedgerBackupKind,
    plain: Uint8List.fromList(databaseBytes),
    passphrase: passphrase,
  );
}

Future<String> encryptLegacyDeviceMigrationBundle({
  required List<int> databaseBytes,
  required List<int> privateKeySeed,
  required String passphrase,
}) {
  final payload = utf8.encode(
    jsonEncode({
      'db': base64Encode(databaseBytes),
      'key': base64Encode(privateKeySeed),
    }),
  );
  return _encryptRaw(
    kind: BooksCopyFile.legacyDeviceMigrationBundleKind,
    plain: Uint8List.fromList(payload),
    passphrase: passphrase,
  );
}

Future<String> _encryptRaw({
  required String kind,
  required Uint8List plain,
  required String passphrase,
}) async {
  const iterations = 210000;
  const saltLength = 16;
  final random = Random.secure();
  final salt = List<int>.generate(saltLength, (_) => random.nextInt(256));
  final secretKey = await Pbkdf2.hmacSha256(
    iterations: iterations,
    bits: 256,
  ).deriveKeyFromPassword(password: passphrase, nonce: salt);
  final box = await AesGcm.with256bits().encrypt(
    plain,
    secretKey: secretKey,
  );
  return jsonEncode({
    'kind': kind,
    'version': 1,
    'kdf': 'pbkdf2-hmac-sha256',
    'iterations': iterations,
    'salt': base64Encode(salt),
    'nonce': base64Encode(box.nonce),
    'cipherText': base64Encode(box.cipherText),
    'mac': base64Encode(box.mac.bytes),
  });
}
