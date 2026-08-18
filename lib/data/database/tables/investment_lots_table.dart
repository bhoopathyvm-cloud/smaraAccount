import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'accounts_table.dart';
import 'instruments_table.dart';
import 'journal_entries_table.dart';

enum LotSource { cashPurchase, nonCashAcquisition }

@DataClassName('InvestmentLotRow')
class InvestmentLots extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get accountId => text().references(Accounts, #id)();
  TextColumn get instrumentId => text().references(Instruments, #id)();
  IntColumn get quantityScaled => integer()();
  IntColumn get unitCostMinor => integer()();
  TextColumn get source => textEnum<LotSource>()();
  DateTimeColumn get acquiredAt => dateTime()();
  DateTimeColumn get lockedUntil => dateTime().nullable()();
  TextColumn get journalEntryId => text().references(JournalEntries, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
