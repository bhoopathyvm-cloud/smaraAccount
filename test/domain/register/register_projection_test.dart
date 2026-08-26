import 'package:test/test.dart';

import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/journal_entry.dart';
import 'package:smara_accounting/domain/models/posting.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/domain/register/register_projection.dart';

JournalEntry _entry({
  required String id,
  required List<Posting> postings,
  bool isVerified = true,
  bool isSupersededByMigration = false,
  DateTime? transactionDate,
  String? description,
  String? reversesEntryId,
}) {
  return JournalEntry(
    id: id,
    transactionDate: transactionDate ?? DateTime(2026, 1, 10),
    recordedAt: DateTime(2026, 1, 10),
    description: description,
    reversesEntryId: reversesEntryId,
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

Account _account({
  required String id,
  required String name,
  required AccountType type,
}) {
  return Account(id: id, name: name, type: type, archived: false);
}

void main() {
  const cashId = 'cash';
  const cardId = 'card';
  const foodId = 'food';
  const gasId = 'gas';
  const openingId = 'opening';

  final accountsById = {
    cashId: _account(id: cashId, name: 'Cash', type: AccountType.asset),
    cardId: _account(id: cardId, name: 'Card', type: AccountType.liability),
  };
  final categoriesById = {
    foodId: _account(id: foodId, name: 'Food', type: AccountType.expense),
    gasId: _account(id: gasId, name: 'Gas', type: AccountType.expense),
  };

  test('asset outflow is moneyOut and adds a negative running balance', () {
    final rows = projectRegisterRows(
      entries: [
        _entry(
          id: 'e1',
          postings: [
            Posting(
              id: 'p1',
              entryId: 'e1',
              accountId: cashId,
              amountMinor: -500,
              lineNumber: 1,
            ),
            Posting(
              id: 'p2',
              entryId: 'e1',
              accountId: foodId,
              amountMinor: 500,
              lineNumber: 2,
            ),
          ],
        ),
      ],
      viewedAccountId: cashId,
      viewedAccountType: AccountType.asset,
      currency: 'USD',
      accountsById: accountsById,
      categoriesById: categoriesById,
      openingBalanceAccountId: openingId,
    );

    expect(rows, hasLength(1));
    expect(rows.single.direction, TransactionDirection.moneyOut);
    expect(rows.single.amountMinor, 500);
    expect(rows.single.runningBalanceMinor, -500);
    expect(rows.single.categoryName, 'Food');
  });

  test('liability purchase increases display balance (owed)', () {
    final rows = projectRegisterRows(
      entries: [
        _entry(
          id: 'e1',
          postings: [
            Posting(
              id: 'p1',
              entryId: 'e1',
              accountId: cardId,
              amountMinor: -800,
              lineNumber: 1,
            ),
            Posting(
              id: 'p2',
              entryId: 'e1',
              accountId: foodId,
              amountMinor: 800,
              lineNumber: 2,
            ),
          ],
        ),
      ],
      viewedAccountId: cardId,
      viewedAccountType: AccountType.liability,
      currency: 'USD',
      accountsById: accountsById,
      categoriesById: categoriesById,
      openingBalanceAccountId: openingId,
    );

    expect(rows.single.direction, TransactionDirection.moneyIn);
    expect(rows.single.amountMinor, 800);
    expect(rows.single.runningBalanceMinor, 800);
  });

  test('quarantined entries stay visible but skip running balance', () {
    final rows = projectRegisterRows(
      entries: [
        _entry(
          id: 'ok',
          postings: [
            Posting(
              id: 'p1',
              entryId: 'ok',
              accountId: cashId,
              amountMinor: 1000,
              lineNumber: 1,
            ),
            Posting(
              id: 'p2',
              entryId: 'ok',
              accountId: foodId,
              amountMinor: -1000,
              lineNumber: 2,
            ),
          ],
        ),
        _entry(
          id: 'bad',
          isVerified: false,
          postings: [
            Posting(
              id: 'p3',
              entryId: 'bad',
              accountId: cashId,
              amountMinor: 400,
              lineNumber: 1,
            ),
            Posting(
              id: 'p4',
              entryId: 'bad',
              accountId: foodId,
              amountMinor: -400,
              lineNumber: 2,
            ),
          ],
        ),
      ],
      viewedAccountId: cashId,
      viewedAccountType: AccountType.asset,
      currency: 'USD',
      accountsById: accountsById,
      categoriesById: categoriesById,
      openingBalanceAccountId: openingId,
    );

    expect(rows, hasLength(2));
    expect(rows.first.entryId, 'bad');
    expect(rows.first.isVerified, isFalse);
    expect(rows.first.runningBalanceMinor, 1000);
    expect(rows.last.runningBalanceMinor, 1000);
  });

  test('split UI label summarizes; export keeps one leg per category', () {
    final projected = projectRegisterEntries(
      entries: [
        _entry(
          id: 'split',
          postings: [
            Posting(
              id: 'p1',
              entryId: 'split',
              accountId: cashId,
              amountMinor: -10000,
              lineNumber: 1,
            ),
            Posting(
              id: 'p2',
              entryId: 'split',
              accountId: foodId,
              amountMinor: 6000,
              lineNumber: 2,
            ),
            Posting(
              id: 'p3',
              entryId: 'split',
              accountId: gasId,
              amountMinor: 4000,
              lineNumber: 3,
            ),
          ],
        ),
      ],
      viewedAccountId: cashId,
      viewedAccountType: AccountType.asset,
      currency: 'USD',
      accountsById: accountsById,
      categoriesById: categoriesById,
      openingBalanceAccountId: openingId,
    );

    expect(projected, hasLength(1));
    expect(projected.single.row.categoryName, 'Food +1 more');
    expect(projected.single.legs, hasLength(2));
    expect(projected.single.legs.map((l) => l.amountMinor).toList(), [
      6000,
      4000,
    ]);
    expect(projected.single.legs.map((l) => l.label).toList(), ['Food', 'Gas']);
  });

  test('transfer counterpart uses Transfer: name', () {
    final rows = projectRegisterRows(
      entries: [
        _entry(
          id: 't',
          postings: [
            Posting(
              id: 'p1',
              entryId: 't',
              accountId: cashId,
              amountMinor: -200,
              lineNumber: 1,
            ),
            Posting(
              id: 'p2',
              entryId: 't',
              accountId: cardId,
              amountMinor: 200,
              lineNumber: 2,
            ),
          ],
        ),
      ],
      viewedAccountId: cashId,
      viewedAccountType: AccountType.asset,
      currency: 'USD',
      accountsById: accountsById,
      categoriesById: categoriesById,
      openingBalanceAccountId: openingId,
    );

    expect(rows.single.categoryName, 'Transfer: Card');
  });
}
