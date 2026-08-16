import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/ledger_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/models/account_group.dart';
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
    _groupsSubscription = _ledgerRepository
        .watchAccountGroups(includeArchived: true)
        .listen((groups) {
          _groups = groups;
          notifyListeners();
        });
    _categoriesSubscription = _ledgerRepository.watchCategories().listen((
      categories,
    ) {
      _categories = categories;
      notifyListeners();
    });
  }

  final LedgerRepository _ledgerRepository;
  late final StreamSubscription<List<Account>> _accountsSubscription;
  late final StreamSubscription<List<AccountGroup>> _groupsSubscription;
  late final StreamSubscription<List<Account>> _categoriesSubscription;

  List<Account> _financialAccounts = const [];
  List<Account> get financialAccounts => _financialAccounts;

  List<AccountGroup> _groups = const [];

  List<Account> _categories = const [];

  /// Active categories matching the currently selected transaction
  /// direction (income for money-in, expense for money-out).
  List<Account> get categories {
    final categoryType = _direction == TransactionDirection.moneyIn
        ? AccountType.income
        : AccountType.expense;
    return _categories.where((a) => a.type == categoryType).toList();
  }

  /// The ISO 4217 currency of [accountId]'s group, or null if either
  /// can't be resolved yet.
  String? currencyFor(String? accountId) {
    final account = _financialAccounts
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

  /// The selected financial account's own currency.
  String? get accountCurrency => currencyFor(_financialAccountId);

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

  /// Explicit override of the transaction's native currency; null means
  /// "same as the selected account's currency" (the common case - no
  /// foreign-currency handling needed).
  String? _nativeCurrency;
  String? get nativeCurrency => _nativeCurrency;
  void setNativeCurrency(String? value) {
    _nativeCurrency = (value == null || value.isEmpty) ? null : value;
    notifyListeners();
  }

  /// Whether this transaction's native currency differs from the selected
  /// account's own currency (multi-currency-support design.md Decision 7) -
  /// drives whether the optional "known account-currency amount" field is
  /// shown at all.
  bool get isForeignCurrency {
    final account = accountCurrency;
    return _nativeCurrency != null &&
        account != null &&
        _nativeCurrency != account;
  }

  /// Only meaningful when [isForeignCurrency]. Left null: the account leg
  /// posts provisionally, settled later. Supplied: the rate was known
  /// upfront and a single complete entry posts now.
  int? _accountCurrencyAmountMinor;
  int? get accountCurrencyAmountMinor => _accountCurrencyAmountMinor;
  void setAccountCurrencyAmountMinor(int? value) {
    _accountCurrencyAmountMinor = value;
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
        nativeCurrency: isForeignCurrency ? _nativeCurrency : null,
        accountCurrencyAmountMinor: isForeignCurrency
            ? _accountCurrencyAmountMinor
            : null,
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
    _groupsSubscription.cancel();
    _categoriesSubscription.cancel();
    super.dispose();
  }
}
