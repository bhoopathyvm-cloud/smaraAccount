import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/exchange_rate_service.dart';
import '../../../../data/repositories/account_repository.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/ledger_repository.dart';
import '../../../../data/repositories/settings_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/models/account_currency_catalog.dart';
import '../../../../domain/models/exchange_rate_provider.dart';
import '../../../../domain/models/transaction_direction.dart';
import '../../../../domain/transfer/transfer_order_draft.dart';
import '../../../../l10n/l10n.dart';

class TransferViewModel extends ChangeNotifier with LocalizedErrorMixin {
  TransferViewModel({
    required LedgerRepository ledgerRepository,
    required AccountRepository accountRepository,
    required CategoryRepository categoryRepository,
    String? initialFromAccountId,
    String? initialToAccountId,
    ExchangeRateService? exchangeRateService,
    SettingsRepository? settingsRepository,
  }) : _ledgerRepository = ledgerRepository,
       _accountRepository = accountRepository,
       _categoryRepository = categoryRepository,
       _exchangeRateService = exchangeRateService ?? ExchangeRateService(),
       _settingsRepository = settingsRepository ?? SettingsRepository(),
       _draft = TransferOrderDraft() {
    _accountsSubscription = _accountRepository.watchFinancialAccounts().listen((
      accounts,
    ) {
      _accounts = accounts;
      if (_draft.fromAccountId == null && accounts.isNotEmpty) {
        final requested = initialFromAccountId;
        final requestedIsActive =
            requested != null && accounts.any((a) => a.id == requested);
        _draft.fromAccountId = requestedIsActive
            ? requested
            : accounts.first.id;
      }
      if (_draft.toAccountId == null) {
        final requestedTo = initialToAccountId;
        final requestedToIsActive =
            requestedTo != null &&
            requestedTo != _draft.fromAccountId &&
            accounts.any((a) => a.id == requestedTo);
        if (requestedToIsActive) {
          _draft.toAccountId = requestedTo;
        } else {
          for (final account in accounts) {
            if (account.id != _draft.fromAccountId) {
              _draft.toAccountId = account.id;
              break;
            }
          }
        }
      }
      _syncCurrencies();
      _maybeFetchReferenceRate();
      notifyListeners();
    });
    _currenciesSubscription = _accountRepository
        .watchAccountCurrencies(includeArchived: true)
        .listen((catalog) {
          _currencies = catalog;
          _syncCurrencies();
          _maybeFetchReferenceRate();
          notifyListeners();
        });
    _categoriesSubscription = _categoryRepository.watchCategories().listen((
      categories,
    ) {
      _expenseCategories = categories
          .where((c) => c.type == AccountType.expense)
          .toList();
      notifyListeners();
    });
    _loadReferenceRateSettings();
  }

  final LedgerRepository _ledgerRepository;
  final AccountRepository _accountRepository;
  final CategoryRepository _categoryRepository;
  final ExchangeRateService _exchangeRateService;
  final SettingsRepository _settingsRepository;
  final TransferOrderDraft _draft;
  late final StreamSubscription<List<Account>> _accountsSubscription;
  late final StreamSubscription<AccountCurrencyCatalog> _currenciesSubscription;
  late final StreamSubscription<List<Account>> _categoriesSubscription;
  bool _isDisposed = false;

  List<Account> _accounts = const [];
  List<Account> get accounts => _accounts;

  AccountCurrencyCatalog _currencies = AccountCurrencyCatalog.empty;

  List<Account> _expenseCategories = const [];
  List<Account> get expenseCategories => _expenseCategories;

  String? currencyFor(String? accountId) => _currencies.currencyFor(accountId);

  void _syncCurrencies() {
    _draft.fromCurrency = currencyFor(_draft.fromAccountId);
    _draft.toCurrency = currencyFor(_draft.toAccountId);
  }

  String? get fromAccountId => _draft.fromAccountId;
  void setFromAccountId(String? value) {
    _draft.setFromAccountId(value);
    _syncCurrencies();
    _maybeFetchReferenceRate();
    notifyListeners();
  }

  String? get toAccountId => _draft.toAccountId;
  void setToAccountId(String? value) {
    _draft.toAccountId = value;
    _syncCurrencies();
    _maybeFetchReferenceRate();
    notifyListeners();
  }

  bool get isCrossCurrency => _draft.isCrossCurrency;

  int? get amountMinor => _draft.amountMinor;
  void setAmountMinor(int? value) {
    _draft.amountMinor = value;
    notifyListeners();
  }

  int? get destinationAmountMinor => _draft.destinationAmountMinor;
  void setDestinationAmountMinor(int? value) {
    _draft.destinationAmountMinor = value;
    notifyListeners();
  }

  bool _referenceRateLookupEnabled = false;
  ExchangeRateProvider _selectedProvider = ExchangeRateProvider.values.first;

  Future<void> _loadReferenceRateSettings() async {
    _referenceRateLookupEnabled = await _settingsRepository
        .isReferenceRateLookupEnabled();
    _selectedProvider = await _settingsRepository.selectedProvider();
    if (_isDisposed) return;
    _maybeFetchReferenceRate();
    notifyListeners();
  }

  double? _referenceRate;
  double? get referenceRate => _referenceRate;

  double? get impliedRate => _draft.impliedRate;

  int _referenceRateFetchGeneration = 0;

  void _maybeFetchReferenceRate() {
    _referenceRateFetchGeneration++;
    final generation = _referenceRateFetchGeneration;
    _referenceRate = null;

    if (!_referenceRateLookupEnabled || !isCrossCurrency) return;
    final from = currencyFor(_draft.fromAccountId);
    final to = currencyFor(_draft.toAccountId);
    if (from == null || to == null) return;

    unawaited(
      _exchangeRateService
          .fetchRate(from: from, to: to, provider: _selectedProvider)
          .then((rate) {
            if (_isDisposed || generation != _referenceRateFetchGeneration) {
              return;
            }
            _referenceRate = rate;
            notifyListeners();
          }),
    );
  }

  DateTime get transactionDate => _draft.transactionDate;
  void setTransactionDate(DateTime value) {
    _draft.transactionDate = value;
    notifyListeners();
  }

  String? get description => _draft.description;
  void setDescription(String? value) {
    _draft.description = value;
    notifyListeners();
  }

  int? get feeAmountMinor => _draft.feeAmountMinor;
  void setFeeAmountMinor(int? value) {
    _draft.feeAmountMinor = value;
    notifyListeners();
  }

  String? get feeCategoryId => _draft.feeCategoryId;
  void setFeeCategoryId(String? value) {
    _draft.feeCategoryId = value;
    notifyListeners();
  }

  String? get feeDescription => _draft.feeDescription;
  void setFeeDescription(String? value) {
    _draft.feeDescription = value;
    notifyListeners();
  }

  bool get feeDeductedFromAmount => _draft.feeDeductedFromAmount;
  void setFeeDeductedFromAmount(bool value) {
    _draft.feeDeductedFromAmount = value;
    notifyListeners();
  }

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  Future<bool> submit() async {
    if (!_draft.hasRequiredAccountsAndAmount) {
      setFailure(const AppFailure(AppErrorCode.validationFromToAmountRequired));
      return false;
    }

    if (_draft.feeInvalid) {
      setFailure(
        const AppFailure(AppErrorCode.validationFeePositiveWithCategory),
      );
      return false;
    }

    final transferAmountMinor = _draft.transferAmountMinor;
    if (_draft.feeExceedsAmountWhenDeducted || transferAmountMinor == null) {
      setFailure(
        const AppFailure(AppErrorCode.validationFeeMustBeLessThanAmount),
      );
      return false;
    }

    final fromAccountId = _draft.fromAccountId!;
    final toAccountId = _draft.toAccountId!;
    final feeAmountMinor = _draft.feeAmountMinor;
    final hasFee = _draft.hasFee;

    _isSubmitting = true;
    clearFailure();
    notifyListeners();
    try {
      await _ledgerRepository.recordTransfer(
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        amountMinor: transferAmountMinor,
        transactionDate: _draft.transactionDate,
        description: _draft.description,
        destinationAmountMinor: isCrossCurrency
            ? _draft.destinationAmountMinor
            : null,
      );
    } on InvalidTransferException catch (error) {
      _isSubmitting = false;
      setFailure(error);
      return false;
    } on AccountGroupException catch (error) {
      _isSubmitting = false;
      setFailure(error);
      return false;
    }

    if (hasFee) {
      try {
        await _ledgerRepository.recordTransaction(
          amountMinor: feeAmountMinor!,
          direction: TransactionDirection.moneyOut,
          categoryId: _draft.feeCategoryId!,
          financialAccountId: fromAccountId,
          transactionDate: _draft.transactionDate,
          description:
              _draft.feeDescription ?? _defaultFeeDescription(toAccountId),
        );
      } on InvalidTransactionAmountException catch (error) {
        _isSubmitting = false;
        setFailure(
          AppFailure(
            AppErrorCode.validationTransferSavedFeeFailed,
            params: {'innerCode': error.code.name, ...error.params},
          ),
        );
        return false;
      } on AccountGroupException catch (error) {
        _isSubmitting = false;
        setFailure(
          AppFailure(
            AppErrorCode.validationTransferSavedFeeFailed,
            params: {'innerCode': error.code.name, ...error.params},
          ),
        );
        return false;
      }
    }

    _isSubmitting = false;
    notifyListeners();
    return true;
  }

  String _defaultFeeDescription(String toAccountId) {
    final destination = _accounts
        .where((a) => a.id == toAccountId)
        .cast<Account?>()
        .firstWhere((a) => a != null, orElse: () => null);
    return destination == null
        ? englishAppLocalizations.feeForTransfer
        : englishAppLocalizations.feeForTransferTo(destination.name);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _accountsSubscription.cancel();
    _currenciesSubscription.cancel();
    _categoriesSubscription.cancel();
    super.dispose();
  }
}
