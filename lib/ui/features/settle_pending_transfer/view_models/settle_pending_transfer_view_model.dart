import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/account_repository.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/ledger_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../l10n/l10n.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/models/account_currency_catalog.dart';
import '../../../../domain/models/home_overview.dart';
import '../../../../domain/transfer/settle_pending_draft.dart';

/// Form state for settling a pending transfer or foreign-currency
/// transaction. Owns streams and submit; form rules live on
/// [SettlePendingDraft].
class SettlePendingTransferViewModel extends ChangeNotifier
    with LocalizedErrorMixin {
  SettlePendingTransferViewModel({
    required LedgerRepository ledgerRepository,
    required AccountRepository accountRepository,
    required CategoryRepository categoryRepository,
    required PendingTransferSummary summary,
  }) : _ledgerRepository = ledgerRepository,
       _accountRepository = accountRepository,
       _categoryRepository = categoryRepository,
       _draft = SettlePendingDraft(summary: summary) {
    _categoriesSubscription = _categoryRepository.watchCategories().listen((
      categories,
    ) {
      _expenseCategories = categories
          .where((c) => c.type == AccountType.expense)
          .toList();
      notifyListeners();
    });
    _currenciesSubscription = _accountRepository
        .watchAccountCurrencies(includeArchived: true)
        .listen((catalog) {
          _currencies = catalog;
          _syncTargetCurrency();
          notifyListeners();
        });
    _syncTargetCurrency();
  }

  final LedgerRepository _ledgerRepository;
  final AccountRepository _accountRepository;
  final CategoryRepository _categoryRepository;
  final SettlePendingDraft _draft;

  PendingTransferSummary get summary => _draft.summary;

  late final StreamSubscription<List<Account>> _categoriesSubscription;
  List<Account> _expenseCategories = const [];
  List<Account> get expenseCategories => _expenseCategories;

  late final StreamSubscription<AccountCurrencyCatalog> _currenciesSubscription;
  AccountCurrencyCatalog _currencies = AccountCurrencyCatalog.empty;

  String? currencyFor(String? accountId) => _currencies.currencyFor(accountId);

  void _syncTargetCurrency() {
    final accountId = _draft.isTransfer
        ? _draft.summary.pendingTransfer.destinationAccountId
        : _draft.summary.pendingTransfer.sourceAccountId;
    _draft.targetAccountCurrency = currencyFor(accountId);
  }

  String? get settledAmountCurrency => _draft.settledAmountCurrency;

  bool get isTransfer => _draft.isTransfer;

  String? get settledToAccountId => _draft.settledToAccountId;
  void setSettledToAccountId(String? value) {
    _draft.settledToAccountId = value;
    _syncTargetCurrency();
    notifyListeners();
  }

  bool get isShortfallComparable => _draft.isShortfallComparable;

  int? get settledAmountMinor => _draft.settledAmountMinor;
  void setSettledAmountMinor(int? value) {
    _draft.settledAmountMinor = value;
    notifyListeners();
  }

  int get shortfallMinor => _draft.shortfallMinor;

  String? get feeCategoryId => _draft.feeCategoryId;
  void setFeeCategoryId(String? value) {
    _draft.feeCategoryId = value;
    notifyListeners();
  }

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  Future<bool> submit() async {
    final settledAmountMinor = _draft.settledAmountMinor;
    if (settledAmountMinor == null) {
      setFailure(
        const AppFailure(AppErrorCode.validationAmountArrivedRequired),
      );
      return false;
    }
    final settledToAccountId = _draft.effectiveSettledToAccountId;
    if (settledToAccountId == null) {
      setFailure(
        const AppFailure(AppErrorCode.validationChooseReceivingAccount),
      );
      return false;
    }

    _isSubmitting = true;
    clearFailure();
    notifyListeners();
    try {
      await _ledgerRepository.settlePendingTransfer(
        pendingTransferId: _draft.summary.pendingTransfer.id,
        settledToAccountId: settledToAccountId,
        settledAmountMinor: settledAmountMinor,
        feeCategoryId: _draft.isShortfallComparable
            ? _draft.feeCategoryId
            : null,
      );
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on PendingTransferException catch (e) {
      _isSubmitting = false;
      setFailure(e);
      return false;
    }
  }

  @override
  void dispose() {
    _categoriesSubscription.cancel();
    _currenciesSubscription.cancel();
    super.dispose();
  }
}
