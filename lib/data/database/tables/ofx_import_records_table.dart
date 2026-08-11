import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'accounts_table.dart';
import 'journal_entries_table.dart';

/// Tracks which OFX statement transactions have already been imported into
/// which financial account, so a re-imported (overlapping-date-range) file
/// can be flagged as a duplicate (ofx-transaction-import design.md
/// Decision 2). Purely additive metadata alongside [JournalEntries] - never
/// mutates that append-only, signed table.
///
/// Named OfxImportRecordRow (not the Drift default) to stay distinct from
/// any future domain/models/ofx_import_record.dart class.
@DataClassName('OfxImportRecordRow')
class OfxImportRecords extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();

  TextColumn get financialAccountId => text().references(Accounts, #id)();

  /// The bank's own stable transaction id, when the source file provided
  /// one. Authoritative de-duplication key when present.
  TextColumn get fitid => text().nullable()();

  /// Fallback de-duplication key (`transactionDate|amountMinor|memo`) used
  /// when [fitid] is absent, per design.md Decision 2.
  TextColumn get fallbackMatchKey => text().nullable()();

  TextColumn get journalEntryId => text().references(JournalEntries, #id)();

  DateTimeColumn get importedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
