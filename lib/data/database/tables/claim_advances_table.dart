import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'accounts_table.dart';
import 'journal_entries_table.dart';
import 'linked_devices_table.dart';

@DataClassName('ClaimAdvanceRow')
class ClaimAdvances extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();

  TextColumn get claimantDeviceId =>
      text().references(LinkedDevices, #deviceId)();

  IntColumn get amountMinor => integer()();

  TextColumn get paidFromAccountId => text().references(Accounts, #id)();

  TextColumn get postedEntryId => text().references(JournalEntries, #id)();

  TextColumn get description => text().nullable()();

  DateTimeColumn get recordedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
