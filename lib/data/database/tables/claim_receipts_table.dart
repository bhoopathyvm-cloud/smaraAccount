import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'claim_items_table.dart';

@DataClassName('ClaimReceiptRow')
class ClaimReceipts extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();

  TextColumn get claimItemId => text().references(ClaimItems, #id)();

  TextColumn get contentType => text()();

  TextColumn get fileName => text()();

  IntColumn get byteSize => integer()();

  TextColumn get contentHash => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
