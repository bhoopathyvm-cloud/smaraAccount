import 'package:cryptography/cryptography.dart'
    show SecretBoxAuthenticationError;
import 'package:smara_accounting/domain/backup/device_migration_bundle_file.dart';
import 'package:smara_accounting/domain/crypto/keystore_file.dart';
import 'package:test/test.dart';

void main() {
  final seed = List<int>.generate(32, (i) => i);
  final databaseBytes = List<int>.generate(64, (i) => 255 - i);

  group('encrypt / decrypt round trip', () {
    test('decrypting with the correct passphrase recovers both the database '
        'bytes and the private key seed', () async {
      final file = await DeviceMigrationBundleFile.encrypt(
        databaseBytes: databaseBytes,
        privateKeySeed: seed,
        passphrase: 'correct horse battery staple',
      );

      final decrypted = await DeviceMigrationBundleFile.decrypt(
        fileContents: file,
        passphrase: 'correct horse battery staple',
      );

      expect(decrypted.databaseBytes, equals(databaseBytes));
      expect(decrypted.privateKeySeed, equals(seed));
    });

    test('decrypting with the wrong passphrase throws', () async {
      final file = await DeviceMigrationBundleFile.encrypt(
        databaseBytes: databaseBytes,
        privateKeySeed: seed,
        passphrase: 'correct horse battery staple',
      );

      expect(
        () => DeviceMigrationBundleFile.decrypt(
          fileContents: file,
          passphrase: 'wrong passphrase',
        ),
        throwsA(isA<SecretBoxAuthenticationError>()),
      );
    });
  });

  group('mismatched file kind', () {
    test(
      'decrypting a keystore file as a bundle throws FormatException',
      () async {
        final keystoreFile = await KeystoreFile.encrypt(
          privateKeySeed: seed,
          passphrase: 'p',
        );

        expect(
          () => DeviceMigrationBundleFile.decrypt(
            fileContents: keystoreFile,
            passphrase: 'p',
          ),
          throwsA(isA<FormatException>()),
        );
      },
    );
  });

  group('encrypt', () {
    test(
      'produces different ciphertext for the same inputs each time',
      () async {
        final a = await DeviceMigrationBundleFile.encrypt(
          databaseBytes: databaseBytes,
          privateKeySeed: seed,
          passphrase: 'p',
        );
        final b = await DeviceMigrationBundleFile.encrypt(
          databaseBytes: databaseBytes,
          privateKeySeed: seed,
          passphrase: 'p',
        );

        expect(a, isNot(equals(b)));
      },
    );
  });
}
