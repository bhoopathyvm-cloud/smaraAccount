import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Chart-of-accounts row type.
///
/// Financial accounts: [asset], [liability].
/// Categories: [income], [expense].
/// System offset for opening balances: [equity] (never user-facing).
enum AccountType { asset, liability, equity, income, expense }

/// Stable well-known id for the single Opening Balance Equity system row.
const openingBalanceEquityAccountId = 'account_opening_balance_equity';
const openingBalanceEquityAccountName = 'Opening Balance Equity';

/// Named AccountRow (not the Drift default "Account") to stay distinct from
/// domain/models/account.dart's Account - Repositories expose domain
/// models, never Drift's generated row classes (smara-tech-guidelines.md).
@DataClassName('AccountRow')
class Accounts extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get name => text()();
  TextColumn get type => textEnum<AccountType>()();

  /// Required for asset/liability; NULL for income/expense/equity.
  TextColumn get groupId => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
