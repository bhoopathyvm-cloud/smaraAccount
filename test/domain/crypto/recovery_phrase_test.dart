import 'package:bip39_mnemonic/bip39_mnemonic.dart';
import 'package:smara_accounting/domain/crypto/recovery_phrase.dart';
import 'package:test/test.dart';

void main() {
  group('RecoveryPhrase.generate', () {
    test('uses the English BIP39 wordlist by default', () {
      final english = Language.english.list.toSet();
      final phrase = RecoveryPhrase.generate();
      expect(phrase.words.every(english.contains), isTrue);
      expect(phrase.language, Language.english);
    });

    test('produces different words on each call', () {
      final a = RecoveryPhrase.generate();
      final b = RecoveryPhrase.generate();

      expect(a.words, isNot(equals(b.words)));
    });

    test('generates from the requested localized wordlist', () {
      for (final language in const [
        Language.french,
        Language.japanese,
        Language.simplifiedChinese,
        Language.korean,
      ]) {
        final words = language.list.toSet();
        final phrase = RecoveryPhrase.generate(language: language);
        expect(phrase.language, language);
        expect(
          phrase.words.every(words.contains),
          isTrue,
          reason: 'every word should come from the ${language.label} wordlist',
        );
      }
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

  group('RecoveryPhrase.fromWords language auto-detection', () {
    test(
      'detects the wordlist of a localized phrase and round-trips its seed',
      () {
        for (final language in const [
          Language.french,
          Language.japanese,
          Language.simplifiedChinese,
          Language.korean,
        ]) {
          final generated = RecoveryPhrase.generate(language: language);

          final restored = RecoveryPhrase.fromWords(generated.words);

          expect(restored.language, language, reason: language.label);
          // The seed must match the generation seed exactly - restore depends
          // on picking the right wordlist (separator/normalization differ per
          // language), so a mis-detected language would derive a different key.
          expect(restored.seed, equals(generated.seed), reason: language.label);
        }
      },
    );

    test('an English phrase still detects as English (unchanged path)', () {
      final generated = RecoveryPhrase.generate();
      final restored = RecoveryPhrase.fromWords(generated.words);
      expect(restored.language, Language.english);
      expect(restored.seed, equals(generated.seed));
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
