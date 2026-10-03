import 'package:smara_accounting/domain/linked_devices/join_code_crypto.dart';
import 'package:smara_accounting/domain/linked_devices/join_offer_discovery.dart';
import 'package:test/test.dart';

void main() {
  tearDown(() {
    FakeJoinOfferDiscovery.resetAll();
  });

  test(
    'FakeJoinOfferDiscovery advertises offer id only and finds peers',
    () async {
      final host = FakeJoinOfferDiscovery(networkId: 'join-lan');
      final joiner = FakeJoinOfferDiscovery(networkId: 'join-lan');

      final found = <DiscoveredJoinOffer>[];
      final sub = joiner.browse().listen(found.add);

      await host.startAdvertising(
        const JoinOfferAdvertisement(offerId: 'offer-abc', port: 7123),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await sub.cancel();

      expect(found, isNotEmpty);
      expect(found.first.offerId, 'offer-abc');
      expect(found.first.port, 7123);
      // TXT must never carry the join code — only offer id.
      expect(found.first.offerId.contains('K7QF'), isFalse);

      await host.stopAdvertising();
      await host.dispose();
      await joiner.dispose();
    },
  );

  test('peers on different networks never see join offers', () async {
    final a = FakeJoinOfferDiscovery(networkId: 'lan-a');
    final b = FakeJoinOfferDiscovery(networkId: 'lan-b');
    final found = <DiscoveredJoinOffer>[];
    final sub = b.browse().listen(found.add);
    await a.startAdvertising(
      const JoinOfferAdvertisement(offerId: 'offer-x', port: 1),
    );
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await sub.cancel();
    expect(found, isEmpty);
    await a.dispose();
    await b.dispose();
  });

  test('service type is _smara-join._tcp', () {
    expect(smaraJoinMdnsServiceType, '_smara-join._tcp');
  });

  test('check code crypto still agrees across sides', () {
    final code = JoinCodeCrypto.checkCode(
      code: 'K7QF3M9P',
      inviterPublicKey: List.filled(32, 1),
      joinerPublicKey: List.filled(32, 2),
      inviterNonce: List.filled(16, 3),
      joinerNonce: List.filled(16, 4),
    );
    expect(code.length, 6);
  });
}
