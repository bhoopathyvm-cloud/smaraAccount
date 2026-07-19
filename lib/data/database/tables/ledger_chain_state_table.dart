import 'package:drift/drift.dart';

import 'journal_entries_table.dart';

/// A convenience pointer, also derived: exists purely so
/// `recordTransaction`/`reverseEntry` don't have to re-derive "what's the
/// last verified entry to chain onto" from a full scan on every write.
/// Fully recomputable from journal_entries + entry_verification_cache
/// (design.md).
///
/// Named ChainStateRow (not the Drift default) to stay distinct from any
/// future domain model of the same concept.
@DataClassName('ChainStateRow')
class LedgerChainState extends Table {
  /// Fixed value 'singleton' - this table always has exactly one row.
  TextColumn get id => text()();

  TextColumn get trustedTipEntryId =>
      text().nullable().references(JournalEntries, #id)();

  BlobColumn get trustedTipHash => blob().nullable()();

  IntColumn get nextDeviceChainSequence => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The fixed single-row id for [LedgerChainState].
const ledgerChainStateSingletonId = 'singleton';
