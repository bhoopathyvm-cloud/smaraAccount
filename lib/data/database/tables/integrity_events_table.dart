import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/models/integrity_event_type.dart';
import 'journal_entries_table.dart';
import 'signing_identities_table.dart';

export '../../../domain/models/integrity_event_type.dart';

/// Named IntegrityEventRow (not the Drift default) to stay distinct from
/// any future domain model of the same concept.
@DataClassName('IntegrityEventRow')
class IntegrityEvents extends Table {
  TextColumn get eventId => text().clientDefault(() => const Uuid().v4())();

  TextColumn get eventType => textEnum<IntegrityEventType>()();

  DateTimeColumn get occurredAt => dateTime().withDefault(currentDateAndTime)();

  TextColumn get relatedEntryId =>
      text().nullable().references(JournalEntries, #id)();

  TextColumn get relatedIdentityId =>
      text().nullable().references(SigningIdentities, #identityId)();

  TextColumn get detail => text().nullable()();

  @override
  Set<Column> get primaryKey => {eventId};
}
