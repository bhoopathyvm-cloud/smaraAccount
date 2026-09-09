import 'package:bip39_mnemonic/bip39_mnemonic.dart';

/// The subset of app UI locales that have an official BIP39 wordlist bundled
/// with `bip39_mnemonic` (onboarding-language-selection design.md Decision 8).
/// Every other supported locale - including all 22 Indian scheduled languages
/// this app ships - has no standard wordlist, so its recovery phrase stays
/// English (with a disclosed notice; see [recoveryPhraseUsesEnglishFallback]).
///
/// Keyed on the bare language code (`Locale.languageCode`), which is all the
/// supported tags carry for these seven; `zh` maps to Simplified Chinese, the
/// only Chinese pack this app ships.
const _bip39LanguageByCode = <String, Language>{
  'fr': Language.french,
  'it': Language.italian,
  'es': Language.spanish,
  'pt': Language.portuguese,
  'ja': Language.japanese,
  'ko': Language.korean,
  'zh': Language.simplifiedChinese,
};

/// The BIP39 wordlist [Language] a freshly generated recovery phrase should
/// use for [languageCode], or [Language.english] for any locale without an
/// official wordlist (including English itself). Never invents a wordlist.
Language bip39LanguageForLocale(String languageCode) {
  return _bip39LanguageByCode[languageCode] ?? Language.english;
}

/// Whether a user on [languageCode] must be shown the English-fallback notice
/// before their recovery phrase is generated: true only for a non-English
/// locale that has no official BIP39 wordlist. English (nothing to disclose)
/// and the seven wordlist-backed locales return false.
bool recoveryPhraseUsesEnglishFallback(String languageCode) {
  return languageCode != 'en' && !_bip39LanguageByCode.containsKey(languageCode);
}
