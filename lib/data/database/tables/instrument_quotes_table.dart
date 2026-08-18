import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'instruments_table.dart';

@DataClassName('InstrumentQuoteRow')
class InstrumentQuotes extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get instrumentId => text().references(Instruments, #id)();
  IntColumn get priceMinor => integer()();
  TextColumn get currency => text()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
