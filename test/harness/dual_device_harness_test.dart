import 'package:test/test.dart';

import 'dual_device_harness.dart';

void main() {
  late DualDeviceHarness harness;

  setUp(() async {
    harness = DualDeviceHarness();
    await harness.setUp();
  });

  tearDown(() async {
    await harness.tearDown();
  });

  test('9.1 smoke: create A/B, link, sync one entry', () async {
    await harness.link();

    final entryId = await harness.a.recordSpend(
      amountMinor: 2500,
      description: 'coffee',
    );

    final result = await harness.syncNow(from: harness.a, to: harness.b);
    expect(result.sender.connected, isTrue);
    expect(result.sender.entriesSent, greaterThanOrEqualTo(1));
    expect(result.receiver.entriesReceived, greaterThanOrEqualTo(1));

    final onB = await harness.b.ledger.watchEntries().first;
    expect(onB.map((e) => e.id), contains(entryId));
    final coffee = onB.firstWhere((e) => e.id == entryId);
    expect(coffee.description, 'coffee');
    expect(coffee.signedByIdentityId, await harness.a.currentIdentityId());

    // Original unchanged on A.
    final onA = await harness.a.ledger.watchEntries().first;
    expect(onA.firstWhere((e) => e.id == entryId).description, 'coffee');
  });
}
