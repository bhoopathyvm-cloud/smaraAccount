import 'package:test/test.dart';

import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/domain/register/register_row.dart';
import 'package:smara_accounting/domain/register/register_row_policy.dart';

RegisterRow _row({
  String entryId = 'e1',
  List<String> counterparts = const ['cat-1'],
  bool isReversal = false,
  bool isVerified = true,
  bool isSupersededByMigration = false,
  TransactionDirection direction = TransactionDirection.moneyOut,
  DateTime? date,
  String? description,
  String categoryName = 'Food',
  int amountMinor = 1000,
}) {
  return RegisterRow(
    entryId: entryId,
    categoryName: categoryName,
    counterpartAccountIds: counterparts,
    direction: direction,
    amountMinor: amountMinor,
    currency: 'USD',
    transactionDate: date ?? DateTime(2026, 3, 15),
    description: description,
    runningBalanceMinor: 0,
    isReversal: isReversal,
    isVerified: isVerified,
    breakReason: null,
    isSupersededByMigration: isSupersededByMigration,
  );
}

void main() {
  group('isRegisterRowFixable', () {
    test('true for ordinary single-category verified row', () {
      expect(
        isRegisterRowFixable(
          row: _row(),
          categoryIds: {'cat-1'},
          reversedEntryIds: {},
        ),
        isTrue,
      );
    });

    test('false for splits, transfers, reversals, quarantined, superseded', () {
      expect(
        isRegisterRowFixable(
          row: _row(counterparts: ['cat-1', 'cat-2']),
          categoryIds: {'cat-1', 'cat-2'},
          reversedEntryIds: {},
        ),
        isFalse,
      );
      expect(
        isRegisterRowFixable(
          row: _row(counterparts: ['acct-2']),
          categoryIds: {'cat-1'},
          reversedEntryIds: {},
        ),
        isFalse,
      );
      expect(
        isRegisterRowFixable(
          row: _row(isReversal: true),
          categoryIds: {'cat-1'},
          reversedEntryIds: {},
        ),
        isFalse,
      );
      expect(
        isRegisterRowFixable(
          row: _row(isVerified: false),
          categoryIds: {'cat-1'},
          reversedEntryIds: {},
        ),
        isFalse,
      );
      expect(
        isRegisterRowFixable(
          row: _row(isSupersededByMigration: true),
          categoryIds: {'cat-1'},
          reversedEntryIds: {},
        ),
        isFalse,
      );
      expect(
        isRegisterRowFixable(
          row: _row(),
          categoryIds: {'cat-1'},
          reversedEntryIds: {'e1'},
        ),
        isFalse,
      );
    });
  });

  group('filterRegisterRows', () {
    final rows = [
      _row(
        entryId: 'a',
        description: 'Coffee',
        date: DateTime(2026, 3, 10),
        direction: TransactionDirection.moneyOut,
      ),
      _row(
        entryId: 'b',
        description: 'Salary',
        categoryName: 'Income',
        date: DateTime(2026, 3, 20),
        direction: TransactionDirection.moneyIn,
        amountMinor: 5000,
      ),
    ];

    test('returns all when no filters', () {
      expect(
        filterRegisterRows(
          rows: rows,
          searchText: '',
          amountTextFor: (_) => '',
        ),
        rows,
      );
    });

    test('filters by direction and inclusive date range', () {
      final filtered = filterRegisterRows(
        rows: rows,
        searchText: '',
        filterDirection: TransactionDirection.moneyIn,
        filterStartDate: DateTime(2026, 3, 15),
        filterEndDate: DateTime(2026, 3, 20),
        amountTextFor: (_) => '',
      );
      expect(filtered.map((r) => r.entryId), ['b']);
    });

    test('search matches description, category, or amount text', () {
      expect(
        filterRegisterRows(
          rows: rows,
          searchText: 'coff',
          amountTextFor: (_) => '10.00',
        ).map((r) => r.entryId),
        ['a'],
      );
      expect(
        filterRegisterRows(
          rows: rows,
          searchText: 'income',
          amountTextFor: (_) => '10.00',
        ).map((r) => r.entryId),
        ['b'],
      );
      expect(
        filterRegisterRows(
          rows: rows,
          searchText: '50.00',
          amountTextFor: (r) => r.entryId == 'b' ? '50.00' : '10.00',
        ).map((r) => r.entryId),
        ['b'],
      );
    });
  });
}
