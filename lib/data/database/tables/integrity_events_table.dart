import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'journal_entries_table.dart';
import 'signing_identities_table.dart';

/// Append-only audit log for breaks and migrations (design.md). Like
/// [JournalEntries], no code path issues an UPDATE or DELETE against a row
/// here once written - but intentionally not part of the cryptographic
/// chain itself; it's an audit trail about the chain, not financial data.
enum IntegrityEventType {
  chainBreakDetected,
  chainReanchored,
  keyMigrationConfirmed,
}

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
