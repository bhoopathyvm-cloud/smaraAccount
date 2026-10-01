import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../domain/crypto/secure_key_storage.dart';
import '../../domain/models/transaction_direction.dart';
import '../books_set/books_set_paths.dart';
import 'tables/account_groups_table.dart';
import 'tables/accounts_table.dart';
import 'tables/books_set_metadata_table.dart';
import 'tables/category_merge_map_table.dart';
import 'tables/category_rules_table.dart';
import 'tables/category_translations_table.dart';
import 'tables/claim_advances_table.dart';
import 'tables/claim_category_allowlist_table.dart';
import 'tables/claim_item_decisions_table.dart';
import 'tables/claim_items_table.dart';
import 'tables/claim_receipts_table.dart';
import 'tables/claim_spending_hints_table.dart';
import 'tables/claims_table.dart';
import 'tables/csv_import_profiles_table.dart';
import 'tables/entry_verification_cache_table.dart';
import 'tables/integrity_events_table.dart';
import 'tables/instrument_quotes_table.dart';
import 'tables/instruments_table.dart';
import 'tables/investment_lots_table.dart';
import 'tables/investment_sells_table.dart';
import 'tables/journal_entries_table.dart';
import 'tables/ledger_chain_state_table.dart';
import 'tables/ledger_identity_chain_tips_table.dart';
import 'tables/linked_devices_table.dart';
import 'tables/membership_notices_table.dart';
import 'tables/ofx_import_records_table.dart';
import 'tables/payees_table.dart';
import 'tables/pending_join_requests_table.dart';
import 'tables/pending_transfers_table.dart';
import 'tables/postings_table.dart';
import 'tables/recurring_templates_table.dart';
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
  'Food out',
  'Phone',
  'Health',
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
    Instruments,
    InvestmentLots,
    InvestmentSells,
    InstrumentQuotes,
    PendingTransfers,
    OfxImportRecords,
    CsvImportProfiles,
    CategoryRules,
    Payees,
    RecurringTemplates,
    LinkedDevices,
    LedgerIdentityChainTips,
    CategoryTranslations,
    CategoryMergeMap,
    BooksSetMetadata,
    MembershipNotices,
    PendingJoinRequests,
    Claims,
    ClaimItems,
    ClaimItemDecisions,
    ClaimReceipts,
    ClaimAdvances,
    ClaimCategoryAllowlist,
    ClaimSpendingHints,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  /// Opens [file] directly as an `AppDatabase`, running the same
  /// migrations as a normal launch would (ledger-backup-restore: used to
  /// validate a decrypted backup file - a fresh identity read plus a
  /// migration run is a real sanity check that it's a genuine, openable
  /// ledger database, not just bytes that happened to decrypt).
  AppDatabase.openFile(File file) : super(NativeDatabase(file));

  /// The active books set's database file under
  /// `books/<booksSetId>/ledger.sqlite`. Runs the one-time legacy single-
  /// file move when needed (linked-devices design Decision 4).
  static Future<File> resolveDatabaseFile({
    String? booksSetId,
    Directory? supportDirectory,
    BooksSetStore? booksSetStore,
    SecureKeyStorage? secureStorage,
  }) async {
    final dir = supportDirectory ?? await getApplicationSupportDirectory();
    await dir.create(recursive: true);
    final store = booksSetStore ?? BooksSetStore();
    await BooksSetPaths.migrateLegacyLayoutIfNeeded(
      supportDirectory: dir,
      store: store,
      secureStorage: secureStorage ?? FlutterSecureKeyStorage(),
    );
    var id = booksSetId ?? await store.activeBooksSetId();
    if (id == null) {
      id = const Uuid().v4();
      await store.setActiveBooksSetId(id);
    }
    await BooksSetPaths.ensureBooksSetDirectory(dir, id);
    return BooksSetPaths.databaseFile(dir, id);
  }

  @override
  int get schemaVersion => 22;

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

      if (from < 10) {
        // investment-holdings: additive investment-account flag, global
        // instruments table, per-account lots, quote cache, and the fifth
        // seeded system group. Existing asset accounts remain ordinary
        // non-investment accounts by default (design.md Migration Plan).
        if (from >= 1) {
          await m.addColumn(accounts, accounts.holdsInvestments);
          await m.addColumn(accounts, accounts.investmentOwnerAccountId);
        }
        await m.createTable(instruments);
        await m.createTable(investmentLots);
        await m.createTable(instrumentQuotes);

        final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        await customStatement(
          'INSERT INTO account_groups (id, name, kind, sort_order, is_system, created_at) VALUES '
          "(?, 'Investments', 'assetGroup', 4, 1, ?)",
          [groupInvestmentsId, now],
        );
      }

      if (from < 11) {
        // investment-holdings: sell rows for date-ordered replay (design.md
        // Decision 3) — additive alongside investment_lots from schema 10.
        await m.createTable(investmentSells);
      }

      if (from < 12) {
        // deferred-onboarding-first-entry: nullable acknowledgedAt tracks
        // the mandatory recovery-phrase acknowledgment separately from
        // identity existence, since onboarding now commits the identity
        // before the acknowledgment screens run. Every identity that
        // already exists in a database upgrading from an earlier schema
        // was, by definition, onboarded under the old flow where identity
        // commit and acknowledgment were the same moment - backfill
        // acknowledgedAt from createdAt so an existing user is never sent
        // back through acknowledgment screens for a phrase this app never
        // stored and cannot show again.
        //
        // A database skipping straight from schemaVersion < 2 to 12 hits
        // the `from < 2` branch above first in this same migration call,
        // which runs `m.createTable(signingIdentities)` against the
        // *current* table definition - already including
        // `acknowledgedAt`, since Drift always generates a table's
        // columns from its live class, not a versioned snapshot. Adding
        // the column again here would be a duplicate-column error (same
        // reasoning as `accountGroups.currency` in the `from < 4` branch
        // above), so it's only needed for a database that already had
        // `signing_identities` before this migration ran.
        if (from >= 2) {
          await m.addColumn(
            signingIdentities,
            signingIdentities.acknowledgedAt,
          );
          await customStatement(
            'UPDATE signing_identities SET acknowledged_at = created_at '
            'WHERE acknowledged_at IS NULL',
          );
        }
      }

      if (from < 13) {
        // payees-and-spending-memory: additive payees table for remembered
        // payee defaults (design.md Decision 1). No FK/link column on
        // journal_entries - matching is done at query time by normalized
        // description, not by a stored relationship.
        await m.createTable(payees);
      }

      if (from < 14) {
        // recurring-templates: additive recurring_templates table.
        // Recording a due template just calls recordTransaction like a
        // manual entry - no FK/link column on journal_entries either.
        await m.createTable(recurringTemplates);
      }

      if (from < 15) {
        // monthly-category-limits: nullable monthly_limit_minor on
        // accounts (Expense categories only). `accounts` has existed
        // since schemaVersion 1 and is never recreated by a later
        // `m.createTable` branch, so this is a plain addColumn with no
        // duplicate-column guard needed (unlike accountGroups.currency).
        await m.addColumn(accounts, accounts.monthlyLimitMinor);
      }

      if (from < 16) {
        // credit-card-household-flow: is_credit_card on accounts
        // (Liability accounts only), same plain-addColumn reasoning as
        // monthlyLimitMinor above.
        await m.addColumn(accounts, accounts.isCreditCard);
      }

      if (from < 17 && from >= 10) {
        // instrument-identifier-assist: nullable resolved_symbol / exchange
        // on instruments (design.md Migration Plan step 1). Additive, no
        // backfill - existing instruments keep fetching quotes by raw
        // ticker until a resolve confirms a canonical symbol.
        //
        // Guarded to `from >= 10`: a database upgrading from < 10 has its
        // `instruments` table freshly built by the `from < 10`
        // `createTable(instruments)` branch above, which already uses the
        // current table definition (both new columns included). Only a
        // database that carried a pre-17 `instruments` table (schemaVersion
        // 10-16) needs these columns added.
        await m.addColumn(instruments, instruments.resolvedSymbol);
        await m.addColumn(instruments, instruments.exchange);
      }

      if (from < 18) {
        // books-copy-and-continuation: Continuation links between signing
        // identities. Nullable columns only; existing identities stay
        // current (both null) and keep their values.
        //
        // Same duplicate-column pitfall as `acknowledgedAt` above: a
        // database skipping straight from schemaVersion < 2 to 18 already
        // gets these columns from the `from < 2` branch's
        // `m.createTable(signingIdentities)` (built from the *current*
        // table definition), so this only runs for a database that
        // already had `signing_identities` before this migration call.
        if (from >= 2) {
          await m.addColumn(signingIdentities, signingIdentities.continuedAt);
          await m.addColumn(
            signingIdentities,
            signingIdentities.continuesIdentityId,
          );
        }
      }

      if (from < 19) {
        // linked-devices-and-sync: membership, per-identity chain tips,
        // category translations / merge map, and books-set metadata.
        // Additive tables only. The on-disk move of the legacy single
        // SQLite file into books/<id>/ is handled outside Drift by
        // BooksSetPaths.migrateLegacyLayoutIfNeeded before open.
        // ledger_chain_state singleton tip is kept; identity tips are
        // populated by later multi-chain tasks (3.x).
        await m.createTable(linkedDevices);
        await m.createTable(ledgerIdentityChainTips);
        await m.createTable(categoryTranslations);
        await m.createTable(categoryMergeMap);
        await m.createTable(booksSetMetadata);
      }

      if (from < 20) {
        // linked-devices membership notices + Books-Copy join requests
        // (tasks 4.4 / 4.5). Additive only.
        await m.createTable(membershipNotices);
        await m.createTable(pendingJoinRequests);
      }

      if (from < 21) {
        // Peer sync: device_chain_sequence is unique per signing identity,
        // not globally — two devices may each have sequence 1.
        await customStatement('PRAGMA foreign_keys = OFF');
        await customStatement('''
CREATE TABLE journal_entries__new (
  id TEXT NOT NULL PRIMARY KEY,
  transaction_date TEXT NOT NULL,
  recorded_at INTEGER NOT NULL,
  description TEXT NULL,
  reverses_entry_id TEXT NULL REFERENCES journal_entries__new(id),
  created_at INTEGER NOT NULL DEFAULT (CAST(strftime('%s', 'now') AS INTEGER)),
  device_chain_sequence INTEGER NOT NULL,
  previous_entry_hash BLOB NOT NULL,
  entry_hash BLOB NOT NULL,
  signed_by_identity_id TEXT NOT NULL REFERENCES signing_identities(identity_id),
  signature BLOB NOT NULL,
  migrated_from_entry_id TEXT NULL REFERENCES journal_entries__new(id),
  UNIQUE (signed_by_identity_id, device_chain_sequence)
);
''');
        await customStatement(
          'INSERT INTO journal_entries__new SELECT * FROM journal_entries',
        );
        await customStatement('DROP TABLE journal_entries');
        await customStatement(
          'ALTER TABLE journal_entries__new RENAME TO journal_entries',
        );
        await customStatement('PRAGMA foreign_keys = ON');
      }

      if (from < 22) {
        // shared-accounts-and-expense-claims: role set + owed-to link on
        // membership; claim / receipt / advance / allowlist / hint tables;
        // receipt-required threshold on books metadata.
        //
        // Guard linked_devices column adds: a DB upgrading from < 19 gets
        // linked_devices from createTable(linkedDevices) already including
        // the new columns (current table definition). Only DBs that already
        // had linked_devices (from >= 19) need addColumn.
        if (from >= 19) {
          await m.addColumn(linkedDevices, linkedDevices.rolesCsv);
          await m.addColumn(linkedDevices, linkedDevices.owedToAccountId);
          await m.addColumn(linkedDevices, linkedDevices.personDisplayName);
          await customStatement(
            "UPDATE linked_devices SET roles_csv = role "
            "WHERE roles_csv IS NULL OR roles_csv = ''",
          );
        } else {
          // Fresh linked_devices from from < 19 createTable already has
          // rolesCsv default ''; backfill from role after create.
          await customStatement(
            "UPDATE linked_devices SET roles_csv = role "
            "WHERE roles_csv IS NULL OR roles_csv = ''",
          );
        }

        // books_set_metadata: same duplicate-column guard — created at 19.
        if (from >= 19) {
          await m.addColumn(
            booksSetMetadata,
            booksSetMetadata.receiptRequiredAboveMinor,
          );
        }

        await m.createTable(claims);
        await m.createTable(claimItems);
        await m.createTable(claimItemDecisions);
        await m.createTable(claimReceipts);
        await m.createTable(claimAdvances);
        await m.createTable(claimCategoryAllowlist);
        await m.createTable(claimSpendingHints);
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
  // Resolve the active books-set path (and run the one-time legacy move)
  // lazily so SharedPreferences / path_provider are available. Application
  // Support isn't TCC-protected on macOS and is the correct home for a
  // private local database (same rationale as the prior driftDatabase
  // databaseDirectory override).
  return LazyDatabase(() async {
    final file = await AppDatabase.resolveDatabaseFile();
    return NativeDatabase.createInBackground(file);
  });
}
