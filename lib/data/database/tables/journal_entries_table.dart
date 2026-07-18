import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Journal entries are append-only: no code path issues an UPDATE or DELETE
/// against a posted row (Golden Rule #7, smara-tech-guidelines.md).
///
/// Named JournalEntryRow (not the Drift default "JournalEntry") to stay
/// distinct from domain/models/journal_entry.dart's JournalEntry.
@DataClassName('JournalEntryRow')
class JournalEntries extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();

  /// User-supplied, date only (no time-of-day) - stored as an ISO-8601
  /// date string ("YYYY-MM-DD"), never derived from [recordedAt].
  TextColumn get transactionDate => text()();

  /// System-captured at the moment of posting via `DateTime.now()`.
  /// No code path accepts a client-provided value here.
  DateTimeColumn get recordedAt => dateTime()();

  TextColumn get description => text().nullable()();

  TextColumn get reversesEntryId =>
      text().nullable().references(JournalEntries, #id)();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
