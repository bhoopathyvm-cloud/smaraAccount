import 'package:flutter/foundation.dart';

import '../../../../data/repositories/identity_repository.dart';
import '../../../../data/repositories/ledger_chain_verifier.dart';
import '../../../../domain/crypto/signing_key_service.dart';
import '../../../../domain/exceptions.dart';
import '../../../../l10n/l10n.dart';

/// New Setup onboarding: generate a this-device-only key and commit the
/// signing identity with the chosen currency (books-copy-and-continuation).
class FirstIdentitySetupViewModel extends ChangeNotifier
    with LocalizedErrorMixin {
  FirstIdentitySetupViewModel({
    required IdentityRepository identityRepository,
    required LedgerChainVerifier chainVerifier,
  }) : _identityRepository = identityRepository,
       _chainVerifier = chainVerifier;

  final IdentityRepository _identityRepository;
  final LedgerChainVerifier _chainVerifier;

  GeneratedIdentity? _generated;
  bool get isReady => _generated != null;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  bool get hasGenerationError => failure != null && _generated == null;

  Future<void> ensureGenerated() async {
    if (_generated != null) return;
    try {
      _generated = await _identityRepository.generateFirstIdentity();
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

  /// Commits the signing identity with starter account groups in [currency].
  Future<bool> commitIdentity(String currency) async {
    await ensureGenerated();
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
