import 'package:drift/drift.dart';

import 'accounts_table.dart';

/// Per-category spending-limit hints for Claims (informational only).
@DataClassName('ClaimSpendingHintRow')
class ClaimSpendingHints extends Table {
  TextColumn get categoryId => text().references(Accounts, #id)();

  IntColumn get maxAmountMinor => integer()();

  TextColumn get unitLabel => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {categoryId};
}
