import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/domain/models/join_qr_payload.dart';
import 'package:smara_accounting/domain/models/linked_device_role.dart';

void main() {
  test('JoinQrPayload encode/decode round-trip', () {
    const payload = JoinQrPayload(
      booksSetId: 'set-1',
      hostDeviceId: 'dev-1',
      hostDisplayName: 'Pad',
      signingPublicKey: [1, 2, 3, 4],
      deviceCertDer: [9, 8, 7],
      deviceCertFingerprint: 'abc',
      roleOffer: LinkedDeviceRole.member,
      joinNonce: 'nonce-1',
    );
    final again = JoinQrPayload.decode(payload.encode());
    expect(again.booksSetId, payload.booksSetId);
    expect(again.hostDeviceId, payload.hostDeviceId);
    expect(again.signingPublicKey, payload.signingPublicKey);
    expect(again.deviceCertDer, payload.deviceCertDer);
    expect(again.roleOffer, LinkedDeviceRole.member);
    expect(again.joinNonce, 'nonce-1');
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
        '"signingPublicKey":"YQ==","deviceCert":"YQ==",'
        '"deviceCertFingerprint":"f","roleOffer":"member","joinNonce":"n",'
        '"secretKey":"bad"}',
      ),
      throwsA(isA<FormatException>()),
    );
  });
}
