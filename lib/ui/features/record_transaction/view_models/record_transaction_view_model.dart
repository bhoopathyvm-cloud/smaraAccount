import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../../data/repositories/account_repository.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/ledger_repository.dart';
import '../../../../data/repositories/payee_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/models/account_currency_catalog.dart';
import '../../../../domain/models/payee.dart';
import '../../../../domain/models/transaction_direction.dart';
import '../../../../domain/record_transaction/record_transaction_draft.dart';
import '../../../../l10n/l10n.dart';

export '../../../../domain/record_transaction/record_transaction_draft.dart'
    show SplitLine;

/// Form state for recording a transaction (amount, direction, category,
/// financial account, date). Owns streams and submit; form rules live on
/// [RecordTransactionDraft].
class RecordTransactionViewModel extends ChangeNotifier
    with LocalizedErrorMixin {
  RecordTransactionViewModel({
    required LedgerRepository ledgerRepository,
    required AccountRepository accountRepository,
    required CategoryRepository categoryRepository,
    required PayeeRepository payeeRepository,
    String? initialFinancialAccountId,
    TransactionDirection initialDirection = TransactionDirection.moneyIn,
  }) : _ledgerRepository = ledgerRepository,
       _accountRepository = accountRepository,
       _categoryRepository = categoryRepository,
       _payeeRepository = payeeRepository,
       _draft = RecordTransactionDraft(direction: initialDirection),
       _initialFinancialAccountId = initialFinancialAccountId {
    _accountsSubscription = _accountRepository.watchFinancialAccounts().listen((
      accounts,
    ) {
      _draft.financialAccounts = accounts;
      if (_draft.financialAccountId == null && accounts.isNotEmpty) {
        _draft.financialAccountId =
            _initialFinancialAccountId ?? accounts.first.id;
      }
      notifyListeners();
    });
    _currenciesSubscription = _accountRepository
        .watchAccountCurrencies(includeArchived: true)
        .listen((catalog) {
          _currencies = catalog;
          _draft.accountCurrency = catalog.currencyFor(
            _draft.financialAccountId,
          );
          notifyListeners();
        });
    _categoriesSubscription = _categoryRepository.watchCategories().listen((
      categories,
    ) {
      _draft.allCategories = categories;
      notifyListeners();
    });
    _payeesSubscription = _payeeRepository.watchPayees().listen((payees) {
      _draft.payees = payees;
      notifyListeners();
    });
  }

  final LedgerRepository _ledgerRepository;
  final AccountRepository _accountRepository;
  final CategoryRepository _categoryRepository;
  final PayeeRepository _payeeRepository;
  final String? _initialFinancialAccountId;
  final RecordTransactionDraft _draft;

  late final StreamSubscription<List<Account>> _accountsSubscription;
  late final StreamSubscription<AccountCurrencyCatalog> _currenciesSubscription;
  late final StreamSubscription<List<Account>> _categoriesSubscription;
  late final StreamSubscription<List<Payee>> _payeesSubscription;

  AccountCurrencyCatalog _currencies = AccountCurrencyCatalog.empty;

  List<Account> get financialAccounts => _draft.financialAccounts;

  /// Active categories matching the currently selected transaction
  /// direction (income for money-in, expense for money-out).
  List<Account> get categories => _draft.categories;

  /// The ISO 4217 currency of [accountId]'s group, or null if either
  /// can't be resolved yet.
  String? currencyFor(String? accountId) => _currencies.currencyFor(accountId);

  /// The selected financial account's own currency.
  String? get accountCurrency => _draft.accountCurrency;

  int? get amountMinor => _draft.amountMinor;
  void setAmountMinor(int? value) {
    _draft.amountMinor = value;
    notifyListeners();
  }

  TransactionDirection get direction => _draft.direction;
  void setDirection(TransactionDirection value) {
    _draft.setDirection(value);
    notifyListeners();
  }

  String? get categoryId => _draft.categoryId;
  void setCategoryId(String? value) {
    _draft.categoryId = value;
    notifyListeners();
  }

  List<SplitLine> get splitLines => _draft.splitLines;
  bool get isSplitting => _draft.isSplitting;

  int get splitRemainderMinor => _draft.splitRemainderMinor;

  void startSplitting() {
    _draft.startSplitting();
    notifyListeners();
  }

  void addSplitLine() {
    _draft.addSplitLine();
    notifyListeners();
  }

  void removeSplitLine(int index) {
    _draft.removeSplitLine(index);
    notifyListeners();
  }

  void setSplitLineCategory(int index, String? categoryId) {
    _draft.setSplitLineCategory(index, categoryId);
    notifyListeners();
  }

  void setSplitLineAmount(int index, int? amountMinor) {
    _draft.setSplitLineAmount(index, amountMinor);
    notifyListeners();
  }

  String? get financialAccountId => _draft.financialAccountId;
  void setFinancialAccountId(String? value) {
    _draft.financialAccountId = value;
    _draft.accountCurrency = _currencies.currencyFor(value);
    notifyListeners();
  }

  bool get hasCardAccounts => _draft.hasCardAccounts;

  List<Account> get financialAccountOptions => _draft.financialAccountOptions;

  bool get isPaidFromCard => _draft.paidFromCard;
  bool get isPaidFromBank => _draft.paidFromBank;

  void selectPaidFromCard() {
    _draft.selectPaidFromCard();
    _draft.accountCurrency = _currencies.currencyFor(_draft.financialAccountId);
    notifyListeners();
  }

  void selectPaidFromBank() {
    _draft.selectPaidFromBank();
    _draft.accountCurrency = _currencies.currencyFor(_draft.financialAccountId);
    notifyListeners();
  }

  String? get nativeCurrency => _draft.nativeCurrency;
  void setNativeCurrency(String? value) {
    _draft.setNativeCurrency(value);
    notifyListeners();
  }

  bool get isForeignCurrency => _draft.isForeignCurrency;

  int? get accountCurrencyAmountMinor => _draft.accountCurrencyAmountMinor;
  void setAccountCurrencyAmountMinor(int? value) {
    _draft.accountCurrencyAmountMinor = value;
    notifyListeners();
  }

  DateTime get transactionDate => _draft.transactionDate;
  void setTransactionDate(DateTime value) {
    _draft.transactionDate = value;
    notifyListeners();
  }

  List<Payee> payeeSuggestions(String query) => _draft.payeeSuggestions(query);

  String? get description => _draft.description;
  void setDescription(String? value) {
    _draft.setDescription(value);
    notifyListeners();
  }

  void selectPayee(Payee payee) {
    _draft.selectPayee(payee);
    _draft.accountCurrency = _currencies.currencyFor(_draft.financialAccountId);
    notifyListeners();
  }

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  Future<bool> submit() {
    return isSplitting ? _submitSplit() : _submitSingle();
  }

  Future<bool> _submitSingle() async {
    if (!_draft.canSubmitSingle) {
      setFailure(
        const AppFailure(AppErrorCode.validationAmountAccountCategoryRequired),
      );
      return false;
    }

    final categoryId = _draft.categoryId!;
    final amountMinor = _draft.amountMinor!;
    final financialAccountId = _draft.financialAccountId!;

    _isSubmitting = true;
    clearFailure();
    notifyListeners();

    try {
      await _ledgerRepository.recordTransaction(
        amountMinor: amountMinor,
        direction: _draft.direction,
        categoryId: categoryId,
        financialAccountId: financialAccountId,
        transactionDate: _draft.transactionDate,
        description: _draft.description,
        nativeCurrency: _draft.isForeignCurrency ? _draft.nativeCurrency : null,
        accountCurrencyAmountMinor: _draft.isForeignCurrency
            ? _draft.accountCurrencyAmountMinor
            : null,
      );
      final matchedPayee = _draft.matchedPayeeForUsage();
      if (matchedPayee != null) {
        await _payeeRepository.recordPayeeUsage(
          payeeId: matchedPayee.id,
          categoryId: categoryId,
          financialAccountId: financialAccountId,
        );
      }
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on InvalidTransactionAmountException catch (e) {
      _isSubmitting = false;
      setFailure(e);
      return false;
    } on AccountGroupException catch (e) {
      _isSubmitting = false;
      setFailure(e);
      return false;
    }
  }

  Future<bool> _submitSplit() async {
    if (_draft.amountMinor == null || _draft.financialAccountId == null) {
      setFailure(
        const AppFailure(AppErrorCode.validationAmountAccountRequired),
      );
      return false;
    }
    if (_draft.splitLinesIncomplete) {
      setFailure(const AppFailure(AppErrorCode.validationSplitLineIncomplete));
      return false;
    }
    if (_draft.splitRemainderMinor != 0) {
      setFailure(const AppFailure(AppErrorCode.validationSplitSumMismatch));
      return false;
    }

    final amountMinor = _draft.amountMinor!;
    final financialAccountId = _draft.financialAccountId!;

    _isSubmitting = true;
    clearFailure();
    notifyListeners();

    try {
      await _ledgerRepository.recordSplitTransaction(
        totalAmountMinor: amountMinor,
        splitLines: [
          for (final line in _draft.splitLines)
            (categoryId: line.categoryId!, amountMinor: line.amountMinor!),
        ],
        direction: _draft.direction,
        financialAccountId: financialAccountId,
        transactionDate: _draft.transactionDate,
        description: _draft.description,
      );
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on InvalidTransactionAmountException catch (e) {
      _isSubmitting = false;
      setFailure(e);
      return false;
    } on AccountGroupException catch (e) {
      _isSubmitting = false;
      setFailure(e);
      return false;
    }
  }

  @override
  void dispose() {
    _accountsSubscription.cancel();
    _currenciesSubscription.cancel();
    _categoriesSubscription.cancel();
    _payeesSubscription.cancel();
    super.dispose();
  }
}
