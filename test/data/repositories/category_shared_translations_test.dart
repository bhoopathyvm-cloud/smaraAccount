import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/repositories/account_chart_reader.dart';
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/data/repositories/category_repository.dart';
import 'package:smara_accounting/data/repositories/identity_repository.dart';
import 'package:smara_accounting/data/repositories/ledger_chain_store.dart';
import 'package:smara_accounting/data/repositories/ledger_chain_verifier.dart';
import 'package:smara_accounting/data/repositories/ledger_posting.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/data/repositories/sync_merge_repository.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/models/account.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/domain/peer_sync/sync_payloads.dart';
import 'package:test/test.dart';

import '../../domain/crypto/in_memory_secure_key_storage.dart';

void main() {
  late AppDatabase db;
  late CategoryRepository categories;
  late AccountRepository accounts;
  late IdentityRepository identity;
  late LedgerRepository ledger;
  late LedgerPosting posting;
  late LedgerChainVerifier verifier;
  late SyncMergeRepository merge;
  late SigningKeyService keys;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    keys = SigningKeyService(secureStorage: InMemorySecureKeyStorage());
    final chain = LedgerChainStore(db);
    ledger = LedgerRepository(
      database: db,
      signingKeyService: keys,
      chain: chain,
    );
    accounts = AccountRepository(database: db, ledgerRepository: ledger);
    categories = CategoryRepository(database: db);
    identity = IdentityRepository(
      database: db,
      accountRepository: accounts,
      chain: chain,
      signingKeyService: keys,
    );
    posting = LedgerPosting(
      database: db,
      chart: AccountChartReader(db),
      chain: chain,
      entriesForAccount: (id) => ledger.watchEntriesForAccount(id).first,
      signingKeyService: keys,
    );
    verifier = LedgerChainVerifier(
      database: db,
      signingKeyService: keys,
      chain: chain,
    );
    merge = SyncMergeRepository(
      database: db,
      signingKeyService: keys,
      chain: chain,
      posting: posting,
    );

    await db
        .into(db.booksSetMetadata)
        .insert(
          BooksSetMetadataCompanion.insert(
            id: 'books-1',
            displayName: 'Household',
            defaultCategoryLocale: const Value('en'),
          ),
        );
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> seedNewSetup() async {
    final generated = await identity.generateFirstIdentity();
    await identity.confirmFirstIdentity(generated, currency: 'USD');
  }

  test('7.1 default locale + translation CRUD + display fallback', () async {
    await seedNewSetup();
    expect(await categories.defaultCategoryLocale(), 'en');
    await categories.setDefaultCategoryLocale('de');
    expect(await categories.defaultCategoryLocale(), 'de');

    final cats = await categories.watchCategories().first;
    final groceries = cats.firstWhere((c) => c.name == 'Groceries');
    await categories.setTranslation(
      categoryId: groceries.id,
      locale: 'de',
      name: 'Lebensmittel',
    );
    final translations = await categories.listTranslations(groceries.id);
    expect(translations.single.name, 'Lebensmittel');

    expect(
      await categories.displayNameFor(groceries, appLocale: 'de'),
      'Lebensmittel',
    );
    expect(
      await categories.displayNameFor(groceries, appLocale: 'fr'),
      'Groceries',
    );
  });

  test('7.1 translation sync via MetadataOps', () async {
    await seedNewSetup();
    final cats = await categories.watchCategories().first;
    final groceries = cats.firstWhere((c) => c.name == 'Groceries');

    await merge.applyMetadataOps(
      MetadataOps(
        operations: [
          MetadataOperation(
            entityType: 'category_translation',
            entityId: groceries.id,
            field: 'fr',
            value: 'Épicerie',
            updatedAt: DateTime.utc(2026, 5, 1),
            updatedByIdentityId: 'peer-1',
          ),
          MetadataOperation(
            entityType: 'settings',
            entityId: 'books',
            field: 'defaultCategoryLocale',
            value: 'fr',
            updatedAt: DateTime.utc(2026, 5, 1),
            updatedByIdentityId: 'peer-1',
          ),
        ],
      ),
    );

    expect(await categories.defaultCategoryLocale(), 'fr');
    expect(
      await categories.displayNameFor(groceries, appLocale: 'fr'),
      'Épicerie',
    );
    expect(merge.appliedBooksSettings['defaultCategoryLocale'], 'fr');
  });

  test('7.3 merge map rolls up totals; postings keep original ids', () async {
    await seedNewSetup();
    final financialId =
        (await accounts.watchFinancialAccounts().first).first.id;
    final cats = await categories.watchCategories().first;
    final groceries = cats.firstWhere((c) => c.name == 'Groceries');

    await categories.addCategory(
      name: 'Lebensmittel',
      type: AccountType.expense,
    );
    final afterAdd = await categories
        .watchCategories(includeMerged: true)
        .first;
    final lebensmittel = afterAdd.firstWhere((c) => c.name == 'Lebensmittel');

    await posting.recordTransaction(
      financialAccountId: financialId,
      categoryId: groceries.id,
      amountMinor: 1000,
      direction: TransactionDirection.moneyOut,
      transactionDate: DateTime.utc(2026, 5, 2),
    );
    await posting.recordTransaction(
      financialAccountId: financialId,
      categoryId: lebensmittel.id,
      amountMinor: 500,
      direction: TransactionDirection.moneyOut,
      transactionDate: DateTime.utc(2026, 5, 3),
    );

    // Same German name on both after translation → auto-merge.
    await categories.setTranslation(
      categoryId: groceries.id,
      locale: 'de',
      name: 'Lebensmittel',
    );

    final listed = await categories.watchCategories().first;
    expect(
      listed.where((c) => c.id == lebensmittel.id || c.id == groceries.id),
      hasLength(1),
    );

    final map = await categories.mergeMap();
    final survivorId =
        map[lebensmittel.id] ?? map[groceries.id] ?? groceries.id;
    // The other id must be absorbed (or they are the same if somehow equal).
    expect(
      map.containsKey(lebensmittel.id) || map.containsKey(groceries.id),
      isTrue,
    );

    final totals = await categories
        .watchCategoryTotals(
          start: DateTime.utc(2026, 5, 1),
          end: DateTime.utc(2026, 5, 31),
        )
        .first;
    final groceriesTotal = totals.firstWhere((t) => t.categoryId == survivorId);
    expect(groceriesTotal.totalMinor, 1500);

    // Postings still reference original absorbed id.
    final postings = await db.select(db.postings).get();
    final absorbedId = map.keys.first;
    expect(postings.any((p) => p.accountId == absorbedId), isTrue);

    // Entry hashes still verify after merge.
    final result = await verifier.verifyChain();
    expect(result.isFullyVerified, isTrue);
  });

  test('7.3 manual merge keeps entry hashes valid', () async {
    await seedNewSetup();
    final financialId =
        (await accounts.watchFinancialAccounts().first).first.id;
    await categories.addCategory(name: 'Food A', type: AccountType.expense);
    await categories.addCategory(name: 'Food B', type: AccountType.expense);
    final cats = await categories.watchCategories().first;
    final a = cats.firstWhere((c) => c.name == 'Food A');
    final b = cats.firstWhere((c) => c.name == 'Food B');

    await posting.recordTransaction(
      financialAccountId: financialId,
      categoryId: b.id,
      amountMinor: 250,
      direction: TransactionDirection.moneyOut,
      transactionDate: DateTime.utc(2026, 5, 4),
    );

    await categories.mergeCategories(
      survivorCategoryId: a.id,
      absorbedCategoryId: b.id,
    );

    final map = await categories.mergeMap();
    expect(map[b.id], a.id);

    final totals = await categories
        .watchCategoryTotals(
          start: DateTime.utc(2026, 5, 1),
          end: DateTime.utc(2026, 5, 31),
        )
        .first;
    expect(totals.firstWhere((t) => t.categoryId == a.id).totalMinor, 250);

    final result = await verifier.verifyChain();
    expect(result.isFullyVerified, isTrue);
  });

  test('7.4 joining device skips starter categories', () async {
    final generated = await identity.generateFirstIdentity();
    await identity.confirmFirstIdentity(
      generated,
      currency: 'USD',
      seedStarterCategories: false,
    );

    final cats = await categories.watchCategories(includeArchived: true).first;
    expect(cats, isEmpty);

    // Host catalog arrives via MetadataOps / sync — add one received category.
    await categories.addCategory(
      name: 'Shared Rent',
      type: AccountType.expense,
    );
    final after = await categories.watchCategories().first;
    expect(after.map((c) => c.name), ['Shared Rent']);
    expect(after.any((c) => c.name == 'Groceries'), isFalse);
    expect(after.any((c) => c.name == 'Salary'), isFalse);
  });
}
