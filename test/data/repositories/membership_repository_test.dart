import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/data/repositories/identity_repository.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/data/repositories/membership_repository.dart';
import 'package:smara_accounting/domain/app_error.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/linked_devices/local_network_reachability.dart';
import 'package:smara_accounting/domain/models/join_qr_payload.dart';
import 'package:smara_accounting/domain/models/linked_device_role.dart';
import 'package:smara_accounting/domain/models/membership_notice.dart';

import '../../domain/crypto/in_memory_secure_key_storage.dart';

void main() {
  late AppDatabase db;
  late IdentityRepository identity;
  late MembershipRepository membership;
  late FakeLocalNetworkReachability reachability;
  late DateTime now;

  setUp(() async {
    now = DateTime.utc(2026, 3, 1, 12);
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final keys = SigningKeyService(secureStorage: InMemorySecureKeyStorage());
    final ledger = LedgerRepository(database: db, signingKeyService: keys);
    final accounts = AccountRepository(database: db, ledgerRepository: ledger);
    identity = IdentityRepository(
      database: db,
      accountRepository: accounts,
      signingKeyService: keys,
    );
    reachability = FakeLocalNetworkReachability(onLocalNetwork: true);
    membership = MembershipRepository(
      database: db,
      identityRepository: identity,
      reachability: reachability,
      clock: () => now,
    );

    final generated = await identity.generateFirstIdentity();
    await identity.confirmFirstIdentity(generated, currency: 'USD');
    await membership.ensureLocalOwner(
      localDeviceId: 'device-a',
      displayName: 'Phone A',
    );
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> addMemberB({bool canAdd = false}) async {
    final peer = await identity.addLinkedPeerIdentity(
      publicKey: List<int>.generate(32, (i) => i + 1),
    );
    await membership.addDevice(
      actorDeviceId: 'device-a',
      deviceId: 'device-b',
      displayName: 'Phone B',
      signingIdentityId: peer.identityId,
      deviceCertFingerprint: 'fp-b',
      canAdd: canAdd,
    );
  }

  Future<void> markRemoved(String deviceId) async {
    await (db.update(db.linkedDevices)
          ..where((t) => t.deviceId.equals(deviceId)))
        .write(LinkedDevicesCompanion(removedAt: Value(now)));
  }

  Future<void> markActive(String deviceId) async {
    await (db.update(db.linkedDevices)
          ..where((t) => t.deviceId.equals(deviceId)))
        .write(const LinkedDevicesCompanion(removedAt: Value(null)));
  }

  group('role gates', () {
    test('Owner can add; Member without can-add cannot', () async {
      expect(await membership.canAddDevices('device-a'), isTrue);
      await addMemberB();
      expect(await membership.canAddDevices('device-b'), isFalse);

      await expectLater(
        membership.addDevice(
          actorDeviceId: 'device-b',
          deviceId: 'device-c',
          displayName: 'C',
          signingIdentityId: 'missing',
          deviceCertFingerprint: 'fp',
        ),
        throwsA(isA<AppFailure>()),
      );
    });

    test('Member with can-add may add; only Owner may remove', () async {
      await addMemberB(canAdd: true);
      expect(await membership.canAddDevices('device-b'), isTrue);

      final peerC = await identity.addLinkedPeerIdentity(
        publicKey: List<int>.generate(32, (i) => i + 40),
      );
      await membership.addDevice(
        actorDeviceId: 'device-b',
        deviceId: 'device-c',
        displayName: 'Phone C',
        signingIdentityId: peerC.identityId,
        deviceCertFingerprint: 'fp-c',
      );

      await expectLater(
        membership.removeDevice(
          actorDeviceId: 'device-b',
          targetDeviceId: 'device-c',
        ),
        throwsA(isA<AppFailure>()),
      );

      final removed = await membership.removeDevice(
        actorDeviceId: 'device-a',
        targetDeviceId: 'device-c',
      );
      expect(removed.isActive, isFalse);
    });

    test('suggests second Owner when one Owner and another device', () async {
      expect(await membership.shouldSuggestSecondOwner(), isFalse);
      await addMemberB();
      expect(await membership.shouldSuggestSecondOwner(), isTrue);
      await membership.promoteToOwner(
        actorDeviceId: 'device-a',
        targetDeviceId: 'device-b',
      );
      expect(await membership.shouldSuggestSecondOwner(), isFalse);
    });
  });

  group('erase pending', () {
    test('marks erase pending then erased', () async {
      await addMemberB();
      await membership.removeDevice(
        actorDeviceId: 'device-a',
        targetDeviceId: 'device-b',
      );
      final pending = await membership.markErasePending(
        actorDeviceId: 'device-a',
        targetDeviceId: 'device-b',
      );
      expect(pending.isErasePending, isTrue);

      now = now.add(const Duration(days: 1));
      final erased = await membership.markErased(targetDeviceId: 'device-b');
      expect(erased.isErased, isTrue);
      expect(erased.erasedAt!.isAtSameMomentAs(now), isTrue);
    });
  });

  group('sole-Owner claim', () {
    test('claim timing and objection cancel', () async {
      await addMemberB();
      await markRemoved('device-a');

      final claimed = await membership.claimSoleOwnership(
        claimantDeviceId: 'device-b',
      );
      expect(claimed.hasPendingSoleOwnerClaim, isTrue);
      expect(claimed.soleOwnerClaimedAt!.isAtSameMomentAs(now), isTrue);

      now = now.add(const Duration(days: 6));
      var promoted = await membership.applyDueSoleOwnerClaims();
      expect(promoted, isEmpty);
      expect(
        (await membership.findByDeviceId('device-b'))!.role,
        LinkedDeviceRole.member,
      );

      await markActive('device-a');
      await membership.objectToSoleOwnerClaim(
        actorDeviceId: 'device-a',
        claimantDeviceId: 'device-b',
      );
      expect(
        (await membership.findByDeviceId('device-b'))!.soleOwnerClaimedAt,
        isNull,
      );
      expect(
        (await membership.findByDeviceId('device-b'))!.role,
        LinkedDeviceRole.member,
      );

      await markRemoved('device-a');
      now = DateTime.utc(2026, 4, 1);
      await membership.claimSoleOwnership(claimantDeviceId: 'device-b');
      now = now.add(const Duration(days: 7));
      promoted = await membership.applyDueSoleOwnerClaims();
      expect(promoted, hasLength(1));
      expect(promoted.single.role, LinkedDeviceRole.owner);
      expect(promoted.single.soleOwnerClaimedAt, isNull);
    });
  });

  group('QR join payload', () {
    test('round-trips without private key material', () async {
      final payload = await membership.buildJoinQrPayload(
        hostDeviceId: 'device-a',
        hostDisplayName: 'Phone A',
        booksSetId: 'books-1',
      );
      final encoded = payload.encode();
      expect(JoinQrPayload.containsPrivateKeyMaterial(encoded), isFalse);
      final decoded = JoinQrPayload.decode(encoded);
      expect(decoded.booksSetId, 'books-1');
      expect(decoded.hostDeviceId, 'device-a');
      expect(decoded.signingPublicKey, isNotEmpty);
      expect(decoded.deviceCertDer, isNotEmpty);
      expect(decoded.joinNonce, isNotEmpty);

      expect(
        () => JoinQrPayload.decode(
          '{"booksSetId":"x","privateKey":"secret","hostDeviceId":"h",'
          '"hostDisplayName":"n","signingPublicKey":"YQ==","deviceCert":"YQ==",'
          '"deviceCertFingerprint":"f","roleOffer":"member","joinNonce":"n"}',
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects join when not on local network', () async {
      reachability.onLocalNetwork = false;
      final payload = await membership.buildJoinQrPayload(
        hostDeviceId: 'device-a',
        hostDisplayName: 'Phone A',
        booksSetId: 'books-1',
      );
      await expectLater(
        membership.acceptJoinFromQr(
          actorDeviceId: 'device-a',
          payload: payload,
          joinerDeviceId: 'device-b',
          joinerDisplayName: 'Phone B',
          joinerSigningPublicKey: List<int>.filled(32, 7),
          joinerDeviceCertFingerprint: 'fp-b',
        ),
        throwsA(isA<AppFailure>()),
      );
    });
  });

  group('Books-Copy join request', () {
    test(
      'approve links requester; refuse leaves membership unchanged',
      () async {
        final request = await membership.createJoinRequest(
          requesterDeviceId: 'device-b',
          requesterDisplayName: 'Phone B',
          signingPublicKey: List<int>.generate(32, (i) => i + 2),
          deviceCertDer: List<int>.filled(16, 9),
          deviceCertFingerprint: 'fp-b',
          booksSetId: 'books-1',
        );

        await membership.refuseJoinRequest(
          actorDeviceId: 'device-a',
          requestId: request.requestId,
        );
        expect(await membership.listActiveDevices(), hasLength(1));
        expect(await membership.listPendingJoinRequests(), isEmpty);

        final request2 = await membership.createJoinRequest(
          requesterDeviceId: 'device-b',
          requesterDisplayName: 'Phone B',
          signingPublicKey: List<int>.generate(32, (i) => i + 2),
          deviceCertDer: List<int>.filled(16, 9),
          deviceCertFingerprint: 'fp-b',
          booksSetId: 'books-1',
        );
        final linked = await membership.approveJoinRequest(
          actorDeviceId: 'device-a',
          requestId: request2.requestId,
        );
        expect(linked.deviceId, 'device-b');
        expect(linked.isActive, isTrue);
        expect(await membership.listActiveDevices(), hasLength(2));
      },
    );
  });

  group('membership notices', () {
    test('created on membership ops and surfaced to notice feed', () async {
      await addMemberB();
      await membership.removeDevice(
        actorDeviceId: 'device-a',
        targetDeviceId: 'device-b',
      );
      await membership.markErasePending(
        actorDeviceId: 'device-a',
        targetDeviceId: 'device-b',
      );

      final notices = await membership.listNotices();
      final kinds = notices.map((n) => n.kind).toSet();
      expect(kinds, contains(MembershipNoticeKind.deviceAdded));
      expect(kinds, contains(MembershipNoticeKind.deviceRemoved));
      expect(kinds, contains(MembershipNoticeKind.erasePending));

      final unread = await membership.listNotices(unreadOnly: true);
      expect(unread, isNotEmpty);
      await membership.acknowledgeNotice(unread.first.noticeId);
      final stillUnread = await membership.listNotices(unreadOnly: true);
      expect(stillUnread.length, unread.length - 1);
    });
  });
}
