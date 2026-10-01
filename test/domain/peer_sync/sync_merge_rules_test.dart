import 'package:smara_accounting/domain/peer_sync/competing_fix_resolver.dart';
import 'package:smara_accounting/domain/peer_sync/metadata_lww.dart';
import 'package:smara_accounting/domain/peer_sync/sync_payloads.dart';
import 'package:smara_accounting/domain/peer_sync/sync_settings_allowlist.dart';
import 'package:test/test.dart';

void main() {
  group('CompetingFixResolver', () {
    test('first Fix wins by recordedAt, then identity, then entryId', () {
      final resolver = const CompetingFixResolver();
      final earlier = CompetingFixCandidate(
        entryId: 'fix-b',
        reversesEntryId: 'original',
        recordedAt: DateTime.utc(2026, 4, 1, 10),
        signedByIdentityId: 'id-b',
      );
      final later = CompetingFixCandidate(
        entryId: 'fix-a',
        reversesEntryId: 'original',
        recordedAt: DateTime.utc(2026, 4, 1, 11),
        signedByIdentityId: 'id-a',
      );

      final resolutions = resolver.resolve([later, earlier]);
      expect(resolutions, hasLength(1));
      expect(resolutions.single.winner.entryId, 'fix-b');
      expect(resolutions.single.losers.map((l) => l.entryId), ['fix-a']);
    });

    test('tie-break by identity then entryId when recordedAt equal', () {
      final resolver = const CompetingFixResolver();
      final a = CompetingFixCandidate(
        entryId: 'z-entry',
        reversesEntryId: 'original',
        recordedAt: DateTime.utc(2026, 4, 1, 10),
        signedByIdentityId: 'id-b',
      );
      final b = CompetingFixCandidate(
        entryId: 'a-entry',
        reversesEntryId: 'original',
        recordedAt: DateTime.utc(2026, 4, 1, 10),
        signedByIdentityId: 'id-a',
      );
      final winner = resolver.resolve([a, b]).single.winner;
      expect(winner.entryId, 'a-entry');
      expect(winner.signedByIdentityId, 'id-a');
    });

    test('unrelated originals are independent', () {
      final resolver = const CompetingFixResolver();
      final resolutions = resolver.resolve([
        CompetingFixCandidate(
          entryId: 'f1',
          reversesEntryId: 'o1',
          recordedAt: DateTime.utc(2026, 4, 1),
          signedByIdentityId: 'a',
        ),
        CompetingFixCandidate(
          entryId: 'f2',
          reversesEntryId: 'o2',
          recordedAt: DateTime.utc(2026, 4, 2),
          signedByIdentityId: 'b',
        ),
      ]);
      expect(resolutions, isEmpty);
    });
  });

  group('MetadataLww', () {
    test('later name wins; earlier archive kept when newer on its field', () {
      final lww = const MetadataLww();
      final rename = MetadataOperation(
        entityType: 'category',
        entityId: 'cat-1',
        field: 'name',
        value: 'Food',
        updatedAt: DateTime.utc(2026, 4, 2),
        updatedByIdentityId: 'id-a',
      );
      final archive = MetadataOperation(
        entityType: 'category',
        entityId: 'cat-1',
        field: 'archived',
        value: true,
        updatedAt: DateTime.utc(2026, 4, 1),
        updatedByIdentityId: 'id-b',
      );
      final laterArchive = MetadataOperation(
        entityType: 'category',
        entityId: 'cat-1',
        field: 'archived',
        value: false,
        updatedAt: DateTime.utc(2026, 4, 3),
        updatedByIdentityId: 'id-a',
      );

      final merged = lww.merge([rename, archive, laterArchive]);
      final byField = {for (final o in merged) o.field: o};
      expect(byField['name']!.value, 'Food');
      expect(byField['archived']!.value, false);
    });

    test('identity tie-break when updatedAt equal', () {
      final lww = const MetadataLww();
      final a = MetadataOperation(
        entityType: 'account',
        entityId: 'acc-1',
        field: 'name',
        value: 'FromA',
        updatedAt: DateTime.utc(2026, 4, 1),
        updatedByIdentityId: 'id-a',
      );
      final b = MetadataOperation(
        entityType: 'account',
        entityId: 'acc-1',
        field: 'name',
        value: 'FromB',
        updatedAt: DateTime.utc(2026, 4, 1),
        updatedByIdentityId: 'id-b',
      );
      expect(lww.merge([b, a]).single.value, 'FromA');
    });
  });

  group('SyncSettingsAllowlist', () {
    test('keeps books settings and drops device settings', () {
      final filtered = SyncSettingsAllowlist.filterBooksSettings({
        'referenceRateLookupEnabled': true,
        'quoteProvider': 'yahoo',
        'appLockEnabled': true,
        'preferredLocaleTag': 'en',
        'researchTool': 'perplexity',
        'localDeviceId': 'device-a',
      });
      expect(
        filtered.keys,
        unorderedEquals(['referenceRateLookupEnabled', 'quoteProvider']),
      );
      expect(SyncSettingsAllowlist.isDeviceSetting('appLockEnabled'), isTrue);
      expect(SyncSettingsAllowlist.isBooksSetting('appLockEnabled'), isFalse);
    });
  });
}
