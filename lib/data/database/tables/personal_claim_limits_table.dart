import 'package:drift/drift.dart';

/// Personal claim limits per person + category (real-sync task 6.1).
@DataClassName('PersonalClaimLimitRow')
class PersonalClaimLimits extends Table {
  TextColumn get personDeviceId => text()();

  TextColumn get categoryId => text()();

  /// Amount in company currency minor units; null means cleared.
  IntColumn get amountMinor => integer().nullable()();

  TextColumn get unitLabel => text().nullable()();

  DateTimeColumn get updatedAt => dateTime()();

  TextColumn get updatedByIdentityId => text()();

  @override
  Set<Column> get primaryKey => {personDeviceId, categoryId};
}
