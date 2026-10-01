import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smara_accounting/data/books_set/books_set_paths.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/database/tables/accounts_table.dart';
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/data/repositories/books_set_repository.dart';
import 'package:smara_accounting/data/repositories/category_repository.dart';
import 'package:smara_accounting/data/repositories/identity_repository.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';

import '../../domain/crypto/in_memory_secure_key_storage.dart';

void main() {
  late Directory tempDir;
  late BooksSetStore store;
  late InMemorySecureKeyStorage secureStorage;
  late BooksSetRepository repository;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('smara-books-set-repo-');
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    store = BooksSetStore();
    secureStorage = InMemorySecureKeyStorage();
    repository = BooksSetRepository(
      supportDirectory: tempDir,
      store: store,
      secureStorage: secureStorage,
    );
  });

  tearDown(() async {
    await repository.close();
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  Future<void> seedBooksWithEntry({
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
      transactionDate: DateTime.utc(2026, 1, 1),
      amountMinor: 500,
      direction: TransactionDirection.moneyOut,
      financialAccountId: financial.id,
      categoryId: expense.id,
      description: description,
    );
  }

  test('create, list, rename, switch, and remove sets', () async {
    final a = await repository.createSet(displayName: 'Household');
    expect(a.isActive, isTrue);
    expect(await store.activeBooksSetId(), a.id);

    final b = await repository.createSet(displayName: 'Travel');
    expect(b.isActive, isTrue);
    expect(await store.activeBooksSetId(), b.id);

    var listed = await repository.listSets();
    expect(listed, hasLength(2));
    expect(listed.map((s) => s.displayName).toSet(), {'Household', 'Travel'});

    await repository.renameSet(a.id, 'My household');
    listed = await repository.listSets();
    expect(listed.firstWhere((s) => s.id == a.id).displayName, 'My household');

    await repository.switchActiveSet(a.id);
    expect(await store.activeBooksSetId(), a.id);
    listed = await repository.listSets();
    expect(listed.firstWhere((s) => s.id == a.id).isActive, isTrue);
    expect(listed.firstWhere((s) => s.id == b.id).isActive, isFalse);

    await repository.removeSet(b.id, confirmed: true);
    listed = await repository.listSets();
    expect(listed, hasLength(1));
    expect(listed.single.id, a.id);
    expect(
      BooksSetPaths.booksSetDirectory(tempDir, b.id).existsSync(),
      isFalse,
    );
  });

  test('two sets keep entries and signing keys independent', () async {
    final setA = await repository.createSet(displayName: 'Set A', id: 'set-a');
    final keysA = repository.signingKeyServiceFor(setA.id);
    await seedBooksWithEntry(
      db: repository.activeDatabase!,
      keys: keysA,
      description: 'only-in-a',
    );
    final publicA = (await keysA.loadStoredKeyMaterial())!.publicKey;

    final setB = await repository.createSet(displayName: 'Set B', id: 'set-b');
    final keysB = repository.signingKeyServiceFor(setB.id);
    await seedBooksWithEntry(
      db: repository.activeDatabase!,
      keys: keysB,
      description: 'only-in-b',
    );
    final publicB = (await keysB.loadStoredKeyMaterial())!.publicKey;

    expect(publicA, isNot(equals(publicB)));
    expect(
      await secureStorage.read(SigningKeyService.storageKeyFor('set-a')),
      isNotNull,
    );
    expect(
      await secureStorage.read(SigningKeyService.storageKeyFor('set-b')),
      isNotNull,
    );

    // Switch back to A: entries and key remain A's.
    final dbA = await repository.switchActiveSet('set-a');
    final entriesA = await dbA.select(dbA.journalEntries).get();
    expect(entriesA, hasLength(1));
    expect(entriesA.single.description, 'only-in-a');
    expect((await keysA.loadStoredKeyMaterial())!.publicKey, publicA);

    final dbB = await repository.switchActiveSet('set-b');
    final entriesB = await dbB.select(dbB.journalEntries).get();
    expect(entriesB, hasLength(1));
    expect(entriesB.single.description, 'only-in-b');
    expect((await keysB.loadStoredKeyMaterial())!.publicKey, publicB);

    // Removing B deletes B's key and directory; A is untouched.
    await repository.switchActiveSet('set-a');
    await repository.removeSet('set-b', confirmed: true);
    expect(
      await secureStorage.read(SigningKeyService.storageKeyFor('set-b')),
      isNull,
    );
    expect(
      await secureStorage.read(SigningKeyService.storageKeyFor('set-a')),
      isNotNull,
    );
    final stillA = await repository.activeDatabase!
        .select(repository.activeDatabase!.journalEntries)
        .get();
    expect(stillA.single.description, 'only-in-a');
  });
}
