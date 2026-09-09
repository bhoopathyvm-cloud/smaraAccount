import 'package:bip39_mnemonic/bip39_mnemonic.dart';
import 'package:smara_accounting/domain/crypto/recovery_phrase.dart';
import 'package:test/test.dart';

void main() {
  group('RecoveryPhrase.generate', () {
    test('uses the English BIP39 wordlist regardless of other languages', () {
      final english = Language.english.list.toSet();
      final phrase = RecoveryPhrase.generate();
      expect(phrase.words.every(english.contains), isTrue);
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

  group('non-English languages (onboarding-language-selection)', () {
    test('generate() in French uses the French wordlist', () {
      final french = Language.french.list.toSet();
      final phrase = RecoveryPhrase.generate(language: Language.french);
      expect(phrase.words.every(french.contains), isTrue);
      expect(phrase.language, Language.french);
    });

    test(
      'a French phrase round-trips through fromWords with language: french',
      () {
        final generated = RecoveryPhrase.generate(language: Language.french);

        final reconstructed = RecoveryPhrase.fromWords(
          generated.words,
          language: Language.french,
        );

        expect(reconstructed.seed, equals(generated.seed));
      },
    );

    test('reconstructing a French phrase as English throws rather than '
        'silently deriving the wrong seed', () {
      final generated = RecoveryPhrase.generate(language: Language.french);

      expect(
        () => RecoveryPhrase.fromWords(generated.words),
        throwsA(anything),
      );
    });
  });

  group('RecoveryPhrase.fromWords', () {
    test('rejects words with an invalid checksum', () {
      final valid = RecoveryPhrase.generate().words;
      // The last word encodes the BIP-39 checksum. Swapping the first two
      // words can still land on a valid checksum (~1/256 for 24-word
      // phrases), so try last-word replacements until checksum fails.
      List<String>? invalid;
      for (final candidate in valid) {
        if (candidate == valid.last) continue;
        final tampered = [...valid.sublist(0, valid.length - 1), candidate];
        try {
          RecoveryPhrase.fromWords(tampered);
        } on MnemonicInvalidChecksumException {
          invalid = tampered;
          break;
        }
      }
      expect(invalid, isNotNull);
      expect(
        () => RecoveryPhrase.fromWords(invalid!),
        throwsA(isA<MnemonicInvalidChecksumException>()),
      );
    });
  });
}
