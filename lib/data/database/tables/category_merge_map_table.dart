import 'package:drift/drift.dart';

import 'accounts_table.dart';

/// Maps an absorbed category id to its survivor after a merge. Posting rows
/// keep the original [absorbedCategoryId] so entry hashes stay valid
/// (shared-categories design Decision 8).
@DataClassName('CategoryMergeMapRow')
class CategoryMergeMap extends Table {
  TextColumn get absorbedCategoryId => text().references(Accounts, #id)();

  TextColumn get survivorCategoryId => text().references(Accounts, #id)();

  DateTimeColumn get mergedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {absorbedCategoryId};
}
