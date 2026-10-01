import 'package:drift/drift.dart';

/// Per-books-set metadata stored inside that set's SQLite file. The
/// directory name under `books/<id>/` matches [id]; the active id itself
/// lives in SharedPreferences (device setting, not synced).
@DataClassName('BooksSetMetadataRow')
class BooksSetMetadata extends Table {
  /// Same id as the `books/<id>/` directory name.
  TextColumn get id => text()();

  TextColumn get displayName => text()();

  /// Default language for category names (books setting; design Decision 9).
  TextColumn get defaultCategoryLocale =>
      text().withDefault(const Constant('en'))();

  /// Company-currency amount above which a Claim Item requires a receipt.
  /// Default 0 = always required (claim-receipts spec).
  IntColumn get receiptRequiredAboveMinor =>
      integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
