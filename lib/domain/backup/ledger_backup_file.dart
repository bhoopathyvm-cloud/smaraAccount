import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Passphrase-protected encryption of an arbitrary byte payload -
/// specifically, the raw local ledger database file (ledger-backup-restore:
/// "the encrypted raw SQLite file, not a logical export"). Same primitive
/// family as `KeystoreFile` (AES-256-GCM, PBKDF2-HMAC-SHA256), kept as a
/// separate class since it protects a different, much larger and
/// structurally different payload - the whole database, not a 32-byte key
/// seed - and carries its own format tag so the two file types are never
/// confused with each other.
class LedgerBackupFile {
  const LedgerBackupFile._();

  static const _formatVersion = 1;
  static const _kind = 'smara-ledger-backup';
  static const _iterations = 210000;
  static const _saltLength = 16;

  /// Encrypts [databaseBytes] under [passphrase] and returns the backup
  /// file contents as a JSON string, ready to write to disk.
  static Future<String> encrypt({
    required List<int> databaseBytes,
    required String passphrase,
  }) async {
    final random = Random.secure();
    final salt = List<int>.generate(_saltLength, (_) => random.nextInt(256));
    final secretKey = await _deriveKey(passphrase: passphrase, salt: salt);

    final box = await AesGcm.with256bits().encrypt(
      databaseBytes,
      secretKey: secretKey,
    );

    return jsonEncode({
      'kind': _kind,
      'version': _formatVersion,
      'kdf': 'pbkdf2-hmac-sha256',
      'iterations': _iterations,
      'salt': base64Encode(salt),
      'nonce': base64Encode(box.nonce),
      'cipherText': base64Encode(box.cipherText),
      'mac': base64Encode(box.mac.bytes),
    });
  }

  /// Decrypts a backup file's JSON contents under [passphrase], returning
  /// the original database bytes. Throws [SecretBoxAuthenticationError] if
  /// the passphrase is wrong or the file was tampered with, and
  /// [FormatException] if the contents aren't a valid backup file (either
  /// malformed JSON or a file of the wrong kind, e.g. a keystore file
  /// mistakenly selected here).
  static Future<Uint8List> decrypt({
    required String fileContents,
    required String passphrase,
  }) async {
    final json = jsonDecode(fileContents) as Map<String, dynamic>;
    if (json['kind'] != _kind) {
      throw const FormatException('This file is not a Smara ledger backup.');
    }
    if (json['version'] != _formatVersion) {
      throw FormatException(
        'Unsupported ledger backup file version: ${json['version']}',
      );
    }
    final salt = base64Decode(json['salt'] as String);
    final iterations = json['iterations'] as int;
    final secretKey = await _deriveKey(
      passphrase: passphrase,
      salt: salt,
      iterations: iterations,
    );

    final box = SecretBox(
      base64Decode(json['cipherText'] as String),
      nonce: base64Decode(json['nonce'] as String),
      mac: Mac(base64Decode(json['mac'] as String)),
    );

    final plainText = await AesGcm.with256bits().decrypt(
      box,
      secretKey: secretKey,
    );
    return Uint8List.fromList(plainText);
  }

  static Future<SecretKey> _deriveKey({
    required String passphrase,
    required List<int> salt,
    int iterations = _iterations,
  }) {
    return Pbkdf2.hmacSha256(
      iterations: iterations,
      bits: 256,
    ).deriveKeyFromPassword(password: passphrase, nonce: salt);
  }
}
