import 'linked_device_role.dart';

/// A device that is (or was) a member of this books set's Linked devices
/// membership (linked-devices-and-sync design Decision 6; role **set**
/// extended by shared-accounts-and-expense-claims).
class LinkedDevice {
  const LinkedDevice({
    required this.deviceId,
    required this.displayName,
    required this.signingIdentityId,
    required this.deviceCertFingerprint,
    required this.role,
    required this.roles,
    required this.canAdd,
    required this.createdAt,
    this.removedAt,
    this.erasePendingAt,
    this.erasedAt,
    this.soleOwnerClaimedAt,
    this.owedToAccountId,
    this.personDisplayName,
  });

  final String deviceId;
  final String displayName;
  final String signingIdentityId;
  final String deviceCertFingerprint;

  /// Primary role for backward-compatible single-role call sites.
  final LinkedDeviceRole role;

  /// Full role set (Owner, Approver, Member, Claimant combinations).
  final Set<LinkedDeviceRole> roles;

  final bool canAdd;
  final DateTime createdAt;
  final DateTime? removedAt;
  final DateTime? erasePendingAt;
  final DateTime? erasedAt;
  final DateTime? soleOwnerClaimedAt;

  /// Liability Financial Account "Owed to \<name\>" when Claimant.
  final String? owedToAccountId;

  /// Person-facing display name when joined via "Add a person".
  final String? personDisplayName;

  bool get isActive => removedAt == null;

  bool get isErasePending =>
      removedAt != null && erasePendingAt != null && erasedAt == null;

  bool get isErased => erasedAt != null;

  bool get hasPendingSoleOwnerClaim =>
      soleOwnerClaimedAt != null && !hasRole(LinkedDeviceRole.owner);

  bool hasRole(LinkedDeviceRole r) => roles.contains(r);

  bool get canManageMembership =>
      MembershipRoleGates.canManageMembership(roles);

  bool get canApproveClaims => MembershipRoleGates.canApproveClaims(roles);

  bool get canBookkeep => MembershipRoleGates.canBookkeep(roles);

  bool get canSubmitOwnClaims => MembershipRoleGates.canSubmitOwnClaims(roles);

  bool get isClaimantOnly => MembershipRoleGates.isClaimantOnly(roles);
}
