/// Signing Identity reserved for a books set the device is about to join.
///
/// Created under that set's namespaced private key *before* the join hello,
/// so the host pins the identity that will actually sign the joined set's
/// entries (linked-devices design Decision 4 — one key per books set).
class ReservedJoinIdentity {
  const ReservedJoinIdentity({
    required this.booksSetId,
    required this.identityId,
    required this.publicKey,
  });

  final String booksSetId;
  final String identityId;
  final List<int> publicKey;
}
