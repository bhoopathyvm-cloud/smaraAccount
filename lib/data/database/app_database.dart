import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

import 'tables/accounts_table.dart';
import 'tables/journal_entries_table.dart';
import 'tables/postings_table.dart';

part 'app_database.g.dart';

/// The single financial account seeded on first launch. Never archivable -
/// archiving is only offered for income/expense rows (Category Management
/// requirement).
const financialAccountName = 'Cash & Bank';

/// Starter category set (design.md: "Starter category set"). All are
/// renameable, extendable, and archivable - this is a starting point, not
/// a fixed taxonomy.
const starterIncomeCategories = ['Salary', 'Other Income'];
const starterExpenseCategories = [
  'Groceries',
  'Rent/Mortgage',
  'Utilities',
  'Transport',
  'Other Expense',
];

@DriftDatabase(tables: [Accounts, JournalEntries, Postings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await into(accounts).insert(
        AccountsCompanion.insert(
          name: financialAccountName,
          type: AccountType.asset,
        ),
      );
      for (final name in starterIncomeCategories) {
        await into(accounts).insert(
          AccountsCompanion.insert(name: name, type: AccountType.income),
        );
      }
      for (final name in starterExpenseCategories) {
        await into(accounts).insert(
          AccountsCompanion.insert(name: name, type: AccountType.expense),
        );
      }
    },
  );
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'smara_accounting');
}
