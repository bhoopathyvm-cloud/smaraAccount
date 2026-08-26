import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/account_repository.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/ledger_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../l10n/l10n.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/models/account_currency_catalog.dart';
import '../../../../domain/models/transaction_direction.dart';

/// Form state for fixing a posted transaction (fix-this-correction-wizard):
/// prefilled from the original entry, editable, and on [fix] posts a
/// reversal of the original plus a new entry with the corrected fields -
/// the original entry is never edited or deleted (Golden Rule #7).
class CorrectionViewModel extends ChangeNotifier with LocalizedErrorMixin {
  CorrectionViewModel({
    required LedgerRepository ledgerRepository,
    required AccountRepository accountRepository,
    required CategoryRepository categoryRepository,
    required this.entryId,
    required int initialAmountMinor,
    required TransactionDirection initialDirection,
    required String initialCategoryId,
    required String initialFinancialAccountId,
    required DateTime initialTransactionDate,
    String? initialDescription,
  }) : _ledgerRepository = ledgerRepository,
       _accountRepository = accountRepository,
       _categoryRepository = categoryRepository,
       _amountMinor = initialAmountMinor,
       _direction = initialDirection,
       _categoryId = initialCategoryId,
       _financialAccountId = initialFinancialAccountId,
       _transactionDate = initialTransactionDate,
       _description = initialDescription {
    _accountsSubscription = _accountRepository.watchFinancialAccounts().listen((
      accounts,
    ) {
      _financialAccounts = accounts;
      notifyListeners();
    });
    _categoriesSubscription = _categoryRepository.watchCategories().listen((
      categories,
    ) {
      _categories = categories;
      notifyListeners();
    });
    _currenciesSubscription = _accountRepository
        .watchAccountCurrencies(includeArchived: true)
        .listen((catalog) {
          _currencies = catalog;
          notifyListeners();
        });
  }

  final LedgerRepository _ledgerRepository;
  final AccountRepository _accountRepository;
  final CategoryRepository _categoryRepository;

  /// The original, still-unmodified entry this Fix corrects.
  final String entryId;

  late final StreamSubscription<List<Account>> _accountsSubscription;
  late final StreamSubscription<List<Account>> _categoriesSubscription;
  late final StreamSubscription<AccountCurrencyCatalog> _currenciesSubscription;

  List<Account> _financialAccounts = const [];
  List<Account> get financialAccounts => _financialAccounts;

  AccountCurrencyCatalog _currencies = AccountCurrencyCatalog.empty;

  /// The selected account's own currency (localized-money-formatting), or
  /// null until accounts/groups have loaded.
  String? get currency => _currencies.currencyFor(_financialAccountId);

  List<Account> _categories = const [];

  /// Active categories matching the currently selected direction (income
  /// for Received, expense for Spent) - same rule as record-transaction.
  List<Account> get categories {
    final categoryType = _direction == TransactionDirection.moneyIn
        ? AccountType.income
        : AccountType.expense;
    return _categories.where((a) => a.type == categoryType).toList();
  }

  int _amountMinor;
  int get amountMinor => _amountMinor;
  void setAmountMinor(int? value) {
    if (value == null) return;
    _amountMinor = value;
    notifyListeners();
  }

  TransactionDirection _direction;
  TransactionDirection get direction => _direction;
  void setDirection(TransactionDirection value) {
    if (_direction == value) return;
    _direction = value;
    // The previously-selected category almost certainly doesn't match the
    // new direction's category type (income vs expense) - clear it rather
    // than silently keep an invalid selection, same as record-transaction.
    _categoryId = null;
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

  DateTime _transactionDate;
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

  /// Posts the fix: a reversal of [entryId] and a new entry with the
  /// corrected fields, as one repository transaction. The original entry
  /// is never edited or deleted (Golden Rule #7).
  Future<bool> fix() async {
    final categoryId = _categoryId;
    final financialAccountId = _financialAccountId;
    final amountMinor = _amountMinor;
    if (categoryId == null || financialAccountId == null) {
      setFailure(
        const AppFailure(AppErrorCode.validationAccountCategoryRequired),
      );
      return false;
    }

    _isSubmitting = true;
    clearFailure();
    notifyListeners();

    try {
      await _ledgerRepository.fixPostedTransaction(
        entryId: entryId,
        amountMinor: amountMinor,
        direction: _direction,
        categoryId: categoryId,
        financialAccountId: financialAccountId,
        transactionDate: _transactionDate,
        description: _description,
      );
      return true;
    } on InvalidTransactionAmountException catch (e) {
      setFailure(e);
      return false;
    } on AccountGroupException catch (e) {
      setFailure(e);
      return false;
    } on AlreadyReversedException catch (e) {
      setFailure(e);
      return false;
    } on PendingTransferException catch (e) {
      setFailure(e);
      return false;
    } on InvestmentException catch (e) {
      setFailure(e);
      return false;
    } catch (e) {
      setFailure(const AppFailure(AppErrorCode.validationFixFailed));
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _accountsSubscription.cancel();
    _categoriesSubscription.cancel();
    _currenciesSubscription.cancel();
    super.dispose();
  }
}
