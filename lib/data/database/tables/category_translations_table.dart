import 'package:drift/drift.dart';

import 'accounts_table.dart';

/// Optional translated display name for a category in a given locale
/// (shared-categories / linked-devices-and-sync design Decision 8).
@DataClassName('CategoryTranslationRow')
class CategoryTranslations extends Table {
  TextColumn get categoryId => text().references(Accounts, #id)();

  /// BCP-47 language tag (e.g. `en`, `de`).
  TextColumn get locale => text()();

  TextColumn get name => text()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {categoryId, locale};
}
