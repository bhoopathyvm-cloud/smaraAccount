import 'package:bip39_mnemonic/bip39_mnemonic.dart';
import 'package:smara_accounting/domain/crypto/recovery_phrase.dart';
import 'package:test/test.dart';

void main() {
  group('RecoveryPhrase.generate', () {
    test('produces a 24-word phrase', () {
      final phrase = RecoveryPhrase.generate();

      expect(phrase.words, hasLength(24));
    });

    test('produces different words on each call', () {
      final a = RecoveryPhrase.generate();
      final b = RecoveryPhrase.generate();

      expect(a.words, isNot(equals(b.words)));
    });
  });

  group('seed derivation', () {
    test('the same words deterministically derive the same seed', () {
      final generated = RecoveryPhrase.generate();

      final first = RecoveryPhrase.fromWords(generated.words).seed;
      final second = RecoveryPhrase.fromWords(generated.words).seed;

      expect(first, equals(second));
    });

    test('different phrases derive different seeds', () {
      final a = RecoveryPhrase.generate();
      final b = RecoveryPhrase.generate();

      expect(a.seed, isNot(equals(b.seed)));
    });

    test('seed is at least 32 bytes (the Ed25519 seed length)', () {
      final phrase = RecoveryPhrase.generate();

      expect(phrase.seed.length, greaterThanOrEqualTo(32));
    });
  });

  group('RecoveryPhrase.fromWords', () {
    test('rejects words with an invalid checksum', () {
      final valid = RecoveryPhrase.generate().words;
      final tampered = [...valid];
      // Swap two words - overwhelmingly likely to invalidate the checksum
      // without accidentally producing another valid phrase.
      final tmp = tampered[0];
      tampered[0] = tampered[1];
      tampered[1] = tmp;

      expect(
        () => RecoveryPhrase.fromWords(tampered),
        throwsA(isA<MnemonicInvalidChecksumException>()),
      );
    });
  });
}
