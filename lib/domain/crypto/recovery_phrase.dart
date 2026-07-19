import 'package:bip39_mnemonic/bip39_mnemonic.dart';

/// Generation and deterministic re-derivation of the BIP-39-style recovery
/// phrase that backs the device signing key (spec: "Mandatory Recovery
/// Phrase Acknowledgment"). No passphrase is used on top of the phrase
/// itself - the phrase alone must be sufficient to recover the key, since
/// the app has no server to remind the user of an additional secret.
class RecoveryPhrase {
  const RecoveryPhrase._(this.words);

  /// Generates a new, random 24-word recovery phrase (256 bits of entropy -
  /// the strongest length this wordlist format supports).
  factory RecoveryPhrase.generate() {
    final mnemonic = Mnemonic.generate(
      Language.english,
      length: MnemonicLength.words24,
    );
    return RecoveryPhrase._(mnemonic.words);
  }

  /// Reconstructs a phrase from words the user typed in (e.g. during
  /// import/restore). Throws if the checksum embedded in the words is
  /// invalid - the strongest available signal that the user mistyped a
  /// word, before ever comparing against a stored public key.
  factory RecoveryPhrase.fromWords(List<String> words) {
    final mnemonic = Mnemonic.fromWords(
      words: words,
      language: Language.english,
    );
    return RecoveryPhrase._(mnemonic.words);
  }

  final List<String> words;

  /// The 64-byte PBKDF2-derived seed (BIP-39 standard derivation, no extra
  /// passphrase). The first 32 bytes of this seed are used as the Ed25519
  /// private key seed - see [Ed25519Signing.keyPairFromSeed].
  List<int> get seed {
    final mnemonic = Mnemonic.fromWords(
      words: words,
      language: Language.english,
    );
    return mnemonic.seed;
  }
}
