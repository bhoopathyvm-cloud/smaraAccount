import 'package:bip39_mnemonic/bip39_mnemonic.dart';

/// Generation and deterministic re-derivation of the BIP-39-style recovery
/// phrase that backs the device signing key (spec: "Mandatory Recovery
/// Phrase Acknowledgment"). No passphrase is used on top of the phrase
/// itself - the phrase alone must be sufficient to recover the key, since
/// the app has no server to remind the user of an additional secret.
///
/// A phrase carries the BIP39 [language] whose wordlist it was drawn from:
/// generation may localize it (onboarding-language-selection design.md
/// Decision 8), and the same language must be used to re-derive the seed,
/// since BIP39 seed derivation normalizes the sentence with the language's
/// own word separator. English remains the default and the seed derivation
/// for it is byte-for-byte identical to before this became configurable.
class RecoveryPhrase {
  const RecoveryPhrase._(this.words, this.language);

  /// Every BIP39 wordlist bundled with `bip39_mnemonic`, tried English-first
  /// when re-deriving from typed words so an existing English phrase keeps
  /// its original, unchanged path and any interoperable phrase still
  /// restores. See [fromWords].
  static const _detectionOrder = <Language>[
    Language.english,
    Language.french,
    Language.italian,
    Language.spanish,
    Language.portuguese,
    Language.czech,
    Language.japanese,
    Language.korean,
    Language.simplifiedChinese,
    Language.traditionalChinese,
  ];

  /// Generates a new, random 24-word recovery phrase (256 bits of entropy -
  /// the strongest length this wordlist format supports) in [language]
  /// (English by default).
  factory RecoveryPhrase.generate({Language language = Language.english}) {
    final mnemonic = Mnemonic.generate(
      language,
      length: MnemonicLength.words24,
    );
    return RecoveryPhrase._(mnemonic.words, language);
  }

  /// Reconstructs a phrase from words the user typed in (e.g. during
  /// import/restore). The wordlist language is detected by trying each
  /// bundled wordlist in turn (English first) and keeping the first under
  /// which the words form a valid, checksum-correct phrase - so a phrase
  /// generated in any supported language restores without the caller having
  /// to know which language it was. Throws if [words] match no wordlist or
  /// fail their checksum - the strongest available signal that the user
  /// mistyped a word, before ever comparing against a stored public key.
  factory RecoveryPhrase.fromWords(List<String> words) {
    // A word-not-found error only means "not this wordlist"; a checksum error
    // means every word *was* found in that wordlist but the phrase is
    // mistyped - a far more specific signal, so prefer surfacing it (and the
    // first one seen) over the generic not-found from later wordlists.
    MnemonicInvalidChecksumException? checksumError;
    Object? notFoundError;
    for (final language in _detectionOrder) {
      try {
        final mnemonic = Mnemonic.fromWords(words: words, language: language);
        return RecoveryPhrase._(mnemonic.words, language);
      } on MnemonicInvalidChecksumException catch (e) {
        checksumError ??= e;
      } catch (e) {
        notFoundError = e;
      }
    }
    throw checksumError ??
        notFoundError ??
        const FormatException('Empty recovery phrase.');
  }

  final List<String> words;

  /// The BIP39 wordlist language this phrase belongs to.
  final Language language;

  /// The 64-byte PBKDF2-derived seed (BIP-39 standard derivation, no extra
  /// passphrase). The first 32 bytes of this seed are used as the Ed25519
  /// private key seed - see [Ed25519Signing.keyPairFromSeed].
  List<int> get seed {
    final mnemonic = Mnemonic.fromWords(words: words, language: language);
    return mnemonic.seed;
  }
}
