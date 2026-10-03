import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/domain/models/join_qr_payload.dart';
import 'package:smara_accounting/domain/models/linked_device_role.dart';
import 'package:smara_accounting/l10n/l10n.dart';
import 'package:smara_accounting/ui/features/settings/join_qr_scanner.dart';
import 'package:smara_accounting/ui/features/settings/views/join_qr_offer_panel.dart';

void main() {
  testWidgets('JoinQrOfferPanel shows QR check code', (tester) async {
    final checkCode = await JoinQrPayload.deriveCheckCode('widget-nonce');
    final payload = JoinQrPayload(
      booksSetId: 'set',
      hostDeviceId: 'host',
      hostDisplayName: 'Host',
      hostIdentityId: 'id',
      signingPublicKey: const [1, 2],
      deviceCertDer: const [3, 4],
      deviceCertFingerprint: 'fp',
      roleOffer: LinkedDeviceRole.member,
      joinNonce: 'widget-nonce',
      expiresAt: DateTime.utc(2026, 10, 2, 12).add(JoinQrPayload.joinQrTtl),
      checkCode: checkCode,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: JoinQrOfferPanel(payload: payload)),
      ),
    );

    expect(find.byKey(const Key('join-qr-check-code')), findsOneWidget);
    expect(find.text(checkCode), findsOneWidget);
  });

  test('FakeJoinQrScanner returns injected payload', () async {
    final checkCode = await JoinQrPayload.deriveCheckCode('scan-nonce');
    final payload = JoinQrPayload(
      booksSetId: 'set',
      hostDeviceId: 'host',
      hostDisplayName: 'Host',
      hostIdentityId: 'id',
      signingPublicKey: const [1],
      deviceCertDer: const [2],
      deviceCertFingerprint: 'fp',
      roleOffer: LinkedDeviceRole.member,
      joinNonce: 'scan-nonce',
      expiresAt: DateTime.utc(2030, 1, 1),
      checkCode: checkCode,
    );
    final scanner = FakeJoinQrScanner(payload: payload);
    expect(await scanner.scanOnce(), same(payload));
    expect(scanner.scanCount, 1);
  });
}
