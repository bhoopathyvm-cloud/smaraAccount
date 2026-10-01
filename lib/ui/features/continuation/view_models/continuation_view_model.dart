import 'package:flutter/foundation.dart';

import '../../../../data/repositories/books_copy_repository.dart';
import '../../../../data/repositories/identity_repository.dart';
import '../../../../data/repositories/ledger_chain_verifier.dart';
import '../../../../domain/exceptions.dart';
import '../../../../l10n/l10n.dart';

/// /continue screen: continue books under a new this-device-only identity,
/// or restore from a Books Copy.
class ContinuationViewModel extends ChangeNotifier with LocalizedErrorMixin {
  ContinuationViewModel({
    required IdentityRepository identityRepository,
    required LedgerChainVerifier chainVerifier,
    required BooksCopyRepository booksCopyRepository,
  }) : _identityRepository = identityRepository,
       _chainVerifier = chainVerifier,
       _booksCopyRepository = booksCopyRepository;

  final IdentityRepository _identityRepository;
  final LedgerChainVerifier _chainVerifier;
  final BooksCopyRepository _booksCopyRepository;

  bool _isBusy = false;
  bool get isBusy => _isBusy;

  bool _continued = false;
  bool get continued => _continued;

  Future<bool> continueBooks({DateTime? copySavedAt}) async {
    _isBusy = true;
    clearFailure();
    notifyListeners();
    try {
      await _identityRepository.continueBooks(copySavedAt: copySavedAt);
      await _chainVerifier.verifyChain();
      _continued = true;
      return true;
    } catch (e) {
      setFailure(
        AppFailure(
          AppErrorCode.validationGenerateKeyFailed,
          debugMessage: '$e',
        ),
      );
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<bool> restoreFromCopy({
    required String fileContents,
    required String passphrase,
  }) async {
    _isBusy = true;
    clearFailure();
    notifyListeners();
    try {
      await _booksCopyRepository.restoreBooksCopy(
        fileContents: fileContents,
        passphrase: passphrase,
      );
      return true;
    } catch (e) {
      setFailure(
        AppFailure(
          AppErrorCode.invalidLedgerBackupUnreadable,
          debugMessage: '$e',
        ),
      );
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }
}
