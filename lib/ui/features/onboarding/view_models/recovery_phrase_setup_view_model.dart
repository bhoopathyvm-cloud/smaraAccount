import 'package:bip39_mnemonic/bip39_mnemonic.dart';
import 'package:flutter/foundation.dart';

import '../../../../data/repositories/identity_repository.dart';
import '../../../../data/repositories/ledger_chain_verifier.dart';
import '../../../../domain/crypto/signing_key_service.dart';
import '../../../../domain/exceptions.dart';
import '../../../../l10n/l10n.dart';

/// Spans the New Setup onboarding screens (currency, then the Settings
/// recovery-phrase/keystore-export/device-migration-bundle-export screens
/// once an identity exists) so the same [GeneratedIdentity] - one freshly
/// generated phrase and its key pair - carries through without
/// regenerating (each generation would produce a different phrase/key,
/// spec: "Device Signing Identity").
///
/// The identity is committed to the database in [commitIdentity], right
/// after the user picks a currency - onboarding never blocks on any
/// backup step afterward (`ledger-integrity-signing`'s "Optional Recovery
/// and Backup Setup"). [ensureGenerated] transparently resumes from a
/// stashed phrase (see [resumePendingIdentity]) if the app was killed and
/// relaunched anywhere in this window, so the words are never lost -
/// [loadExistingPhraseForDisplay] does the same for a later Settings
/// visit, but never generates a new identity if nothing was stashed.
class RecoveryPhraseSetupViewModel extends ChangeNotifier
    with LocalizedErrorMixin {
  RecoveryPhraseSetupViewModel({
    required IdentityRepository identityRepository,
    required LedgerChainVerifier chainVerifier,
  }) : _identityRepository = identityRepository,
       _chainVerifier = chainVerifier;

  final IdentityRepository _identityRepository;
  final LedgerChainVerifier _chainVerifier;

  GeneratedIdentity? _generated;
  List<String> get words => _generated?.phrase.words ?? const [];
  bool get isReady => _generated != null;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _keystoreExportPath;
  String? get keystoreExportPath => _keystoreExportPath;

  bool get hasGenerationError => failure != null && _generated == null;

  bool _hasCheckedExistingPhrase = false;

  /// True once [loadExistingPhraseForDisplay] has resolved (successfully
  /// or not). Distinguishes "still loading" from "checked, and this
  /// identity genuinely has no phrase to show" - both look like
  /// `!isReady` on their own.
  bool get hasCheckedExistingPhrase => _hasCheckedExistingPhrase;

  /// Idempotent - safe to call from every build of the display screen, and
  /// from [commitIdentity] before currency selection has even reached that
  /// screen. First tries to resume a phrase already stashed by an earlier,
  /// possibly-killed session ([resumePendingIdentity]) so the same words
  /// are shown again rather than silently generating a different phrase
  /// out from under an already-committed identity. On failure (e.g. OS
  /// secure storage rejects the write), sets [errorMessage] rather than
  /// leaving the caller waiting on a Future that already failed silently
  /// in the background.
  Future<void> ensureGenerated({Language language = Language.english}) async {
    if (_generated != null) return;
    try {
      final resumed = await _identityRepository.resumePendingIdentity();
      if (resumed != null) {
        _generated = resumed;
      } else {
        final generated = await _identityRepository.generateFirstIdentity(
          language: language,
        );
        await _identityRepository.stashPendingPhraseWords(
          generated.phrase.words,
          language: language,
        );
        _generated = generated;
      }
    } catch (e) {
      setFailure(
        AppFailure(
          AppErrorCode.validationGenerateKeyFailed,
          debugMessage: '$e',
        ),
      );
    }
    notifyListeners();
  }

  Future<String> exportKeystoreFile({required String passphrase}) {
    return _identityRepository.exportKeystoreFile(passphrase: passphrase);
  }

  void recordKeystoreExportPath(String path) {
    _keystoreExportPath = path;
    notifyListeners();
  }

  /// Loads the current identity's stashed phrase for display in Settings,
  /// if one exists. Unlike [ensureGenerated], this never generates a new
  /// identity - an identity restored from a keystore file, recovery
  /// phrase, or device migration bundle has no phrase of its own stashed,
  /// and this must never silently mint an unrelated one instead. Callers
  /// should treat "still not [isReady] and no [failure]" as "this
  /// identity has no recovery phrase to show", not as an error.
  /// Set [retry] to force a fresh attempt after a prior failure (e.g. the
  /// user tapped Retry) - otherwise a no-op once already checked.
  Future<void> loadExistingPhraseForDisplay({bool retry = false}) async {
    if (_hasCheckedExistingPhrase && !retry) return;
    if (retry) clearFailure();
    try {
      _generated = await _identityRepository.resumePendingIdentity();
    } catch (e) {
      setFailure(
        AppFailure(
          AppErrorCode.validationGenerateKeyFailed,
          debugMessage: '$e',
        ),
      );
    }
    _hasCheckedExistingPhrase = true;
    notifyListeners();
  }

  /// Commits the signing identity with the starter account groups seeded
  /// in [currency], then verifies the chain - the last step of New Setup
  /// onboarding; nothing blocks the app afterward.
  Future<bool> commitIdentity(
    String currency, {
    Language language = Language.english,
  }) async {
    await ensureGenerated(language: language);
    final generated = _generated;
    if (generated == null) return false;

    _isSubmitting = true;
    clearFailure();
    notifyListeners();

    await _identityRepository.confirmFirstIdentity(
      generated,
      currency: currency,
    );
    await _chainVerifier.verifyChain();

    _isSubmitting = false;
    notifyListeners();
    return true;
  }
}
