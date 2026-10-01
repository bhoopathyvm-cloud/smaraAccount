import 'linked_device_role.dart';

/// A device that is (or was) a member of this books set's Linked devices
/// membership (linked-devices-and-sync design Decision 6).
class LinkedDevice {
  const LinkedDevice({
    required this.deviceId,
    required this.displayName,
    required this.signingIdentityId,
    required this.deviceCertFingerprint,
    required this.role,
    required this.canAdd,
    required this.createdAt,
    this.removedAt,
    this.erasePendingAt,
    this.erasedAt,
    this.soleOwnerClaimedAt,
  });

  final String deviceId;
  final String displayName;
  final String signingIdentityId;
  final String deviceCertFingerprint;
  final LinkedDeviceRole role;
  final bool canAdd;
  final DateTime createdAt;
  final DateTime? removedAt;
  final DateTime? erasePendingAt;
  final DateTime? erasedAt;
  final DateTime? soleOwnerClaimedAt;

  bool get isActive => removedAt == null;

  bool get isErasePending =>
      removedAt != null && erasePendingAt != null && erasedAt == null;

  bool get isErased => erasedAt != null;

  bool get hasPendingSoleOwnerClaim =>
      soleOwnerClaimedAt != null && role == LinkedDeviceRole.member;
}
