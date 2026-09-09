import 'package:bip39_mnemonic/bip39_mnemonic.dart';
import 'package:smara_accounting/domain/crypto/recovery_phrase_language.dart';
import 'package:test/test.dart';

void main() {
  group('bip39LanguageForLocale', () {
    test('maps the seven wordlist-backed locales to their BIP39 language', () {
      expect(bip39LanguageForLocale('fr'), Language.french);
      expect(bip39LanguageForLocale('it'), Language.italian);
      expect(bip39LanguageForLocale('es'), Language.spanish);
      expect(bip39LanguageForLocale('pt'), Language.portuguese);
      expect(bip39LanguageForLocale('ja'), Language.japanese);
      expect(bip39LanguageForLocale('ko'), Language.korean);
      expect(bip39LanguageForLocale('zh'), Language.simplifiedChinese);
    });

    test('falls back to English for English itself', () {
      expect(bip39LanguageForLocale('en'), Language.english);
    });

    test('falls back to English for a locale with no official wordlist', () {
      for (final code in const ['ta', 'hi', 'ur', 'ar', 'ru', 'de', 'nl']) {
        expect(
          bip39LanguageForLocale(code),
          Language.english,
          reason: '$code has no official BIP39 wordlist bundled here',
        );
      }
    });

    test('falls back to English for an unknown code', () {
      expect(bip39LanguageForLocale('zz'), Language.english);
    });
  });

  group('recoveryPhraseUsesEnglishFallback', () {
    test('is false for English (nothing to disclose)', () {
      expect(recoveryPhraseUsesEnglishFallback('en'), isFalse);
    });

    test('is false for the seven wordlist-backed locales', () {
      for (final code in const ['fr', 'it', 'es', 'pt', 'ja', 'ko', 'zh']) {
        expect(recoveryPhraseUsesEnglishFallback(code), isFalse, reason: code);
      }
    });

    test('is true for a non-English locale with no official wordlist', () {
      for (final code in const ['ta', 'hi', 'ur', 'ar', 'ru', 'de', 'nl']) {
        expect(recoveryPhraseUsesEnglishFallback(code), isTrue, reason: code);
      }
    });
  });
}
