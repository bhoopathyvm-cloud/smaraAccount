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

  Future<bool>? _commitInFlight;
  bool _committed = false;

  /// Commits the signing identity with starter account groups in [currency].
  ///
  /// Safe against double taps: a call made while a commit is running gets
  /// that commit's result, and a call after a successful commit does
  /// nothing, so the starter books are never seeded twice.
  Future<bool> commitIdentity(String currency) {
    if (_committed) return Future.value(true);
    return _commitInFlight ??= _commit(
      currency,
    ).whenComplete(() => _commitInFlight = null);
  }

  Future<bool> _commit(String currency) async {
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

    _committed = true;
    _isSubmitting = false;
    notifyListeners();
    return true;
  }
}
