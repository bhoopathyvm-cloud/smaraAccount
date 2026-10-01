import 'package:smara_accounting/domain/peer_sync/claim_sync_payloads.dart';
import 'package:smara_accounting/domain/peer_sync/sync_payloads.dart';
import 'package:test/test.dart';

void main() {
  test('ClaimBatch round-trips without private keys', () {
    final batch = ClaimBatch(
      claims: [
        SyncClaim(
          id: 'c1',
          claimantDeviceId: 'ravi',
          status: 'submitted',
          createdAt: DateTime.utc(2026, 3, 1),
          updatedAt: DateTime.utc(2026, 3, 1),
          submittedAt: DateTime.utc(2026, 3, 1),
          items: [
            SyncClaimItem(
              id: 'i1',
              claimId: 'c1',
              categoryId: 'travel',
              expenseDate: '2026-03-01',
              paidCurrency: 'USD',
              paidAmountMinor: 100,
              companyCurrencyAmountMinor: 100,
              sortOrder: 0,
            ),
          ],
        ),
      ],
    );
    final encoded = batch.encode();
    expect(syncPayloadContainsPrivateKeyMaterial(encoded), isFalse);
    final decoded = ClaimBatch.decode(encoded);
    expect(decoded.claims.single.id, 'c1');
    expect(decoded.claims.single.items.single.categoryId, 'travel');
  });

  test('ClaimBatch rejects private key material', () {
    expect(
      () => ClaimBatch.fromJson({
        'kind': 'claimBatch',
        'claims': [],
        'privateKey': 'secret',
      }),
      throwsFormatException,
    );
  });

  test(
    'ClaimantSyncFilter keeps own claims and drops foreign bank entries',
    () {
      final batch = ClaimBatch(
        claims: [
          SyncClaim(
            id: 'c1',
            claimantDeviceId: 'ravi',
            status: 'submitted',
            createdAt: DateTime.utc(2026, 3, 1),
            updatedAt: DateTime.utc(2026, 3, 1),
            items: const [],
          ),
          SyncClaim(
            id: 'c2',
            claimantDeviceId: 'other',
            status: 'submitted',
            createdAt: DateTime.utc(2026, 3, 1),
            updatedAt: DateTime.utc(2026, 3, 1),
            items: const [],
          ),
        ],
      );
      final filtered = ClaimantSyncFilter.filterClaims(
        batch: batch,
        claimantDeviceId: 'ravi',
      );
      expect(filtered.claims.map((c) => c.id), ['c1']);

      final entries = EntryBatch(
        entries: [
          SyncJournalEntry(
            id: 'e1',
            transactionDate: '2026-03-01',
            recordedAt: DateTime.utc(2026, 3, 1),
            description: 'claim pay',
            reversesEntryId: null,
            deviceChainSequence: 1,
            previousEntryHash: List.filled(32, 0),
            entryHash: List.filled(32, 1),
            signedByIdentityId: 'id',
            signature: List.filled(64, 2),
            postings: const [
              SyncPosting(
                accountId: 'owed-ravi',
                amountMinor: 100,
                lineNumber: 1,
              ),
              SyncPosting(accountId: 'bank', amountMinor: -100, lineNumber: 2),
            ],
          ),
          SyncJournalEntry(
            id: 'e2',
            transactionDate: '2026-03-01',
            recordedAt: DateTime.utc(2026, 3, 1),
            description: 'unrelated rent',
            reversesEntryId: null,
            deviceChainSequence: 2,
            previousEntryHash: List.filled(32, 1),
            entryHash: List.filled(32, 2),
            signedByIdentityId: 'id',
            signature: List.filled(64, 3),
            postings: const [
              SyncPosting(accountId: 'bank', amountMinor: -500, lineNumber: 1),
              SyncPosting(accountId: 'rent', amountMinor: 500, lineNumber: 2),
            ],
          ),
        ],
      );
      final allowed = {'owed-ravi', 'bank', 'travel'};
      final scoped = ClaimantSyncFilter.filterEntryBatch(
        batch: entries,
        allowedAccountIds: allowed,
      );
      expect(scoped.entries.map((e) => e.id), ['e1']);
      expect(
        ClaimantSyncFilter.containsForeignBankEntry(
          batch: scoped,
          allowedAccountIds: allowed,
        ),
        isFalse,
      );
    },
  );
}
