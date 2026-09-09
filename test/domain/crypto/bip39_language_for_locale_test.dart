import 'package:bip39_mnemonic/bip39_mnemonic.dart';
import 'package:smara_accounting/domain/crypto/bip39_language_for_locale.dart';
import 'package:smara_accounting/l10n/supported_locales.dart';
import 'package:test/test.dart';

void main() {
  group('bip39LanguageForLocale', () {
    test('maps each of the 7 supported BIP39 locales to its language', () {
      expect(bip39LanguageForLocale('fr'), Language.french);
      expect(bip39LanguageForLocale('it'), Language.italian);
      expect(bip39LanguageForLocale('es'), Language.spanish);
      expect(bip39LanguageForLocale('pt'), Language.portuguese);
      expect(bip39LanguageForLocale('ja'), Language.japanese);
      expect(bip39LanguageForLocale('ko'), Language.korean);
      expect(bip39LanguageForLocale('zh'), Language.simplifiedChinese);
    });

    test('English maps to English', () {
      expect(bip39LanguageForLocale('en'), Language.english);
    });

    test('an unmapped code falls back to English', () {
      expect(bip39LanguageForLocale('xx'), Language.english);
      expect(bip39LanguageForLocale(''), Language.english);
    });

    test("every one of India's scheduled languages this app supports has no "
        'official BIP39 wordlist and falls back to English', () {
      const indianLanguages = [
        'ta',
        'te',
        'ml',
        'kn',
        'hi',
        'ur',
        'pa',
        'ne',
        'sa',
        'doi',
        'ks',
        'mai',
        'mr',
        'gu',
        'kok',
        'sd',
        'bn',
        'as',
        'or',
        'mni',
        'brx',
        'sat',
      ];
      for (final code in indianLanguages) {
        expect(bip39LanguageForLocale(code), Language.english, reason: code);
      }
    });

    test('every supported locale tag resolves to some Language', () {
      for (final tag in kSupportedLocaleTags) {
        expect(bip39LanguageForLocale(tag), isNotNull, reason: tag);
      }
    });
  });

  group('bip39RestoreLanguageCandidates', () {
    test('starts with English, then covers every mapped language once', () {
      expect(bip39RestoreLanguageCandidates.first, Language.english);
      expect(bip39RestoreLanguageCandidates.toSet().length, 8);
      expect(
        bip39RestoreLanguageCandidates,
        containsAll(<Language>[
          Language.english,
          Language.french,
          Language.italian,
          Language.spanish,
          Language.portuguese,
          Language.japanese,
          Language.korean,
          Language.simplifiedChinese,
        ]),
      );
    });
  });
}
