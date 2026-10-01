import 'package:drift/drift.dart';

import '../../domain/models/account.dart';
import '../../domain/models/join_qr_payload.dart';
import '../../domain/models/linked_device.dart';
import '../../domain/models/linked_device_role.dart';
import '../database/app_database.dart';
import '../database/tables/account_groups_table.dart';
import 'account_repository.dart';
import 'membership_repository.dart';

/// Coordinates "Add a person" with automatic "Owed to \<name\>" liability
/// account creation (design Decision 5). Lives outside MembershipRepository
/// so Account → Membership never closes the Identity → Account → Ledger
/// cycle (ADR 0002).
class ClaimPersonService {
  ClaimPersonService({
    required MembershipRepository membership,
    required AccountRepository accounts,
    required AppDatabase database,
  }) : _membership = membership,
       _accounts = accounts,
       _db = database;

  final MembershipRepository _membership;
  final AccountRepository _accounts;
  final AppDatabase _db;

  static const peopleOwedGroupName = 'People owed';

  /// Ensures the "People owed" liability group exists for [currency].
  Future<String> ensurePeopleOwedGroup({required String currency}) async {
    final existing = await (_db.select(
      _db.accountGroups,
    )..where((g) => g.id.equals(groupPeopleOwedId))).getSingleOrNull();
    if (existing != null) return existing.id;

    await _db
        .into(_db.accountGroups)
        .insert(
          AccountGroupsCompanion.insert(
            id: const Value(groupPeopleOwedId),
            name: peopleOwedGroupName,
            kind: AccountGroupKind.liabilityGroup,
            sortOrder: 50,
            isSystem: true,
            currency: Value(currency),
          ),
        );
    return groupPeopleOwedId;
  }

  /// Creates (or reuses) "Owed to \<name\>" and returns its account.
  Future<Account> ensureOwedToAccount({
    required String displayName,
    required String currency,
  }) async {
    final groupId = await ensurePeopleOwedGroup(currency: currency);
    final expectedName = 'Owed to $displayName';
    final existing = await (_db.select(
      _db.accounts,
    )..where((a) => a.name.equals(expectedName))).get();
    final active = existing.where((a) => a.archivedAt == null);
    if (active.isNotEmpty) {
      final row = active.first;
      return Account(
        id: row.id,
        name: row.name,
        type: row.type,
        archived: false,
        groupId: row.groupId,
        sortOrder: row.sortOrder,
        holdsInvestments: row.holdsInvestments,
        isCreditCard: row.isCreditCard,
        monthlyLimitMinor: row.monthlyLimitMinor,
      );
    }
    return _accounts.createFinancialAccount(
      name: expectedName,
      type: AccountType.liability,
      groupId: groupId,
    );
  }

  /// Builds an "Add a person" QR (default role Claimant).
  Future<JoinQrPayload> buildAddPersonQr({
    required String hostDeviceId,
    required String hostDisplayName,
    required String booksSetId,
    required String personDisplayName,
    Set<LinkedDeviceRole> roles = const {LinkedDeviceRole.claimant},
  }) {
    return _membership.buildJoinQrPayload(
      hostDeviceId: hostDeviceId,
      hostDisplayName: hostDisplayName,
      booksSetId: booksSetId,
      roleOffer: MembershipRoleGates.primaryRole(roles),
      personRoles: roles,
      personDisplayName: personDisplayName,
      isPersonJoin: true,
    );
  }

  /// Completes Add a person: creates owed-to account when Claimant is in
  /// the role set, then links the device.
  Future<LinkedDevice> acceptAddPerson({
    required String actorDeviceId,
    required JoinQrPayload payload,
    required String joinerDeviceId,
    required String joinerDisplayName,
    required List<int> joinerSigningPublicKey,
    required String joinerDeviceCertFingerprint,
    required String currency,
    String? joinerIdentityId,
    String? peerHint,
  }) async {
    final roles = payload.personRoles.isNotEmpty
        ? payload.personRoles
        : {payload.roleOffer};
    final personName = payload.personDisplayName ?? joinerDisplayName;
    String? owedToId;
    if (roles.contains(LinkedDeviceRole.claimant)) {
      final account = await ensureOwedToAccount(
        displayName: personName,
        currency: currency,
      );
      owedToId = account.id;
    }
    return _membership.acceptJoinFromQr(
      actorDeviceId: actorDeviceId,
      payload: payload,
      joinerDeviceId: joinerDeviceId,
      joinerDisplayName: joinerDisplayName,
      joinerSigningPublicKey: joinerSigningPublicKey,
      joinerDeviceCertFingerprint: joinerDeviceCertFingerprint,
      joinerIdentityId: joinerIdentityId,
      peerHint: peerHint,
      owedToAccountId: owedToId,
    );
  }
}
