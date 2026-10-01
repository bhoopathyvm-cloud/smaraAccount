/// Domain-facing view of a `signing_identities` row - the device's
/// current, continued, or superseded signing key, public half only
/// (design.md: "Only the public key is ever stored in the database").
class SigningIdentity {
  const SigningIdentity({
    required this.identityId,
    required this.publicKey,
    required this.createdAt,
    required this.supersedesIdentityId,
    required this.supersededAt,
    required this.continuesIdentityId,
    required this.continuedAt,
    required this.acknowledgedAt,
  });

  final String identityId;
  final List<int> publicKey;
  final DateTime createdAt;
  final String? supersedesIdentityId;
  final DateTime? supersededAt;

  /// Previous identity this one continues, when created by Continuation.
  final String? continuesIdentityId;

  /// When this identity was continued by a later one (entries stay active).
  final DateTime? continuedAt;

  /// When the (retired) recovery-phrase acknowledgment completed, or null.
  final DateTime? acknowledgedAt;
}
