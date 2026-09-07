import 'dart:math' as math;

import '../money/currency_minor_units.dart';

/// Mutable transfer-form state: from/to accounts, amounts, optional fee,
/// and computed cross-currency / implied-rate / fee-deducted transfer
/// amount. Catalog currencies are snapshots updated by the ViewModel.
///
/// Never touches Drift, a Repository, or [ExchangeRateService].
class TransferOrderDraft {
  String? fromAccountId;
  String? toAccountId;
  String? fromCurrency;
  String? toCurrency;

  int? amountMinor;
  int? destinationAmountMinor;
  DateTime transactionDate = DateTime.now();
  String? description;

  int? feeAmountMinor;
  String? feeCategoryId;
  String? feeDescription;
  bool feeDeductedFromAmount = false;

  bool get isCrossCurrency {
    final from = fromCurrency;
    final to = toCurrency;
    return from != null && to != null && from != to;
  }

  bool get hasRequiredAccountsAndAmount =>
      fromAccountId != null && toAccountId != null && amountMinor != null;

  bool get hasFee => feeAmountMinor != null;

  /// Fee present but non-positive or missing category.
  bool get feeInvalid =>
      hasFee && (feeAmountMinor! <= 0 || feeCategoryId == null);

  /// Amount that actually moves in the transfer entry after optional
  /// fee deduction. Null when accounts/amount missing, or when deducted
  /// fee would leave a non-positive transfer.
  int? get transferAmountMinor {
    final amount = amountMinor;
    if (amount == null) return null;
    if (!hasFee || !feeDeductedFromAmount) return amount;
    final fee = feeAmountMinor!;
    final transfer = amount - fee;
    if (transfer <= 0) return null;
    return transfer;
  }

  bool get feeExceedsAmountWhenDeducted =>
      hasFee &&
      feeDeductedFromAmount &&
      amountMinor != null &&
      transferAmountMinor == null;

  /// Locally computed from entered amounts. Null unless both amounts are
  /// set for a cross-currency transfer with a positive converted amount.
  double? get impliedRate {
    final amount = amountMinor;
    final destination = destinationAmountMinor;
    final from = fromCurrency;
    final to = toCurrency;
    if (!isCrossCurrency ||
        amount == null ||
        amount <= 0 ||
        destination == null ||
        from == null ||
        to == null) {
      return null;
    }
    final convertedAmount = hasFee && feeDeductedFromAmount
        ? amount - feeAmountMinor!
        : amount;
    if (convertedAmount <= 0) return null;
    final fromMajor =
        convertedAmount / math.pow(10, minorUnitDigitsForCurrency(from));
    final toMajor = destination / math.pow(10, minorUnitDigitsForCurrency(to));
    return toMajor / fromMajor;
  }

  void setFromAccountId(String? value) {
    fromAccountId = value;
    if (toAccountId == value) toAccountId = null;
  }
}
