import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// A remembered payee name with optional defaults (payees-and-spending-memory
/// design.md Decision 1): `payees(id, name, default_category_id,
/// default_financial_account_id)`, matched against a typed description via
/// the same `normalizeDescription` function import category rules use - no
/// DB-level uniqueness on [name], matching happens at query time.
@DataClassName('PayeeRow')
class Payees extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();

  TextColumn get name => text()();

  TextColumn get defaultCategoryId => text().nullable()();

  TextColumn get defaultFinancialAccountId => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
