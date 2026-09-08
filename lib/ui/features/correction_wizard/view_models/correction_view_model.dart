import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/account_repository.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/ledger_repository.dart';
import '../../../../domain/correction/correction_draft.dart';
import '../../../../domain/exceptions.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/models/transaction_direction.dart';
import '../../../../l10n/l10n.dart';

/// Form state for fixing a posted transaction (fix-this-correction-wizard):
/// prefilled from the original entry, editable, and on [fix] posts a
/// reversal of the original plus a new entry with the corrected fields -
/// the original entry is never edited or deleted (Golden Rule #7).
///
/// Field rules live on [CorrectionDraft]; this ViewModel owns stream
/// subscriptions, notifies listeners, and orchestrates
/// [LedgerRepository.fixPostedTransaction].
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
       _draft = CorrectionDraft(
         amountMinor: initialAmountMinor,
         direction: initialDirection,
         categoryId: initialCategoryId,
         financialAccountId: initialFinancialAccountId,
         transactionDate: initialTransactionDate,
         description: initialDescription,
       ) {
    _accountsSubscription = _accountRepository.watchFinancialAccounts().listen((
      accounts,
    ) {
      _draft.financialAccounts = accounts;
      notifyListeners();
    });
    _categoriesSubscription = _categoryRepository.watchCategories().listen((
      categories,
    ) {
      _draft.allCategories = categories;
      notifyListeners();
    });
    _currenciesSubscription = _accountRepository
        .watchAccountCurrencies(includeArchived: true)
        .listen((catalog) {
          _draft.currencies = catalog;
          notifyListeners();
        });
  }

  final LedgerRepository _ledgerRepository;
  final AccountRepository _accountRepository;
  final CategoryRepository _categoryRepository;
  final CorrectionDraft _draft;

  /// The original, still-unmodified entry this Fix corrects.
  final String entryId;

  late final StreamSubscription<List<Account>> _accountsSubscription;
  late final StreamSubscription<List<Account>> _categoriesSubscription;
  late final StreamSubscription _currenciesSubscription;

  List<Account> get financialAccounts => _draft.financialAccounts;

  /// The selected account's own currency (localized-money-formatting), or
  /// null until accounts/groups have loaded.
  String? get currency => _draft.currency;

  /// Active categories matching the currently selected direction (income
  /// for Received, expense for Spent) - same rule as record-transaction.
  List<Account> get categories => _draft.categories;

  int get amountMinor => _draft.amountMinor;
  void setAmountMinor(int? value) {
    _draft.setAmountMinor(value);
    notifyListeners();
  }

  TransactionDirection get direction => _draft.direction;
  void setDirection(TransactionDirection value) {
    if (_draft.direction == value) return;
    _draft.setDirection(value);
    notifyListeners();
  }

  String? get categoryId => _draft.categoryId;
  void setCategoryId(String? value) {
    _draft.setCategoryId(value);
    notifyListeners();
  }

  String? get financialAccountId => _draft.financialAccountId;
  void setFinancialAccountId(String? value) {
    _draft.setFinancialAccountId(value);
    notifyListeners();
  }

  DateTime get transactionDate => _draft.transactionDate;
  void setTransactionDate(DateTime value) {
    _draft.setTransactionDate(value);
    notifyListeners();
  }

  String? get description => _draft.description;
  void setDescription(String? value) {
    _draft.setDescription(value);
    notifyListeners();
  }

  bool get canSubmit => _draft.canSubmit;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  /// Posts the fix: a reversal of [entryId] and a new entry with the
  /// corrected fields, as one repository transaction. The original entry
  /// is never edited or deleted (Golden Rule #7).
  Future<bool> fix() async {
    if (!_draft.canSubmit) {
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
        amountMinor: _draft.amountMinor,
        direction: _draft.direction,
        categoryId: _draft.categoryId!,
        financialAccountId: _draft.financialAccountId!,
        transactionDate: _draft.transactionDate,
        description: _draft.description,
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
