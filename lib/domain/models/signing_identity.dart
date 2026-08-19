/// Domain-facing view of a `signing_identities` row - the device's
/// current or superseded signing key, public half only (design.md:
/// "Only the public key is ever stored in the database").
class SigningIdentity {
  const SigningIdentity({
    required this.identityId,
    required this.publicKey,
    required this.createdAt,
    required this.supersedesIdentityId,
    required this.supersededAt,
    required this.acknowledgedAt,
  });

  final String identityId;
  final List<int> publicKey;
  final DateTime createdAt;
  final String? supersedesIdentityId;
  final DateTime? supersededAt;

  /// When the mandatory recovery-phrase acknowledgment completed for this
  /// identity, or null if it's still pending (deferred-onboarding-first-entry:
  /// the identity is committed before the user reaches the acknowledgment
  /// screens, so this can be null for a brief, deliberate window).
  final DateTime? acknowledgedAt;
}
