import 'package:flutter/foundation.dart';

import '../../../../data/repositories/ledger_repository.dart';
import '../../../../domain/crypto/signing_key_service.dart';
import '../../../../domain/exceptions.dart';
import '../../../../l10n/l10n.dart';

/// Spans every onboarding screen (currency, recovery-phrase display,
/// optional keystore export, confirmation) so the same [GeneratedIdentity]
/// - one freshly generated phrase and its key pair - carries through the
/// whole flow without regenerating (each generation would produce a
/// different phrase/key, spec: "Device Signing Identity").
///
/// deferred-onboarding-first-entry: the identity is committed to the
/// database in [commitIdentity], right after the user picks a currency -
/// before the phrase is ever displayed or confirmed - so a guided first
/// entry can post between commit and acknowledgment. The mandatory
/// acknowledgment ritual (display, optional keystore export, confirm)
/// still fully gates everything else; [acknowledge] is what finally lifts
/// that gate. [ensureGenerated] transparently resumes from a stashed
/// phrase (see [resumePendingIdentity]) if the app was killed and
/// relaunched anywhere in this window, so the words are never lost.
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

  /// Idempotent - safe to call from every build of the display screen, and
  /// from [commitIdentity] before currency selection has even reached that
  /// screen. First tries to resume a phrase already stashed by an earlier,
  /// possibly-killed session ([resumePendingIdentity]) so the same words
  /// are shown again rather than silently generating a different phrase
  /// out from under an already-committed identity. On failure (e.g. OS
  /// secure storage rejects the write), sets [errorMessage] rather than
  /// leaving the caller waiting on a Future that already failed silently
  /// in the background.
  Future<void> ensureGenerated() async {
    if (_generated != null) return;
    try {
      final resumed = await _ledgerRepository.resumePendingIdentity();
      if (resumed != null) {
        _generated = resumed;
      } else {
        final generated = await _ledgerRepository.generateFirstIdentity();
        await _ledgerRepository.stashPendingPhraseWords(generated.phrase.words);
        _generated = generated;
      }
    } catch (e) {
      _errorMessage = localizeVmError(
        AppFailure(
          AppErrorCode.validationGenerateKeyFailed,
          params: {'detail': '$e'},
        ),
      );
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
  /// [enteredWords] (same indices). Returns true on success; on mismatch,
  /// sets [errorMessage] and leaves everything else untouched so the user
  /// can retry. Only validates locally - does not itself acknowledge
  /// anything; the caller still needs to call [acknowledge] on success
  /// (deferred-onboarding-first-entry: the identity and starter accounts
  /// were already committed earlier, in [commitIdentity]).
  bool confirm(Map<int, String> enteredWords) {
    final generated = _generated;
    if (generated == null) return false;

    for (final index in confirmationWordIndices) {
      final entered = (enteredWords[index] ?? '').trim().toLowerCase();
      if (entered != generated.phrase.words[index]) {
        _errorMessage = localizeVmError(
          AppFailure(
            AppErrorCode.validationConfirmWordMismatch,
            params: {'n': '${index + 1}'},
          ),
        );
        notifyListeners();
        return false;
      }
    }
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  /// Commits the signing identity with the starter account groups seeded
  /// in [currency], then verifies the chain. This is the first onboarding
  /// step now (deferred-onboarding-first-entry) - it generates the
  /// identity if [ensureGenerated] hasn't already run, and does not wait
  /// for phrase display or confirmation, which happen later.
  Future<bool> commitIdentity(String currency) async {
    await ensureGenerated();
    final generated = _generated;
    if (generated == null) return false;

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    await _ledgerRepository.confirmFirstIdentity(generated, currency: currency);
    await _ledgerRepository.verifyChain();

    _isSubmitting = false;
    notifyListeners();
    return true;
  }

  /// Completes the mandatory recovery-phrase acknowledgment. Call only
  /// after [confirm] has already returned true.
  Future<void> acknowledge() {
    return _ledgerRepository.acknowledgeIdentity();
  }
}
