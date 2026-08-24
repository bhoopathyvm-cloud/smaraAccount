import 'package:flutter/foundation.dart';

import '../../../../data/repositories/ledger_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../l10n/l10n.dart';

/// One-time prompt for a database migrated from schemaVersion 3 (before
/// account groups had a currency) - see
/// [LedgerRepository.needsCurrencyBackfill] (multi-currency-support
/// design.md Migration Plan step 3).
class CurrencyBackfillViewModel extends ChangeNotifier
    with LocalizedErrorMixin {
  CurrencyBackfillViewModel({required LedgerRepository ledgerRepository})
    : _ledgerRepository = ledgerRepository;

  final LedgerRepository _ledgerRepository;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  Future<bool> submit(String currency) async {
    _isSubmitting = true;
    clearFailure();
    notifyListeners();
    try {
      await _ledgerRepository.backfillGroupCurrencies(currency);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSubmitting = false;
      setFailure(
        AppFailure(
          AppErrorCode.validationSaveCurrencyFailed,
          debugMessage: '$e',
        ),
      );
      return false;
    }
  }
}
