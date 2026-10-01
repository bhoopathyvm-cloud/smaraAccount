import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/models/claim_item_decision_kind.dart';
import 'claim_items_table.dart';
import 'journal_entries_table.dart';
import 'linked_devices_table.dart';

export '../../../domain/models/claim_item_decision_kind.dart';

@DataClassName('ClaimItemDecisionRow')
class ClaimItemDecisions extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();

  TextColumn get claimItemId => text().references(ClaimItems, #id)();

  TextColumn get kind => textEnum<ClaimItemDecisionKind>()();

  IntColumn get approvedAmountMinor => integer().nullable()();

  TextColumn get reason => text().nullable()();

  TextColumn get decidedByDeviceId =>
      text().references(LinkedDevices, #deviceId)();

  DateTimeColumn get decidedAt => dateTime()();

  TextColumn get postedEntryId =>
      text().nullable().references(JournalEntries, #id)();

  @override
  Set<Column> get primaryKey => {id};
}
