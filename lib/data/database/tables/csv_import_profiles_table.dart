import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// A saved, reusable CSV column mapping (csv-transaction-import
/// design.md Decision 6): `header_fingerprint` and `column_mapping` are
/// both JSON-encoded, since the mapping shape is a small, self-contained
/// structure with no need for relational queries into its fields.
///
/// Named CsvImportProfileRow (not the Drift default) to stay distinct
/// from domain/csv/csv_import_profile.dart's CsvImportProfile.
@DataClassName('CsvImportProfileRow')
class CsvImportProfiles extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();

  TextColumn get name => text()();

  /// JSON-encoded ordered list of normalized header cells - the exact-match
  /// fingerprint a later file's header row is compared against.
  TextColumn get headerFingerprint => text()();

  /// JSON-encoded `CsvColumnMapping`.
  TextColumn get columnMapping => text()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
