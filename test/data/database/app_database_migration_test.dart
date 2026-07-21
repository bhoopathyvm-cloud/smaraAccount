import 'package:drift/native.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/database/tables/account_groups_table.dart';
import 'package:smara_accounting/data/database/tables/accounts_table.dart';
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

void main() {
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
        await repository.confirmFirstIdentity(generated);

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
