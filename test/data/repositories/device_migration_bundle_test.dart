import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/data/repositories/category_repository.dart';
import 'package:smara_accounting/data/repositories/device_migration_bundle_repository.dart';
import 'package:smara_accounting/data/repositories/identity_repository.dart';
import 'package:smara_accounting/data/repositories/ledger_chain_verifier.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/domain/backup/device_migration_bundle_file.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/exceptions.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:test/test.dart';

import '../../domain/crypto/in_memory_secure_key_storage.dart';

/// Exercises real file-backed databases (not `NativeDatabase.memory()`),
/// same reasoning as `ledger_backup_restore_test.dart` - export/import's
/// whole point is operating on the on-disk database file.
void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('smara-bundle-test-');
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  File fileNamed(String name) => File(p.join(tempDir.path, name));

  Future<
    ({
      LedgerRepository repository,
      AccountRepository accountRepository,
      CategoryRepository categoryRepository,
      IdentityRepository identityRepository,
      LedgerChainVerifier chainVerifier,
      DeviceMigrationBundleRepository bundleRepository,
      InMemorySecureKeyStorage secureStorage,
    })
  >
  openRepository(File file, {InMemorySecureKeyStorage? secureStorage}) async {
    final db = AppDatabase.openFile(file);
    final storage = secureStorage ?? InMemorySecureKeyStorage();
    final keys = SigningKeyService(secureStorage: storage);
    final repository = LedgerRepository(database: db, signingKeyService: keys);
    final accountRepository = AccountRepository(
      database: db,
      ledgerRepository: repository,
    );
    final identityRepository = IdentityRepository(
      database: db,
      accountRepository: accountRepository,
      signingKeyService: keys,
    );
    final chainVerifier = LedgerChainVerifier(
      database: db,
      signingKeyService: keys,
    );
    return (
      repository: repository,
      accountRepository: accountRepository,
      categoryRepository: CategoryRepository(database: db),
      identityRepository: identityRepository,
      chainVerifier: chainVerifier,
      bundleRepository: DeviceMigrationBundleRepository(
        database: db,
        identityRepository: identityRepository,
        signingKeyService: keys,
      ),
      secureStorage: storage,
    );
  }

  Future<
    ({
      LedgerRepository repository,
      AccountRepository accountRepository,
      CategoryRepository categoryRepository,
      IdentityRepository identityRepository,
      LedgerChainVerifier chainVerifier,
      DeviceMigrationBundleRepository bundleRepository,
      InMemorySecureKeyStorage secureStorage,
    })
  >
  seedRepository(File file) async {
    final opened = await openRepository(file);
    final repository = opened.repository;
    final generated = await opened.identityRepository.generateFirstIdentity();
    await opened.identityRepository.confirmFirstIdentity(
      generated,
      currency: 'USD',
    );
    final account =
        (await opened.accountRepository.watchFinancialAccounts().first).first;
    final category =
        (await opened.categoryRepository.watchCategories().first).first;
    await repository.recordTransaction(
      amountMinor: 5000,
      direction: TransactionDirection.moneyIn,
      categoryId: category.id,
      financialAccountId: account.id,
      transactionDate: DateTime(2026, 1, 1),
    );
    return opened;
  }

  test(
    'export then import onto a fresh device reproduces the exact ledger '
    'state, fully verified, and ready to record a new entry immediately',
    () async {
      final sourceFile = fileNamed('source.sqlite');
      final sourceOpened = await seedRepository(sourceFile);
      final source = sourceOpened.repository;

      final bundleContents = await sourceOpened.bundleRepository.exportBundle(
        passphrase: 'correct horse battery staple',
        databaseFile: sourceFile,
      );
      await source.close();

      final targetFile = fileNamed('target.sqlite');
      final freshDeviceOpened = await openRepository(targetFile);
      await freshDeviceOpened.bundleRepository.importBundle(
        fileContents: bundleContents,
        passphrase: 'correct horse battery staple',
        targetFile: targetFile,
      );
      // freshDevice's connection is now closed by importBundle - open a
      // brand new one against the replaced file, exactly as the app
      // would do on the next launch, sharing the same secure storage
      // (the key was stored there by importBundle).
      final restoredOpened = await openRepository(
        targetFile,
        secureStorage: freshDeviceOpened.secureStorage,
      );
      final restored = restoredOpened.repository;

      final account =
          (await restoredOpened.accountRepository
                  .watchFinancialAccounts()
                  .first)
              .first;
      final entries = await restored.watchEntriesForAccount(account.id).first;
      expect(entries, hasLength(1));
      expect(entries.single.postings, hasLength(2));

      final verification = await restoredOpened.chainVerifier.verifyChain();
      expect(verification.isFullyVerified, isTrue);

      // Unlike a data-only ledger-backup restore, the matching private key
      // was restored too - recording works immediately, no further setup.
      final category =
          (await restoredOpened.categoryRepository.watchCategories().first)
              .first;
      await restored.recordTransaction(
        amountMinor: 100,
        direction: TransactionDirection.moneyOut,
        categoryId: category.id,
        financialAccountId: account.id,
        transactionDate: DateTime(2026, 1, 2),
      );
      final entriesAfter = await restored
          .watchEntriesForAccount(account.id)
          .first;
      expect(entriesAfter, hasLength(2));
    },
  );

  test(
    'import is rejected when the bundle identity differs from the '
    "device's own active identity, and the target file is left untouched",
    () async {
      final sourceFile = fileNamed('source.sqlite');
      final sourceOpened = await seedRepository(sourceFile);
      final bundleContents = await sourceOpened.bundleRepository.exportBundle(
        passphrase: 'passphrase-a',
        databaseFile: sourceFile,
      );
      await sourceOpened.repository.close();

      final targetFile = fileNamed('target.sqlite');
      final alreadySetUpOpened = await seedRepository(targetFile);
      final targetBytesBefore = await targetFile.readAsBytes();

      await expectLater(
        alreadySetUpOpened.bundleRepository.importBundle(
          fileContents: bundleContents,
          passphrase: 'passphrase-a',
          targetFile: targetFile,
        ),
        throwsA(isA<ForeignDeviceMigrationBundleIdentityException>()),
      );

      final targetBytesAfter = await targetFile.readAsBytes();
      expect(targetBytesAfter, equals(targetBytesBefore));
    },
  );

  test('import fails cleanly on the wrong passphrase, with no partial '
      'replacement', () async {
    final sourceFile = fileNamed('source.sqlite');
    final sourceOpened = await seedRepository(sourceFile);
    final bundleContents = await sourceOpened.bundleRepository.exportBundle(
      passphrase: 'the-real-passphrase',
      databaseFile: sourceFile,
    );
    await sourceOpened.repository.close();

    final targetFile = fileNamed('target.sqlite');
    final freshDeviceOpened = await openRepository(targetFile);

    await expectLater(
      freshDeviceOpened.bundleRepository.importBundle(
        fileContents: bundleContents,
        passphrase: 'a-wrong-passphrase',
        targetFile: targetFile,
      ),
      throwsA(anything),
    );

    final stillFresh = (await openRepository(targetFile)).identityRepository;
    expect(await stillFresh.currentIdentity(), isNull);
  });

  test('import is rejected when the bundle chain does not fully verify, '
      'and the target file is left untouched', () async {
    final sourceFile = fileNamed('source.sqlite');
    final sourceOpened = await seedRepository(sourceFile);
    await sourceOpened.repository.close();

    final tamperDb = AppDatabase.openFile(sourceFile);
    await tamperDb.customStatement(
      "UPDATE journal_entries SET entry_hash = "
      "X'0000000000000000000000000000000000000000000000000000000000000000'",
    );
    await tamperDb.close();

    // Reopen with the *same* secure storage as seedRepository used - the
    // private key lives there, not in the sqlite file, so a fresh
    // InMemorySecureKeyStorage here would leave this "device" with no
    // key to export a bundle with at all.
    final tamperedOpened = await openRepository(
      sourceFile,
      secureStorage: sourceOpened.secureStorage,
    );
    final bundleContents = await tamperedOpened.bundleRepository.exportBundle(
      passphrase: 'passphrase-a',
      databaseFile: sourceFile,
    );
    await tamperedOpened.repository.close();

    final targetFile = fileNamed('target.sqlite');
    final alreadySetUpOpened = await seedRepository(targetFile);
    final targetBytesBefore = await targetFile.readAsBytes();

    await expectLater(
      alreadySetUpOpened.bundleRepository.importBundle(
        fileContents: bundleContents,
        passphrase: 'passphrase-a',
        targetFile: targetFile,
      ),
      throwsA(isA<InvalidDeviceMigrationBundleException>()),
    );

    final targetBytesAfter = await targetFile.readAsBytes();
    expect(targetBytesAfter, equals(targetBytesBefore));
  });

  test('import is rejected when the bundle key does not match its own '
      'database, and the target file is left untouched', () async {
    final sourceFile = fileNamed('source.sqlite');
    final sourceOpened = await seedRepository(sourceFile);
    await sourceOpened.repository.close();

    final mismatchedBundle = await DeviceMigrationBundleFile.encrypt(
      databaseBytes: await sourceFile.readAsBytes(),
      privateKeySeed: List<int>.generate(32, (i) => i),
      passphrase: 'p',
    );

    final targetFile = fileNamed('target.sqlite');
    final freshDeviceOpened = await openRepository(targetFile);

    await expectLater(
      freshDeviceOpened.bundleRepository.importBundle(
        fileContents: mismatchedBundle,
        passphrase: 'p',
        targetFile: targetFile,
      ),
      throwsA(isA<InvalidDeviceMigrationBundleException>()),
    );

    final stillFresh = (await openRepository(
      targetFile,
      secureStorage: freshDeviceOpened.secureStorage,
    )).identityRepository;
    expect(await stillFresh.currentIdentity(), isNull);
  });
}
