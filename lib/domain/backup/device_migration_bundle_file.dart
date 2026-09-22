import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Passphrase-protected export/import of the raw local ledger database
/// file and the private key seed together, for moving to a new device in
/// one step (spec: `device-migration-bundle`). Same primitive family as
/// `KeystoreFile`/`LedgerBackupFile` (AES-256-GCM, PBKDF2-HMAC-SHA256),
/// kept as its own class and format tag - a compromised bundle grants
/// both data read access and signing capability, a strictly larger
/// exposure than either existing artifact alone, so it must never be
/// confused with a data-only `ledger-backup` file by construction, not
/// just by UI copy.
class DeviceMigrationBundleFile {
  const DeviceMigrationBundleFile._();

  static const _formatVersion = 1;
  static const _kind = 'smara-device-migration-bundle';
  static const _iterations = 210000;
  static const _saltLength = 16;

  /// Encrypts [databaseBytes] and [privateKeySeed] together under
  /// [passphrase] and returns the bundle file's contents as a JSON
  /// string, ready to write to disk.
  static Future<String> encrypt({
    required List<int> databaseBytes,
    required List<int> privateKeySeed,
    required String passphrase,
  }) async {
    final random = Random.secure();
    final salt = List<int>.generate(_saltLength, (_) => random.nextInt(256));
    final secretKey = await _deriveKey(passphrase: passphrase, salt: salt);

    final payload = utf8.encode(
      jsonEncode({
        'db': base64Encode(databaseBytes),
        'key': base64Encode(privateKeySeed),
      }),
    );
    final box = await AesGcm.with256bits().encrypt(
      payload,
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

  /// Decrypts a bundle file's JSON contents under [passphrase], returning
  /// the original database bytes and private key seed. Throws
  /// [SecretBoxAuthenticationError] if the passphrase is wrong or the
  /// file was tampered with, and [FormatException] if the contents aren't
  /// a valid bundle file (malformed JSON, or a `kind`/`version` mismatch -
  /// e.g. a `KeystoreFile` or `LedgerBackupFile` selected by mistake).
  static Future<DeviceMigrationBundle> decrypt({
    required String fileContents,
    required String passphrase,
  }) async {
    final json = jsonDecode(fileContents) as Map<String, dynamic>;
    if (json['kind'] != _kind) {
      throw const FormatException(
        'This file is not a Smara device migration bundle.',
      );
    }
    if (json['version'] != _formatVersion) {
      throw FormatException(
        'Unsupported device migration bundle version: ${json['version']}',
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
    final payload = jsonDecode(utf8.decode(plainText)) as Map<String, dynamic>;
    return DeviceMigrationBundle(
      databaseBytes: base64Decode(payload['db'] as String),
      privateKeySeed: base64Decode(payload['key'] as String),
    );
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

/// The decrypted contents of a [DeviceMigrationBundleFile]: a ledger
/// database and the private key seed that signed it, restorable together
/// in one step.
class DeviceMigrationBundle {
  const DeviceMigrationBundle({
    required this.databaseBytes,
    required this.privateKeySeed,
  });

  final Uint8List databaseBytes;
  final Uint8List privateKeySeed;
}
