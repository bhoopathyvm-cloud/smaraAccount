import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Chart-of-accounts row type.
///
/// Financial accounts: [asset], [liability].
/// Categories: [income], [expense].
/// System offset for opening balances: [equity] (never user-facing).
/// System clearing account for cross-currency settlement: [clearing]
/// (never user-facing) - a distinct type, not reused from asset/liability,
/// so the existing `type IN (asset, liability)` picker allowlists exclude
/// it automatically rather than needing to filter it out by id everywhere
/// (multi-currency-support design.md Decision 3).
///
/// Investment inventory companion account: [inventory] (never user-facing),
/// used to keep holdings on-ledger as an asset without exposing that
/// internal leg in financial-account pickers.
enum AccountType {
  asset,
  liability,
  equity,
  clearing,
  inventory,
  income,
  expense,
}

/// Stable well-known id for the single Opening Balance Equity system row.
const openingBalanceEquityAccountId = 'account_opening_balance_equity';
const openingBalanceEquityAccountName = 'Opening Balance Equity';

/// Stable well-known id for the single Transfers-in-transit system row
/// (multi-currency-support design.md Decision 3).
const transfersInTransitAccountId = 'account_transfers_in_transit';
const transfersInTransitAccountName = 'Transfers in transit';

/// Named AccountRow (not the Drift default "Account") to stay distinct from
/// domain/models/account.dart's Account - Repositories expose domain
/// models, never Drift's generated row classes (smara-tech-guidelines.md).
@DataClassName('AccountRow')
class Accounts extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get name => text()();
  TextColumn get type => textEnum<AccountType>()();
  BoolColumn get holdsInvestments =>
      boolean().withDefault(const Constant(false))();
  TextColumn get investmentOwnerAccountId =>
      text().nullable().references(Accounts, #id)();

  /// Required for asset/liability; NULL for income/expense/equity.
  TextColumn get groupId => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
