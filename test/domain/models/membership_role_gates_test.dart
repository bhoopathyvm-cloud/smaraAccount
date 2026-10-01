import 'package:smara_accounting/domain/models/linked_device_role.dart';
import 'package:test/test.dart';

void main() {
  group('MembershipRoleGates', () {
    test('Owner can manage membership, approve, and bookkeep', () {
      const roles = {LinkedDeviceRole.owner};
      expect(MembershipRoleGates.canManageMembership(roles), isTrue);
      expect(MembershipRoleGates.canApproveClaims(roles), isTrue);
      expect(MembershipRoleGates.canBookkeep(roles), isTrue);
      expect(MembershipRoleGates.canSubmitOwnClaims(roles), isFalse);
      expect(MembershipRoleGates.isClaimantOnly(roles), isFalse);
    });

    test('Approver can approve but not manage membership alone', () {
      const roles = {LinkedDeviceRole.approver};
      expect(MembershipRoleGates.canManageMembership(roles), isFalse);
      expect(MembershipRoleGates.canApproveClaims(roles), isTrue);
      expect(MembershipRoleGates.canBookkeep(roles), isFalse);
      expect(MembershipRoleGates.canSubmitOwnClaims(roles), isFalse);
    });

    test('Member can bookkeep only', () {
      const roles = {LinkedDeviceRole.member};
      expect(MembershipRoleGates.canManageMembership(roles), isFalse);
      expect(MembershipRoleGates.canApproveClaims(roles), isFalse);
      expect(MembershipRoleGates.canBookkeep(roles), isTrue);
      expect(MembershipRoleGates.canSubmitOwnClaims(roles), isFalse);
    });

    test('Claimant can submit own claims; Claimant-only flag', () {
      const roles = {LinkedDeviceRole.claimant};
      expect(MembershipRoleGates.canSubmitOwnClaims(roles), isTrue);
      expect(MembershipRoleGates.canApproveClaims(roles), isFalse);
      expect(MembershipRoleGates.canBookkeep(roles), isFalse);
      expect(MembershipRoleGates.isClaimantOnly(roles), isTrue);
    });

    test('Approver+Member multi-role combination', () {
      const roles = {LinkedDeviceRole.approver, LinkedDeviceRole.member};
      expect(MembershipRoleGates.canApproveClaims(roles), isTrue);
      expect(MembershipRoleGates.canBookkeep(roles), isTrue);
      expect(MembershipRoleGates.canManageMembership(roles), isFalse);
      expect(MembershipRoleGates.isClaimantOnly(roles), isFalse);
      expect(MembershipRoleGates.primaryRole(roles), LinkedDeviceRole.approver);
    });

    test('encode/decode roles round-trip with legacy fallback', () {
      const roles = {LinkedDeviceRole.claimant, LinkedDeviceRole.approver};
      final csv = MembershipRoleGates.encodeRoles(roles);
      expect(csv, 'approver,claimant');
      expect(MembershipRoleGates.decodeRoles(csv), roles);
      expect(
        MembershipRoleGates.decodeRoles(
          null,
          legacyRole: LinkedDeviceRole.owner,
        ),
        {LinkedDeviceRole.owner},
      );
    });
  });
}
