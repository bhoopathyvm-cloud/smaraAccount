import 'package:flutter/foundation.dart';

import '../../../../data/repositories/ledger_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../domain/models/transaction_direction.dart';

/// Form state for recording a transaction (amount, direction, category,
/// date). Calls `recordTransaction`; domain exceptions surface as
/// [errorMessage], never reaching the View as a raw exception
/// (smara-tech-guidelines.md's error handling rules).
class RecordTransactionViewModel extends ChangeNotifier {
  RecordTransactionViewModel({required LedgerRepository ledgerRepository})
    : _ledgerRepository = ledgerRepository;

  final LedgerRepository _ledgerRepository;

  int? _amountMinor;
  int? get amountMinor => _amountMinor;
  void setAmountMinor(int? value) {
    _amountMinor = value;
    notifyListeners();
  }

  TransactionDirection _direction = TransactionDirection.moneyIn;
  TransactionDirection get direction => _direction;
  void setDirection(TransactionDirection value) {
    _direction = value;
    notifyListeners();
  }

  String? _categoryId;
  String? get categoryId => _categoryId;
  void setCategoryId(String? value) {
    _categoryId = value;
    notifyListeners();
  }

  DateTime _transactionDate = DateTime.now();
  DateTime get transactionDate => _transactionDate;
  void setTransactionDate(DateTime value) {
    _transactionDate = value;
    notifyListeners();
  }

  String? _description;
  String? get description => _description;
  void setDescription(String? value) {
    _description = value;
    notifyListeners();
  }

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Returns true on success. On failure, [errorMessage] is set and the
  /// form state is left untouched so the user can correct it.
  Future<bool> submit() async {
    final categoryId = _categoryId;
    final amountMinor = _amountMinor;
    if (categoryId == null || amountMinor == null) {
      _errorMessage = 'Amount and category are required.';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _ledgerRepository.recordTransaction(
        amountMinor: amountMinor,
        direction: _direction,
        categoryId: categoryId,
        transactionDate: _transactionDate,
        description: _description,
      );
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on InvalidTransactionAmountException catch (e) {
      _isSubmitting = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }
}
