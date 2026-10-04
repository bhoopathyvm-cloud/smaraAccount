import 'package:drift/drift.dart';

/// Persisted last-write-wins winners per metadata field (task 5.2).
@DataClassName('MetadataLwwStateRow')
class MetadataLwwState extends Table {
  TextColumn get fieldKey => text()();

  TextColumn get entityType => text()();

  TextColumn get entityId => text()();

  TextColumn get field => text()();

  TextColumn get valueJson => text().nullable()();

  DateTimeColumn get hlcWall => dateTime()();

  IntColumn get hlcCounter => integer()();

  TextColumn get hlcDeviceId => text()();

  TextColumn get updatedByIdentityId => text()();

  @override
  Set<Column> get primaryKey => {fieldKey};
}

/// Single-row hybrid logical clock state for this books set (task 5.2).
@DataClassName('HlcStateRow')
class HlcState extends Table {
  /// Always `local` — one row per books database.
  TextColumn get id => text()();

  DateTimeColumn get lastWall => dateTime()();

  IntColumn get counter => integer()();

  TextColumn get deviceId => text()();

  @override
  Set<Column> get primaryKey => {id};
}
