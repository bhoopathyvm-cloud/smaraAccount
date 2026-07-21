import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/ledger_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/models/transaction_direction.dart';

/// Form state for recording a transaction (amount, direction, category,
/// financial account, date).
class RecordTransactionViewModel extends ChangeNotifier {
  RecordTransactionViewModel({
    required LedgerRepository ledgerRepository,
    String? initialFinancialAccountId,
  }) : _ledgerRepository = ledgerRepository {
    _accountsSubscription = _ledgerRepository.watchFinancialAccounts().listen((
      accounts,
    ) {
      _financialAccounts = accounts;
      if (_financialAccountId == null && accounts.isNotEmpty) {
        _financialAccountId = initialFinancialAccountId ?? accounts.first.id;
      }
      notifyListeners();
    });
  }

  final LedgerRepository _ledgerRepository;
  late final StreamSubscription<List<Account>> _accountsSubscription;

  List<Account> _financialAccounts = const [];
  List<Account> get financialAccounts => _financialAccounts;

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

  String? _financialAccountId;
  String? get financialAccountId => _financialAccountId;
  void setFinancialAccountId(String? value) {
    _financialAccountId = value;
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

  Future<bool> submit() async {
    final categoryId = _categoryId;
    final amountMinor = _amountMinor;
    final financialAccountId = _financialAccountId;
    if (categoryId == null ||
        amountMinor == null ||
        financialAccountId == null) {
      _errorMessage = 'Amount, account, and category are required.';
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
        financialAccountId: financialAccountId,
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
    } on AccountGroupException catch (e) {
      _isSubmitting = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _accountsSubscription.cancel();
    super.dispose();
  }
}
