import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/ledger_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/models/account_group.dart';
import '../../../../domain/models/home_overview.dart';
import '../../../../domain/models/pending_transfer.dart';

/// Form state for settling a pending transfer or foreign-currency
/// transaction (multi-currency-support design.md Decision 5).
///
/// A `transfer` may settle to either its own planned destination account
/// (normal delivery, no shortfall comparison) or back to its own source
/// account (bounced/returned - a shortfall below the provisional amount
/// requires a fee/loss category). A `foreignTransaction` always settles to
/// its own source account, following the same no-shortfall path as
/// destination delivery - there's no account picker for it at all.
class SettlePendingTransferViewModel extends ChangeNotifier {
  SettlePendingTransferViewModel({
    required LedgerRepository ledgerRepository,
    required PendingTransferSummary summary,
  }) : _ledgerRepository = ledgerRepository,
       _summary = summary {
    if (isTransfer) {
      _settledToAccountId = summary.pendingTransfer.destinationAccountId;
    }
    _categoriesSubscription = _ledgerRepository.watchCategories().listen((
      categories,
    ) {
      _expenseCategories = categories
          .where((c) => c.type == AccountType.expense)
          .toList();
      notifyListeners();
    });
    _accountsSubscription = _ledgerRepository
        .watchFinancialAccounts(includeArchived: true)
        .listen((accounts) {
          _accounts = accounts;
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
  final PendingTransferSummary _summary;
  PendingTransferSummary get summary => _summary;

  late final StreamSubscription<List<Account>> _categoriesSubscription;
  List<Account> _expenseCategories = const [];
  List<Account> get expenseCategories => _expenseCategories;

  late final StreamSubscription<List<Account>> _accountsSubscription;
  List<Account> _accounts = const [];

  late final StreamSubscription<List<AccountGroup>> _groupsSubscription;
  List<AccountGroup> _groups = const [];

  /// The ISO 4217 currency of [accountId]'s group, or null if either
  /// can't be resolved yet.
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

  /// The currency [settledAmountMinor] should be entered in, given the
  /// current settlement target.
  String? get settledAmountCurrency {
    if (isShortfallComparable) return _summary.currency;
    final targetAccountId = isTransfer
        ? _summary.pendingTransfer.destinationAccountId
        : _summary.pendingTransfer.sourceAccountId;
    return currencyFor(targetAccountId);
  }

  bool get isTransfer =>
      _summary.pendingTransfer.kind == PendingTransferKind.transfer;

  /// Only meaningful when [isTransfer] - a foreignTransaction always
  /// settles to its own source account with no choice offered.
  String? _settledToAccountId;
  String? get settledToAccountId => _settledToAccountId;
  void setSettledToAccountId(String? value) {
    _settledToAccountId = value;
    notifyListeners();
  }

  /// Whether the settlement compares [settledAmountMinor] to the
  /// provisional amount and allows a shortfall fee - true only for a
  /// transfer settling back to its own source account.
  bool get isShortfallComparable =>
      isTransfer &&
      _settledToAccountId == _summary.pendingTransfer.sourceAccountId;

  int? _settledAmountMinor;
  int? get settledAmountMinor => _settledAmountMinor;
  void setSettledAmountMinor(int? value) {
    _settledAmountMinor = value;
    notifyListeners();
  }

  /// Only relevant when [isShortfallComparable] and a shortfall exists.
  int get shortfallMinor {
    if (!isShortfallComparable) return 0;
    final settled = _settledAmountMinor;
    if (settled == null) return 0;
    final shortfall = _summary.amountMinor - settled;
    return shortfall > 0 ? shortfall : 0;
  }

  String? _feeCategoryId;
  String? get feeCategoryId => _feeCategoryId;
  void setFeeCategoryId(String? value) {
    _feeCategoryId = value;
    notifyListeners();
  }

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> submit() async {
    final settledAmountMinor = _settledAmountMinor;
    if (settledAmountMinor == null) {
      _errorMessage = 'Settled amount is required.';
      notifyListeners();
      return false;
    }
    final settledToAccountId = isTransfer
        ? _settledToAccountId
        : _summary.pendingTransfer.sourceAccountId;
    if (settledToAccountId == null) {
      _errorMessage = 'Choose which account received the funds.';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _ledgerRepository.settlePendingTransfer(
        pendingTransferId: _summary.pendingTransfer.id,
        settledToAccountId: settledToAccountId,
        settledAmountMinor: settledAmountMinor,
        feeCategoryId: isShortfallComparable ? _feeCategoryId : null,
      );
      _isSubmitting = false;
      notifyListeners();
      return true;
    } on PendingTransferException catch (e) {
      _isSubmitting = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _categoriesSubscription.cancel();
    _accountsSubscription.cancel();
    _groupsSubscription.cancel();
    super.dispose();
  }
}
