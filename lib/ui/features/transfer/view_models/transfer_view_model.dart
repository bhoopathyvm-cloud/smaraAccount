import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/ledger_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../domain/models/account.dart';

class TransferViewModel extends ChangeNotifier {
  TransferViewModel({required LedgerRepository ledgerRepository})
    : _ledgerRepository = ledgerRepository {
    _accountsSubscription = _ledgerRepository.watchFinancialAccounts().listen((
      accounts,
    ) {
      _accounts = accounts;
      if (_fromAccountId == null && accounts.isNotEmpty) {
        _fromAccountId = accounts.first.id;
      }
      if (_toAccountId == null) {
        for (final account in accounts) {
          if (account.id != _fromAccountId) {
            _toAccountId = account.id;
            break;
          }
        }
      }
      notifyListeners();
    });
  }

  final LedgerRepository _ledgerRepository;
  late final StreamSubscription<List<Account>> _accountsSubscription;

  List<Account> _accounts = const [];
  List<Account> get accounts => _accounts;

  String? _fromAccountId;
  String? get fromAccountId => _fromAccountId;
  void setFromAccountId(String? value) {
    _fromAccountId = value;
    if (_toAccountId == value) _toAccountId = null;
    notifyListeners();
  }

  String? _toAccountId;
  String? get toAccountId => _toAccountId;
  void setToAccountId(String? value) {
    _toAccountId = value;
    notifyListeners();
  }

  int? _amountMinor;
  int? get amountMinor => _amountMinor;
  void setAmountMinor(int? value) {
    _amountMinor = value;
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
    final fromAccountId = _fromAccountId;
    final toAccountId = _toAccountId;
    final amountMinor = _amountMinor;
    if (fromAccountId == null || toAccountId == null || amountMinor == null) {
      _errorMessage = 'From account, to account, and amount are required.';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _ledgerRepository.recordTransfer(
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        amountMinor: amountMinor,
        transactionDate: _transactionDate,
        description: _description,
      );
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on InvalidTransferException catch (error) {
      _isSubmitting = false;
      _errorMessage = error.message;
      notifyListeners();
      return false;
    } on AccountGroupException catch (error) {
      _isSubmitting = false;
      _errorMessage = error.message;
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
