import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/ledger_repository.dart';
import '../../../../domain/exceptions.dart';
import '../../../../domain/models/account.dart';
import '../../../../domain/models/account_group.dart';
import '../../../../domain/models/payee.dart';
import '../../../../domain/models/transaction_direction.dart';
import '../../../../domain/statement_import/category_rule.dart'
    show normalizeDescription;

/// One category line within an in-progress split (split-transactions
/// spec: "Split Entry Form Shows a Running Remainder"). [id] is a stable
/// per-line identity (not the category id, which can be null while
/// unset) - the view keys each line's controllers off it so editing one
/// line never rebuilds another's text field state.
class SplitLine {
  SplitLine({this.categoryId, this.amountMinor}) : id = _nextId++;

  static int _nextId = 0;

  final int id;
  String? categoryId;
  int? amountMinor;
}

/// Form state for recording a transaction (amount, direction, category,
/// financial account, date).
class RecordTransactionViewModel extends ChangeNotifier {
  RecordTransactionViewModel({
    required LedgerRepository ledgerRepository,
    String? initialFinancialAccountId,
    TransactionDirection initialDirection = TransactionDirection.moneyIn,
  }) : _ledgerRepository = ledgerRepository,
       _direction = initialDirection {
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
    _payeesSubscription = _ledgerRepository.watchPayees().listen((payees) {
      _payees = payees;
      notifyListeners();
    });
  }

  final LedgerRepository _ledgerRepository;
  late final StreamSubscription<List<Account>> _accountsSubscription;
  late final StreamSubscription<List<AccountGroup>> _groupsSubscription;
  late final StreamSubscription<List<Account>> _categoriesSubscription;
  late final StreamSubscription<List<Payee>> _payeesSubscription;

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

  TransactionDirection _direction;
  TransactionDirection get direction => _direction;
  void setDirection(TransactionDirection value) {
    _direction = value;
    // Categories are direction-scoped (income vs expense) - a split
    // line's previously chosen category is no longer valid once the
    // direction changes, same as the single-category field.
    for (final line in _splitLines) {
      line.categoryId = null;
    }
    // credit-card-household-flow: the paid-from-card/bank shortcuts only
    // apply to Spent - clear them on any direction change so a stale
    // filter never silently narrows the Account picker once the
    // shortcut chips themselves are no longer shown.
    _paidFromCard = false;
    _paidFromBank = false;
    notifyListeners();
  }

  String? _categoryId;
  String? get categoryId => _categoryId;
  void setCategoryId(String? value) {
    _categoryId = value;
    notifyListeners();
  }

  /// Empty means an ordinary, single-category transaction ([categoryId]
  /// is the whole amount) - split-transactions spec: "A Non-Split
  /// Transaction Is The One-Line Case". Non-empty means the user has
  /// expanded into a split; [categoryId] is no longer used at submit time.
  final List<SplitLine> _splitLines = [];
  List<SplitLine> get splitLines => List.unmodifiable(_splitLines);
  bool get isSplitting => _splitLines.isNotEmpty;

  /// Transaction total minus every split line's entered amount - save is
  /// disabled while this is nonzero (spec: "Split Entry Form Shows a
  /// Running Remainder").
  int get splitRemainderMinor {
    final total = _amountMinor ?? 0;
    final allocated = _splitLines.fold<int>(
      0,
      (sum, line) => sum + (line.amountMinor ?? 0),
    );
    return total - allocated;
  }

  /// Expands into a split: the current single category becomes line 1,
  /// a blank line 2 is added. A no-op if already splitting.
  void startSplitting() {
    if (_splitLines.isNotEmpty) return;
    _splitLines.add(SplitLine(categoryId: _categoryId));
    _splitLines.add(SplitLine());
    notifyListeners();
  }

  void addSplitLine() {
    _splitLines.add(SplitLine());
    notifyListeners();
  }

  /// Removing down to one line collapses back to the ordinary,
  /// non-split experience (spec: splitting is "an in-place expansion
  /// from one line to several", reversible the same way).
  void removeSplitLine(int index) {
    _splitLines.removeAt(index);
    if (_splitLines.length == 1) {
      _categoryId = _splitLines.first.categoryId;
      _splitLines.clear();
    }
    notifyListeners();
  }

  void setSplitLineCategory(int index, String? categoryId) {
    _splitLines[index].categoryId = categoryId;
    notifyListeners();
  }

  void setSplitLineAmount(int index, int? amountMinor) {
    _splitLines[index].amountMinor = amountMinor;
    notifyListeners();
  }

  String? _financialAccountId;
  String? get financialAccountId => _financialAccountId;
  void setFinancialAccountId(String? value) {
    _financialAccountId = value;
    notifyListeners();
  }

  /// credit-card-household-flow: whether at least one financial account
  /// is flagged as a credit card - gates the "Paid from card"/"Paid from
  /// bank" shortcuts (spec: "No cards means no shortcut").
  bool get hasCardAccounts => _financialAccounts.any((a) => a.isCreditCard);

  /// Narrows [financialAccounts] to just the picker options relevant to
  /// the active shortcut (design.md Decision 2: "the record-transaction
  /// screen's financial-account picker is unchanged" underneath - this
  /// only filters which of the same accounts it offers).
  bool _paidFromCard = false;
  bool _paidFromBank = false;
  List<Account> get financialAccountOptions {
    if (_paidFromCard) {
      return _financialAccounts.where((a) => a.isCreditCard).toList();
    }
    if (_paidFromBank) {
      return _financialAccounts.where((a) => !a.isCreditCard).toList();
    }
    return _financialAccounts;
  }

  bool get isPaidFromCard => _paidFromCard;
  bool get isPaidFromBank => _paidFromBank;

  void selectPaidFromCard() {
    _paidFromCard = true;
    _paidFromBank = false;
    _preselectFirstOption();
  }

  void selectPaidFromBank() {
    _paidFromCard = false;
    _paidFromBank = true;
    _preselectFirstOption();
  }

  void _preselectFirstOption() {
    final options = financialAccountOptions;
    if (options.isNotEmpty &&
        !options.any((a) => a.id == _financialAccountId)) {
      _financialAccountId = options.first.id;
    }
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

  List<Payee> _payees = const [];

  /// Payees whose (normalized) name contains the given [query] - the
  /// autocomplete source for the description field (payees-and-spending-memory
  /// design.md Non-Goals: v1 suggests only from saved payees, not from
  /// mining historical transaction descriptions).
  List<Payee> payeeSuggestions(String query) {
    final normalizedQuery = normalizeDescription(query);
    if (normalizedQuery.isEmpty) return const [];
    return _payees
        .where((p) => normalizeDescription(p.name).contains(normalizedQuery))
        .toList();
  }

  String? _selectedPayeeId;

  String? _description;
  String? get description => _description;
  void setDescription(String? value) {
    _description = value;
    if (_selectedPayeeId != null && !_matchesSelectedPayee(value)) {
      _selectedPayeeId = null;
    }
    notifyListeners();
  }

  bool _matchesSelectedPayee(String? value) {
    final selected = _payees
        .where((p) => p.id == _selectedPayeeId)
        .cast<Payee?>()
        .firstWhere((p) => p != null, orElse: () => null);
    return selected != null &&
        normalizeDescription(selected.name) ==
            normalizeDescription(value ?? '');
  }

  /// Applies [payee]'s defaults to the form (category, financial account),
  /// always overridable afterward. Tracked so a successful [submit]
  /// updates this payee's remembered defaults to what was actually used.
  void selectPayee(Payee payee) {
    _description = payee.name;
    _selectedPayeeId = payee.id;
    if (payee.defaultCategoryId != null) {
      _categoryId = payee.defaultCategoryId;
    }
    if (payee.defaultFinancialAccountId != null) {
      _financialAccountId = payee.defaultFinancialAccountId;
    }
    notifyListeners();
  }

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> submit() {
    return isSplitting ? _submitSplit() : _submitSingle();
  }

  Future<bool> _submitSingle() async {
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
      final matchedPayee = _matchedPayeeForUsage();
      if (matchedPayee != null) {
        await _ledgerRepository.recordPayeeUsage(
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

  /// split-transactions: not payee-usage-tracked (design.md Risks - a
  /// split has no single category to remember a payee's default as, out
  /// of scope for v1) and no foreign-currency support (recordSplitTransaction
  /// always posts in the financial account's own currency).
  Future<bool> _submitSplit() async {
    final amountMinor = _amountMinor;
    final financialAccountId = _financialAccountId;
    if (amountMinor == null || financialAccountId == null) {
      _errorMessage = 'Amount and account are required.';
      notifyListeners();
      return false;
    }
    if (_splitLines.any(
      (line) => line.categoryId == null || line.amountMinor == null,
    )) {
      _errorMessage = 'Every split line needs a category and an amount.';
      notifyListeners();
      return false;
    }
    if (splitRemainderMinor != 0) {
      _errorMessage = 'Split lines must add up to the transaction total.';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _ledgerRepository.recordSplitTransaction(
        totalAmountMinor: amountMinor,
        splitLines: [
          for (final line in _splitLines)
            (categoryId: line.categoryId!, amountMinor: line.amountMinor!),
        ],
        direction: _direction,
        financialAccountId: financialAccountId,
        transactionDate: _transactionDate,
        description: _description,
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

  /// The payee whose remembered defaults should be updated after a
  /// successful submit: either the explicitly selected payee, or - if the
  /// user typed a description matching an existing payee's name exactly
  /// without picking a suggestion - that payee (design.md Decisions:
  /// defaults double as "last used").
  Payee? _matchedPayeeForUsage() {
    if (_selectedPayeeId != null) {
      return _payees
          .where((p) => p.id == _selectedPayeeId)
          .cast<Payee?>()
          .firstWhere((p) => p != null, orElse: () => null);
    }
    final normalizedDescription = normalizeDescription(_description ?? '');
    if (normalizedDescription.isEmpty) return null;
    return _payees.cast<Payee?>().firstWhere(
      (p) => normalizeDescription(p!.name) == normalizedDescription,
      orElse: () => null,
    );
  }

  @override
  void dispose() {
    _accountsSubscription.cancel();
    _groupsSubscription.cancel();
    _categoriesSubscription.cancel();
    _payeesSubscription.cancel();
    super.dispose();
  }
}
