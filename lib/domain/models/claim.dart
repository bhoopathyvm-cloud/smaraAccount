import 'claim_item.dart';
import 'claim_status.dart';

/// A Claim — list of Claim Items with receipts and a derived status.
/// Lives in the company Books Set but is **not** a Journal Entry until
/// an Approver approves an item (Golden Rule #7 / design Decision 1).
class Claim {
  const Claim({
    required this.id,
    required this.claimantDeviceId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.submittedAt,
    this.paidAt,
    this.items = const [],
  });

  final String id;
  final String claimantDeviceId;
  final ClaimStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? submittedAt;
  final DateTime? paidAt;
  final List<ClaimItem> items;

  bool get isEditable => status == ClaimStatus.draft;

  int get approvedCompanyCurrencyTotalMinor => items
      .where((i) => i.decision?.isApproved == true)
      .fold(0, (sum, i) => sum + (i.decision!.approvedAmountMinor ?? 0));
}
