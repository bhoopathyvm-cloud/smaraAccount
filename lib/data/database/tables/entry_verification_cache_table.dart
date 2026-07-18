import 'package:drift/drift.dart';

import 'journal_entries_table.dart';

/// Why an entry failed verification (Golden Rule #5: no magic strings for
/// fixed sets).
enum VerificationBreakReason {
  hashMismatch,
  signatureInvalid,
  chainLinkBroken,
  excludedAfterBreak,
}

/// Derived data, never part of the immutable truth: whether an entry
/// currently verifies is a projection that can be recomputed and rebuilt
/// wholesale on every app startup, never a column mutated on
/// [JournalEntries] itself (design.md: "verification results are derived
/// data, never part of the immutable truth").
///
/// Named EntryVerificationRow (not the Drift default) to stay distinct from
/// any future domain model of the same concept.
@DataClassName('EntryVerificationRow')
class EntryVerificationCache extends Table {
  TextColumn get entryId => text().references(JournalEntries, #id)();

  BoolColumn get isVerified => boolean()();

  /// Null when [isVerified] is true.
  TextColumn get breakReason =>
      textEnum<VerificationBreakReason>().nullable()();

  DateTimeColumn get checkedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {entryId};
}
