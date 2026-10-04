import 'package:drift/drift.dart';

/// Outbox of metadata field changes for peer sync (real-sync task 5.1).
@DataClassName('MetadataOperationRow')
class MetadataOperations extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get entityType => text()();

  TextColumn get entityId => text()();

  TextColumn get field => text()();

  /// JSON-encoded value (string / number / bool / null).
  TextColumn get valueJson => text().nullable()();

  DateTimeColumn get updatedAt => dateTime()();

  TextColumn get updatedByIdentityId => text()();

  IntColumn get hlcCounter => integer().withDefault(const Constant(0))();

  TextColumn get hlcDeviceId => text().withDefault(const Constant(''))();
}
