import 'package:bip39_mnemonic/bip39_mnemonic.dart';

/// Generation and deterministic re-derivation of the BIP-39-style recovery
/// phrase that backs the device signing key (spec: "Mandatory Recovery
/// Phrase Acknowledgment"). No passphrase is used on top of the phrase
/// itself - the phrase alone must be sufficient to recover the key, since
/// the app has no server to remind the user of an additional secret.
class RecoveryPhrase {
  const RecoveryPhrase._(this.words, this.language);

  /// Generates a new, random 24-word recovery phrase (256 bits of entropy -
  /// the strongest length this wordlist format supports), in [language]
  /// (English by default; see `bip39LanguageForLocale` for which other
  /// languages this app ever passes here - onboarding-language-selection
  /// design.md Decision 8).
  factory RecoveryPhrase.generate({Language language = Language.english}) {
    final mnemonic = Mnemonic.generate(
      language,
      length: MnemonicLength.words24,
    );
    return RecoveryPhrase._(mnemonic.words, language);
  }

  /// Reconstructs a phrase from words the user typed in (e.g. during
  /// import/restore), or previously stashed. [language] MUST match the
  /// language the words were originally generated in - it is not
  /// recoverable from the words alone without trying candidates (see
  /// `SigningKeyService.restoreFromRecoveryPhrase`). Throws if the
  /// checksum embedded in the words is invalid for [language] - the
  /// strongest available signal that the user mistyped a word or the
  /// language is wrong, before ever comparing against a stored public key.
  factory RecoveryPhrase.fromWords(
    List<String> words, {
    Language language = Language.english,
  }) {
    final mnemonic = Mnemonic.fromWords(words: words, language: language);
    return RecoveryPhrase._(mnemonic.words, language);
  }

  final List<String> words;
  final Language language;

  /// The 64-byte PBKDF2-derived seed (BIP-39 standard derivation, no extra
  /// passphrase). The first 32 bytes of this seed are used as the Ed25519
  /// private key seed - see [Ed25519Signing.keyPairFromSeed]. Reconstructs
  /// using [language] - the same language [words] was generated in -
  /// rather than assuming English, so a non-English phrase's seed is
  /// derived correctly.
  List<int> get seed {
    final mnemonic = Mnemonic.fromWords(words: words, language: language);
    return mnemonic.seed;
  }
}
