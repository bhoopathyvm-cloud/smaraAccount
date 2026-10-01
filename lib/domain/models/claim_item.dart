import 'claim_item_decision.dart';
import 'claim_receipt.dart';

/// One line on a Claim: category, amounts, optional FX, optional receipt.
class ClaimItem {
  const ClaimItem({
    required this.id,
    required this.claimId,
    required this.categoryId,
    required this.expenseDate,
    required this.paidCurrency,
    required this.paidAmountMinor,
    required this.companyCurrencyAmountMinor,
    required this.sortOrder,
    required this.createdAt,
    this.description,
    this.employeeStatedRate,
    this.rateUsed,
    this.receipt,
    this.decision,
  });

  final String id;
  final String claimId;
  final String categoryId;
  final DateTime expenseDate;
  final String? description;

  /// Currency the employee actually paid in.
  final String paidCurrency;
  final int paidAmountMinor;

  /// Optional card-statement rate (paid → company) from the employee.
  final double? employeeStatedRate;

  /// Rate actually used for [companyCurrencyAmountMinor] (employee stated,
  /// app fallback, or Approver override before approve).
  final double? rateUsed;

  /// Amount in company books currency (before or after Approver edit).
  final int companyCurrencyAmountMinor;

  final int sortOrder;
  final DateTime createdAt;
  final ClaimReceipt? receipt;
  final ClaimItemDecision? decision;

  bool get isPendingDecision => decision == null;
}
