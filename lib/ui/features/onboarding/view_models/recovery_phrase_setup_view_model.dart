import 'package:flutter/foundation.dart';

import '../../../../data/repositories/ledger_repository.dart';
import '../../../../domain/crypto/signing_key_service.dart';

/// Spans all three onboarding screens (recovery-phrase display, optional
/// keystore export, confirmation) so the same [GeneratedIdentity] - one
/// freshly generated phrase and its key pair - carries through the whole
/// flow without regenerating (each generation would produce a different
/// phrase/key, spec: "Device Signing Identity"). The identity is only
/// written to the database at the very end, in [confirm] - until then the
/// ledger stays unusable (spec: "Onboarding blocks until recovery phrase
/// is acknowledged").
class RecoveryPhraseSetupViewModel extends ChangeNotifier {
  RecoveryPhraseSetupViewModel({required LedgerRepository ledgerRepository})
    : _ledgerRepository = ledgerRepository;

  final LedgerRepository _ledgerRepository;

  /// Fixed spread across a 24-word phrase, asked back during confirmation.
  static const confirmationWordIndices = [2, 9, 17];

  GeneratedIdentity? _generated;
  List<String> get words => _generated?.phrase.words ?? const [];
  bool get isReady => _generated != null;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _keystoreExportPath;
  String? get keystoreExportPath => _keystoreExportPath;

  bool get hasGenerationError => _errorMessage != null && _generated == null;

  /// Idempotent - safe to call from every build of the display screen. On
  /// failure (e.g. OS secure storage rejects the write), sets
  /// [errorMessage] rather than leaving the caller waiting on a Future
  /// that already failed silently in the background.
  Future<void> ensureGenerated() async {
    if (_generated != null) return;
    try {
      _generated = await _ledgerRepository.generateFirstIdentity();
    } catch (e) {
      _errorMessage = 'Could not generate a signing key on this device: $e';
    }
    notifyListeners();
  }

  Future<String> exportKeystoreFile({required String passphrase}) {
    return _ledgerRepository.exportKeystoreFile(passphrase: passphrase);
  }

  void recordKeystoreExportPath(String path) {
    _keystoreExportPath = path;
    notifyListeners();
  }

  /// Validates the words at [confirmationWordIndices] against
  /// [enteredWords] (same indices), then commits the identity. Returns
  /// true on success; on mismatch, sets [errorMessage] and leaves
  /// everything else untouched so the user can retry.
  Future<bool> confirm(Map<int, String> enteredWords) async {
    final generated = _generated;
    if (generated == null) return false;

    for (final index in confirmationWordIndices) {
      final entered = (enteredWords[index] ?? '').trim().toLowerCase();
      if (entered != generated.phrase.words[index]) {
        _errorMessage =
            'Word ${index + 1} doesn\'t match your saved phrase. Check it and try again.';
        notifyListeners();
        return false;
      }
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    await _ledgerRepository.confirmFirstIdentity(generated);
    await _ledgerRepository.verifyChain();

    _isSubmitting = false;
    notifyListeners();
    return true;
  }
}
