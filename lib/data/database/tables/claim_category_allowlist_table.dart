import 'package:drift/drift.dart';

import 'accounts_table.dart';

/// Expense categories allowed on Claims for this books set.
@DataClassName('ClaimCategoryAllowlistRow')
class ClaimCategoryAllowlist extends Table {
  TextColumn get categoryId => text().references(Accounts, #id)();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {categoryId};
}
