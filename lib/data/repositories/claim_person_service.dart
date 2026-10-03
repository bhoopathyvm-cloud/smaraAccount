import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/app_error.dart';
import '../../domain/models/account.dart';
import '../../domain/models/join_qr_payload.dart';
import '../../domain/models/linked_device.dart';
import '../../domain/models/linked_device_role.dart';
import '../database/app_database.dart';
import '../database/tables/account_groups_table.dart';
import 'account_repository.dart';
import 'membership_repository.dart';
import 'metadata_outbox.dart';

/// Coordinates "Add a person" with automatic "Owed to \<name\>" liability
/// account creation (design Decision 5). Lives outside MembershipRepository
/// so Account → Membership never closes the Identity → Account → Ledger
/// cycle (ADR 0002).
class ClaimPersonService {
  ClaimPersonService({
    required MembershipRepository membership,
    required AccountRepository accounts,
    required AppDatabase database,
    MetadataOutbox? outbox,
    Future<String?> Function()? currentIdentityId,
  }) : _membership = membership,
       _accounts = accounts,
       _db = database,
       _outbox = outbox,
       _currentIdentityId = currentIdentityId;

  final MembershipRepository _membership;
  final AccountRepository _accounts;
  final AppDatabase _db;
  final MetadataOutbox? _outbox;
  final Future<String?> Function()? _currentIdentityId;

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
    await _emit('account_group', groupPeopleOwedId, 'kind', 'liabilityGroup');
    await _emit(
      'account_group',
      groupPeopleOwedId,
      'name',
      peopleOwedGroupName,
    );
    await _emit('account_group', groupPeopleOwedId, 'currency', currency);
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

  /// Best-effort company currency from an existing account group.
  Future<String> resolveCompanyCurrency({String fallback = 'EUR'}) async {
    final groups = await _db.select(_db.accountGroups).get();
    for (final g in groups) {
      final c = g.currency;
      if (c != null && c.isNotEmpty) return c;
    }
    return fallback;
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
    List<int> joinerDeviceCertDer = const [],
    String? currency,
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
        currency: currency ?? await resolveCompanyCurrency(),
      );
      owedToId = account.id;
    }
    final linked = await _membership.acceptJoinFromQr(
      actorDeviceId: actorDeviceId,
      payload: payload,
      joinerDeviceId: joinerDeviceId,
      joinerDisplayName: joinerDisplayName,
      joinerSigningPublicKey: joinerSigningPublicKey,
      joinerDeviceCertFingerprint: joinerDeviceCertFingerprint,
      joinerDeviceCertDer: joinerDeviceCertDer,
      joinerIdentityId: joinerIdentityId,
      peerHint: peerHint,
      owedToAccountId: owedToId,
    );
    await emitLinkedDeviceMetadata(
      linked,
      signingPublicKey: joinerSigningPublicKey,
      deviceCertDer: joinerDeviceCertDer,
    );
    return linked;
  }

  /// Emits membership fields so peers (Approver) receive Owed-to linkage.
  Future<void> emitLinkedDeviceMetadata(
    LinkedDevice device, {
    List<int> signingPublicKey = const [],
    List<int> deviceCertDer = const [],
  }) async {
    await _emit(
      'linked_device',
      device.deviceId,
      'displayName',
      device.displayName,
    );
    await _emit(
      'linked_device',
      device.deviceId,
      'signingIdentityId',
      device.signingIdentityId,
    );
    if (signingPublicKey.isNotEmpty) {
      await _emit(
        'linked_device',
        device.deviceId,
        'signingPublicKey',
        base64Encode(signingPublicKey),
      );
    }
    await _emit(
      'linked_device',
      device.deviceId,
      'deviceCertFingerprint',
      device.deviceCertFingerprint,
    );
    if (deviceCertDer.isNotEmpty) {
      await _emit(
        'linked_device',
        device.deviceId,
        'deviceCertDer',
        base64Encode(deviceCertDer),
      );
    }
    await _emit(
      'linked_device',
      device.deviceId,
      'rolesCsv',
      MembershipRoleGates.encodeRoles(device.roles),
    );
    await _emit('linked_device', device.deviceId, 'canAdd', device.canAdd);
    if (device.owedToAccountId != null) {
      await _emit(
        'linked_device',
        device.deviceId,
        'owedToAccountId',
        device.owedToAccountId,
      );
    }
    if (device.personDisplayName != null) {
      await _emit(
        'linked_device',
        device.deviceId,
        'personDisplayName',
        device.personDisplayName,
      );
    }
  }

  /// Removes a person (Owner only). History, receipts, and posted Journal
  /// Entries remain. Archives the owed-to account when [balanceMinor] is
  /// zero (design Decision 5); leaves it when a balance remains.
  Future<LinkedDevice> removePerson({
    required String actorDeviceId,
    required String targetDeviceId,
    int balanceMinor = 0,
  }) async {
    final target = await _membership.findByDeviceId(targetDeviceId);
    if (target == null || !target.isActive) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Person is not an active member.',
      );
    }
    final owedToId = target.owedToAccountId;
    final removed = await _membership.removeDevice(
      actorDeviceId: actorDeviceId,
      targetDeviceId: targetDeviceId,
    );
    if (owedToId != null && balanceMinor == 0) {
      await _accounts.archiveFinancialAccount(owedToId);
    }
    return removed;
  }

  Future<void> _emit(
    String entityType,
    String entityId,
    String field,
    Object? value,
  ) async {
    final outbox = _outbox;
    final identityFn = _currentIdentityId;
    if (outbox == null || identityFn == null) return;
    final identityId = await identityFn();
    if (identityId == null || identityId.isEmpty) return;
    await outbox.emit(
      entityType: entityType,
      entityId: entityId,
      field: field,
      value: value,
      updatedByIdentityId: identityId,
    );
  }
}
