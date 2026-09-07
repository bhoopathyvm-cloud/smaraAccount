import '../models/account.dart';
import '../models/payee.dart';
import '../models/transaction_direction.dart';
import '../statement_import/category_rule.dart' show normalizeDescription;

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

/// Mutable record-transaction form state: amount, direction, category /
/// split lines, financial-account shortcuts, foreign-currency fields,
/// description/payee selection, plus computed remainder, FX visibility,
/// picker filters, and submit readiness.
///
/// Catalog snapshots ([financialAccounts], [allCategories], [payees],
/// [accountCurrency]) are updated by the ViewModel from repository
/// streams. This module never touches Drift or a Repository.
class RecordTransactionDraft {
  RecordTransactionDraft({
    this.direction = TransactionDirection.moneyIn,
    this.financialAccountId,
  });

  // --- Catalog snapshots (owned by ViewModel streams) ---

  List<Account> financialAccounts = const [];
  List<Account> allCategories = const [];
  List<Payee> payees = const [];

  /// ISO 4217 of the selected financial account's group, or null if
  /// unresolved.
  String? accountCurrency;

  // --- Form fields ---

  int? amountMinor;
  TransactionDirection direction;
  String? categoryId;
  String? financialAccountId;
  String? nativeCurrency;
  int? accountCurrencyAmountMinor;
  DateTime transactionDate = DateTime.now();
  String? description;
  String? selectedPayeeId;

  bool paidFromCard = false;
  bool paidFromBank = false;

  final List<SplitLine> _splitLines = [];
  List<SplitLine> get splitLines => List.unmodifiable(_splitLines);
  bool get isSplitting => _splitLines.isNotEmpty;

  /// Active categories matching the currently selected transaction
  /// direction (income for money-in, expense for money-out).
  List<Account> get categories {
    final categoryType = direction == TransactionDirection.moneyIn
        ? AccountType.income
        : AccountType.expense;
    return allCategories.where((a) => a.type == categoryType).toList();
  }

  /// Transaction total minus every split line's entered amount.
  int get splitRemainderMinor {
    final total = amountMinor ?? 0;
    final allocated = _splitLines.fold<int>(
      0,
      (sum, line) => sum + (line.amountMinor ?? 0),
    );
    return total - allocated;
  }

  bool get hasCardAccounts => financialAccounts.any((a) => a.isCreditCard);

  List<Account> get financialAccountOptions {
    if (paidFromCard) {
      return financialAccounts.where((a) => a.isCreditCard).toList();
    }
    if (paidFromBank) {
      return financialAccounts.where((a) => !a.isCreditCard).toList();
    }
    return financialAccounts;
  }

  /// Whether this transaction's native currency differs from the selected
  /// account's own currency.
  bool get isForeignCurrency {
    final account = accountCurrency;
    return nativeCurrency != null &&
        account != null &&
        nativeCurrency != account;
  }

  bool get canSubmitSingle =>
      categoryId != null && amountMinor != null && financialAccountId != null;

  bool get canSubmitSplit {
    if (amountMinor == null || financialAccountId == null) return false;
    if (_splitLines.any(
      (line) => line.categoryId == null || line.amountMinor == null,
    )) {
      return false;
    }
    return splitRemainderMinor == 0;
  }

  bool get splitLinesIncomplete => _splitLines.any(
    (line) => line.categoryId == null || line.amountMinor == null,
  );

  void setDirection(TransactionDirection value) {
    direction = value;
    for (final line in _splitLines) {
      line.categoryId = null;
    }
    paidFromCard = false;
    paidFromBank = false;
  }

  void setNativeCurrency(String? value) {
    nativeCurrency = (value == null || value.isEmpty) ? null : value;
  }

  /// Expands into a split: the current single category becomes line 1,
  /// a blank line 2 is added. A no-op if already splitting.
  void startSplitting() {
    if (_splitLines.isNotEmpty) return;
    _splitLines.add(SplitLine(categoryId: categoryId));
    _splitLines.add(SplitLine());
  }

  void addSplitLine() {
    _splitLines.add(SplitLine());
  }

  /// Removing down to one line collapses back to the ordinary,
  /// non-split experience.
  void removeSplitLine(int index) {
    _splitLines.removeAt(index);
    if (_splitLines.length == 1) {
      categoryId = _splitLines.first.categoryId;
      _splitLines.clear();
    }
  }

  void setSplitLineCategory(int index, String? categoryId) {
    _splitLines[index].categoryId = categoryId;
  }

  void setSplitLineAmount(int index, int? amountMinor) {
    _splitLines[index].amountMinor = amountMinor;
  }

  void selectPaidFromCard() {
    paidFromCard = true;
    paidFromBank = false;
    preselectFirstOption();
  }

  void selectPaidFromBank() {
    paidFromCard = false;
    paidFromBank = true;
    preselectFirstOption();
  }

  void preselectFirstOption() {
    final options = financialAccountOptions;
    if (options.isNotEmpty && !options.any((a) => a.id == financialAccountId)) {
      financialAccountId = options.first.id;
    }
  }

  List<Payee> payeeSuggestions(String query) {
    final normalizedQuery = normalizeDescription(query);
    if (normalizedQuery.isEmpty) return const [];
    return payees
        .where((p) => normalizeDescription(p.name).contains(normalizedQuery))
        .toList();
  }

  void setDescription(String? value) {
    description = value;
    if (selectedPayeeId != null && !_matchesSelectedPayee(value)) {
      selectedPayeeId = null;
    }
  }

  bool _matchesSelectedPayee(String? value) {
    final selected = payees
        .where((p) => p.id == selectedPayeeId)
        .cast<Payee?>()
        .firstWhere((p) => p != null, orElse: () => null);
    return selected != null &&
        normalizeDescription(selected.name) ==
            normalizeDescription(value ?? '');
  }

  void selectPayee(Payee payee) {
    description = payee.name;
    selectedPayeeId = payee.id;
    if (payee.defaultCategoryId != null) {
      categoryId = payee.defaultCategoryId;
    }
    if (payee.defaultFinancialAccountId != null) {
      financialAccountId = payee.defaultFinancialAccountId;
    }
  }

  /// The payee whose remembered defaults should be updated after a
  /// successful submit: either the explicitly selected payee, or an
  /// exact normalized name match on the description.
  Payee? matchedPayeeForUsage() {
    if (selectedPayeeId != null) {
      return payees
          .where((p) => p.id == selectedPayeeId)
          .cast<Payee?>()
          .firstWhere((p) => p != null, orElse: () => null);
    }
    final normalizedDescription = normalizeDescription(description ?? '');
    if (normalizedDescription.isEmpty) return null;
    return payees.cast<Payee?>().firstWhere(
      (p) => normalizeDescription(p!.name) == normalizedDescription,
      orElse: () => null,
    );
  }
}
