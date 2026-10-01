import 'package:drift/drift.dart';

import '../../../domain/models/claim_status.dart';
import 'linked_devices_table.dart';

export '../../../domain/models/claim_status.dart';

/// Claims live in the books set but outside the posted ledger until
/// approval (shared-accounts-and-expense-claims design Decision 1).
@DataClassName('ClaimRow')
class Claims extends Table {
  TextColumn get id => text()();

  TextColumn get claimantDeviceId =>
      text().references(LinkedDevices, #deviceId)();

  /// Cached derived status for queries; always recomputed on write paths.
  TextColumn get status => textEnum<ClaimStatus>()();

  DateTimeColumn get submittedAt => dateTime().nullable()();

  DateTimeColumn get paidAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
