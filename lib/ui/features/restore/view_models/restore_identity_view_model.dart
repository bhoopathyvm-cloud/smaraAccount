import 'package:cryptography/cryptography.dart'
    show SecretBoxAuthenticationError;
import 'package:flutter/foundation.dart';

import '../../../../data/repositories/ledger_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../l10n/l10n.dart';

/// Reinstall/new-device restore, using a previously-saved recovery phrase
/// or keystore file (spec: "Recoverable Reinstall or Device Migration").
/// Never re-signs or alters any entry - only re-derives and matches the
/// device's private key.
class RestoreIdentityViewModel extends ChangeNotifier {
  RestoreIdentityViewModel({required LedgerRepository ledgerRepository})
    : _ledgerRepository = ledgerRepository;

  final LedgerRepository _ledgerRepository;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> restoreFromPhrase(String phraseText) {
    final words = phraseText
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    return _restore(
      () => _ledgerRepository.restoreIdentity(recoveryPhraseWords: words),
    );
  }

  Future<bool> restoreFromKeystore({
    required String fileContents,
    required String passphrase,
  }) {
    return _restore(
      () => _ledgerRepository.restoreIdentity(
        keystoreFileContents: fileContents,
        keystorePassphrase: passphrase,
      ),
    );
  }

  Future<bool> _restore(Future<void> Function() attempt) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await attempt();
      await _ledgerRepository.verifyChain();
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on SigningIdentityMismatchException catch (e) {
      _errorMessage = localizeVmError(e);
    } on SecretBoxAuthenticationError {
      _errorMessage = localizeVmError(
        const AppFailure(AppErrorCode.validationWrongKeystorePassphrase),
      );
    } on FormatException {
      _errorMessage = localizeVmError(
        const AppFailure(AppErrorCode.validationInvalidKeystoreFile),
      );
    } catch (_) {
      _errorMessage = localizeVmError(
        const AppFailure(AppErrorCode.validationRestorePhraseFailed),
      );
    }

    _isSubmitting = false;
    notifyListeners();
    return false;
  }
}
