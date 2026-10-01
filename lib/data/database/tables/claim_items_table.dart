import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'accounts_table.dart';
import 'claims_table.dart';

@DataClassName('ClaimItemRow')
class ClaimItems extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();

  TextColumn get claimId => text().references(Claims, #id)();

  TextColumn get categoryId => text().references(Accounts, #id)();

  /// Calendar date of the expense (YYYY-MM-DD stored as text for stability).
  TextColumn get expenseDate => text()();

  TextColumn get description => text().nullable()();

  TextColumn get paidCurrency => text()();

  IntColumn get paidAmountMinor => integer()();

  /// Optional employee card-statement rate (paid → company).
  RealColumn get employeeStatedRate => real().nullable()();

  RealColumn get rateUsed => real().nullable()();

  IntColumn get companyCurrencyAmountMinor => integer()();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
