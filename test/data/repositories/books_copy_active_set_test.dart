import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smara_accounting/data/books_set/books_set_paths.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/database/tables/accounts_table.dart';
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/data/repositories/books_copy_repository.dart';
import 'package:smara_accounting/data/repositories/books_set_repository.dart';
import 'package:smara_accounting/data/repositories/category_repository.dart';
import 'package:smara_accounting/data/repositories/identity_repository.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/data/repositories/settings_repository.dart';
import 'package:smara_accounting/domain/backup/books_copy_file.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';

import '../../domain/crypto/in_memory_secure_key_storage.dart';

void main() {
  late Directory tempDir;
  late BooksSetStore store;
  late InMemorySecureKeyStorage secureStorage;
  late BooksSetRepository booksSets;
  late SettingsRepository settings;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('smara-books-copy-active-');
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    store = BooksSetStore();
    secureStorage = InMemorySecureKeyStorage();
    booksSets = BooksSetRepository(
      supportDirectory: tempDir,
      store: store,
      secureStorage: secureStorage,
    );
    settings = SettingsRepository(booksSetStore: store);
  });

  tearDown(() async {
    await booksSets.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  Future<void> seedEntry({
    required AppDatabase db,
    required SigningKeyService keys,
    required String description,
  }) async {
    final ledger = LedgerRepository(database: db, signingKeyService: keys);
    final accounts = AccountRepository(database: db, ledgerRepository: ledger);
    final categories = CategoryRepository(database: db);
    final identity = IdentityRepository(
      database: db,
      accountRepository: accounts,
      signingKeyService: keys,
    );
    final generated = await identity.generateFirstIdentity();
    await identity.confirmFirstIdentity(generated, currency: 'USD');
    final financial = (await accounts.watchFinancialAccounts().first).first;
    final expense = (await categories.watchCategories().first).firstWhere(
      (a) => a.type == AccountType.expense,
    );
    await ledger.recordTransaction(
      transactionDate: DateTime.utc(2026, 2, 1),
      amountMinor: 700,
      direction: TransactionDirection.moneyOut,
      financialAccountId: financial.id,
      categoryId: expense.id,
      description: description,
    );
  }

  test('Books Copy from set A does not include set B entries', () async {
    final a = await booksSets.createSet(displayName: 'A', id: 'set-a');
    final keysA = booksSets.signingKeyServiceFor(a.id);
    await seedEntry(
      db: booksSets.activeDatabase!,
      keys: keysA,
      description: 'only-in-a',
    );

    final b = await booksSets.createSet(displayName: 'B', id: 'set-b');
    final keysB = booksSets.signingKeyServiceFor(b.id);
    await seedEntry(
      db: booksSets.activeDatabase!,
      keys: keysB,
      description: 'only-in-b',
    );

    // Active is B. Switch to A and save a copy — must contain only A.
    final dbA = await booksSets.switchActiveSet('set-a');
    final identityA = IdentityRepository(
      database: dbA,
      signingKeyService: keysA,
    );
    final copyRepo = BooksCopyRepository(
      database: dbA,
      identityRepository: identityA,
      settingsRepository: settings,
      signingKeyService: keysA,
    );
    final encoded = await copyRepo.saveBooksCopy(
      passphrase: 'passphrase-a',
      databaseFile: BooksSetPaths.databaseFile(tempDir, 'set-a'),
    );

    final contents = await BooksCopyFile.decrypt(
      fileContents: encoded,
      passphrase: 'passphrase-a',
    );
    final inspectFile = File(p.join(tempDir.path, 'inspect-a.sqlite'));
    await inspectFile.writeAsBytes(contents.databaseBytes);
    final inspectDb = AppDatabase.openFile(inspectFile);
    try {
      final entries = await inspectDb.select(inspectDb.journalEntries).get();
      expect(entries, hasLength(1));
      expect(entries.single.description, 'only-in-a');
      expect(entries.any((e) => e.description == 'only-in-b'), isFalse);
    } finally {
      await inspectDb.close();
    }
  });

  test('backup reminder counters are keyed by active books set', () async {
    await booksSets.createSet(displayName: 'A', id: 'set-a');
    await settings.recordBooksCopySaved(
      at: DateTime.utc(2026, 3, 1),
      entryCount: 3,
    );
    expect(await settings.entryCountAtLastCopy(), 3);

    await booksSets.createSet(displayName: 'B', id: 'set-b');
    // Set B has no copy recorded yet.
    expect(await settings.entryCountAtLastCopy(), 0);
    expect(await settings.lastCopySavedAt(), isNull);

    await settings.recordBooksCopySaved(
      at: DateTime.utc(2026, 3, 2),
      entryCount: 9,
    );
    expect(await settings.entryCountAtLastCopy(), 9);

    await booksSets.switchActiveSet('set-a');
    expect(await settings.entryCountAtLastCopy(), 3);
    expect(
      (await settings.lastCopySavedAt())!.toUtc(),
      DateTime.utc(2026, 3, 1),
    );
  });
}
