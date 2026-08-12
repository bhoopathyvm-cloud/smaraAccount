import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'accounts_table.dart';
import 'journal_entries_table.dart';

/// Which statement format a de-duplication record came from
/// (csv-transaction-import design.md Decision 5) - kept as metadata only;
/// dedupe matching itself is source-agnostic.
enum ImportSource { ofx, csv }

/// Tracks which statement transactions have already been imported into
/// which financial account, so a re-imported (overlapping-date-range) file
/// can be flagged as a duplicate (ofx-transaction-import design.md
/// Decision 2). Purely additive metadata alongside [JournalEntries] - never
/// mutates that append-only, signed table. Table and column names stay
/// OFX-named even though CSV rows are recorded here too
/// (csv-transaction-import design.md Decision 5: renaming the SQL table
/// would need a migration for zero user-visible benefit).
///
/// Named OfxImportRecordRow (not the Drift default) to stay distinct from
/// any future domain/models/ofx_import_record.dart class.
@DataClassName('OfxImportRecordRow')
class OfxImportRecords extends Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();

  TextColumn get financialAccountId => text().references(Accounts, #id)();

  /// The source's own stable transaction id, when the source file provided
  /// one - OFX's `FITID`, or a CSV row's mapped reference-id column.
  /// Authoritative de-duplication key when present.
  TextColumn get fitid => text().nullable()();

  /// Fallback de-duplication key (`transactionDate|amountMinor|memo`) used
  /// when [fitid] is absent, per design.md Decision 2.
  TextColumn get fallbackMatchKey => text().nullable()();

  TextColumn get journalEntryId => text().references(JournalEntries, #id)();

  DateTimeColumn get importedAt => dateTime()();

  /// Null for rows written before this column existed - all of which were
  /// necessarily OFX imports, since CSV import didn't exist yet.
  TextColumn get source => textEnum<ImportSource>().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
