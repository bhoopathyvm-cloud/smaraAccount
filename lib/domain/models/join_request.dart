/// A join request from a device that restored a Books Copy and wants to
/// become a Linked device (linked-devices spec: Join After Restoring).
class JoinRequest {
  const JoinRequest({
    required this.requestId,
    required this.requesterDeviceId,
    required this.requesterDisplayName,
    required this.signingPublicKey,
    required this.deviceCertDer,
    required this.deviceCertFingerprint,
    required this.booksSetId,
    required this.createdAt,
    this.resolvedAt,
    this.approved,
  });

  final String requestId;
  final String requesterDeviceId;
  final String requesterDisplayName;
  final List<int> signingPublicKey;
  final List<int> deviceCertDer;
  final String deviceCertFingerprint;
  final String booksSetId;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final bool? approved;

  bool get isPending => resolvedAt == null;
}
