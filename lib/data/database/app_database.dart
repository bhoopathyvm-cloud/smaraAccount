import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'tables/account_groups_table.dart';
import 'tables/accounts_table.dart';
import 'tables/category_rules_table.dart';
import 'tables/csv_import_profiles_table.dart';
import 'tables/entry_verification_cache_table.dart';
import 'tables/integrity_events_table.dart';
import 'tables/journal_entries_table.dart';
import 'tables/ledger_chain_state_table.dart';
import 'tables/ofx_import_records_table.dart';
import 'tables/pending_transfers_table.dart';
import 'tables/postings_table.dart';
import 'tables/signing_identities_table.dart';

part 'app_database.g.dart';

/// The single financial account seeded on first launch.
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
    AccountGroups,
    Accounts,
    JournalEntries,
    Postings,
    SigningIdentities,
    EntryVerificationCache,
    LedgerChainState,
    IntegrityEvents,
    PendingTransfers,
    OfxImportRecords,
    CsvImportProfiles,
    CategoryRules,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      // Schema only - no data. Starter groups/accounts are seeded by
      // LedgerRepository.confirmFirstIdentity, not here: spec
      // ("Device Signing Identity") requires the signing identity to
      // exist before any starter account or journal entry does.
      await m.createAll();
      await _createOfxImportRecordsIndexes();
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

      if (from < 3) {
        // multi-account-support: account_groups + group_id/sort_order on
        // accounts. Safe with existing journal_entries — metadata only,
        // no re-hash of history. No reject-if-rows guard needed.
        await m.createTable(accountGroups);
        await m.addColumn(accounts, accounts.groupId);
        await m.addColumn(
          accounts,
          GeneratedColumn<int>(
            'sort_order',
            'accounts',
            false,
            type: DriftSqlType.int,
            defaultValue: const Constant(0),
          ),
        );

        // Drift's default (non-text) DateTime columns store unix seconds,
        // not milliseconds - binding milliseconds directly here would
        // corrupt created_at for these rows by a factor of 1000 the next
        // time Drift reads it back (DateTime.fromMillisecondsSinceEpoch
        // applied to an already-too-large value).
        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        await customStatement(
          'INSERT INTO account_groups (id, name, kind, sort_order, is_system, created_at) VALUES '
          "(?, 'Cash & cash equivalents', 'assetGroup', 0, 1, ?), "
          "(?, 'Pension & retirement', 'assetGroup', 1, 1, ?), "
          "(?, 'Credit & short-term debt', 'liabilityGroup', 2, 1, ?), "
          "(?, 'Loans & mortgages', 'liabilityGroup', 3, 1, ?)",
          [
            groupCashEquivalentsId,
            now,
            groupPensionRetirementId,
            now,
            groupCreditShortTermId,
            now,
            groupLoansMortgagesId,
            now,
          ],
        );

        await customStatement(
          'INSERT INTO accounts (id, name, type, group_id, sort_order, archived_at, created_at) '
          "VALUES (?, ?, 'equity', NULL, 0, NULL, ?)",
          [openingBalanceEquityAccountId, openingBalanceEquityAccountName, now],
        );

        // Backfill the existing sole asset financial account into Cash &
        // cash equivalents. Categories stay group_id NULL.
        await customStatement(
          "UPDATE accounts SET group_id = ? WHERE type = 'asset'",
          [groupCashEquivalentsId],
        );
      }

      if (from < 4) {
        // multi-currency-support: account_groups.currency + the
        // Transfers-in-transit system account + pending_transfers.
        // currency is added nullable - existing account_groups rows land
        // as NULL here, which is exactly the "needs the one-time currency
        // backfill prompt" signal the app-level flow checks for
        // (LedgerRepository.groupsNeedingCurrencyBackfill). A fresh
        // schemaVersion-4 onCreate install never hits this path at all:
        // confirmFirstIdentity always seeds groups with a currency
        // already chosen during onboarding.
        //
        // A database skipping straight from schemaVersion < 3 to 4 hits
        // the `from < 3` branch above first in this same migration call,
        // which runs `m.createTable(accountGroups)` against the *current*
        // table definition - already including `currency`, since Drift
        // always generates a table's columns from its live class, not a
        // versioned snapshot. Adding the column again here would be a
        // duplicate-column error, so it's only needed for a database that
        // already had `account_groups` before this migration ran.
        if (from >= 3) {
          await m.addColumn(accountGroups, accountGroups.currency);
        }
        await m.createTable(pendingTransfers);

        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        await customStatement(
          'INSERT INTO accounts (id, name, type, group_id, sort_order, archived_at, created_at) '
          "VALUES (?, ?, 'clearing', NULL, 0, NULL, ?)",
          [transfersInTransitAccountId, transfersInTransitAccountName, now],
        );
      }

      if (from < 5) {
        // custom-account-groups: account_groups.archived_at. Added
        // nullable - every existing group (system or otherwise) lands as
        // NULL, i.e. not archived, which is correct for all of them; no
        // backfill needed. account_groups.id's new client-side UUID
        // default has no DDL impact.
        //
        // Same duplicate-column pitfall as `currency` above: a database
        // skipping straight from schemaVersion < 3 to 5 already gets
        // archived_at for free from the `from < 3` branch's
        // `m.createTable(accountGroups)` (always built from the *current*
        // table definition), so this only runs for a database that
        // already had `account_groups` before this migration call.
        if (from >= 3) {
          await m.addColumn(accountGroups, accountGroups.archivedAt);
        }
      }

      if (from < 6) {
        // ofx-transaction-import: additive ofx_import_records table plus
        // its lookup indexes. journal_entries itself is untouched - the
        // signed hash chain is unaffected by this migration (design.md
        // Decision 2).
        await m.createTable(ofxImportRecords);
        await _createOfxImportRecordsIndexes();
      }

      if (from < 7) {
        // csv-transaction-import: ofx_import_records.source, so a
        // duplicate-detection record can note whether it came from an OFX
        // or CSV import. Nullable and additive - existing rows land as
        // NULL, understood as "OFX" since CSV import didn't exist before
        // this migration (design.md Decision 5).
        //
        // Same duplicate-column pitfall as `currency`/`archived_at`
        // above: a database skipping straight from schemaVersion < 6 to 7
        // already gets `source` for free from the `from < 6` branch's
        // `m.createTable(ofxImportRecords)` (built from the *current*
        // table definition), so this only runs for a database that
        // already had `ofx_import_records` before this migration call.
        if (from >= 6) {
          await m.addColumn(ofxImportRecords, ofxImportRecords.source);
        }
      }

      if (from < 8) {
        // csv-transaction-import: additive csv_import_profiles table for
        // saved column-mapping profiles (design.md Decision 6).
        await m.createTable(csvImportProfiles);
      }

      if (from < 9) {
        // import-category-rules: additive category_rules table for saved
        // keyword-to-category rules (design.md: "Persistence follows the
        // CsvImportProfiles pattern exactly").
        await m.createTable(categoryRules);
      }
    },
  );

  /// A plain (non-partial) `UNIQUE` index on `(financial_account_id, fitid)`
  /// is sufficient to only enforce uniqueness for non-null `fitid` values:
  /// SQLite already treats every `NULL` as distinct from every other `NULL`
  /// under a `UNIQUE` constraint, so rows using the fallback-match-key path
  /// (`fitid IS NULL`) never conflict with each other.
  Future<void> _createOfxImportRecordsIndexes() async {
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS ofx_import_records_account_fitid_idx '
      'ON ofx_import_records (financial_account_id, fitid)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS ofx_import_records_account_fallback_idx '
      'ON ofx_import_records (financial_account_id, fallback_match_key)',
    );
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'smara_accounting',
    native: DriftNativeOptions(
      // The default (getApplicationDocumentsDirectory) resolves to the
      // real ~/Documents on desktop, which macOS's privacy protection
      // (TCC) blocks unsigned/ad-hoc dev builds from opening - causing an
      // unhandled SqliteException(14) during startup routing. Application
      // Support isn't TCC-protected and is the correct home for a
      // private local database anyway.
      databaseDirectory: () async {
        final dir = await getApplicationSupportDirectory();
        await dir.create(recursive: true);
        return dir;
      },
    ),
  );
}
