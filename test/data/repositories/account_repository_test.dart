import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/database/tables/account_groups_table.dart';
import 'package:smara_accounting/data/database/tables/accounts_table.dart';
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/data/repositories/identity_repository.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:test/test.dart';

import '../../domain/crypto/in_memory_secure_key_storage.dart';

void main() {
  late AppDatabase db;
  late LedgerRepository ledgerRepository;
  late AccountRepository accountRepository;
  late IdentityRepository identityRepository;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final keys = SigningKeyService(secureStorage: InMemorySecureKeyStorage());
    ledgerRepository = LedgerRepository(database: db, signingKeyService: keys);
    accountRepository = AccountRepository(
      database: db,
      ledgerRepository: ledgerRepository,
    );
    identityRepository = IdentityRepository(
      database: db,
      accountRepository: accountRepository,
      signingKeyService: keys,
    );
    final generated = await identityRepository.generateFirstIdentity();
    await identityRepository.confirmFirstIdentity(generated, currency: 'USD');
  });

  tearDown(() async {
    await db.close();
  });

  group('watchAccountCurrencies / groupCurrencyFor', () {
    test('known account resolves its group currency', () async {
      final account =
          (await accountRepository.watchFinancialAccounts().first).first;
      final catalog = await accountRepository.watchAccountCurrencies().first;

      expect(catalog.currencyFor(account.id), 'USD');
      expect(await accountRepository.groupCurrencyFor(account.id), 'USD');
    });

    test('missing account is null', () async {
      final catalog = await accountRepository.watchAccountCurrencies().first;

      expect(catalog.currencyFor('missing-account'), isNull);
      expect(
        await accountRepository.groupCurrencyFor('missing-account'),
        isNull,
      );
    });

    test('group currency change updates the catalog', () async {
      final account =
          (await accountRepository.watchFinancialAccounts().first).first;
      final groupId = account.groupId!;
      final nextCatalog = accountRepository
          .watchAccountCurrencies()
          .skip(1)
          .first;

      await (db.update(db.accountGroups)..where((g) => g.id.equals(groupId)))
          .write(const AccountGroupsCompanion(currency: Value('EUR')));

      final catalog = await nextCatalog;
      expect(catalog.currencyFor(account.id), 'EUR');
      expect(await accountRepository.groupCurrencyFor(account.id), 'EUR');
    });

    test(
      'archived accounts appear only when includeArchived is true',
      () async {
        final assetGroup = (await accountRepository.watchAccountGroups().first)
            .firstWhere((g) => g.kind == AccountGroupKind.assetGroup);
        final extra = await accountRepository.createFinancialAccount(
          name: 'To archive',
          type: AccountType.asset,
          groupId: assetGroup.id,
        );
        await accountRepository.archiveFinancialAccount(extra.id);

        final active = await accountRepository.watchAccountCurrencies().first;
        final all = await accountRepository
            .watchAccountCurrencies(includeArchived: true)
            .first;

        expect(active.currencyFor(extra.id), isNull);
        expect(all.currencyFor(extra.id), 'USD');
      },
    );
  });
}
