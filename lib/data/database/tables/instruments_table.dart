import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

enum InstrumentKind { stock, etf, mutualFund, bond, other }

@DataClassName('InstrumentRow')
class Instruments extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get name => text()();
  TextColumn get kind => textEnum<InstrumentKind>()();
  TextColumn get ticker => text().nullable()();
  TextColumn get isin => text().nullable()();
  DateTimeColumn get archivedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
