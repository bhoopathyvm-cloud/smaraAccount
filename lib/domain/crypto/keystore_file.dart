import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// Passphrase-protected export/import of the raw 32-byte Ed25519 seed, as
/// an alternative or supplement to the recovery phrase (spec: "Optional
/// keystore file export"). The file is a self-contained JSON document -
/// nothing about decrypting it depends on this app's database or any
/// external service, matching the "no server-side escrow" constraint.
class KeystoreFile {
  const KeystoreFile._();

  static const _formatVersion = 1;
  static const _iterations = 210000;
  static const _saltLength = 16;

  /// Encrypts [privateKeySeed] under [passphrase] and returns the keystore
  /// file contents as a JSON string, ready to write to disk.
  static Future<String> encrypt({
    required List<int> privateKeySeed,
    required String passphrase,
  }) async {
    final random = Random.secure();
    final salt = List<int>.generate(_saltLength, (_) => random.nextInt(256));
    final secretKey = await _deriveKey(passphrase: passphrase, salt: salt);

    final box = await AesGcm.with256bits().encrypt(
      privateKeySeed,
      secretKey: secretKey,
    );

    return jsonEncode({
      'version': _formatVersion,
      'kdf': 'pbkdf2-hmac-sha256',
      'iterations': _iterations,
      'salt': base64Encode(salt),
      'nonce': base64Encode(box.nonce),
      'cipherText': base64Encode(box.cipherText),
      'mac': base64Encode(box.mac.bytes),
    });
  }

  /// Decrypts a keystore file's JSON contents under [passphrase], returning
  /// the original private key seed. Throws [SecretBoxAuthenticationError]
  /// if the passphrase is wrong or the file was tampered with, and
  /// [FormatException] if the contents aren't a valid keystore file.
  static Future<Uint8List> decrypt({
    required String fileContents,
    required String passphrase,
  }) async {
    final json = jsonDecode(fileContents) as Map<String, dynamic>;
    if (json['version'] != _formatVersion) {
      throw FormatException(
        'Unsupported keystore file version: ${json['version']}',
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
