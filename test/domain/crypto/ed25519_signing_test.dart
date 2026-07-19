import 'package:smara_accounting/domain/crypto/ed25519_signing.dart';
import 'package:test/test.dart';

void main() {
  final signer = const Ed25519Signing();

  group('keyPairFromSeed', () {
    test('same seed deterministically derives the same key pair', () async {
      final seed = List<int>.generate(32, (i) => i);

      final first = await signer.keyPairFromSeed(seed);
      final second = await signer.keyPairFromSeed(seed);

      expect(first.publicKey, equals(second.publicKey));
      expect(first.privateKeySeed, equals(second.privateKeySeed));
    });

    test('different seeds derive different key pairs', () async {
      final seedA = List<int>.generate(32, (i) => i);
      final seedB = List<int>.generate(32, (i) => i + 1);

      final a = await signer.keyPairFromSeed(seedA);
      final b = await signer.keyPairFromSeed(seedB);

      expect(a.publicKey, isNot(equals(b.publicKey)));
    });
  });

  group('generateKeyPair', () {
    test('produces different key pairs on each call', () async {
      final a = await signer.generateKeyPair();
      final b = await signer.generateKeyPair();

      expect(a.publicKey, isNot(equals(b.publicKey)));
    });
  });

  group('sign / verify', () {
    test('a signature verifies against the matching public key', () async {
      final keyPair = await signer.generateKeyPair();
      final message = 'hello ledger'.codeUnits;

      final signature = await signer.sign(
        message,
        privateKeySeed: keyPair.privateKeySeed,
      );

      final isValid = await signer.verify(
        message,
        signature: signature,
        publicKey: keyPair.publicKey,
      );

      expect(isValid, isTrue);
    });

    test(
      'a signature does not verify against a different public key',
      () async {
        final signingKeyPair = await signer.generateKeyPair();
        final otherKeyPair = await signer.generateKeyPair();
        final message = 'hello ledger'.codeUnits;

        final signature = await signer.sign(
          message,
          privateKeySeed: signingKeyPair.privateKeySeed,
        );

        final isValid = await signer.verify(
          message,
          signature: signature,
          publicKey: otherKeyPair.publicKey,
        );

        expect(isValid, isFalse);
      },
    );

    test(
      'a signature does not verify against tampered message content',
      () async {
        final keyPair = await signer.generateKeyPair();
        final signature = await signer.sign(
          'original content'.codeUnits,
          privateKeySeed: keyPair.privateKeySeed,
        );

        final isValid = await signer.verify(
          'tampered content'.codeUnits,
          signature: signature,
          publicKey: keyPair.publicKey,
        );

        expect(isValid, isFalse);
      },
    );
  });
}
