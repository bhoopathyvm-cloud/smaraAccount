import 'package:drift/native.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/database/tables/accounts_table.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/domain/exceptions.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:test/test.dart';

void main() {
  late AppDatabase db;
  late LedgerRepository repository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = LedgerRepository(database: db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<String> firstCategoryId(AccountType type) async {
    final categories = await repository.watchCategories().first;
    return categories.firstWhere((a) => a.type == type).id;
  }

  group('onCreate seeding', () {
    test('seeds the single asset account and starter categories', () async {
      final categories = await repository.watchCategories().first;
      expect(
        categories.map((a) => a.name),
        containsAll(starterIncomeCategories + starterExpenseCategories),
      );
      expect(categories.every((a) => a.type != AccountType.asset), isTrue);
    });
  });

  group('recordTransaction', () {
    test('money in credits income category, debits asset', () async {
      final incomeId = await firstCategoryId(AccountType.income);

      await repository.recordTransaction(
        amountMinor: 1000,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        transactionDate: DateTime(2026, 1, 15),
      );

      final entries = await repository.watchEntries().first;
      expect(entries, hasLength(1));
      final entry = entries.single;
      expect(entry.postings, hasLength(2));
      expect(
        entry.postings.map((p) => p.amountMinor).toSet(),
        equals({1000, -1000}),
      );
      final categoryPosting = entry.postings.firstWhere(
        (p) => p.accountId == incomeId,
      );
      expect(categoryPosting.amountMinor, equals(-1000));
    });

    test('money out debits expense category, credits asset', () async {
      final expenseId = await firstCategoryId(AccountType.expense);

      await repository.recordTransaction(
        amountMinor: 500,
        direction: TransactionDirection.moneyOut,
        categoryId: expenseId,
        transactionDate: DateTime(2026, 1, 15),
      );

      final entry = (await repository.watchEntries().first).single;
      final categoryPosting = entry.postings.firstWhere(
        (p) => p.accountId == expenseId,
      );
      expect(categoryPosting.amountMinor, equals(500));
    });

    test('rejects a zero amount', () async {
      final incomeId = await firstCategoryId(AccountType.income);
      expect(
        () => repository.recordTransaction(
          amountMinor: 0,
          direction: TransactionDirection.moneyIn,
          categoryId: incomeId,
          transactionDate: DateTime(2026, 1, 15),
        ),
        throwsA(isA<InvalidTransactionAmountException>()),
      );
      expect(await repository.watchEntries().first, isEmpty);
    });

    test('rejects a negative amount', () async {
      final incomeId = await firstCategoryId(AccountType.income);
      expect(
        () => repository.recordTransaction(
          amountMinor: -100,
          direction: TransactionDirection.moneyIn,
          categoryId: incomeId,
          transactionDate: DateTime(2026, 1, 15),
        ),
        throwsA(isA<InvalidTransactionAmountException>()),
      );
    });
  });

  group('reverseEntry', () {
    test(
      'posts a new entry with swapped amounts, original unchanged',
      () async {
        final incomeId = await firstCategoryId(AccountType.income);
        await repository.recordTransaction(
          amountMinor: 1000,
          direction: TransactionDirection.moneyIn,
          categoryId: incomeId,
          transactionDate: DateTime(2026, 1, 15),
        );
        final original = (await repository.watchEntries().first).single;

        await repository.reverseEntry(original.id);

        final entries = await repository.watchEntries().first;
        expect(entries, hasLength(2));

        final unchangedOriginal = entries.firstWhere(
          (e) => e.id == original.id,
        );
        expect(
          unchangedOriginal.postings.map((p) => p.amountMinor).toSet(),
          equals({1000, -1000}),
        );

        final reversal = entries.firstWhere((e) => e.id != original.id);
        expect(reversal.reversesEntryId, equals(original.id));
        expect(
          reversal.postings.map((p) => p.amountMinor).toSet(),
          equals({-1000, 1000}),
        );
      },
    );
  });

  group('category management', () {
    test(
      'archived category is excluded from watchCategories() by default',
      () async {
        final incomeId = await firstCategoryId(AccountType.income);
        await repository.archiveCategory(incomeId);

        final active = await repository.watchCategories().first;
        expect(active.any((a) => a.id == incomeId), isFalse);

        final all = await repository
            .watchCategories(includeArchived: true)
            .first;
        expect(all.any((a) => a.id == incomeId), isTrue);
      },
    );

    test('addCategory rejects AccountType.asset', () async {
      expect(
        () => repository.addCategory(name: 'Nope', type: AccountType.asset),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('renameCategory updates the name', () async {
      final incomeId = await firstCategoryId(AccountType.income);
      await repository.renameCategory(id: incomeId, newName: 'Freelance');
      final categories = await repository.watchCategories().first;
      expect(categories.firstWhere((a) => a.id == incomeId).name, 'Freelance');
    });
  });

  group('watchSummary', () {
    test(
      'sums income and expense within the date range, reversal nets to zero',
      () async {
        final incomeId = await firstCategoryId(AccountType.income);
        final expenseId = await firstCategoryId(AccountType.expense);

        await repository.recordTransaction(
          amountMinor: 1000,
          direction: TransactionDirection.moneyIn,
          categoryId: incomeId,
          transactionDate: DateTime(2026, 1, 10),
        );
        await repository.recordTransaction(
          amountMinor: 300,
          direction: TransactionDirection.moneyOut,
          categoryId: expenseId,
          transactionDate: DateTime(2026, 1, 12),
        );
        final toReverse = (await repository.watchEntries().first).firstWhere(
          (e) =>
              e.postings.any((p) => p.accountId == incomeId) &&
              e.reversesEntryId == null,
        );
        await repository.reverseEntry(toReverse.id);

        // reverseEntry dates the reversal as of today (when the correction
        // happens, not backdated to the original) - so a range wide enough
        // to cover both the fixed historical dates above and "today" is
        // needed to see the net-zero effect.
        final summary = await repository
            .watchSummary(
              start: DateTime(2020, 1, 1),
              end: DateTime(2030, 12, 31),
            )
            .first;

        expect(summary.totalIncomeMinor, equals(0));
        expect(summary.totalExpenseMinor, equals(300));
      },
    );

    test('excludes entries outside the date range', () async {
      final incomeId = await firstCategoryId(AccountType.income);
      await repository.recordTransaction(
        amountMinor: 1000,
        direction: TransactionDirection.moneyIn,
        categoryId: incomeId,
        transactionDate: DateTime(2026, 2, 1),
      );

      final summary = await repository
          .watchSummary(start: DateTime(2026, 1, 1), end: DateTime(2026, 1, 31))
          .first;

      expect(summary.totalIncomeMinor, equals(0));
    });
  });
}
