/// Kind of membership / erase / sync notice shown on Home and Device history
/// after the next sync (linked-devices + peer-sync specs).
enum MembershipNoticeKind {
  deviceAdded,
  deviceRemoved,
  erasePending,
  erased,
  soleOwnerClaimed,
  soleOwnerClaimCancelled,
  soleOwnerClaimEffective,

  /// Entry from a peer failed verification and was not accepted.
  entryNotAccepted,

  /// Owner alert that an unverified batch was refused.
  ownerVerificationAlert,

  /// Competing Fixes resolved; people should check the result.
  competingFixCheck,
}

/// A user-visible membership notice stored in the books database.
class MembershipNotice {
  const MembershipNotice({
    required this.noticeId,
    required this.kind,
    required this.createdAt,
    this.relatedDeviceId,
    this.relatedDisplayName,
    this.detail,
    this.acknowledgedAt,
  });

  final String noticeId;
  final MembershipNoticeKind kind;
  final DateTime createdAt;
  final String? relatedDeviceId;
  final String? relatedDisplayName;
  final String? detail;
  final DateTime? acknowledgedAt;

  bool get isUnread => acknowledgedAt == null;
}
