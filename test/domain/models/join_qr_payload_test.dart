import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/domain/models/join_qr_payload.dart';
import 'package:smara_accounting/domain/models/linked_device_role.dart';

void main() {
  test('JoinQrPayload encode/decode round-trip', () async {
    final expiresAt = DateTime.utc(2026, 10, 2, 12, 0);
    final checkCode = await JoinQrPayload.deriveCheckCode('nonce-1');
    final payload = JoinQrPayload(
      booksSetId: 'set-1',
      hostDeviceId: 'dev-1',
      hostDisplayName: 'Pad',
      hostIdentityId: 'id-host-1',
      signingPublicKey: const [1, 2, 3, 4],
      deviceCertDer: const [9, 8, 7],
      deviceCertFingerprint: 'abc',
      roleOffer: LinkedDeviceRole.member,
      joinNonce: 'nonce-1',
      expiresAt: expiresAt,
      checkCode: checkCode,
    );
    final again = JoinQrPayload.decode(payload.encode());
    expect(again.booksSetId, payload.booksSetId);
    expect(again.hostDeviceId, payload.hostDeviceId);
    expect(again.hostIdentityId, 'id-host-1');
    expect(again.signingPublicKey, payload.signingPublicKey);
    expect(again.deviceCertDer, payload.deviceCertDer);
    expect(again.roleOffer, LinkedDeviceRole.member);
    expect(again.joinNonce, 'nonce-1');
    expect(again.expiresAt, expiresAt);
    expect(again.checkCode, checkCode);
  });

  test('rejects payloads that include private key fields', () {
    expect(
      JoinQrPayload.containsPrivateKeyMaterial(
        '{"signing_private_key":"nope"}',
      ),
      isTrue,
    );
    expect(
      () => JoinQrPayload.decode(
        '{"v":1,"booksSetId":"s","hostDeviceId":"h","hostDisplayName":"n",'
        '"hostIdentityId":"id","signingPublicKey":"YQ==","deviceCert":"YQ==",'
        '"deviceCertFingerprint":"f","roleOffer":"member","joinNonce":"n",'
        '"expiresAt":"2026-10-02T12:00:00.000Z","checkCode":"ABC123",'
        '"secretKey":"bad"}',
      ),
      throwsA(isA<FormatException>()),
    );
  });

  test('deriveCheckCode is stable and six uppercase hex chars', () async {
    final a = await JoinQrPayload.deriveCheckCode('nonce-stable');
    final b = await JoinQrPayload.deriveCheckCode('nonce-stable');
    expect(a, b);
    expect(a.length, 6);
    expect(a, equals(a.toUpperCase()));
    expect(RegExp(r'^[0-9A-F]{6}$').hasMatch(a), isTrue);
  });

  test('isExpiredAt is true at and after expiresAt', () {
    final expiresAt = DateTime.utc(2026, 10, 2, 12, 0);
    final payload = JoinQrPayload(
      booksSetId: 's',
      hostDeviceId: 'h',
      hostDisplayName: 'n',
      hostIdentityId: 'id',
      signingPublicKey: const [1],
      deviceCertDer: const [2],
      deviceCertFingerprint: 'f',
      roleOffer: LinkedDeviceRole.member,
      joinNonce: 'n',
      expiresAt: expiresAt,
      checkCode: 'ABCDEF',
    );
    expect(
      payload.isExpiredAt(expiresAt.subtract(const Duration(seconds: 1))),
      isFalse,
    );
    expect(payload.isExpiredAt(expiresAt), isTrue);
    expect(
      payload.isExpiredAt(expiresAt.add(const Duration(seconds: 1))),
      isTrue,
    );
  });

  test('JoinNonceRegistry refuses reuse', () {
    final registry = JoinNonceRegistry();
    expect(registry.hasBeenUsed('n1'), isFalse);
    registry.markUsed('n1');
    expect(registry.hasBeenUsed('n1'), isTrue);
    expect(registry.hasBeenUsed('n2'), isFalse);
  });
}
