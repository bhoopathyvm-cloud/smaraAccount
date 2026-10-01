import '../models/claim_item.dart';
import '../models/claim_status.dart';

/// Derives [ClaimStatus] from items and whether approved amounts are settled
/// (shared-accounts-and-expense-claims design Decision 3).
abstract final class ClaimStatusDerivation {
  static ClaimStatus derive({
    required bool isSubmitted,
    required List<ClaimItem> items,
    required bool approvedAmountFullySettled,
  }) {
    if (!isSubmitted) return ClaimStatus.draft;
    if (items.isEmpty) return ClaimStatus.submitted;

    final pending = items.where((i) => i.isPendingDecision).length;
    final approved = items.where((i) => i.decision?.isApproved == true).length;
    final rejected = items.where((i) => i.decision?.isRejected == true).length;
    final decided = approved + rejected;

    if (decided == 0) return ClaimStatus.submitted;

    if (rejected == items.length) return ClaimStatus.rejected;

    if (pending > 0) {
      if (approved > 0 || rejected > 0) return ClaimStatus.partlyApproved;
      return ClaimStatus.submitted;
    }

    // All decided, at least one approved.
    if (approvedAmountFullySettled) return ClaimStatus.paid;
    return ClaimStatus.approved;
  }
}
