import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

enum AccountType { asset, income, expense }

/// Named AccountRow (not the Drift default "Account") to stay distinct from
/// domain/models/account.dart's Account - Repositories expose domain
/// models, never Drift's generated row classes (smara-tech-guidelines.md).
@DataClassName('AccountRow')
class Accounts extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get name => text()();
  TextColumn get type => textEnum<AccountType>()();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
