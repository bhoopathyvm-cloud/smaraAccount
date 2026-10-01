import 'package:drift/drift.dart';

import '../../../domain/models/linked_device_role.dart';
import 'accounts_table.dart';
import 'signing_identities_table.dart';

export '../../../domain/models/linked_device_role.dart';

/// Linked-device membership for this books set (shared via peer sync).
/// First device to create the books is Owner.
@DataClassName('LinkedDeviceRow')
class LinkedDevices extends Table {
  TextColumn get deviceId => text()();

  TextColumn get displayName => text()();

  TextColumn get signingIdentityId =>
      text().references(SigningIdentities, #identityId)();

  /// Fingerprint of the device TLS certificate exchanged at join.
  TextColumn get deviceCertFingerprint => text()();

  /// Primary role (Owner > Approver > Member > Claimant) for B-compatible
  /// single-role reads. Prefer [rolesCsv] for capability checks.
  TextColumn get role => textEnum<LinkedDeviceRole>()();

  /// Comma-separated role set (design Decision 7). Migrated from [role].
  TextColumn get rolesCsv => text().withDefault(const Constant(''))();

  /// Whether this Member may add other devices (Owner policy).
  BoolColumn get canAdd => boolean().withDefault(const Constant(false))();

  /// Liability "Owed to \<name\>" account when this membership is a Claimant.
  TextColumn get owedToAccountId =>
      text().nullable().references(Accounts, #id)();

  /// Person display name when joined via "Add a person" (may differ from
  /// [displayName] device label).
  TextColumn get personDisplayName => text().nullable()();

  DateTimeColumn get removedAt => dateTime().nullable()();

  DateTimeColumn get erasePendingAt => dateTime().nullable()();

  DateTimeColumn get erasedAt => dateTime().nullable()();

  /// When a Member claimed sole ownership; effective after 7 days unless
  /// an Owner objects (linked-devices design Decision 6).
  DateTimeColumn get soleOwnerClaimedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {deviceId};
}
