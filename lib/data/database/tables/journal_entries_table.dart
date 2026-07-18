import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'signing_identities_table.dart';

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

  /// Gapless, ascending position in this device's chain (ledger-integrity-signing
  /// design.md - named `device_chain_sequence`, not `sequence`, for the
  /// per-device chain this becomes once multi-device sync exists).
  IntColumn get deviceChainSequence => integer().unique()();

  /// 32 zero bytes for the genesis entry (see [genesisPreviousEntryHash] in
  /// domain/crypto/entry_canonical_hash.dart) - never an arbitrary null.
  BlobColumn get previousEntryHash => blob()();

  BlobColumn get entryHash => blob()();

  TextColumn get signedByIdentityId =>
      text().references(SigningIdentities, #identityId)();

  BlobColumn get signature => blob()();

  /// Set only on an entry created by the true-key-loss migration flow;
  /// points at the legacy entry whose content this row preserves. The
  /// legacy row itself is left exactly as-is, never edited.
  TextColumn get migratedFromEntryId =>
      text().nullable().references(JournalEntries, #id)();

  @override
  Set<Column> get primaryKey => {id};
}
