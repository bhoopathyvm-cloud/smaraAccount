import 'package:cryptography/cryptography.dart'
    show SecretBoxAuthenticationError;
import 'package:flutter/foundation.dart';

import '../../../../data/repositories/identity_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../l10n/l10n.dart';

/// Reinstall/new-device restore, using a previously-saved recovery phrase
/// or keystore file (spec: "Recoverable Reinstall or Device Migration").
/// Never re-signs or alters any entry - only re-derives and matches the
/// device's private key.
class RestoreIdentityViewModel extends ChangeNotifier with LocalizedErrorMixin {
  RestoreIdentityViewModel({required IdentityRepository identityRepository})
    : _identityRepository = identityRepository;

  final IdentityRepository _identityRepository;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  Future<bool> restoreFromPhrase(String phraseText) {
    final words = phraseText
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    return _restore(
      () => _identityRepository.restoreIdentity(recoveryPhraseWords: words),
    );
  }

  Future<bool> restoreFromKeystore({
    required String fileContents,
    required String passphrase,
  }) {
    return _restore(
      () => _identityRepository.restoreIdentity(
        keystoreFileContents: fileContents,
        keystorePassphrase: passphrase,
      ),
    );
  }

  Future<bool> _restore(Future<void> Function() attempt) async {
    _isSubmitting = true;
    clearFailure();
    notifyListeners();

    try {
      await attempt();
      await _identityRepository.verifyChain();
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on SigningIdentityMismatchException catch (e) {
      setFailure(e);
    } on SecretBoxAuthenticationError {
      setFailure(
        const AppFailure(AppErrorCode.validationWrongKeystorePassphrase),
      );
    } on FormatException {
      setFailure(const AppFailure(AppErrorCode.validationInvalidKeystoreFile));
    } catch (_) {
      setFailure(const AppFailure(AppErrorCode.validationRestorePhraseFailed));
    }

    _isSubmitting = false;
    notifyListeners();
    return false;
  }
}
