import 'package:flutter_test/flutter_test.dart';
import 'package:smara_accounting/domain/peer_sync/claim_sync_payloads.dart';
import 'package:smara_accounting/domain/peer_sync/sync_payloads.dart';

void main() {
  group('Claims dual-device harness (in-process)', () {
    test('submit on B → ClaimBatch → appear on A (no private keys)', () {
      final fromClaimant = ClaimBatch(
        claims: [
          SyncClaim(
            id: 'c-submit',
            claimantDeviceId: 'device-b',
            status: 'submitted',
            createdAt: DateTime.utc(2026, 3, 1),
            updatedAt: DateTime.utc(2026, 3, 1),
            submittedAt: DateTime.utc(2026, 3, 1),
            items: [
              SyncClaimItem(
                id: 'i1',
                claimId: 'c-submit',
                categoryId: 'travel',
                expenseDate: '2026-03-01',
                paidCurrency: 'USD',
                paidAmountMinor: 5000,
                companyCurrencyAmountMinor: 5000,
                sortOrder: 0,
                receiptId: 'r1',
              ),
            ],
          ),
        ],
      );
      final wire = fromClaimant.encode();
      expect(syncPayloadContainsPrivateKeyMaterial(wire), isFalse);
      final onApprover = ClaimBatch.decode(wire);
      expect(onApprover.claims.single.id, 'c-submit');
      expect(onApprover.claims.single.claimantDeviceId, 'device-b');
    });

    test('Claimant-scoped filter omits unrelated bank entries', () {
      final full = EntryBatch(
        entries: [
          SyncJournalEntry(
            id: 'pay',
            transactionDate: '2026-03-01',
            recordedAt: DateTime.utc(2026, 3, 1),
            description: 'pay claimant',
            reversesEntryId: null,
            deviceChainSequence: 1,
            previousEntryHash: List.filled(32, 0),
            entryHash: List.filled(32, 1),
            signedByIdentityId: 'id-a',
            signature: List.filled(64, 2),
            postings: const [
              SyncPosting(accountId: 'owed-b', amountMinor: 100, lineNumber: 1),
              SyncPosting(accountId: 'bank', amountMinor: -100, lineNumber: 2),
            ],
          ),
          SyncJournalEntry(
            id: 'rent',
            transactionDate: '2026-03-01',
            recordedAt: DateTime.utc(2026, 3, 1),
            description: 'office rent',
            reversesEntryId: null,
            deviceChainSequence: 2,
            previousEntryHash: List.filled(32, 1),
            entryHash: List.filled(32, 2),
            signedByIdentityId: 'id-a',
            signature: List.filled(64, 3),
            postings: const [
              SyncPosting(accountId: 'bank', amountMinor: -900, lineNumber: 1),
              SyncPosting(accountId: 'rent', amountMinor: 900, lineNumber: 2),
            ],
          ),
        ],
      );
      final scoped = ClaimantSyncFilter.filterEntryBatch(
        batch: full,
        allowedAccountIds: {'owed-b', 'bank', 'travel'},
      );
      expect(scoped.entries.map((e) => e.id), ['pay']);
    });
  });

  group('Claims physical Claimant-phone manual', () {
    test('manual two-device spot-check', () {
      // Skipped by default: requires two physical devices on office Wi-Fi.
    }, skip: 'Physical Claimant-phone run — leave for human / task 9.3');
  });
}
