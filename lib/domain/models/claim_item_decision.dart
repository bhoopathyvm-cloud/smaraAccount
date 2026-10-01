import 'claim_item_decision_kind.dart';

/// Approver decision recorded against one Claim Item.
class ClaimItemDecision {
  const ClaimItemDecision({
    required this.id,
    required this.claimItemId,
    required this.kind,
    required this.decidedByDeviceId,
    required this.decidedAt,
    this.approvedAmountMinor,
    this.reason,
    this.postedEntryId,
  });

  final String id;
  final String claimItemId;
  final ClaimItemDecisionKind kind;
  final String decidedByDeviceId;
  final DateTime decidedAt;

  /// Company-currency amount posted (required for approve kinds).
  final int? approvedAmountMinor;

  /// Required for [ClaimItemDecisionKind.approveDifferentAmount] and
  /// [ClaimItemDecisionKind.reject].
  final String? reason;

  /// Journal Entry id created on approve; null on reject.
  final String? postedEntryId;

  bool get isApproved =>
      kind == ClaimItemDecisionKind.approve ||
      kind == ClaimItemDecisionKind.approveDifferentAmount;

  bool get isRejected => kind == ClaimItemDecisionKind.reject;
}
