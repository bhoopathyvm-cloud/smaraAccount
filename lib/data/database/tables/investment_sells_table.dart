import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'accounts_table.dart';
import 'instruments_table.dart';
import 'journal_entries_table.dart';

/// One sell of an instrument in an investment account, linked to the sell's
/// journal entry for date-ordered quantity/cost replay (investment-holdings
/// design.md Decision 3).
@DataClassName('InvestmentSellRow')
class InvestmentSells extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get accountId => text().references(Accounts, #id)();
  TextColumn get instrumentId => text().references(Instruments, #id)();
  IntColumn get quantityScaled => integer()();
  TextColumn get journalEntryId => text().references(JournalEntries, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
