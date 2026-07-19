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
  });

  final String identityId;
  final List<int> publicKey;
  final DateTime createdAt;
  final String? supersedesIdentityId;
  final DateTime? supersededAt;
}
