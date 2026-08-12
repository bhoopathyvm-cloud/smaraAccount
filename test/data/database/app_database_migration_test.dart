import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/database/tables/account_groups_table.dart';
import 'package:smara_accounting/data/database/tables/accounts_table.dart';
import 'package:smara_accounting/data/database/tables/ofx_import_records_table.dart'
    show ImportSource;
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;
import 'package:test/test.dart';

import '../../domain/crypto/in_memory_secure_key_storage.dart';

/// Builds a database file matching core-ledger-single-account's shipped
/// schemaVersion 1 - before ledger-integrity-signing added any columns or
/// tables - so onUpgrade(1, 2) can be exercised for real (smara-tech-guidelines.md's
/// Drift Schema Migration Rule #5: "Test both paths before release").
sqlite3.Database _openV1Database() {
  final db = sqlite3.sqlite3.openInMemory();
  db.execute('''
    CREATE TABLE accounts (
      id TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL,
      type TEXT NOT NULL,
      archived_at INTEGER NULL,
      created_at INTEGER NOT NULL DEFAULT 0
    );
    CREATE TABLE journal_entries (
      id TEXT NOT NULL PRIMARY KEY,
      transaction_date TEXT NOT NULL,
      recorded_at INTEGER NOT NULL,
      description TEXT NULL,
      reverses_entry_id TEXT NULL REFERENCES journal_entries(id),
      created_at INTEGER NOT NULL DEFAULT 0
    );
    CREATE TABLE postings (
      id TEXT NOT NULL PRIMARY KEY,
      entry_id TEXT NOT NULL REFERENCES journal_entries(id),
      account_id TEXT NOT NULL REFERENCES accounts(id),
      amount_minor INTEGER NOT NULL,
      line_number INTEGER NOT NULL
    );
    PRAGMA user_version = 1;
  ''');
  return db;
}

/// Builds a database file matching ledger-integrity-signing's shipped
/// schemaVersion 2 - before multi-account-support added `account_groups`
/// or `accounts.group_id`/`sort_order` - so onUpgrade(2, 3) can be
/// exercised for real, per the same Drift Migration Rule #5 discipline as
/// [_openV1Database].
sqlite3.Database _openV2Database() {
  final db = sqlite3.sqlite3.openInMemory();
  db.execute('''
    CREATE TABLE accounts (
      id TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL,
      type TEXT NOT NULL,
      archived_at INTEGER NULL,
      created_at INTEGER NOT NULL DEFAULT 0
    );
    CREATE TABLE signing_identities (
      identity_id TEXT NOT NULL PRIMARY KEY,
      public_key BLOB NOT NULL,
      created_at INTEGER NOT NULL DEFAULT 0,
      supersedes_identity_id TEXT NULL REFERENCES signing_identities(identity_id),
      superseded_at INTEGER NULL
    );
    CREATE TABLE journal_entries (
      id TEXT NOT NULL PRIMARY KEY,
      transaction_date TEXT NOT NULL,
      recorded_at INTEGER NOT NULL,
      description TEXT NULL,
      reverses_entry_id TEXT NULL REFERENCES journal_entries(id),
      created_at INTEGER NOT NULL DEFAULT 0,
      device_chain_sequence INTEGER NOT NULL UNIQUE,
      previous_entry_hash BLOB NOT NULL,
      entry_hash BLOB NOT NULL,
      signed_by_identity_id TEXT NOT NULL REFERENCES signing_identities(identity_id),
      signature BLOB NOT NULL,
      migrated_from_entry_id TEXT NULL REFERENCES journal_entries(id)
    );
    CREATE TABLE postings (
      id TEXT NOT NULL PRIMARY KEY,
      entry_id TEXT NOT NULL REFERENCES journal_entries(id),
      account_id TEXT NOT NULL REFERENCES accounts(id),
      amount_minor INTEGER NOT NULL,
      line_number INTEGER NOT NULL
    );
    CREATE TABLE entry_verification_cache (
      entry_id TEXT NOT NULL PRIMARY KEY REFERENCES journal_entries(id),
      is_verified INTEGER NOT NULL,
      break_reason TEXT NULL,
      checked_at INTEGER NOT NULL
    );
    CREATE TABLE ledger_chain_state (
      id TEXT NOT NULL PRIMARY KEY,
      trusted_tip_entry_id TEXT NULL REFERENCES journal_entries(id),
      trusted_tip_hash BLOB NULL,
      next_device_chain_sequence INTEGER NOT NULL
    );
    CREATE TABLE integrity_events (
      event_id TEXT NOT NULL PRIMARY KEY,
      event_type TEXT NOT NULL,
      occurred_at INTEGER NOT NULL DEFAULT 0,
      related_entry_id TEXT NULL REFERENCES journal_entries(id),
      related_identity_id TEXT NULL REFERENCES signing_identities(identity_id),
      detail TEXT NULL
    );
    PRAGMA user_version = 2;
  ''');
  return db;
}

/// Builds a database file matching multi-account-support's shipped
/// schemaVersion 3 - before multi-currency-support added
/// `account_groups.currency`, `pending_transfers`, or the Transfers-in-transit
/// clearing account - so onUpgrade(3, 4) can be exercised for real, per the
/// same Drift Migration Rule #5 discipline as [_openV1Database] and
/// [_openV2Database].
sqlite3.Database _openV3Database() {
  final db = sqlite3.sqlite3.openInMemory();
  db.execute('''
    CREATE TABLE account_groups (
      id TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL,
      kind TEXT NOT NULL,
      sort_order INTEGER NOT NULL DEFAULT 0,
      is_system INTEGER NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL DEFAULT 0
    );
    CREATE TABLE accounts (
      id TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL,
      type TEXT NOT NULL,
      group_id TEXT NULL REFERENCES account_groups(id),
      sort_order INTEGER NOT NULL DEFAULT 0,
      archived_at INTEGER NULL,
      created_at INTEGER NOT NULL DEFAULT 0
    );
    CREATE TABLE signing_identities (
      identity_id TEXT NOT NULL PRIMARY KEY,
      public_key BLOB NOT NULL,
      created_at INTEGER NOT NULL DEFAULT 0,
      supersedes_identity_id TEXT NULL REFERENCES signing_identities(identity_id),
      superseded_at INTEGER NULL
    );
    CREATE TABLE journal_entries (
      id TEXT NOT NULL PRIMARY KEY,
      transaction_date TEXT NOT NULL,
      recorded_at INTEGER NOT NULL,
      description TEXT NULL,
      reverses_entry_id TEXT NULL REFERENCES journal_entries(id),
      created_at INTEGER NOT NULL DEFAULT 0,
      device_chain_sequence INTEGER NOT NULL UNIQUE,
      previous_entry_hash BLOB NOT NULL,
      entry_hash BLOB NOT NULL,
      signed_by_identity_id TEXT NOT NULL REFERENCES signing_identities(identity_id),
      signature BLOB NOT NULL,
      migrated_from_entry_id TEXT NULL REFERENCES journal_entries(id)
    );
    CREATE TABLE postings (
      id TEXT NOT NULL PRIMARY KEY,
      entry_id TEXT NOT NULL REFERENCES journal_entries(id),
      account_id TEXT NOT NULL REFERENCES accounts(id),
      amount_minor INTEGER NOT NULL,
      line_number INTEGER NOT NULL
    );
    CREATE TABLE entry_verification_cache (
      entry_id TEXT NOT NULL PRIMARY KEY REFERENCES journal_entries(id),
      is_verified INTEGER NOT NULL,
      break_reason TEXT NULL,
      checked_at INTEGER NOT NULL
    );
    CREATE TABLE ledger_chain_state (
      id TEXT NOT NULL PRIMARY KEY,
      trusted_tip_entry_id TEXT NULL REFERENCES journal_entries(id),
      trusted_tip_hash BLOB NULL,
      next_device_chain_sequence INTEGER NOT NULL
    );
    CREATE TABLE integrity_events (
      event_id TEXT NOT NULL PRIMARY KEY,
      event_type TEXT NOT NULL,
      occurred_at INTEGER NOT NULL DEFAULT 0,
      related_entry_id TEXT NULL REFERENCES journal_entries(id),
      related_identity_id TEXT NULL REFERENCES signing_identities(identity_id),
      detail TEXT NULL
    );
    INSERT INTO account_groups (id, name, kind, sort_order, is_system, created_at) VALUES
      ('$groupCashEquivalentsId', 'Cash & cash equivalents', 'assetGroup', 0, 1, 0),
      ('$groupPensionRetirementId', 'Pension & retirement', 'assetGroup', 1, 1, 0),
      ('$groupCreditShortTermId', 'Credit & short-term debt', 'liabilityGroup', 2, 1, 0),
      ('$groupLoansMortgagesId', 'Loans & mortgages', 'liabilityGroup', 3, 1, 0);
    INSERT INTO accounts (id, name, type, group_id, sort_order, archived_at, created_at)
      VALUES ('$openingBalanceEquityAccountId', '$openingBalanceEquityAccountName', 'equity', NULL, 0, NULL, 0);
    PRAGMA user_version = 3;
  ''');
  return db;
}

/// Builds a database file matching multi-currency-support's shipped
/// schemaVersion 4 - before custom-account-groups added
/// `account_groups.archived_at` - so onUpgrade(4, 5) can be exercised for
/// real, per the same Drift Migration Rule #5 discipline as the other
/// `_openVxDatabase` builders. Built by taking [_openV3Database] and
/// hand-applying the same schemaVersion-4 migration SQL the real
/// `onUpgrade` block runs (`account_groups.currency`, `pending_transfers`,
/// the Transfers-in-transit clearing account) - that upgrade path is
/// already covered by its own tests below, so this is just test setup,
/// not a second copy of migration logic under test.
sqlite3.Database _openV4Database() {
  final db = _openV3Database();
  db.execute('''
    ALTER TABLE account_groups ADD COLUMN currency TEXT NULL;
    UPDATE account_groups SET currency = 'USD';
    CREATE TABLE pending_transfers (
      id TEXT NOT NULL PRIMARY KEY,
      kind TEXT NOT NULL,
      source_account_id TEXT NOT NULL REFERENCES accounts(id),
      category_id TEXT NULL REFERENCES accounts(id),
      destination_account_id TEXT NULL REFERENCES accounts(id),
      currency TEXT NOT NULL,
      provisional_entry_id TEXT NOT NULL REFERENCES journal_entries(id),
      status TEXT NOT NULL,
      settlement_entry_id TEXT NULL REFERENCES journal_entries(id),
      fee_entry_id TEXT NULL REFERENCES journal_entries(id),
      initiated_at INTEGER NOT NULL,
      settled_at INTEGER NULL
    );
    INSERT INTO accounts (id, name, type, group_id, sort_order, archived_at, created_at)
      VALUES ('$transfersInTransitAccountId', '$transfersInTransitAccountName', 'clearing', NULL, 0, NULL, 0);
    PRAGMA user_version = 4;
  ''');
  return db;
}

/// Built by taking [_openV4Database] and hand-applying the schemaVersion-5
/// migration SQL (`account_groups.archived_at`) so onUpgrade(5, 6) can be
/// exercised for real for the ofx-transaction-import migration below.
sqlite3.Database _openV5Database() {
  final db = _openV4Database();
  db.execute('''
    ALTER TABLE account_groups ADD COLUMN archived_at INTEGER NULL;
    PRAGMA user_version = 5;
  ''');
  return db;
}

/// Built by taking [_openV5Database] and hand-applying the schemaVersion-6
/// migration SQL (`ofx_import_records` table plus its lookup indexes,
/// ofx-transaction-import) so onUpgrade(6, 7) can be exercised for real for
/// the csv-transaction-import migration below.
sqlite3.Database _openV6Database() {
  final db = _openV5Database();
  db.execute('''
    CREATE TABLE ofx_import_records (
      id TEXT NOT NULL PRIMARY KEY,
      financial_account_id TEXT NOT NULL REFERENCES accounts(id),
      fitid TEXT NULL,
      fallback_match_key TEXT NULL,
      journal_entry_id TEXT NOT NULL REFERENCES journal_entries(id),
      imported_at INTEGER NOT NULL
    );
    CREATE UNIQUE INDEX ofx_import_records_account_fitid_idx
      ON ofx_import_records (financial_account_id, fitid);
    CREATE INDEX ofx_import_records_account_fallback_idx
      ON ofx_import_records (financial_account_id, fallback_match_key);
    PRAGMA user_version = 6;
  ''');
  return db;
}

/// Built by taking [_openV6Database] and hand-applying the schemaVersion-7
/// migration SQL (`ofx_import_records.source`, csv-transaction-import) so
/// onUpgrade(7, 8) can be exercised for real for the csv_import_profiles
/// migration below.
sqlite3.Database _openV7Database() {
  final db = _openV6Database();
  db.execute('''
    ALTER TABLE ofx_import_records ADD COLUMN source TEXT NULL;
    PRAGMA user_version = 7;
  ''');
  return db;
}

void main() {
  group('onUpgrade from schemaVersion 7', () {
    test(
      'existing database upgrades cleanly and csv_import_profiles starts empty',
      () async {
        final v7 = _openV7Database();
        final db = AppDatabase.forTesting(NativeDatabase.opened(v7));
        addTearDown(db.close);

        final rows = await db.select(db.csvImportProfiles).get();
        expect(rows, isEmpty);
      },
    );

    test('a profile can be saved and read back after the upgrade', () async {
      final v7 = _openV7Database();
      final db = AppDatabase.forTesting(NativeDatabase.opened(v7));
      addTearDown(db.close);

      await db
          .into(db.csvImportProfiles)
          .insert(
            CsvImportProfilesCompanion.insert(
              name: 'My Bank',
              headerFingerprint: '["date","description","amount"]',
              columnMapping: '{"currency":"USD"}',
              createdAt: DateTime.now(),
            ),
          );

      final rows = await db.select(db.csvImportProfiles).get();
      expect(rows, hasLength(1));
      expect(rows.single.name, 'My Bank');
    });
  });

  group('onUpgrade from schemaVersion 6', () {
    test(
      'existing ofx_import_records rows land with source = NULL (predates CSV import)',
      () async {
        final v6 = _openV6Database();
        final db = AppDatabase.forTesting(NativeDatabase.opened(v6));
        addTearDown(db.close);
        final repository = LedgerRepository(
          database: db,
          signingKeyService: SigningKeyService(
            secureStorage: InMemorySecureKeyStorage(),
          ),
        );
        final generated = await repository.generateFirstIdentity();
        await repository.confirmFirstIdentity(generated, currency: 'USD');
        final account = (await repository.watchFinancialAccounts().first).first;
        final category = (await repository.watchCategories().first).first;
        await repository.recordTransaction(
          amountMinor: 100,
          direction: TransactionDirection.moneyOut,
          categoryId: category.id,
          financialAccountId: account.id,
          transactionDate: DateTime(2026, 1, 1),
        );
        final entryId =
            (await repository.watchEntriesForAccount(account.id).first)
                .first
                .id;

        await db
            .into(db.ofxImportRecords)
            .insert(
              OfxImportRecordsCompanion.insert(
                financialAccountId: account.id,
                fitid: const Value('FITID-PRE-MIGRATION'),
                journalEntryId: entryId,
                importedAt: DateTime.now(),
              ),
            );

        final row = await (db.select(
          db.ofxImportRecords,
        )..where((r) => r.fitid.equals('FITID-PRE-MIGRATION'))).getSingle();
        expect(row.source, isNull);
      },
    );

    test('a new row can specify its source', () async {
      final v6 = _openV6Database();
      final db = AppDatabase.forTesting(NativeDatabase.opened(v6));
      addTearDown(db.close);
      final repository = LedgerRepository(
        database: db,
        signingKeyService: SigningKeyService(
          secureStorage: InMemorySecureKeyStorage(),
        ),
      );
      final generated = await repository.generateFirstIdentity();
      await repository.confirmFirstIdentity(generated, currency: 'USD');
      final account = (await repository.watchFinancialAccounts().first).first;
      final category = (await repository.watchCategories().first).first;
      await repository.recordTransaction(
        amountMinor: 100,
        direction: TransactionDirection.moneyOut,
        categoryId: category.id,
        financialAccountId: account.id,
        transactionDate: DateTime(2026, 1, 1),
      );
      final entryId =
          (await repository.watchEntriesForAccount(account.id).first).first.id;

      await db
          .into(db.ofxImportRecords)
          .insert(
            OfxImportRecordsCompanion.insert(
              financialAccountId: account.id,
              fitid: const Value('FITID-CSV-1'),
              journalEntryId: entryId,
              importedAt: DateTime.now(),
              source: const Value(ImportSource.csv),
            ),
          );

      final row = await (db.select(
        db.ofxImportRecords,
      )..where((r) => r.fitid.equals('FITID-CSV-1'))).getSingle();
      expect(row.source, ImportSource.csv);
    });
  });

  group('onUpgrade from schemaVersion 5', () {
    test(
      'existing database upgrades cleanly and ofx_import_records starts empty',
      () async {
        final v5 = _openV5Database();
        final db = AppDatabase.forTesting(NativeDatabase.opened(v5));
        addTearDown(db.close);

        final rows = await db.select(db.ofxImportRecords).get();
        expect(rows, isEmpty);
      },
    );

    test(
      'a duplicate (financial_account_id, fitid) pair is rejected by the unique index',
      () async {
        final v5 = _openV5Database();
        final db = AppDatabase.forTesting(NativeDatabase.opened(v5));
        addTearDown(db.close);
        final repository = LedgerRepository(
          database: db,
          signingKeyService: SigningKeyService(
            secureStorage: InMemorySecureKeyStorage(),
          ),
        );
        final generated = await repository.generateFirstIdentity();
        await repository.confirmFirstIdentity(generated, currency: 'USD');
        final account = (await repository.watchFinancialAccounts().first).first;
        final category = (await repository.watchCategories().first).first;
        await repository.recordTransaction(
          amountMinor: 100,
          direction: TransactionDirection.moneyOut,
          categoryId: category.id,
          financialAccountId: account.id,
          transactionDate: DateTime(2026, 1, 1),
        );
        final entryId =
            (await repository.watchEntriesForAccount(account.id).first)
                .first
                .id;

        await db
            .into(db.ofxImportRecords)
            .insert(
              OfxImportRecordsCompanion.insert(
                financialAccountId: account.id,
                fitid: const Value('FITID-1'),
                journalEntryId: entryId,
                importedAt: DateTime.now(),
              ),
            );

        expect(
          () => db
              .into(db.ofxImportRecords)
              .insert(
                OfxImportRecordsCompanion.insert(
                  financialAccountId: account.id,
                  fitid: const Value('FITID-1'),
                  journalEntryId: entryId,
                  importedAt: DateTime.now(),
                ),
              ),
          throwsA(anything),
        );
      },
    );

    test(
      'two rows with a NULL fitid for the same account do not conflict',
      () async {
        final v5 = _openV5Database();
        final db = AppDatabase.forTesting(NativeDatabase.opened(v5));
        addTearDown(db.close);
        final repository = LedgerRepository(
          database: db,
          signingKeyService: SigningKeyService(
            secureStorage: InMemorySecureKeyStorage(),
          ),
        );
        final generated = await repository.generateFirstIdentity();
        await repository.confirmFirstIdentity(generated, currency: 'USD');
        final account = (await repository.watchFinancialAccounts().first).first;
        final category = (await repository.watchCategories().first).first;
        await repository.recordTransaction(
          amountMinor: 100,
          direction: TransactionDirection.moneyOut,
          categoryId: category.id,
          financialAccountId: account.id,
          transactionDate: DateTime(2026, 1, 1),
        );
        final entryId =
            (await repository.watchEntriesForAccount(account.id).first)
                .first
                .id;

        await db
            .into(db.ofxImportRecords)
            .insert(
              OfxImportRecordsCompanion.insert(
                financialAccountId: account.id,
                fallbackMatchKey: const Value('2026-01-01|100|moneyOut|Row A'),
                journalEntryId: entryId,
                importedAt: DateTime.now(),
              ),
            );
        await db
            .into(db.ofxImportRecords)
            .insert(
              OfxImportRecordsCompanion.insert(
                financialAccountId: account.id,
                fallbackMatchKey: const Value('2026-01-02|200|moneyOut|Row B'),
                journalEntryId: entryId,
                importedAt: DateTime.now(),
              ),
            );

        final rows = await db.select(db.ofxImportRecords).get();
        expect(rows, hasLength(2));
      },
    );
  });

  group('onUpgrade from schemaVersion 4', () {
    test(
      'existing account_groups rows land with archived_at = NULL (not archived)',
      () async {
        final v4 = _openV4Database();
        final db = AppDatabase.forTesting(NativeDatabase.opened(v4));
        addTearDown(db.close);
        final repository = LedgerRepository(
          database: db,
          signingKeyService: SigningKeyService(
            secureStorage: InMemorySecureKeyStorage(),
          ),
        );

        final groups = await repository.watchAccountGroups().first;
        expect(groups, isNotEmpty);
        expect(groups.every((g) => !g.archived), isTrue);
      },
    );

    test(
      'a group created after the upgrade can be archived normally',
      () async {
        final v4 = _openV4Database();
        final db = AppDatabase.forTesting(NativeDatabase.opened(v4));
        addTearDown(db.close);
        final repository = LedgerRepository(
          database: db,
          signingKeyService: SigningKeyService(
            secureStorage: InMemorySecureKeyStorage(),
          ),
        );

        final created = await repository.createAccountGroup(
          name: 'Business',
          kind: AccountGroupKind.assetGroup,
          currency: 'USD',
        );
        await repository.archiveAccountGroup(created.id);

        final groups = await repository
            .watchAccountGroups(includeArchived: true)
            .first;
        expect(groups.firstWhere((g) => g.id == created.id).archived, isTrue);
      },
    );
  });

  group('onCreate (fresh install)', () {
    test(
      'every seeded group lands not-archived and a new group gets a client-generated id',
      () async {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(db.close);
        final repository = LedgerRepository(
          database: db,
          signingKeyService: SigningKeyService(
            secureStorage: InMemorySecureKeyStorage(),
          ),
        );
        final generated = await repository.generateFirstIdentity();
        await repository.confirmFirstIdentity(generated, currency: 'USD');

        final groups = await repository.watchAccountGroups().first;
        expect(groups, isNotEmpty);
        expect(groups.every((g) => !g.archived), isTrue);

        final created = await repository.createAccountGroup(
          name: 'Business',
          kind: AccountGroupKind.assetGroup,
          currency: 'USD',
        );
        expect(created.id, isNotEmpty);
      },
    );
  });

  group('onUpgrade from schemaVersion 3', () {
    test(
      'existing account_groups rows land with currency = NULL, signalling the currency-backfill prompt',
      () async {
        final v3 = _openV3Database();
        final db = AppDatabase.forTesting(NativeDatabase.opened(v3));
        addTearDown(db.close);
        final repository = LedgerRepository(
          database: db,
          signingKeyService: SigningKeyService(
            secureStorage: InMemorySecureKeyStorage(),
          ),
        );

        final groups = await db.select(db.accountGroups).get();
        expect(groups, isNotEmpty);
        expect(groups.every((g) => g.currency == null), isTrue);
        expect(await repository.needsCurrencyBackfill(), isTrue);
      },
    );

    test(
      'seeds the Transfers-in-transit clearing account, never in the financial-account picker',
      () async {
        final v3 = _openV3Database();
        final db = AppDatabase.forTesting(NativeDatabase.opened(v3));
        addTearDown(db.close);

        final clearing = await (db.select(
          db.accounts,
        )..where((a) => a.id.equals(transfersInTransitAccountId))).getSingle();
        expect(clearing.type, equals(AccountType.clearing));
        expect(clearing.groupId, isNull);

        final repository = LedgerRepository(
          database: db,
          signingKeyService: SigningKeyService(
            secureStorage: InMemorySecureKeyStorage(),
          ),
        );
        final financialAccounts = await repository
            .watchFinancialAccounts(includeArchived: true)
            .first;
        expect(
          financialAccounts.any((a) => a.id == transfersInTransitAccountId),
          isFalse,
        );
      },
    );

    test(
      'backfillGroupCurrencies sets every null-currency group to the chosen currency',
      () async {
        final v3 = _openV3Database();
        final db = AppDatabase.forTesting(NativeDatabase.opened(v3));
        addTearDown(db.close);
        final repository = LedgerRepository(
          database: db,
          signingKeyService: SigningKeyService(
            secureStorage: InMemorySecureKeyStorage(),
          ),
        );

        expect(await repository.needsCurrencyBackfill(), isTrue);
        await repository.backfillGroupCurrencies('EUR');
        expect(await repository.needsCurrencyBackfill(), isFalse);

        final groups = await db.select(db.accountGroups).get();
        expect(groups.every((g) => g.currency == 'EUR'), isTrue);
      },
    );

    test(
      'the pending_transfers table exists and is usable after the upgrade',
      () async {
        final v3 = _openV3Database();
        final db = AppDatabase.forTesting(NativeDatabase.opened(v3));
        addTearDown(db.close);

        expect(await db.select(db.pendingTransfers).get(), isEmpty);
      },
    );
  });

  group('onUpgrade from schemaVersion 2', () {
    test(
      'seeds the four system groups and the equity account with sane timestamps',
      () async {
        final v2 = _openV2Database();
        final db = AppDatabase.forTesting(NativeDatabase.opened(v2));
        addTearDown(db.close);

        final groups = await db.select(db.accountGroups).get();
        expect(
          groups.map((g) => g.id),
          unorderedEquals(<String>[
            groupCashEquivalentsId,
            groupPensionRetirementId,
            groupCreditShortTermId,
            groupLoansMortgagesId,
          ]),
        );
        expect(groups.every((g) => g.isSystem), isTrue);

        final equity =
            await (db.select(db.accounts)
                  ..where((a) => a.id.equals(openingBalanceEquityAccountId)))
                .getSingle();
        expect(equity.type, equals(AccountType.equity));
        expect(equity.groupId, isNull);

        // Regression for the seconds-vs-milliseconds bug: a corrupted
        // (1000x too large) timestamp would round-trip to a DateTime far
        // outside any sane range once Drift decodes the stored int back
        // via DateTime.fromMillisecondsSinceEpoch(storedSeconds * 1000).
        final now = DateTime.now();
        for (final createdAt in [
          ...groups.map((g) => g.createdAt),
          equity.createdAt,
        ]) {
          expect(
            createdAt.difference(now).abs(),
            lessThan(const Duration(minutes: 5)),
            reason:
                'created_at should be "now", not corrupted by a unit mismatch',
          );
        }
      },
    );

    test(
      'backfills an existing single asset account into Cash & cash equivalents',
      () async {
        final v2 = _openV2Database();
        v2.execute('''
          INSERT INTO accounts (id, name, type, created_at)
          VALUES ('legacy-asset', 'Cash & Bank', 'asset', 0);
        ''');

        final db = AppDatabase.forTesting(NativeDatabase.opened(v2));
        addTearDown(db.close);

        final legacy = await (db.select(
          db.accounts,
        )..where((a) => a.id.equals('legacy-asset'))).getSingle();
        expect(legacy.groupId, equals(groupCashEquivalentsId));
      },
    );

    test(
      'the backfilled legacy account is queryable through the Repository',
      () async {
        final v2 = _openV2Database();
        v2.execute('''
          INSERT INTO accounts (id, name, type, created_at)
          VALUES ('legacy-asset', 'Cash & Bank', 'asset', 0);
        ''');

        final db = AppDatabase.forTesting(NativeDatabase.opened(v2));
        addTearDown(db.close);
        final repository = LedgerRepository(
          database: db,
          signingKeyService: SigningKeyService(
            secureStorage: InMemorySecureKeyStorage(),
          ),
        );

        final accounts = await repository.watchFinancialAccounts().first;
        final legacy = accounts.firstWhere((a) => a.id == 'legacy-asset');
        expect(legacy.groupId, equals(groupCashEquivalentsId));
        expect(await repository.displayBalanceMinor('legacy-asset'), equals(0));
      },
    );
  });

  group('onUpgrade from schemaVersion 1', () {
    test(
      'an empty v1 database upgrades cleanly and is fully usable afterward',
      () async {
        final v1 = _openV1Database();
        final db = AppDatabase.forTesting(NativeDatabase.opened(v1));
        addTearDown(db.close);
        final repository = LedgerRepository(
          database: db,
          signingKeyService: SigningKeyService(
            secureStorage: InMemorySecureKeyStorage(),
          ),
        );

        // The migration itself succeeds simply by opening the database
        // without throwing - exercised by this first query.
        expect(await repository.watchCategories().first, isEmpty);

        final generated = await repository.generateFirstIdentity();
        await repository.confirmFirstIdentity(generated, currency: 'USD');

        final categories = await repository.watchCategories().first;
        final incomeId = categories
            .firstWhere((a) => a.type.name == 'income')
            .id;
        final accounts = await repository.watchFinancialAccounts().first;
        await repository.recordTransaction(
          amountMinor: 1000,
          direction: TransactionDirection.moneyIn,
          categoryId: incomeId,
          financialAccountId: accounts.first.id,
          transactionDate: DateTime(2026, 1, 15),
        );

        final result = await repository.verifyChain();
        expect(result.isFullyVerified, isTrue);
      },
    );

    test(
      'a v1 database with existing journal_entries rows refuses to upgrade',
      () async {
        final v1 = _openV1Database();
        v1.execute('''
          INSERT INTO accounts (id, name, type, created_at)
          VALUES ('acct-1', 'Cash & Bank', 'asset', 0);
          INSERT INTO journal_entries (id, transaction_date, recorded_at, created_at)
          VALUES ('entry-1', '2026-01-01', 0, 0);
        ''');

        final db = AppDatabase.forTesting(NativeDatabase.opened(v1));
        addTearDown(db.close);

        await expectLater(
          db.customSelect('SELECT 1').getSingle(),
          throwsStateError,
        );
      },
    );
  });
}
