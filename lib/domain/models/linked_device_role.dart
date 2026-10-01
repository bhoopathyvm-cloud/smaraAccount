/// Role of a linked device / person in a books set's membership
/// (linked-devices-and-sync design Decision 6; extended by
/// shared-accounts-and-expense-claims for Approver and Claimant).
///
/// A membership holds a **set** of these roles (one person may be
/// Approver+Member, Owner+Approver, etc.). Capability checks live on
/// [MembershipRoleGates].
enum LinkedDeviceRole { owner, member, approver, claimant }

/// Capability checks over a membership role set
/// (shared-accounts-and-expense-claims design Decision 7).
abstract final class MembershipRoleGates {
  /// Owner ⊃ membership admin (add/remove people and devices, erase, …).
  static bool canManageMembership(Set<LinkedDeviceRole> roles) =>
      roles.contains(LinkedDeviceRole.owner);

  /// Approver or Owner may decide claim items and record payments /
  /// advances to claimants.
  static bool canApproveClaims(Set<LinkedDeviceRole> roles) =>
      roles.contains(LinkedDeviceRole.approver) ||
      roles.contains(LinkedDeviceRole.owner);

  /// Member or Owner may perform ordinary bookkeeping (registers,
  /// categories, Fix). Claimant-only may not.
  static bool canBookkeep(Set<LinkedDeviceRole> roles) =>
      roles.contains(LinkedDeviceRole.member) ||
      roles.contains(LinkedDeviceRole.owner);

  /// Claimant (or anyone who also holds Claimant) may create/submit own
  /// claims. Owner/Approver/Member without Claimant do not submit as
  /// employees unless Claimant is also granted.
  static bool canSubmitOwnClaims(Set<LinkedDeviceRole> roles) =>
      roles.contains(LinkedDeviceRole.claimant);

  /// True when the only role is Claimant (Claimant-scoped UI + sync).
  static bool isClaimantOnly(Set<LinkedDeviceRole> roles) =>
      roles.length == 1 && roles.contains(LinkedDeviceRole.claimant);

  /// Encode a role set for storage (stable sorted CSV).
  static String encodeRoles(Set<LinkedDeviceRole> roles) {
    final names = roles.map((r) => r.name).toList()..sort();
    return names.join(',');
  }

  /// Decode a stored role set. Falls back to [legacyRole] when [csv] is
  /// null/empty (pre-claims schema).
  static Set<LinkedDeviceRole> decodeRoles(
    String? csv, {
    LinkedDeviceRole? legacyRole,
  }) {
    if (csv != null && csv.trim().isNotEmpty) {
      final out = <LinkedDeviceRole>{};
      for (final part in csv.split(',')) {
        final name = part.trim();
        if (name.isEmpty) continue;
        final match = LinkedDeviceRole.values.where((r) => r.name == name);
        if (match.isEmpty) {
          throw FormatException('Unknown membership role: $name');
        }
        out.add(match.first);
      }
      if (out.isNotEmpty) return out;
    }
    if (legacyRole != null) return {legacyRole};
    return const {};
  }

  /// Primary role for backward-compatible single-role APIs: Owner >
  /// Approver > Member > Claimant.
  static LinkedDeviceRole primaryRole(Set<LinkedDeviceRole> roles) {
    if (roles.contains(LinkedDeviceRole.owner)) return LinkedDeviceRole.owner;
    if (roles.contains(LinkedDeviceRole.approver)) {
      return LinkedDeviceRole.approver;
    }
    if (roles.contains(LinkedDeviceRole.member)) return LinkedDeviceRole.member;
    if (roles.contains(LinkedDeviceRole.claimant)) {
      return LinkedDeviceRole.claimant;
    }
    throw ArgumentError.value(roles, 'roles', 'Role set must not be empty');
  }
}
