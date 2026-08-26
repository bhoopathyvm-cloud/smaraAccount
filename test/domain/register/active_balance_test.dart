import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/journal_entry.dart';
import 'package:smara_accounting/domain/models/posting.dart';
import 'package:smara_accounting/domain/register/active_balance.dart';
import 'package:test/test.dart';

JournalEntry _entry({
  required String id,
  required List<Posting> postings,
  bool isVerified = true,
  bool isSupersededByMigration = false,
}) {
  return JournalEntry(
    id: id,
    transactionDate: DateTime(2026, 1, 10),
    recordedAt: DateTime(2026, 1, 10),
    description: null,
    reversesEntryId: null,
    postings: postings,
    deviceChainSequence: 0,
    entryHash: const [],
    signedByIdentityId: 'id',
    signature: const [],
    migratedFromEntryId: null,
    isVerified: isVerified,
    breakReason: null,
    isSupersededByMigration: isSupersededByMigration,
  );
}

Posting _post(String accountId, int amount) => Posting(
  id: 'p-$accountId-$amount',
  entryId: 'e',
  accountId: accountId,
  amountMinor: amount,
  lineNumber: 1,
);

void main() {
  test(
    'quarantined and superseded entries are omitted from display balance',
    () {
      final entries = [
        _entry(id: 'ok', postings: [_post('cash', 1000)]),
        _entry(
          id: 'quarantined',
          postings: [_post('cash', 5000)],
          isVerified: false,
        ),
        _entry(
          id: 'migrated',
          postings: [_post('cash', 2000)],
          isSupersededByMigration: true,
        ),
      ];

      expect(
        displayBalanceForAccount(
          entries: entries,
          accountId: 'cash',
          accountType: AccountType.asset,
        ),
        1000,
      );
      expect(rawPostingSumsByAccount(entries)['cash'], 1000);
    },
  );

  test('liability display balance negates the raw posting sum', () {
    final entries = [
      _entry(id: 'owe', postings: [_post('card', 2500)]),
    ];
    expect(
      displayBalanceForAccount(
        entries: entries,
        accountId: 'card',
        accountType: AccountType.liability,
      ),
      -2500,
    );
  });
}
