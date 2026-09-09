import 'package:bip39_mnemonic/bip39_mnemonic.dart';

/// App locale code -> BIP39 [Language], for the 7 supported UI locales
/// that have an official BIP39 wordlist (onboarding-language-selection
/// design.md Decision 8). `bip39_mnemonic` also bundles Czech and
/// Traditional Chinese wordlists, but this app doesn't offer those as UI
/// locales, so they're never selected here.
///
/// Every other locale code - including all 22 of India's scheduled
/// languages this app supports - has no official wordlist and falls back
/// to [Language.english]. That's a deliberate, disclosed limitation (see
/// the corresponding `app-localization` requirement), not a gap to fill
/// with a non-standard wordlist.
const _bip39LanguageByLocale = <String, Language>{
  'fr': Language.french,
  'it': Language.italian,
  'es': Language.spanish,
  'pt': Language.portuguese,
  'ja': Language.japanese,
  'ko': Language.korean,
  'zh': Language.simplifiedChinese,
};

/// The BIP39 [Language] to generate/confirm a recovery phrase in for
/// [languageCode], or [Language.english] if none exists for it.
Language bip39LanguageForLocale(String languageCode) =>
    _bip39LanguageByLocale[languageCode] ?? Language.english;

/// Every [Language] this app ever generates a recovery phrase with,
/// English first (the original, most common case) so restoring a phrase
/// with an unknown-in-advance language tries the widest existing base of
/// phrases first (see `SigningKeyService.restoreFromRecoveryPhrase`).
const bip39RestoreLanguageCandidates = <Language>[
  Language.english,
  Language.french,
  Language.italian,
  Language.spanish,
  Language.portuguese,
  Language.japanese,
  Language.korean,
  Language.simplifiedChinese,
];
