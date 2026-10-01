/// An Advance — payment to a Claimant before Claims, reducing what the
/// company owes when Claims are later approved (design Decision 10).
class ClaimAdvance {
  const ClaimAdvance({
    required this.id,
    required this.claimantDeviceId,
    required this.amountMinor,
    required this.paidFromAccountId,
    required this.postedEntryId,
    required this.recordedAt,
    this.description,
  });

  final String id;
  final String claimantDeviceId;
  final int amountMinor;
  final String paidFromAccountId;
  final String postedEntryId;
  final DateTime recordedAt;
  final String? description;
}
