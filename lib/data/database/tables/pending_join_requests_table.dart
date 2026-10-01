import 'package:drift/drift.dart';

/// Pending Books-Copy-then-join requests awaiting one-tap approve/refuse
/// on an already-linked device (linked-devices task 4.4).
@DataClassName('PendingJoinRequestRow')
class PendingJoinRequests extends Table {
  TextColumn get requestId => text()();

  TextColumn get requesterDeviceId => text()();

  TextColumn get requesterDisplayName => text()();

  BlobColumn get signingPublicKey => blob()();

  BlobColumn get deviceCertDer => blob()();

  TextColumn get deviceCertFingerprint => text()();

  TextColumn get booksSetId => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get resolvedAt => dateTime().nullable()();

  /// Null while pending; true = approved, false = refused.
  BoolColumn get approved => boolean().nullable()();

  @override
  Set<Column> get primaryKey => {requestId};
}
