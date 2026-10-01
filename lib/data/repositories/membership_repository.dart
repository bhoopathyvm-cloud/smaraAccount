import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/app_error.dart';
import '../../domain/linked_devices/device_certificate_store.dart';
import '../../domain/linked_devices/local_network_reachability.dart';
import '../../domain/models/join_qr_payload.dart';
import '../../domain/models/join_request.dart';
import '../../domain/models/linked_device.dart';
import '../../domain/models/linked_device_role.dart';
import '../../domain/models/membership_notice.dart';
import '../database/app_database.dart';
import 'identity_repository.dart';

/// Linked-device membership, roles, join QR/request, and notices
/// (linked-devices-and-sync design Decision 6; tasks 4.1–4.5).
///
/// Depends on [AppDatabase] and [IdentityRepository] only — does not close
/// the Identity → Account → Ledger cycle (ADR 0002).
class MembershipRepository {
  MembershipRepository({
    required AppDatabase database,
    required IdentityRepository identityRepository,
    DeviceCertificateStore? certificateStore,
    LocalNetworkReachability? reachability,
    DateTime Function()? clock,
    Uuid? uuid,
    Duration soleOwnerClaimDelay = const Duration(days: 7),
  }) : _db = database,
       _identity = identityRepository,
       _certs = certificateStore ?? FakeDeviceCertificateStore(),
       _reachability = reachability ?? FakeLocalNetworkReachability(),
       _clock = clock ?? DateTime.now,
       _uuid = uuid ?? const Uuid(),
       _soleOwnerClaimDelay = soleOwnerClaimDelay;

  final AppDatabase _db;
  final IdentityRepository _identity;
  final DeviceCertificateStore _certs;
  final LocalNetworkReachability _reachability;
  final DateTime Function() _clock;
  final Uuid _uuid;
  final Duration _soleOwnerClaimDelay;

  /// Lists all membership rows (including removed/erased).
  Future<List<LinkedDevice>> listDevices() async {
    final rows = await _db.select(_db.linkedDevices).get();
    rows.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return rows.map(_toDevice).toList();
  }

  Future<List<LinkedDevice>> listActiveDevices() async {
    final all = await listDevices();
    return all.where((d) => d.isActive).toList();
  }

  Future<LinkedDevice?> findByDeviceId(String deviceId) async {
    final row = await (_db.select(
      _db.linkedDevices,
    )..where((t) => t.deviceId.equals(deviceId))).getSingleOrNull();
    return row == null ? null : _toDevice(row);
  }

  /// Ensures the local device is registered as Owner when membership is empty
  /// (first device to create the books — design Decision 6).
  ///
  /// Returns null when membership already has other devices and this device
  /// is not yet a member (Books-Copy-then-join path — use [createJoinRequest]).
  Future<LinkedDevice?> ensureLocalOwner({
    required String localDeviceId,
    required String displayName,
  }) async {
    final existing = await findByDeviceId(localDeviceId);
    if (existing != null) return existing;

    final active = await listActiveDevices();
    if (active.isNotEmpty) {
      return null;
    }

    final identity = await _identity.currentIdentity();
    if (identity == null) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'No signing identity for local Owner registration.',
      );
    }
    final cert = await _certs.localCertificate(deviceId: localDeviceId);
    return _insertMember(
      deviceId: localDeviceId,
      displayName: displayName,
      signingIdentityId: identity.identityId,
      deviceCertFingerprint: cert.fingerprint,
      roles: {LinkedDeviceRole.owner},
      canAdd: true,
      emitNotice: false,
    );
  }

  /// Whether [actorDeviceId] may add another device.
  Future<bool> canAddDevices(String actorDeviceId) async {
    final actor = await findByDeviceId(actorDeviceId);
    if (actor == null || !actor.isActive) return false;
    if (actor.hasRole(LinkedDeviceRole.owner)) return true;
    return actor.canAdd;
  }

  Future<bool> isOwner(String deviceId) async {
    final device = await findByDeviceId(deviceId);
    return device != null &&
        device.isActive &&
        device.hasRole(LinkedDeviceRole.owner);
  }

  /// True when books have exactly one active Owner and at least one other
  /// active linked device (spec: Second Owner suggestion).
  Future<bool> shouldSuggestSecondOwner() async {
    final active = await listActiveDevices();
    final owners = active.where((d) => d.hasRole(LinkedDeviceRole.owner));
    return owners.length == 1 && active.length >= 2;
  }

  /// Adds a linked device. Actor must be Owner or a Member with can-add.
  Future<LinkedDevice> addDevice({
    required String actorDeviceId,
    required String deviceId,
    required String displayName,
    required String signingIdentityId,
    required String deviceCertFingerprint,
    LinkedDeviceRole role = LinkedDeviceRole.member,
    Set<LinkedDeviceRole>? roles,
    bool canAdd = false,
    String? owedToAccountId,
    String? personDisplayName,
  }) async {
    if (!await canAddDevices(actorDeviceId)) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Not allowed to add a device.',
      );
    }
    final roleSet = roles ?? {role};
    if (roleSet.contains(LinkedDeviceRole.owner) &&
        !await isOwner(actorDeviceId)) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Only an Owner can make another device an Owner.',
      );
    }
    final existing = await findByDeviceId(deviceId);
    if (existing != null && existing.isActive) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Device is already linked.',
      );
    }
    return _insertMember(
      deviceId: deviceId,
      displayName: displayName,
      signingIdentityId: signingIdentityId,
      deviceCertFingerprint: deviceCertFingerprint,
      roles: roleSet,
      canAdd: roleSet.contains(LinkedDeviceRole.owner) ? true : canAdd,
      owedToAccountId: owedToAccountId,
      personDisplayName: personDisplayName,
    );
  }

  /// Owner (or Member with can-add, for remove only when Owner policy allows
  /// add — remove/erase/promote remain Owner-only per spec).
  Future<LinkedDevice> removeDevice({
    required String actorDeviceId,
    required String targetDeviceId,
  }) async {
    if (!await isOwner(actorDeviceId)) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Only an Owner can remove a device.',
      );
    }
    if (actorDeviceId == targetDeviceId) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Cannot remove the acting device this way.',
      );
    }
    final target = await findByDeviceId(targetDeviceId);
    if (target == null || !target.isActive) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Target device is not an active member.',
      );
    }
    final now = _clock();
    await (_db.update(_db.linkedDevices)
          ..where((t) => t.deviceId.equals(targetDeviceId)))
        .write(LinkedDevicesCompanion(removedAt: Value(now)));
    await _recordNotice(
      kind: MembershipNoticeKind.deviceRemoved,
      relatedDeviceId: target.deviceId,
      relatedDisplayName: target.displayName,
    );
    return (await findByDeviceId(targetDeviceId))!;
  }

  /// Marks erase pending for a removed device (Owner only).
  Future<LinkedDevice> markErasePending({
    required String actorDeviceId,
    required String targetDeviceId,
  }) async {
    if (!await isOwner(actorDeviceId)) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Only an Owner can erase a removed device.',
      );
    }
    final target = await findByDeviceId(targetDeviceId);
    if (target == null || target.removedAt == null) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Device must be removed before erase.',
      );
    }
    if (target.erasedAt != null) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Device is already erased.',
      );
    }
    final now = _clock();
    await (_db.update(_db.linkedDevices)
          ..where((t) => t.deviceId.equals(targetDeviceId)))
        .write(LinkedDevicesCompanion(erasePendingAt: Value(now)));
    await _recordNotice(
      kind: MembershipNoticeKind.erasePending,
      relatedDeviceId: target.deviceId,
      relatedDisplayName: target.displayName,
    );
    return (await findByDeviceId(targetDeviceId))!;
  }

  /// Completes erase when the removed device next contacts a peer.
  Future<LinkedDevice> markErased({
    required String targetDeviceId,
    DateTime? at,
  }) async {
    final target = await findByDeviceId(targetDeviceId);
    if (target == null || target.erasePendingAt == null) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'No erase pending for device.',
      );
    }
    final when = at ?? _clock();
    await (_db.update(_db.linkedDevices)
          ..where((t) => t.deviceId.equals(targetDeviceId)))
        .write(LinkedDevicesCompanion(erasedAt: Value(when)));
    await _recordNotice(
      kind: MembershipNoticeKind.erased,
      relatedDeviceId: target.deviceId,
      relatedDisplayName: target.displayName,
      detail: when.toIso8601String(),
    );
    return (await findByDeviceId(targetDeviceId))!;
  }

  Future<LinkedDevice> setCanAdd({
    required String actorDeviceId,
    required String targetDeviceId,
    required bool canAdd,
  }) async {
    if (!await isOwner(actorDeviceId)) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Only an Owner can change who may add devices.',
      );
    }
    final target = await findByDeviceId(targetDeviceId);
    if (target == null || !target.isActive) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Target device is not an active member.',
      );
    }
    await (_db.update(_db.linkedDevices)
          ..where((t) => t.deviceId.equals(targetDeviceId)))
        .write(LinkedDevicesCompanion(canAdd: Value(canAdd)));
    return (await findByDeviceId(targetDeviceId))!;
  }

  Future<LinkedDevice> promoteToOwner({
    required String actorDeviceId,
    required String targetDeviceId,
  }) async {
    if (!await isOwner(actorDeviceId)) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Only an Owner can make another device an Owner.',
      );
    }
    final target = await findByDeviceId(targetDeviceId);
    if (target == null || !target.isActive) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Target device is not an active member.',
      );
    }
    await (_db.update(
      _db.linkedDevices,
    )..where((t) => t.deviceId.equals(targetDeviceId))).write(
      LinkedDevicesCompanion(
        role: const Value(LinkedDeviceRole.owner),
        rolesCsv: Value(
          MembershipRoleGates.encodeRoles({
            ...target.roles,
            LinkedDeviceRole.owner,
          }),
        ),
        canAdd: const Value(true),
      ),
    );
    return (await findByDeviceId(targetDeviceId))!;
  }

  /// Member claims sole ownership when no active Owner remains.
  Future<LinkedDevice> claimSoleOwnership({
    required String claimantDeviceId,
  }) async {
    final claimant = await findByDeviceId(claimantDeviceId);
    if (claimant == null || !claimant.isActive) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Claimant is not an active member.',
      );
    }
    if (claimant.hasRole(LinkedDeviceRole.owner)) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Claimant is already an Owner.',
      );
    }
    final owners = (await listActiveDevices()).where(
      (d) => d.hasRole(LinkedDeviceRole.owner),
    );
    if (owners.isNotEmpty) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'An Owner still remains in membership.',
      );
    }
    final now = _clock();
    await (_db.update(_db.linkedDevices)
          ..where((t) => t.deviceId.equals(claimantDeviceId)))
        .write(LinkedDevicesCompanion(soleOwnerClaimedAt: Value(now)));
    await _recordNotice(
      kind: MembershipNoticeKind.soleOwnerClaimed,
      relatedDeviceId: claimant.deviceId,
      relatedDisplayName: claimant.displayName,
    );
    return (await findByDeviceId(claimantDeviceId))!;
  }

  /// Owner objection cancels a pending sole-Owner claim.
  Future<void> objectToSoleOwnerClaim({
    required String actorDeviceId,
    required String claimantDeviceId,
  }) async {
    if (!await isOwner(actorDeviceId)) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Only an Owner can object to a sole-Owner claim.',
      );
    }
    final claimant = await findByDeviceId(claimantDeviceId);
    if (claimant == null || claimant.soleOwnerClaimedAt == null) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'No pending sole-Owner claim for device.',
      );
    }
    await (_db.update(_db.linkedDevices)
          ..where((t) => t.deviceId.equals(claimantDeviceId)))
        .write(const LinkedDevicesCompanion(soleOwnerClaimedAt: Value(null)));
    await _recordNotice(
      kind: MembershipNoticeKind.soleOwnerClaimCancelled,
      relatedDeviceId: claimant.deviceId,
      relatedDisplayName: claimant.displayName,
    );
  }

  /// Applies claims whose 7-day wait has elapsed with no objection.
  Future<List<LinkedDevice>> applyDueSoleOwnerClaims() async {
    final now = _clock();
    final pending = (await listDevices()).where(
      (d) =>
          d.isActive &&
          !d.hasRole(LinkedDeviceRole.owner) &&
          d.soleOwnerClaimedAt != null,
    );
    final promoted = <LinkedDevice>[];
    for (final claim in pending) {
      final claimedAt = claim.soleOwnerClaimedAt!;
      if (now.isBefore(claimedAt.add(_soleOwnerClaimDelay))) continue;
      final newRoles = {...claim.roles, LinkedDeviceRole.owner};
      await (_db.update(
        _db.linkedDevices,
      )..where((t) => t.deviceId.equals(claim.deviceId))).write(
        LinkedDevicesCompanion(
          role: const Value(LinkedDeviceRole.owner),
          rolesCsv: Value(MembershipRoleGates.encodeRoles(newRoles)),
          canAdd: const Value(true),
          soleOwnerClaimedAt: const Value(null),
        ),
      );
      await _recordNotice(
        kind: MembershipNoticeKind.soleOwnerClaimEffective,
        relatedDeviceId: claim.deviceId,
        relatedDisplayName: claim.displayName,
      );
      promoted.add((await findByDeviceId(claim.deviceId))!);
    }
    return promoted;
  }

  /// Builds a QR payload for "Add a device" or "Add a person". Never
  /// includes private keys.
  Future<JoinQrPayload> buildJoinQrPayload({
    required String hostDeviceId,
    required String hostDisplayName,
    required String booksSetId,
    LinkedDeviceRole roleOffer = LinkedDeviceRole.member,
    Set<LinkedDeviceRole>? personRoles,
    String? personDisplayName,
    bool isPersonJoin = false,
  }) async {
    if (!await canAddDevices(hostDeviceId)) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Not allowed to add a device.',
      );
    }
    final identity = await _identity.currentIdentity();
    if (identity == null) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'No signing identity for join QR.',
      );
    }
    final cert = await _certs.localCertificate(deviceId: hostDeviceId);
    final roles =
        personRoles ??
        (isPersonJoin ? {LinkedDeviceRole.claimant} : {roleOffer});
    final primary = MembershipRoleGates.primaryRole(roles);
    return JoinQrPayload(
      booksSetId: booksSetId,
      hostDeviceId: hostDeviceId,
      hostDisplayName: hostDisplayName,
      hostIdentityId: identity.identityId,
      signingPublicKey: identity.publicKey,
      deviceCertDer: cert.derBytes,
      deviceCertFingerprint: cert.fingerprint,
      roleOffer: isPersonJoin ? primary : roleOffer,
      joinNonce: _uuid.v4(),
      personRoles: roles,
      personDisplayName: personDisplayName,
      isPersonJoin: isPersonJoin,
    );
  }

  /// Completes an in-person join from a scanned QR. Rejects when peers are
  /// not on the local network (no internet relay).
  Future<LinkedDevice> acceptJoinFromQr({
    required String actorDeviceId,
    required JoinQrPayload payload,
    required String joinerDeviceId,
    required String joinerDisplayName,
    required List<int> joinerSigningPublicKey,
    required String joinerDeviceCertFingerprint,
    String? joinerIdentityId,
    String? peerHint,
    String? owedToAccountId,
  }) async {
    final onLan = await _reachability.arePeersOnLocalNetwork(
      peerHint: peerHint ?? payload.hostDeviceId,
    );
    if (!onLan) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Join requires the same Wi-Fi (local network).',
      );
    }
    final peerIdentity = await _identity.addLinkedPeerIdentity(
      publicKey: joinerSigningPublicKey,
      identityId: joinerIdentityId,
    );
    return addDevice(
      actorDeviceId: actorDeviceId,
      deviceId: joinerDeviceId,
      displayName: joinerDisplayName,
      signingIdentityId: peerIdentity.identityId,
      deviceCertFingerprint: joinerDeviceCertFingerprint,
      role: payload.roleOffer,
      roles: payload.personRoles.isNotEmpty
          ? payload.personRoles
          : {payload.roleOffer},
      personDisplayName: payload.personDisplayName,
      owedToAccountId: owedToAccountId,
    );
  }

  /// Creates a join request after restoring a Books Copy.
  Future<JoinRequest> createJoinRequest({
    required String requesterDeviceId,
    required String requesterDisplayName,
    required List<int> signingPublicKey,
    required List<int> deviceCertDer,
    required String deviceCertFingerprint,
    required String booksSetId,
    String? peerHint,
  }) async {
    final onLan = await _reachability.arePeersOnLocalNetwork(
      peerHint: peerHint ?? booksSetId,
    );
    if (!onLan) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Join requires the same Wi-Fi (local network).',
      );
    }
    final requestId = _uuid.v4();
    final now = _clock();
    await _db
        .into(_db.pendingJoinRequests)
        .insert(
          PendingJoinRequestsCompanion.insert(
            requestId: requestId,
            requesterDeviceId: requesterDeviceId,
            requesterDisplayName: requesterDisplayName,
            signingPublicKey: Uint8List.fromList(signingPublicKey),
            deviceCertDer: Uint8List.fromList(deviceCertDer),
            deviceCertFingerprint: deviceCertFingerprint,
            booksSetId: booksSetId,
            createdAt: Value(now),
          ),
        );
    return JoinRequest(
      requestId: requestId,
      requesterDeviceId: requesterDeviceId,
      requesterDisplayName: requesterDisplayName,
      signingPublicKey: signingPublicKey,
      deviceCertDer: deviceCertDer,
      deviceCertFingerprint: deviceCertFingerprint,
      booksSetId: booksSetId,
      createdAt: now,
    );
  }

  Future<List<JoinRequest>> listPendingJoinRequests() async {
    final rows = await (_db.select(
      _db.pendingJoinRequests,
    )..where((t) => t.resolvedAt.isNull())).get();
    rows.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return rows.map(_toJoinRequest).toList();
  }

  /// One-tap approve: links the requester under its own Signing Identity.
  Future<LinkedDevice> approveJoinRequest({
    required String actorDeviceId,
    required String requestId,
    String? peerHint,
  }) async {
    if (!await canAddDevices(actorDeviceId)) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Not allowed to approve a join request.',
      );
    }
    final row = await (_db.select(
      _db.pendingJoinRequests,
    )..where((t) => t.requestId.equals(requestId))).getSingleOrNull();
    if (row == null || row.resolvedAt != null) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Join request is missing or already resolved.',
      );
    }
    final onLan = await _reachability.arePeersOnLocalNetwork(
      peerHint: peerHint ?? row.requesterDeviceId,
    );
    if (!onLan) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Join requires the same Wi-Fi (local network).',
      );
    }
    final peerIdentity = await _identity.addLinkedPeerIdentity(
      publicKey: row.signingPublicKey,
      identityId: null,
    );
    final linked = await addDevice(
      actorDeviceId: actorDeviceId,
      deviceId: row.requesterDeviceId,
      displayName: row.requesterDisplayName,
      signingIdentityId: peerIdentity.identityId,
      deviceCertFingerprint: row.deviceCertFingerprint,
    );
    final now = _clock();
    await (_db.update(
      _db.pendingJoinRequests,
    )..where((t) => t.requestId.equals(requestId))).write(
      PendingJoinRequestsCompanion(
        resolvedAt: Value(now),
        approved: const Value(true),
      ),
    );
    return linked;
  }

  /// Refuse leaves membership unchanged.
  Future<void> refuseJoinRequest({
    required String actorDeviceId,
    required String requestId,
  }) async {
    if (!await canAddDevices(actorDeviceId)) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Not allowed to refuse a join request.',
      );
    }
    final row = await (_db.select(
      _db.pendingJoinRequests,
    )..where((t) => t.requestId.equals(requestId))).getSingleOrNull();
    if (row == null || row.resolvedAt != null) {
      throw const AppFailure(
        AppErrorCode.generic,
        debugMessage: 'Join request is missing or already resolved.',
      );
    }
    final before = await listDevices();
    final now = _clock();
    await (_db.update(
      _db.pendingJoinRequests,
    )..where((t) => t.requestId.equals(requestId))).write(
      PendingJoinRequestsCompanion(
        resolvedAt: Value(now),
        approved: const Value(false),
      ),
    );
    final after = await listDevices();
    if (before.length != after.length) {
      throw StateError('Refuse must not change membership.');
    }
  }

  Future<List<MembershipNotice>> listNotices({bool unreadOnly = false}) async {
    final query = _db.select(_db.membershipNotices);
    if (unreadOnly) {
      query.where((t) => t.acknowledgedAt.isNull());
    }
    final rows = await query.get();
    rows.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return rows.map(_toNotice).toList();
  }

  Future<void> acknowledgeNotice(String noticeId) async {
    await (_db.update(_db.membershipNotices)
          ..where((t) => t.noticeId.equals(noticeId)))
        .write(MembershipNoticesCompanion(acknowledgedAt: Value(_clock())));
  }

  Future<LinkedDevice> _insertMember({
    required String deviceId,
    required String displayName,
    required String signingIdentityId,
    required String deviceCertFingerprint,
    required Set<LinkedDeviceRole> roles,
    required bool canAdd,
    bool emitNotice = true,
    String? owedToAccountId,
    String? personDisplayName,
  }) async {
    if (roles.isEmpty) {
      throw ArgumentError.value(roles, 'roles', 'Role set must not be empty');
    }
    final primary = MembershipRoleGates.primaryRole(roles);
    final now = _clock();
    await _db
        .into(_db.linkedDevices)
        .insertOnConflictUpdate(
          LinkedDevicesCompanion.insert(
            deviceId: deviceId,
            displayName: displayName,
            signingIdentityId: signingIdentityId,
            deviceCertFingerprint: deviceCertFingerprint,
            role: primary,
            rolesCsv: Value(MembershipRoleGates.encodeRoles(roles)),
            canAdd: Value(canAdd),
            owedToAccountId: Value(owedToAccountId),
            personDisplayName: Value(personDisplayName),
            createdAt: Value(now),
            removedAt: const Value(null),
            erasePendingAt: const Value(null),
            erasedAt: const Value(null),
            soleOwnerClaimedAt: const Value(null),
          ),
        );
    if (emitNotice) {
      await _recordNotice(
        kind: MembershipNoticeKind.deviceAdded,
        relatedDeviceId: deviceId,
        relatedDisplayName: displayName,
      );
    }
    return (await findByDeviceId(deviceId))!;
  }

  Future<void> _recordNotice({
    required MembershipNoticeKind kind,
    String? relatedDeviceId,
    String? relatedDisplayName,
    String? detail,
  }) async {
    await _db
        .into(_db.membershipNotices)
        .insert(
          MembershipNoticesCompanion.insert(
            noticeId: _uuid.v4(),
            kind: kind,
            createdAt: Value(_clock()),
            relatedDeviceId: Value(relatedDeviceId),
            relatedDisplayName: Value(relatedDisplayName),
            detail: Value(detail),
          ),
        );
  }

  LinkedDevice _toDevice(LinkedDeviceRow row) {
    final roles = MembershipRoleGates.decodeRoles(
      row.rolesCsv,
      legacyRole: row.role,
    );
    return LinkedDevice(
      deviceId: row.deviceId,
      displayName: row.displayName,
      signingIdentityId: row.signingIdentityId,
      deviceCertFingerprint: row.deviceCertFingerprint,
      role: MembershipRoleGates.primaryRole(roles),
      roles: roles,
      canAdd: row.canAdd,
      createdAt: row.createdAt,
      removedAt: row.removedAt,
      erasePendingAt: row.erasePendingAt,
      erasedAt: row.erasedAt,
      soleOwnerClaimedAt: row.soleOwnerClaimedAt,
      owedToAccountId: row.owedToAccountId,
      personDisplayName: row.personDisplayName,
    );
  }

  JoinRequest _toJoinRequest(PendingJoinRequestRow row) {
    return JoinRequest(
      requestId: row.requestId,
      requesterDeviceId: row.requesterDeviceId,
      requesterDisplayName: row.requesterDisplayName,
      signingPublicKey: row.signingPublicKey,
      deviceCertDer: row.deviceCertDer,
      deviceCertFingerprint: row.deviceCertFingerprint,
      booksSetId: row.booksSetId,
      createdAt: row.createdAt,
      resolvedAt: row.resolvedAt,
      approved: row.approved,
    );
  }

  MembershipNotice _toNotice(MembershipNoticeRow row) {
    return MembershipNotice(
      noticeId: row.noticeId,
      kind: row.kind,
      createdAt: row.createdAt,
      relatedDeviceId: row.relatedDeviceId,
      relatedDisplayName: row.relatedDisplayName,
      detail: row.detail,
      acknowledgedAt: row.acknowledgedAt,
    );
  }
}
