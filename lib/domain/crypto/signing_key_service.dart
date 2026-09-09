import 'dart:convert';
import 'dart:typed_data';

import 'package:bip39_mnemonic/bip39_mnemonic.dart';

import 'bip39_language_for_locale.dart';
import 'ed25519_signing.dart';
import 'keystore_file.dart';
import 'recovery_phrase.dart';
import 'secure_key_storage.dart';

/// Orchestrates the device signing key's lifecycle: generation, secure
/// storage, signing, and the recovery-phrase / keystore-file backup and
/// restore paths (spec: "Device Signing Identity", "Mandatory Recovery
/// Phrase Acknowledgment", "Recoverable Reinstall or Device Migration").
///
/// Never touches Drift - the private key is stored exclusively in OS
/// secure storage (Keychain/Keystore/DPAPI, via [SecureKeyStorage]), never
/// the SQLite database. Callers (the Repository layer) own persisting the
/// resulting *public* key into `signing_identities`.
class SigningKeyService {
  SigningKeyService({SecureKeyStorage? secureStorage, Ed25519Signing? signer})
    : _secureStorage = secureStorage ?? const FlutterSecureKeyStorage(),
      _signer = signer ?? const Ed25519Signing();

  static const _privateKeySeedStorageKey = 'ledger_signing_private_key_seed';

  /// Holds the plaintext recovery-phrase words between identity commit and
  /// acknowledgment (deferred-onboarding-first-entry), so a killed/crashed
  /// app can still show the user the same words on relaunch instead of
  /// losing them forever. Same OS-protected secure storage already trusted
  /// for the private key; cleared the moment acknowledgment completes (see
  /// [clearPendingPhraseWords]) so it never lingers past that window.
  static const _pendingPhraseWordsStorageKey =
      'ledger_pending_recovery_phrase_words';

  /// The BIP39 language [_pendingPhraseWordsStorageKey]'s words were
  /// generated in (stored by [Language.label]), so [resumePendingIdentity]
  /// reconstructs deterministically instead of assuming English.
  static const _pendingPhraseLanguageStorageKey =
      'ledger_pending_recovery_phrase_language';

  final SecureKeyStorage _secureStorage;
  final Ed25519Signing _signer;

  /// The key material currently in secure storage, if any. Null means no
  /// identity has been generated/restored on this device yet, or the
  /// device's secure storage was cleared independently of the database
  /// (the "existing database file, no key" reinstall scenario - spec:
  /// "Recoverable Reinstall or Device Migration").
  Future<KeyMaterial?> loadStoredKeyMaterial() async {
    final seed = await _readStoredSeed();
    if (seed == null) return null;
    return _signer.keyPairFromSeed(seed);
  }

  /// Generates a brand-new recovery phrase (in [language]; English by
  /// default) and the key pair it deterministically derives, and stores
  /// the private key. This is the only key-generation entry point: the
  /// phrase is always the source of truth for the key, never the other
  /// way around, so recovery always works the same way regardless of
  /// whether this is first-install or a later re-generation.
  Future<GeneratedIdentity> generateNewIdentity({
    Language language = Language.english,
  }) async {
    final phrase = RecoveryPhrase.generate(language: language);
    final keyMaterial = await _signer.keyPairFromSeed(phrase.seed);
    await _storeSeed(keyMaterial.privateKeySeed);
    return GeneratedIdentity(phrase: phrase, keyMaterial: keyMaterial);
  }

  /// Re-derives key material from a recovery phrase the user typed in
  /// during restore, and stores it as the device's active private key.
  /// The restoring device has no record of which language the phrase was
  /// originally generated in, so this tries each language this app ever
  /// generates with ([bip39RestoreLanguageCandidates], English first -
  /// the original, most common case) until one parses with a valid
  /// checksum. Throws the last language's error if none match - the
  /// strongest available signal that [words] themselves are wrong, not
  /// just tried in the wrong language.
  Future<KeyMaterial> restoreFromRecoveryPhrase(List<String> words) async {
    RecoveryPhrase? phrase;
    Object? lastError;
    for (final language in bip39RestoreLanguageCandidates) {
      try {
        phrase = RecoveryPhrase.fromWords(words, language: language);
        break;
      } catch (e) {
        lastError = e;
      }
    }
    if (phrase == null) {
      throw lastError ??
          StateError('Could not parse the recovery phrase in any language.');
    }
    final keyMaterial = await _signer.keyPairFromSeed(phrase.seed);
    await _storeSeed(keyMaterial.privateKeySeed);
    return keyMaterial;
  }

  /// Re-derives key material from an encrypted keystore file's contents,
  /// and stores it as the device's active private key. Throws
  /// [SecretBoxAuthenticationError] if [passphrase] is wrong.
  Future<KeyMaterial> restoreFromKeystoreFile({
    required String fileContents,
    required String passphrase,
  }) async {
    final seed = await KeystoreFile.decrypt(
      fileContents: fileContents,
      passphrase: passphrase,
    );
    final keyMaterial = await _signer.keyPairFromSeed(seed);
    await _storeSeed(keyMaterial.privateKeySeed);
    return keyMaterial;
  }

  /// Encrypted keystore file export of the *currently stored* private key
  /// (spec: "Optional keystore file export"). Throws [StateError] if no
  /// key is currently stored.
  Future<String> exportKeystoreFile({required String passphrase}) async {
    final seed = await _readStoredSeed();
    if (seed == null) {
      throw StateError(
        'No signing identity is currently stored on this device.',
      );
    }
    return KeystoreFile.encrypt(privateKeySeed: seed, passphrase: passphrase);
  }

  /// Signs [message] with the currently stored private key. Throws
  /// [StateError] if no key is currently stored.
  Future<Uint8List> sign(List<int> message) async {
    final seed = await _readStoredSeed();
    if (seed == null) {
      throw StateError(
        'No signing identity is currently stored on this device.',
      );
    }
    return _signer.sign(message, privateKeySeed: seed);
  }

  Future<bool> verify(
    List<int> message, {
    required List<int> signature,
    required List<int> publicKey,
  }) {
    return _signer.verify(message, signature: signature, publicKey: publicKey);
  }

  /// Stashes [words] (the just-generated recovery phrase, generated in
  /// [language]) so they survive an app kill between identity commit and
  /// acknowledgment. Call only for the true-first-launch generation path,
  /// never for the true-key-loss migration path (which never shows a
  /// phrase to re-acknowledge).
  Future<void> stashPendingPhraseWords(
    List<String> words, {
    Language language = Language.english,
  }) async {
    await _secureStorage.write(_pendingPhraseWordsStorageKey, words.join(' '));
    await _secureStorage.write(
      _pendingPhraseLanguageStorageKey,
      language.label,
    );
  }

  /// The words stashed by [stashPendingPhraseWords], if an app kill
  /// interrupted onboarding before [clearPendingPhraseWords] ran. Null
  /// means there's nothing pending - either a true first launch, or
  /// acknowledgment already completed.
  Future<List<String>?> readPendingPhraseWords() async {
    final joined = await _secureStorage.read(_pendingPhraseWordsStorageKey);
    if (joined == null) return null;
    return joined.split(' ');
  }

  /// The language stashed alongside [readPendingPhraseWords]'s words.
  /// Defaults to English if nothing was stored (e.g. words stashed by a
  /// version of this app before language-aware generation existed).
  Future<Language> _readPendingPhraseLanguage() async {
    final label = await _secureStorage.read(_pendingPhraseLanguageStorageKey);
    if (label == null) return Language.english;
    return Language.values.firstWhere(
      (language) => language.label == label,
      orElse: () => Language.english,
    );
  }

  /// Deletes the stashed phrase words and language. Call once
  /// acknowledgment completes (or, for a device that never needed them,
  /// this is a harmless no-op).
  Future<void> clearPendingPhraseWords() async {
    await _secureStorage.delete(_pendingPhraseWordsStorageKey);
    await _secureStorage.delete(_pendingPhraseLanguageStorageKey);
  }

  /// Reconstructs the [GeneratedIdentity] from words stashed by
  /// [stashPendingPhraseWords], for redisplay after an app kill interrupted
  /// onboarding between identity commit and acknowledgment. Re-derives the
  /// same key material deterministically from the phrase - does not
  /// generate a new phrase or overwrite stored key material. Null if there
  /// is nothing pending.
  Future<GeneratedIdentity?> resumePendingIdentity() async {
    final words = await readPendingPhraseWords();
    if (words == null) return null;
    final language = await _readPendingPhraseLanguage();
    final phrase = RecoveryPhrase.fromWords(words, language: language);
    final keyMaterial = await _signer.keyPairFromSeed(phrase.seed);
    return GeneratedIdentity(phrase: phrase, keyMaterial: keyMaterial);
  }

  Future<List<int>?> _readStoredSeed() async {
    final encoded = await _secureStorage.read(_privateKeySeedStorageKey);
    if (encoded == null) return null;
    return base64Decode(encoded);
  }

  Future<void> _storeSeed(List<int> seed) {
    return _secureStorage.write(_privateKeySeedStorageKey, base64Encode(seed));
  }
}

/// A freshly generated identity: the recovery phrase the user must
/// acknowledge (spec: "Mandatory Recovery Phrase Acknowledgment") paired
/// with the key material it derives.
class GeneratedIdentity {
  const GeneratedIdentity({required this.phrase, required this.keyMaterial});

  final RecoveryPhrase phrase;
  final KeyMaterial keyMaterial;
}
