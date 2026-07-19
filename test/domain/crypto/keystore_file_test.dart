import 'package:cryptography/cryptography.dart'
    show SecretBoxAuthenticationError;
import 'package:smara_accounting/domain/crypto/keystore_file.dart';
import 'package:test/test.dart';

void main() {
  final seed = List<int>.generate(32, (i) => i);

  group('encrypt / decrypt round trip', () {
    test(
      'decrypting with the correct passphrase recovers the original seed',
      () async {
        final file = await KeystoreFile.encrypt(
          privateKeySeed: seed,
          passphrase: 'correct horse battery staple',
        );

        final decrypted = await KeystoreFile.decrypt(
          fileContents: file,
          passphrase: 'correct horse battery staple',
        );

        expect(decrypted, equals(seed));
      },
    );

    test('decrypting with the wrong passphrase throws', () async {
      final file = await KeystoreFile.encrypt(
        privateKeySeed: seed,
        passphrase: 'correct horse battery staple',
      );

      expect(
        () => KeystoreFile.decrypt(
          fileContents: file,
          passphrase: 'wrong passphrase',
        ),
        throwsA(isA<SecretBoxAuthenticationError>()),
      );
    });
  });

  group('encrypt', () {
    test(
      'produces different ciphertext for the same seed and passphrase each time',
      () async {
        final a = await KeystoreFile.encrypt(
          privateKeySeed: seed,
          passphrase: 'p',
        );
        final b = await KeystoreFile.encrypt(
          privateKeySeed: seed,
          passphrase: 'p',
        );

        // Random nonce per encryption means the serialized file differs even
        // for identical inputs - a stolen file from one export attempt
        // doesn't help decrypt another.
        expect(a, isNot(equals(b)));
      },
    );
  });
}
