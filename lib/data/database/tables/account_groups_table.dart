import 'package:drift/drift.dart';

/// Kind of an [AccountGroups] row — asset rollups vs liability rollups.
enum AccountGroupKind { assetGroup, liabilityGroup }

/// Stable well-known ids for the four seeded system groups (design.md).
const groupCashEquivalentsId = 'group_cash_equivalents';
const groupPensionRetirementId = 'group_pension_retirement';
const groupCreditShortTermId = 'group_credit_short_term';
const groupLoansMortgagesId = 'group_loans_mortgages';

@DataClassName('AccountGroupRow')
class AccountGroups extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get kind => textEnum<AccountGroupKind>()();
  IntColumn get sortOrder => integer()();
  BoolColumn get isSystem => boolean()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
