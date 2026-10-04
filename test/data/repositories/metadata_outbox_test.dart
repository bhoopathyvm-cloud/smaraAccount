import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/database/tables/accounts_table.dart';
import 'package:smara_accounting/data/repositories/category_repository.dart';
import 'package:smara_accounting/data/repositories/identity_repository.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/data/repositories/metadata_outbox.dart';
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/data/repositories/personal_claim_limit_repository.dart';
import 'package:smara_accounting/data/repositories/recurring_template_repository.dart';
import 'package:smara_accounting/data/repositories/sync_merge_repository.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/models/account_group_kind.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:smara_accounting/domain/peer_sync/sync_payloads.dart';
import 'package:test/test.dart';

import '../../domain/crypto/in_memory_secure_key_storage.dart';

void main() {
  test(
    'category rename emits MetadataOperation that a second DB applies',
    () async {
      final keysA = SigningKeyService(
        secureStorage: InMemorySecureKeyStorage(),
      );
      final dbA = AppDatabase.forTesting(NativeDatabase.memory());
      final ledgerA = LedgerRepository(database: dbA, signingKeyService: keysA);
      final accountsA = AccountRepository(
        database: dbA,
        ledgerRepository: ledgerA,
      );
      final identityA = IdentityRepository(
        database: dbA,
        accountRepository: accountsA,
        signingKeyService: keysA,
      );
      final outboxA = MetadataOutbox(database: dbA);
      final categoriesA = CategoryRepository(
        database: dbA,
        metadataOutbox: outboxA,
        currentIdentityId: () async =>
            (await identityA.currentIdentity())?.identityId,
      );
      final generated = await identityA.generateFirstIdentity();
      await identityA.confirmFirstIdentity(generated, currency: 'USD');

      final categories = await categoriesA.watchCategories().first;
      final groceries = categories.firstWhere((c) => c.name == 'Groceries');
      await categoriesA.renameCategory(id: groceries.id, newName: 'Food shop');

      final ops = await outboxA.listAll();
      expect(ops, isNotEmpty);
      final rename = ops.lastWhere(
        (o) => o.entityType == 'category' && o.field == 'name',
      );
      expect(rename.entityId, groceries.id);
      expect(rename.value, 'Food shop');

      // Second database applies the op via SyncMergeRepository.
      final keysB = SigningKeyService(
        secureStorage: InMemorySecureKeyStorage(),
      );
      final dbB = AppDatabase.forTesting(NativeDatabase.memory());
      final ledgerB = LedgerRepository(database: dbB, signingKeyService: keysB);
      final accountsB = AccountRepository(
        database: dbB,
        ledgerRepository: ledgerB,
      );
      final identityB = IdentityRepository(
        database: dbB,
        accountRepository: accountsB,
        signingKeyService: keysB,
      );
      final categoriesB = CategoryRepository(database: dbB);
      final mergeB = SyncMergeRepository(
        database: dbB,
        signingKeyService: keysB,
      );
      final generatedB = await identityB.generateFirstIdentity();
      await identityB.confirmFirstIdentity(generatedB, currency: 'USD');

      // Seed the same category id on B (books already linked).
      await dbB
          .into(dbB.accounts)
          .insertOnConflictUpdate(
            AccountsCompanion.insert(
              id: Value(groceries.id),
              name: 'Groceries',
              type: AccountType.expense,
            ),
          );

      await mergeB.applyMetadataOps(MetadataOps(operations: [rename]));

      final onB = await categoriesB
          .watchCategories(includeArchived: true)
          .first;
      expect(onB.firstWhere((c) => c.id == groceries.id).name, 'Food shop');

      await dbA.close();
      await dbB.close();
    },
  );

  test(
    'group create, template, and personal limit emit ops a second DB applies',
    () async {
      final keysA = SigningKeyService(
        secureStorage: InMemorySecureKeyStorage(),
      );
      final dbA = AppDatabase.forTesting(NativeDatabase.memory());
      final ledgerA = LedgerRepository(database: dbA, signingKeyService: keysA);
      final outboxA = MetadataOutbox(database: dbA);
      final accountsA = AccountRepository(
        database: dbA,
        ledgerRepository: ledgerA,
        metadataOutbox: outboxA,
        currentIdentityId: () async => 'id-a',
      );
      final identityA = IdentityRepository(
        database: dbA,
        accountRepository: accountsA,
        signingKeyService: keysA,
      );
      final generated = await identityA.generateFirstIdentity();
      await identityA.confirmFirstIdentity(generated, currency: 'EUR');
      final identityId = (await identityA.currentIdentity())!.identityId;

      final accountsWired = AccountRepository(
        database: dbA,
        ledgerRepository: ledgerA,
        metadataOutbox: outboxA,
        currentIdentityId: () async => identityId,
      );
      final group = await accountsWired.createAccountGroup(
        name: 'Travel float',
        kind: AccountGroupKind.assetGroup,
        currency: 'EUR',
      );

      final templates = RecurringTemplateRepository(
        database: dbA,
        ledgerRepository: ledgerA,
        metadataOutbox: outboxA,
        currentIdentityId: () async => identityId,
      );
      final categories = await CategoryRepository(
        database: dbA,
      ).watchCategories().first;
      final hotel = categories.firstWhere((c) => c.name == 'Groceries');
      final financials = await accountsWired.watchFinancialAccounts().first;
      final cash = financials.first;
      final template = await templates.createRecurringTemplate(
        name: 'Rent',
        direction: TransactionDirection.moneyOut,
        financialAccountId: cash.id,
        categoryId: hotel.id,
        amountMinor: 50000,
        dayOfMonth: 1,
      );

      final limits = PersonalClaimLimitRepository(
        database: dbA,
        metadataOutbox: outboxA,
      );
      await limits.setLimit(
        personDeviceId: 'device-ravi',
        categoryId: hotel.id,
        amountMinor: 12000,
        unitLabel: 'per night',
        updatedByIdentityId: identityId,
      );

      final ops = await outboxA.listAll();
      expect(
        ops.any(
          (o) =>
              o.entityType == 'account_group' &&
              o.entityId == group.id &&
              o.field == 'name',
        ),
        isTrue,
      );
      expect(
        ops.any(
          (o) =>
              o.entityType == 'recurring_template' &&
              o.entityId == template.id &&
              o.field == 'name',
        ),
        isTrue,
      );
      expect(
        ops.any(
          (o) =>
              o.entityType == 'personal_claim_limit' &&
              o.field == 'amountMinor' &&
              o.value == 12000,
        ),
        isTrue,
      );

      final keysB = SigningKeyService(
        secureStorage: InMemorySecureKeyStorage(),
      );
      final dbB = AppDatabase.forTesting(NativeDatabase.memory());
      final mergeB = SyncMergeRepository(
        database: dbB,
        signingKeyService: keysB,
      );
      await mergeB.applyMetadataOps(MetadataOps(operations: ops));

      final groupOnB = await (dbB.select(
        dbB.accountGroups,
      )..where((g) => g.id.equals(group.id))).getSingleOrNull();
      expect(groupOnB?.name, 'Travel float');
      expect(groupOnB?.currency, 'EUR');

      final templateOnB = await (dbB.select(
        dbB.recurringTemplates,
      )..where((t) => t.id.equals(template.id))).getSingleOrNull();
      expect(templateOnB?.name, 'Rent');
      expect(templateOnB?.amountMinor, 50000);

      final limitOnB =
          await (dbB.select(dbB.personalClaimLimits)..where(
                (t) =>
                    t.personDeviceId.equals('device-ravi') &
                    t.categoryId.equals(hotel.id),
              ))
              .getSingleOrNull();
      expect(limitOnB?.amountMinor, 12000);
      expect(limitOnB?.unitLabel, 'per night');

      await dbA.close();
      await dbB.close();
    },
  );

  test(
    'an older incoming rename does not overwrite a newer local one',
    () async {
      // Household run on real iPhones: phone A renamed Groceries after the
      // Mac did, then the Mac's older rename arrived and replaced phone A's
      // own name on phone A, because local edits were left out of the merge.
      final keys = SigningKeyService(secureStorage: InMemorySecureKeyStorage());
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final ledger = LedgerRepository(database: db, signingKeyService: keys);
      final accounts = AccountRepository(
        database: db,
        ledgerRepository: ledger,
      );
      final identity = IdentityRepository(
        database: db,
        accountRepository: accounts,
        signingKeyService: keys,
      );
      final outbox = MetadataOutbox(database: db);
      final categories = CategoryRepository(
        database: db,
        metadataOutbox: outbox,
        currentIdentityId: () async =>
            (await identity.currentIdentity())?.identityId,
      );
      final merge = SyncMergeRepository(
        database: db,
        signingKeyService: keys,
        metadataOutbox: outbox,
      );
      await identity.confirmFirstIdentity(
        await identity.generateFirstIdentity(),
        currency: 'USD',
      );
      final groceries = (await categories.watchCategories().first).firstWhere(
        (c) => c.name == 'Groceries',
      );

      // An earlier sync fills the merge's in-memory winners...
      await merge.applyMetadataOps(
        MetadataOps(
          operations: [
            MetadataOperation(
              entityType: 'settings',
              entityId: 'books',
              field: 'defaultCategoryLocale',
              value: 'en',
              updatedAt: DateTime.now().toUtc(),
              updatedByIdentityId: 'mac-identity',
              hlcDeviceId: 'mac',
            ),
          ],
        ),
      );
      // ...then this device renames, saving its winner to the database...
      await categories.renameCategory(
        id: groceries.id,
        newName: 'Supermarket (phone A)',
      );
      // ...and the Mac's older rename arrives.
      await merge.applyMetadataOps(
        MetadataOps(
          operations: [
            MetadataOperation(
              entityType: 'category',
              entityId: groceries.id,
              field: 'name',
              value: 'Food (Mac)',
              updatedAt: DateTime.now().toUtc().subtract(
                const Duration(minutes: 1),
              ),
              updatedByIdentityId: 'mac-identity',
              hlcDeviceId: 'mac',
            ),
          ],
        ),
      );

      final after = (await categories.watchCategories().first).firstWhere(
        (c) => c.id == groceries.id,
      );
      expect(after.name, 'Supermarket (phone A)');
    },
  );

  test('a joined device gets the starter categories, and its rename survives '
      'the host baseline', () async {
    Future<
      ({
        AppDatabase db,
        CategoryRepository categories,
        SyncMergeRepository merge,
        IdentityRepository identity,
      })
    >
    device({required bool starter}) async {
      final keys = SigningKeyService(secureStorage: InMemorySecureKeyStorage());
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final ledger = LedgerRepository(database: db, signingKeyService: keys);
      final accounts = AccountRepository(
        database: db,
        ledgerRepository: ledger,
      );
      final identity = IdentityRepository(
        database: db,
        accountRepository: accounts,
        signingKeyService: keys,
      );
      final outbox = MetadataOutbox(database: db);
      await identity.confirmFirstIdentity(
        await identity.generateFirstIdentity(),
        currency: 'USD',
        seedStarterCategories: starter,
      );
      return (
        db: db,
        categories: CategoryRepository(
          database: db,
          metadataOutbox: outbox,
          currentIdentityId: () async =>
              (await identity.currentIdentity())?.identityId,
        ),
        merge: SyncMergeRepository(
          database: db,
          signingKeyService: keys,
          metadataOutbox: outbox,
        ),
        identity: identity,
      );
    }

    final mac = await device(starter: true);
    final phone = await device(starter: false);
    Future<void> phoneReceivesFromMac() async => phone.merge.applyMetadataOps(
      MetadataOps(operations: await mac.merge.pendingMetadataOperations()),
    );

    // Starter categories are seeded without outbox ops; the baseline
    // still delivers them.
    expect(await phone.categories.watchCategories().first, isEmpty);
    await phoneReceivesFromMac();
    final groceries = (await phone.categories.watchCategories().first)
        .firstWhere((c) => c.name == 'Groceries');

    // The phone renames, then hears the Mac's baseline again.
    await phone.categories.renameCategory(
      id: groceries.id,
      newName: 'Supermarket (phone A)',
    );
    await phoneReceivesFromMac();
    final after = (await phone.categories.watchCategories().first).firstWhere(
      (c) => c.id == groceries.id,
    );
    expect(after.name, 'Supermarket (phone A)');

    // A joined phone has no Cash & Bank of its own (it gets the Mac's).
    final phoneCash = await (phone.db.select(
      phone.db.accounts,
    )..where((a) => a.name.equals('Cash & Bank'))).get();
    expect(phoneCash, hasLength(1));
  });
}
