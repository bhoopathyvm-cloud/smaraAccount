import 'package:drift/native.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/data/repositories/identity_repository.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:test/test.dart';

import '../../domain/crypto/in_memory_secure_key_storage.dart';

void main() {
  late AppDatabase db;
  late IdentityRepository identityRepository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final signingKeyService = SigningKeyService(
      secureStorage: InMemorySecureKeyStorage(),
    );
    final ledgerRepository = LedgerRepository(
      database: db,
      signingKeyService: signingKeyService,
    );
    identityRepository = IdentityRepository(
      database: db,
      accountRepository: AccountRepository(
        database: db,
        ledgerRepository: ledgerRepository,
      ),
      signingKeyService: signingKeyService,
    );
  });

  tearDown(() => db.close());

  Future<Map<String, int>> namesWithCounts() async {
    final counts = <String, int>{};
    for (final account in await db.select(db.accounts).get()) {
      counts[account.name] = (counts[account.name] ?? 0) + 1;
    }
    return counts;
  }

  test(
    'confirming the same first identity twice seeds the books once',
    () async {
      final generated = await identityRepository.generateFirstIdentity();

      final first = await identityRepository.confirmFirstIdentity(
        generated,
        currency: 'EUR',
      );
      final second = await identityRepository.confirmFirstIdentity(
        generated,
        currency: 'EUR',
      );

      expect(second.identityId, first.identityId);
      expect(await db.select(db.signingIdentities).get(), hasLength(1));
      final counts = await namesWithCounts();
      expect(counts.values.every((n) => n == 1), isTrue, reason: '$counts');
    },
  );

  test('two concurrent confirms (a double tap) seed the books once', () async {
    final generated = await identityRepository.generateFirstIdentity();

    final results = await Future.wait([
      identityRepository.confirmFirstIdentity(generated, currency: 'EUR'),
      identityRepository.confirmFirstIdentity(generated, currency: 'EUR'),
    ]);

    expect(results[0].identityId, results[1].identityId);
    expect(await db.select(db.signingIdentities).get(), hasLength(1));
    final counts = await namesWithCounts();
    expect(counts.values.every((n) => n == 1), isTrue, reason: '$counts');
  });
}
