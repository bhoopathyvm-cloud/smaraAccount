import 'package:smara_accounting/domain/peer_sync/hybrid_logical_clock.dart';
import 'package:smara_accounting/domain/peer_sync/metadata_lww.dart';
import 'package:smara_accounting/domain/peer_sync/sync_payloads.dart';
import 'package:test/test.dart';

void main() {
  test('HLC receive advances past skewed remote wall', () {
    var wall = DateTime.utc(2026, 1, 1, 12);
    final clock = HybridLogicalClock(
      deviceId: 'a',
      wallClock: () => wall,
      initialWall: wall,
      initialCounter: 0,
    );
    // Local clock is 10 minutes behind the remote sender's wall.
    wall = DateTime.utc(2026, 1, 1, 12);
    final remote = HybridLogicalTimestamp(
      wall: DateTime.utc(2026, 1, 1, 12, 10),
      counter: 0,
      deviceId: 'b',
    );
    final after = clock.receive(remote);
    expect(after.isAfter(remote), isTrue);

    final older = MetadataOperation(
      entityType: 'category',
      entityId: 'c1',
      field: 'name',
      value: 'old',
      updatedAt: DateTime.utc(2026, 1, 1, 12, 5),
      updatedByIdentityId: 'id-b',
      hlcCounter: 0,
      hlcDeviceId: 'b',
    );
    final newer = MetadataOperation(
      entityType: 'category',
      entityId: 'c1',
      field: 'name',
      value: 'new',
      updatedAt: after.wall,
      updatedByIdentityId: 'id-a',
      hlcCounter: after.counter,
      hlcDeviceId: after.deviceId,
    );
    expect(const MetadataLww().prefer(newer, older), isTrue);
    expect(const MetadataLww().prefer(older, newer), isFalse);
  });

  test('persisted LWW prefers higher HLC after restart-shaped reload', () {
    final first = MetadataOperation(
      entityType: 'category',
      entityId: 'c1',
      field: 'name',
      value: 'A',
      updatedAt: DateTime.utc(2026, 1, 1, 12),
      updatedByIdentityId: 'id-1',
      hlcCounter: 1,
      hlcDeviceId: 'dev-1',
    );
    final lateOld = MetadataOperation(
      entityType: 'category',
      entityId: 'c1',
      field: 'name',
      value: 'B',
      updatedAt: DateTime.utc(2026, 1, 1, 11, 50),
      updatedByIdentityId: 'id-2',
      hlcCounter: 99,
      hlcDeviceId: 'dev-2',
    );
    final winners = const MetadataLww().merge([first, lateOld]);
    expect(winners.single.value, 'A');
  });
}
