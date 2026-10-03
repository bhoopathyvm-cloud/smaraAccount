import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/domain/linked_devices/join_code.dart';
import 'package:smara_accounting/domain/linked_devices/join_code_lookup.dart';
import 'package:smara_accounting/domain/linked_devices/join_offer_discovery.dart';
import 'package:smara_accounting/domain/models/join_qr_payload.dart';
import 'package:smara_accounting/domain/models/linked_device_role.dart';
import 'package:smara_accounting/l10n/l10n.dart';
import 'package:smara_accounting/ui/features/settings/views/join_code_entry_panel.dart';
import 'package:smara_accounting/ui/features/settings/views/join_qr_offer_panel.dart';

void main() {
  Future<JoinQrPayload> samplePayload() async {
    final checkCode = await JoinQrPayload.deriveCheckCode('widget-nonce');
    return JoinQrPayload(
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
  }

  testWidgets('offer panel shows join code and time left beside QR', (
    tester,
  ) async {
    final payload = await samplePayload();
    final joinCode = JoinCode(
      raw: 'K7QF3M9P',
      createdAt: DateTime.now().toUtc(),
      offerId: 'offer-1',
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: JoinQrOfferPanel(payload: payload, joinCode: joinCode),
        ),
      ),
    );

    expect(find.byKey(const Key('join-code-display')), findsOneWidget);
    expect(find.text('K7QF-3M9P'), findsOneWidget);
    expect(find.byKey(const Key('join-code-countdown')), findsOneWidget);
    expect(find.textContaining('left'), findsOneWidget);
    expect(find.byKey(const Key('join-qr-check-code')), findsOneWidget);
  });

  testWidgets('offer panel They dont match invokes callback', (tester) async {
    final payload = await samplePayload();
    var cancelled = false;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: JoinQrOfferPanel(
            payload: payload,
            onCodesDontMatch: () => cancelled = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('join-codes-dont-match')));
    await tester.pump();
    expect(cancelled, isTrue);
  });

  testWidgets('enter code accepts lowercase without dash', (tester) async {
    String? submitted;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: JoinCodeEntryPanel(
            onSubmit: (typed) async {
              submitted = typed;
            },
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const Key('join-code-entry-field')),
      'k7qf3m9p',
    );
    await tester.tap(find.byKey(const Key('join-code-entry-submit')));
    await tester.pumpAndSettle();

    expect(submitted, 'k7qf3m9p');
    expect(JoinCode.normalize(submitted!), 'K7QF3M9P');
  });

  testWidgets('enter code shows expired error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: JoinCodeEntryPanel(
            errorMessage: 'This code has expired — ask for a new one',
            onSubmit: (_) async {},
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('join-code-entry-error')), findsOneWidget);
    expect(
      find.text('This code has expired — ask for a new one'),
      findsOneWidget,
    );
  });

  testWidgets('enter code shows used and not-found errors', (tester) async {
    for (final message in [
      'This code was already used. Ask for a new one.',
      'No device with this code on this Wi-Fi',
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: JoinCodeEntryPanel(
              errorMessage: message,
              onSubmit: (_) async {},
            ),
          ),
        ),
      );
      expect(find.text(message), findsOneWidget);
    }
  });

  test('FakeJoinCodeLookup returns injected success and errors', () async {
    final success = FakeJoinCodeLookup(
      result: JoinCodeLookupResult.success(
        JoinCodeLookupSuccess(
          checkCode: '482913',
          offer: const DiscoveredJoinOffer(
            offerId: 'o1',
            host: '10.0.0.2',
            port: 7123,
          ),
          normalizedCode: 'K7QF3M9P',
        ),
      ),
    );
    final ok = await success.lookup('k7qf-3m9p');
    expect(ok.isSuccess, isTrue);
    expect(ok.success!.checkCode, '482913');
    expect(success.typedCodes, ['k7qf-3m9p']);

    for (final error in JoinCodeLookupError.values) {
      final fake = FakeJoinCodeLookup(
        result: JoinCodeLookupResult.failure(error),
      );
      final result = await fake.lookup('K7QF3M9P');
      expect(result.error, error);
    }
  });
}
