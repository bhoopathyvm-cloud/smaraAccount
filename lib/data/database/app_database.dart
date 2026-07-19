import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

import 'tables/accounts_table.dart';
import 'tables/entry_verification_cache_table.dart';
import 'tables/integrity_events_table.dart';
import 'tables/journal_entries_table.dart';
import 'tables/ledger_chain_state_table.dart';
import 'tables/postings_table.dart';
import 'tables/signing_identities_table.dart';

part 'app_database.g.dart';

/// The single financial account seeded on first launch. Never archivable -
/// archiving is only offered for income/expense rows (Category Management
/// requirement).
const financialAccountName = 'Cash & Bank';

/// Starter category set (design.md: "Starter category set"). All are
/// renameable, extendable, and archivable - this is a starting point, not
/// a fixed taxonomy.
const starterIncomeCategories = ['Salary', 'Other Income'];
const starterExpenseCategories = [
  'Groceries',
  'Rent/Mortgage',
  'Utilities',
  'Transport',
  'Other Expense',
];

@DriftDatabase(
  tables: [
    Accounts,
    JournalEntries,
    Postings,
    SigningIdentities,
    EntryVerificationCache,
    LedgerChainState,
    IntegrityEvents,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      // Schema only - no data. Starter accounts are seeded by
      // LedgerRepository.confirmFirstIdentity, not here: spec
      // ("Device Signing Identity") requires the signing identity to
      // exist before any starter account or journal entry does, so
      // seeding can't happen unconditionally at database-file creation
      // time, before onboarding has run.
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // ledger-integrity-signing: chaining/signing columns on
        // journal_entries, plus four supporting tables. Per design.md's
        // Migration Plan, no shipped version of this app ever had a real
        // user with posted entries, so this path only needs to handle an
        // empty journal_entries table - guarded explicitly below rather
        // than silently accepting rows this migration can't correctly
        // backfill (it has no way to compute a real hash/signature for a
        // pre-existing entry).
        final existingEntryCount = await customSelect(
          'SELECT COUNT(*) AS c FROM journal_entries',
        ).getSingle();
        if ((existingEntryCount.data['c'] as int) > 0) {
          throw StateError(
            'ledger-integrity-signing schema migration does not support '
            'upgrading a database that already has journal_entries rows.',
          );
        }

        // ADD COLUMN with NOT NULL requires a DEFAULT in SQLite. These
        // one-off column definitions carry a default purely to satisfy
        // that DDL rule on an empty table - the real column definitions
        // above (used for onCreate and all application code) have no
        // default, matching design.md exactly.
        await m.addColumn(
          journalEntries,
          GeneratedColumn<int>(
            'device_chain_sequence',
            'journal_entries',
            false,
            type: DriftSqlType.int,
            defaultValue: const Constant(0),
          ),
        );
        await m.addColumn(
          journalEntries,
          GeneratedColumn<Uint8List>(
            'previous_entry_hash',
            'journal_entries',
            false,
            type: DriftSqlType.blob,
            defaultValue: Constant(Uint8List(32)),
          ),
        );
        await m.addColumn(
          journalEntries,
          GeneratedColumn<Uint8List>(
            'entry_hash',
            'journal_entries',
            false,
            type: DriftSqlType.blob,
            defaultValue: Constant(Uint8List(32)),
          ),
        );
        await m.addColumn(
          journalEntries,
          GeneratedColumn<String>(
            'signed_by_identity_id',
            'journal_entries',
            false,
            type: DriftSqlType.string,
            defaultValue: const Constant(''),
          ),
        );
        await m.addColumn(
          journalEntries,
          GeneratedColumn<Uint8List>(
            'signature',
            'journal_entries',
            false,
            type: DriftSqlType.blob,
            defaultValue: Constant(Uint8List(64)),
          ),
        );
        await m.addColumn(journalEntries, journalEntries.migratedFromEntryId);
        await m.createTable(signingIdentities);
        await m.createTable(entryVerificationCache);
        await m.createTable(ledgerChainState);
        await m.createTable(integrityEvents);
      }
    },
  );
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'smara_accounting');
}
