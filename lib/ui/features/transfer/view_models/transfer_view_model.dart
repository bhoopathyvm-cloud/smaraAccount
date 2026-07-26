import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/exchange_rate_service.dart';
import '../../../../data/repositories/ledger_repository.dart';
import '../../../../data/repositories/settings_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/models/account_group.dart';
import '../../../../domain/models/exchange_rate_provider.dart';
import '../../../../domain/models/transaction_direction.dart';

class TransferViewModel extends ChangeNotifier {
  TransferViewModel({
    required LedgerRepository ledgerRepository,
    String? initialFromAccountId,
    ExchangeRateService? exchangeRateService,
    SettingsRepository? settingsRepository,
  }) : _ledgerRepository = ledgerRepository,
       _exchangeRateService = exchangeRateService ?? ExchangeRateService(),
       _settingsRepository = settingsRepository ?? SettingsRepository() {
    _accountsSubscription = _ledgerRepository.watchFinancialAccounts().listen((
      accounts,
    ) {
      _accounts = accounts;
      if (_fromAccountId == null && accounts.isNotEmpty) {
        // Only honor the register's pre-selected account if it's still an
        // active account by the time this first emission arrives - never
        // seed a stale or archived id (e.g. the account was archived
        // between the register screen loading and this one opening).
        final requested = initialFromAccountId;
        final requestedIsActive =
            requested != null && accounts.any((a) => a.id == requested);
        _fromAccountId = requestedIsActive ? requested : accounts.first.id;
      }
      if (_toAccountId == null) {
        for (final account in accounts) {
          if (account.id != _fromAccountId) {
            _toAccountId = account.id;
            break;
          }
        }
      }
      _maybeFetchReferenceRate();
      notifyListeners();
    });
    _groupsSubscription = _ledgerRepository
        .watchAccountGroups(includeArchived: true)
        .listen((groups) {
          _groups = groups;
          _maybeFetchReferenceRate();
          notifyListeners();
        });
    _categoriesSubscription = _ledgerRepository.watchCategories().listen((
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
  final ExchangeRateService _exchangeRateService;
  final SettingsRepository _settingsRepository;
  late final StreamSubscription<List<Account>> _accountsSubscription;
  late final StreamSubscription<List<AccountGroup>> _groupsSubscription;
  late final StreamSubscription<List<Account>> _categoriesSubscription;
  bool _isDisposed = false;

  List<Account> _accounts = const [];
  List<Account> get accounts => _accounts;

  List<AccountGroup> _groups = const [];

  List<Account> _expenseCategories = const [];
  List<Account> get expenseCategories => _expenseCategories;

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
    _maybeFetchReferenceRate();
    notifyListeners();
  }

  String? _toAccountId;
  String? get toAccountId => _toAccountId;
  void setToAccountId(String? value) {
    _toAccountId = value;
    _maybeFetchReferenceRate();
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

  /// Best-effort market rate for the current cross-currency pair, fetched
  /// from the user's selected provider - `null` whenever unavailable
  /// (disabled, same-currency, offline, provider failure, or simply not
  /// fetched yet). Display-only: never written into [destinationAmountMinor]
  /// (design.md Decision 4).
  double? get referenceRate => _referenceRate;

  /// Locally computed from the user's own entered amounts - no network
  /// call, so it's available even when the reference-rate setting is
  /// disabled or the fetch failed. `null` unless both amounts are entered
  /// for a cross-currency transfer. Uses raw minor units directly: this
  /// app's `formatAmountMinor` treats every currency as two-decimal, so
  /// the minor-unit ratio already equals the major-unit ratio.
  double? get impliedRate {
    final amount = _amountMinor;
    final destination = _destinationAmountMinor;
    if (!isCrossCurrency ||
        amount == null ||
        amount <= 0 ||
        destination == null) {
      return null;
    }
    return destination / amount;
  }

  int _referenceRateFetchGeneration = 0;

  /// Re-evaluates whether a reference-rate fetch is warranted for the
  /// current pair and, if so, starts one - cancelling relevance of any
  /// still-in-flight fetch for a previous pair via the generation counter,
  /// so a stale response can never display against the wrong accounts.
  void _maybeFetchReferenceRate() {
    _referenceRateFetchGeneration++;
    final generation = _referenceRateFetchGeneration;
    _referenceRate = null;

    if (!_referenceRateLookupEnabled || !isCrossCurrency) return;
    final from = currencyFor(_fromAccountId);
    final to = currencyFor(_toAccountId);
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

  /// Optional upfront transfer commission/fee - a separate expense entry
  /// against the source account, independent of the transfer entry itself
  /// (design.md Decision 2). Left `null`: no fee path at all, unchanged
  /// single-`recordTransfer` behavior.
  int? _feeAmountMinor;
  int? get feeAmountMinor => _feeAmountMinor;
  void setFeeAmountMinor(int? value) {
    _feeAmountMinor = value;
    notifyListeners();
  }

  String? _feeCategoryId;
  String? get feeCategoryId => _feeCategoryId;
  void setFeeCategoryId(String? value) {
    _feeCategoryId = value;
    notifyListeners();
  }

  String? _feeDescription;
  String? get feeDescription => _feeDescription;
  void setFeeDescription(String? value) {
    _feeDescription = value;
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

    final feeAmountMinor = _feeAmountMinor;
    final hasFee = feeAmountMinor != null;
    if (hasFee && (feeAmountMinor <= 0 || _feeCategoryId == null)) {
      _errorMessage =
          'A transfer fee must be a positive amount with an expense '
          'category selected.';
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

    // The transfer entry is posted and signed at this point - it must not
    // be rolled back, and must not appear to have failed, regardless of
    // what happens to the fee below.
    if (hasFee) {
      try {
        await _ledgerRepository.recordTransaction(
          amountMinor: feeAmountMinor,
          direction: TransactionDirection.moneyOut,
          categoryId: _feeCategoryId!,
          financialAccountId: fromAccountId,
          transactionDate: _transactionDate,
          description: _feeDescription ?? _defaultFeeDescription(toAccountId),
        );
      } on InvalidTransactionAmountException catch (error) {
        _isSubmitting = false;
        _errorMessage =
            'Transfer saved, but the fee could not be recorded: '
            '${error.message}';
        notifyListeners();
        return false;
      } on AccountGroupException catch (error) {
        _isSubmitting = false;
        _errorMessage =
            'Transfer saved, but the fee could not be recorded: '
            '${error.message}';
        notifyListeners();
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
        ? 'Fee for transfer'
        : 'Fee for transfer to ${destination.name}';
  }

  @override
  void dispose() {
    _isDisposed = true;
    _accountsSubscription.cancel();
    _groupsSubscription.cancel();
    _categoriesSubscription.cancel();
    super.dispose();
  }
}
