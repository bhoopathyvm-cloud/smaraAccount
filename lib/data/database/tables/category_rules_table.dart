import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// A saved keyword-to-category rule (import-category-rules design.md
/// Decision: "Persistence follows the CsvImportProfiles pattern exactly").
/// A row's description matching [keyword] (case-insensitive substring) is
/// pre-categorized as [categoryId] during statement-import preview,
/// ahead of the exact-memo fallback.
@DataClassName('CategoryRuleRow')
class CategoryRules extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();

  TextColumn get keyword => text()();

  TextColumn get categoryId => text()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
