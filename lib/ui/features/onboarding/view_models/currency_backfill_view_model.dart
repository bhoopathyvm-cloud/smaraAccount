import 'package:flutter/foundation.dart';

import '../../../../data/repositories/ledger_repository.dart';

/// One-time prompt for a database migrated from schemaVersion 3 (before
/// account groups had a currency) - see
/// [LedgerRepository.needsCurrencyBackfill] (multi-currency-support
/// design.md Migration Plan step 3).
class CurrencyBackfillViewModel extends ChangeNotifier {
  CurrencyBackfillViewModel({required LedgerRepository ledgerRepository})
    : _ledgerRepository = ledgerRepository;

  final LedgerRepository _ledgerRepository;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> submit(String currency) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _ledgerRepository.backfillGroupCurrencies(currency);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = 'Could not save this currency: $e';
      notifyListeners();
      return false;
    }
  }
}
