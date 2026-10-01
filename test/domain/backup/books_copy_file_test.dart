import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:smara_accounting/domain/backup/books_copy_file.dart';
import 'package:smara_accounting/domain/backup/device_migration_bundle_file.dart';
import 'package:smara_accounting/domain/backup/ledger_backup_file.dart';
import 'package:test/test.dart';

void main() {
  final dbBytes = Uint8List.fromList(List<int>.generate(64, (i) => i));
  const settings = <String, Object?>{
    'referenceRateLookupEnabled': true,
    'quoteProvider': 'stooq',
  };
  const passphrase = 'correct horse battery';

  group('BooksCopyFile', () {
    test('round-trips database bytes and settings', () async {
      final encoded = await BooksCopyFile.encrypt(
        databaseBytes: dbBytes,
        settings: settings,
        passphrase: passphrase,
      );
      final decoded = await BooksCopyFile.decrypt(
        fileContents: encoded,
        passphrase: passphrase,
      );
      expect(decoded.databaseBytes, equals(dbBytes));
      expect(decoded.settings, equals(settings));
      expect(decoded.sourceKind, BooksCopySourceKind.booksCopy);
      expect(jsonDecode(encoded)['kind'], BooksCopyFile.kind);
    });

    test('wrong passphrase throws', () async {
      final encoded = await BooksCopyFile.encrypt(
        databaseBytes: dbBytes,
        settings: settings,
        passphrase: passphrase,
      );
      expect(
        () => BooksCopyFile.decrypt(
          fileContents: encoded,
          passphrase: 'wrong',
        ),
        throwsA(isA<SecretBoxAuthenticationError>()),
      );
    });

    test('corrupt file throws', () async {
      final encoded = await BooksCopyFile.encrypt(
        databaseBytes: dbBytes,
        settings: settings,
        passphrase: passphrase,
      );
      final json = jsonDecode(encoded) as Map<String, dynamic>;
      json['mac'] = base64Encode(List<int>.filled(16, 0));
      expect(
        () => BooksCopyFile.decrypt(
          fileContents: jsonEncode(json),
          passphrase: passphrase,
        ),
        throwsA(isA<SecretBoxAuthenticationError>()),
      );
    });

    test('reads a legacy ledger backup with empty settings', () async {
      final legacy = await LedgerBackupFile.encrypt(
        databaseBytes: dbBytes,
        passphrase: passphrase,
      );
      final decoded = await BooksCopyFile.decrypt(
        fileContents: legacy,
        passphrase: passphrase,
      );
      expect(decoded.databaseBytes, equals(dbBytes));
      expect(decoded.settings, isEmpty);
      expect(decoded.sourceKind, BooksCopySourceKind.legacyLedgerBackup);
    });

    test('reads a legacy bundle and discards the key', () async {
      final seed = Uint8List.fromList(List<int>.generate(32, (i) => i + 1));
      final legacy = await DeviceMigrationBundleFile.encrypt(
        databaseBytes: dbBytes,
        privateKeySeed: seed,
        passphrase: passphrase,
      );
      final decoded = await BooksCopyFile.decrypt(
        fileContents: legacy,
        passphrase: passphrase,
      );
      expect(decoded.databaseBytes, equals(dbBytes));
      expect(decoded.settings, isEmpty);
      expect(
        decoded.sourceKind,
        BooksCopySourceKind.legacyDeviceMigrationBundle,
      );
      // Ensure the key is not present on the returned object surface.
      expect(decoded.toString().contains(base64Encode(seed)), isFalse);
    });
  });
}
