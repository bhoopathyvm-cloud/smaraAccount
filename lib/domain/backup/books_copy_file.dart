import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import '../crypto/crypto_backend.dart';

/// Passphrase-protected Books Copy: the encrypted raw SQLite database plus
/// the books' settings. Never carries a private key (ADR 0004 /
/// books-copy-and-continuation).
///
/// Same cipher family as the retired ledger backup and device migration
/// bundle (AES-256-GCM, PBKDF2-HMAC-SHA256 @ 210,000 iterations). The
/// reader also accepts those legacy kinds and discards any key they carry.
///
/// All cryptography goes through [CryptoBackend], so a copy saved on any
/// platform restores on every other: the file layout (`salt`, `nonce`,
/// `cipherText`, `mac`) is identical whichever backend produced it.
class BooksCopyFile {
  const BooksCopyFile._();

  static const formatVersion = 1;
  static const kind = 'smara-books-copy';
  static const legacyLedgerBackupKind = 'smara-ledger-backup';
  static const legacyDeviceMigrationBundleKind =
      'smara-device-migration-bundle';
  static const _iterations = 210000;
  static const _saltLength = 16;

  /// Encrypts [databaseBytes] and [settings] under [passphrase] as a
  /// `smara-books-copy` v1 file. Optional [receiptsById] maps receipt id →
  /// raw bytes (Claim receipts under `books/<id>/receipts/`).
  static Future<String> encrypt({
    required List<int> databaseBytes,
    required Map<String, Object?> settings,
    required String passphrase,
    Map<String, List<int>> receiptsById = const {},
    CryptoBackend? backend,
  }) async {
    final crypto = backend ?? CryptoBackend.instance;
    final random = Random.secure();
    final salt = List<int>.generate(_saltLength, (_) => random.nextInt(256));
    final secretKey = await _deriveKey(
      crypto,
      passphrase: passphrase,
      salt: salt,
    );

    final payload = utf8.encode(
      jsonEncode({
        'db': base64Encode(databaseBytes),
        'settings': settings,
        if (receiptsById.isNotEmpty)
          'receipts': {
            for (final e in receiptsById.entries) e.key: base64Encode(e.value),
          },
      }),
    );
    final box = await crypto.aesGcmEncrypt(key: secretKey, plainText: payload);

    return jsonEncode({
      'kind': kind,
      'version': formatVersion,
      'kdf': 'pbkdf2-hmac-sha256',
      'iterations': _iterations,
      'salt': base64Encode(salt),
      'nonce': base64Encode(box.nonce),
      'cipherText': base64Encode(box.cipherText),
      'mac': base64Encode(box.mac),
    });
  }

  /// Decrypts a Books Copy or a legacy backup/bundle. Legacy files return
  /// empty settings; a bundle's private key is discarded and never returned.
  /// Throws [CryptoAuthenticationException] for a wrong passphrase or a
  /// tampered file.
  static Future<BooksCopyContents> decrypt({
    required String fileContents,
    required String passphrase,
    CryptoBackend? backend,
  }) async {
    final crypto = backend ?? CryptoBackend.instance;
    final json = jsonDecode(fileContents) as Map<String, dynamic>;
    final fileKind = json['kind'];
    if (fileKind == kind) {
      return _decryptBooksCopy(crypto, json: json, passphrase: passphrase);
    }
    if (fileKind == legacyLedgerBackupKind) {
      final db = await _decryptRawPayload(
        crypto,
        json: json,
        passphrase: passphrase,
      );
      return BooksCopyContents(
        databaseBytes: db,
        settings: const {},
        sourceKind: BooksCopySourceKind.legacyLedgerBackup,
      );
    }
    if (fileKind == legacyDeviceMigrationBundleKind) {
      final plain = await _decryptRawPayload(
        crypto,
        json: json,
        passphrase: passphrase,
      );
      final payload = jsonDecode(utf8.decode(plain)) as Map<String, dynamic>;
      // Discard `key` deliberately - never return or write it.
      return BooksCopyContents(
        databaseBytes: base64Decode(payload['db'] as String),
        settings: const {},
        sourceKind: BooksCopySourceKind.legacyDeviceMigrationBundle,
      );
    }
    throw const FormatException(
      'This file is not a Smara books copy, ledger backup, or device '
      'migration bundle.',
    );
  }

  static Future<BooksCopyContents> _decryptBooksCopy(
    CryptoBackend crypto, {
    required Map<String, dynamic> json,
    required String passphrase,
  }) async {
    if (json['version'] != formatVersion) {
      throw FormatException(
        'Unsupported books copy file version: ${json['version']}',
      );
    }
    final plain = await _decryptRawPayload(
      crypto,
      json: json,
      passphrase: passphrase,
    );
    final payload = jsonDecode(utf8.decode(plain)) as Map<String, dynamic>;
    final settingsRaw = payload['settings'];
    final settings = <String, Object?>{};
    if (settingsRaw is Map) {
      settingsRaw.forEach((key, value) {
        settings[key.toString()] = value;
      });
    }
    final receiptsRaw = payload['receipts'];
    final receipts = <String, List<int>>{};
    if (receiptsRaw is Map) {
      receiptsRaw.forEach((key, value) {
        if (value is String) {
          receipts[key.toString()] = base64Decode(value);
        }
      });
    }
    return BooksCopyContents(
      databaseBytes: base64Decode(payload['db'] as String),
      settings: settings,
      receiptsById: receipts,
      sourceKind: BooksCopySourceKind.booksCopy,
    );
  }

  static Future<Uint8List> _decryptRawPayload(
    CryptoBackend crypto, {
    required Map<String, dynamic> json,
    required String passphrase,
  }) async {
    final salt = base64Decode(json['salt'] as String);
    final iterations = json['iterations'] as int;
    final secretKey = await _deriveKey(
      crypto,
      passphrase: passphrase,
      salt: salt,
      iterations: iterations,
    );

    final box = AesGcmBox(
      nonce: base64Decode(json['nonce'] as String),
      cipherText: base64Decode(json['cipherText'] as String),
      mac: base64Decode(json['mac'] as String),
    );
    return crypto.aesGcmDecrypt(key: secretKey, box: box);
  }

  static Future<Uint8List> _deriveKey(
    CryptoBackend crypto, {
    required String passphrase,
    required List<int> salt,
    int iterations = _iterations,
  }) {
    return crypto.pbkdf2HmacSha256(
      password: utf8.encode(passphrase),
      salt: salt,
      iterations: iterations,
      keyLength: 32,
    );
  }
}

/// Decrypted contents of a Books Copy (or a legacy file read as one).
/// Never includes a private key.
class BooksCopyContents {
  const BooksCopyContents({
    required this.databaseBytes,
    required this.settings,
    required this.sourceKind,
    this.receiptsById = const {},
  });

  final Uint8List databaseBytes;
  final Map<String, Object?> settings;
  final BooksCopySourceKind sourceKind;

  /// Claim receipt blobs keyed by receipt id (empty for legacy copies).
  final Map<String, List<int>> receiptsById;
}

enum BooksCopySourceKind {
  booksCopy,
  legacyLedgerBackup,
  legacyDeviceMigrationBundle,
}
