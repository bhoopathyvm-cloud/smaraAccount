import 'package:drift/native.dart';
import 'package:smara_accounting/data/database/app_database.dart';
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

void main() {
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
        await repository.recordTransaction(
          amountMinor: 1000,
          direction: TransactionDirection.moneyIn,
          categoryId: incomeId,
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
