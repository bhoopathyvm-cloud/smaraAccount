import 'package:flutter/foundation.dart';

import '../../../../data/repositories/account_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../l10n/l10n.dart';

/// One-time prompt for a database migrated from schemaVersion 3 (before
/// account groups had a currency) - see
/// [AccountRepository.needsCurrencyBackfill] (multi-currency-support
/// design.md Migration Plan step 3).
class CurrencyBackfillViewModel extends ChangeNotifier
    with LocalizedErrorMixin {
  CurrencyBackfillViewModel({required AccountRepository accountRepository})
    : _accountRepository = accountRepository;

  final AccountRepository _accountRepository;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  Future<bool> submit(String currency) async {
    _isSubmitting = true;
    clearFailure();
    notifyListeners();
    try {
      await _accountRepository.backfillGroupCurrencies(currency);
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
