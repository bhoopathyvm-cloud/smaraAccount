import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/ledger_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/models/account_group.dart';

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
    _groupsSubscription = _ledgerRepository
        .watchAccountGroups(includeArchived: true)
        .listen((groups) {
          _groups = groups;
          notifyListeners();
        });
  }

  final LedgerRepository _ledgerRepository;
  late final StreamSubscription<List<Account>> _accountsSubscription;
  late final StreamSubscription<List<AccountGroup>> _groupsSubscription;

  List<Account> _accounts = const [];
  List<Account> get accounts => _accounts;

  List<AccountGroup> _groups = const [];

  /// The ISO 4217 currency of [accountId]'s group, or null if either can't
  /// be resolved yet.
  String? currencyFor(String? accountId) {
    final account = _accounts
        .where((a) => a.id == accountId)
        .cast<Account?>()
        .firstWhere((a) => a != null, orElse: () => null);
    if (account?.groupId == null) return null;
    return _groups
        .where((g) => g.id == account!.groupId)
        .cast<AccountGroup?>()
        .firstWhere((g) => g != null, orElse: () => null)
        ?.currency;
  }

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

  /// Whether the from/to accounts are in different-currency groups
  /// (multi-currency-support design.md Decisions 4/6) - drives whether the
  /// optional "known destination amount" field is shown at all.
  bool get isCrossCurrency {
    final from = currencyFor(_fromAccountId);
    final to = currencyFor(_toAccountId);
    return from != null && to != null && from != to;
  }

  int? _amountMinor;
  int? get amountMinor => _amountMinor;
  void setAmountMinor(int? value) {
    _amountMinor = value;
    notifyListeners();
  }

  /// Only meaningful when [isCrossCurrency]. Left null: the transfer posts
  /// provisionally, settled later. Supplied: the rate/fee was known
  /// upfront and a single complete entry posts now.
  int? _destinationAmountMinor;
  int? get destinationAmountMinor => _destinationAmountMinor;
  void setDestinationAmountMinor(int? value) {
    _destinationAmountMinor = value;
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
        destinationAmountMinor: isCrossCurrency
            ? _destinationAmountMinor
            : null,
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
    _groupsSubscription.cancel();
    super.dispose();
  }
}
