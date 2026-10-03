import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/data/repositories/books_copy_repository.dart';
import 'package:smara_accounting/data/repositories/category_repository.dart';
import 'package:smara_accounting/data/repositories/identity_repository.dart';
import 'package:smara_accounting/data/repositories/ledger_chain_verifier.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/data/repositories/settings_repository.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/exceptions.dart';
import 'package:smara_accounting/domain/models/exchange_rate_provider.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';

import '../../domain/backup/legacy_backup_encrypt.dart';
import '../../domain/crypto/in_memory_secure_key_storage.dart';

/// File-backed databases only — save/restore operates on the on-disk file.
void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('smara-books-copy-test-');
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  File fileNamed(String name) => File(p.join(tempDir.path, name));

  Future<
    ({
      AppDatabase database,
      LedgerRepository repository,
      AccountRepository accountRepository,
      CategoryRepository categoryRepository,
      IdentityRepository identityRepository,
      LedgerChainVerifier chainVerifier,
      BooksCopyRepository booksCopyRepository,
      SettingsRepository settingsRepository,
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
    final settingsRepository = SettingsRepository();
    return (
      database: db,
      repository: repository,
      accountRepository: accountRepository,
      categoryRepository: CategoryRepository(database: db),
      identityRepository: identityRepository,
      chainVerifier: chainVerifier,
      booksCopyRepository: BooksCopyRepository(
        database: db,
        identityRepository: identityRepository,
        settingsRepository: settingsRepository,
        signingKeyService: keys,
      ),
      settingsRepository: settingsRepository,
      secureStorage: storage,
    );
  }

  Future<
    ({
      AppDatabase database,
      LedgerRepository repository,
      AccountRepository accountRepository,
      CategoryRepository categoryRepository,
      IdentityRepository identityRepository,
      LedgerChainVerifier chainVerifier,
      BooksCopyRepository booksCopyRepository,
      SettingsRepository settingsRepository,
      InMemorySecureKeyStorage secureStorage,
    })
  >
  seedRepository(File file, {InMemorySecureKeyStorage? secureStorage}) async {
    final opened = await openRepository(file, secureStorage: secureStorage);
    final generated = await opened.identityRepository.generateFirstIdentity();
    await opened.identityRepository.confirmFirstIdentity(
      generated,
      currency: 'USD',
    );
    final account =
        (await opened.accountRepository.watchFinancialAccounts().first).first;
    final category =
        (await opened.categoryRepository.watchCategories().first).first;
    await opened.repository.recordTransaction(
      amountMinor: 5000,
      direction: TransactionDirection.moneyIn,
      categoryId: category.id,
      financialAccountId: account.id,
      transactionDate: DateTime(2026, 1, 1),
    );
    return opened;
  }

  test(
    'save encrypts books and records last-copy time and entry count',
    () async {
      final sourceFile = fileNamed('source.sqlite');
      final source = await seedRepository(sourceFile);
      await source.settingsRepository.setReferenceRateLookupEnabled(true);
      await source.settingsRepository.setSelectedProvider(
        ExchangeRateProvider.openErApi,
      );

      final seedEncoded = await source.secureStorage.read(
        SigningKeyService.privateKeySeedStorageKey,
      );
      expect(seedEncoded, isNotNull);
      final seedBytes = base64Decode(seedEncoded!);

      final savedAt = DateTime.utc(2026, 3, 15, 12);
      final contents = await source.booksCopyRepository.saveBooksCopy(
        passphrase: 'correct horse battery staple',
        databaseFile: sourceFile,
        now: savedAt,
      );

      // Assert real secret material is absent — not the substrings
      // 'seed'/'privateKey', which random Base64 ciphertext can contain.
      expect(contents, isNot(contains(seedEncoded)));
      expect(contents, isNot(contains(String.fromCharCodes(seedBytes))));
      expect(
        await source.settingsRepository.lastCopySavedAt(),
        equals(savedAt),
      );
      expect(await source.settingsRepository.entryCountAtLastCopy(), equals(1));

      await source.repository.close();
    },
  );

  test('replacementCounts omits zero counts via nonZero', () async {
    final emptyFile = fileNamed('empty.sqlite');
    final empty = await openRepository(emptyFile);
    final emptyCounts = await empty.booksCopyRepository.replacementCounts();
    expect(emptyCounts.entries, equals(0));
    expect(emptyCounts.nonZero, isEmpty);
    await empty.repository.close();

    final seededFile = fileNamed('seeded.sqlite');
    final seeded = await seedRepository(seededFile);
    final counts = await seeded.booksCopyRepository.replacementCounts();
    expect(counts.entries, equals(1));
    expect(counts.financialAccounts, greaterThan(0));
    expect(counts.categories, greaterThan(0));
    expect(counts.nonZero.containsKey('entries'), isTrue);
    expect(counts.nonZero.containsKey('payees'), isFalse);
    await seeded.repository.close();
  });

  test('restore replaces books; foreign identity is allowed; device key is '
      'cleared so recording needs Continuation', () async {
    final sourceFile = fileNamed('source.sqlite');
    final source = await seedRepository(sourceFile);
    await source.settingsRepository.setReferenceRateLookupEnabled(true);
    await source.settingsRepository.setFirstWeekSetupCompleted(true);
    final copy = await source.booksCopyRepository.saveBooksCopy(
      passphrase: 'passphrase-a',
      databaseFile: sourceFile,
    );
    await source.repository.close();

    final targetFile = fileNamed('target.sqlite');
    final target = await seedRepository(targetFile);
    await target.settingsRepository.setPreferredLocaleTag('hi');
    await target.settingsRepository.setAppLockEnabled(true);
    await target.settingsRepository.setReferenceRateLookupEnabled(false);

    await target.booksCopyRepository.restoreBooksCopy(
      fileContents: copy,
      passphrase: 'passphrase-a',
      targetFile: targetFile,
    );

    final restored = await openRepository(
      targetFile,
      secureStorage: target.secureStorage,
    );
    final account =
        (await restored.accountRepository.watchFinancialAccounts().first).first;
    final entries = await restored.repository
        .watchEntriesForAccount(account.id)
        .first;
    expect(entries, hasLength(1));
    expect(entries.single.postings, hasLength(2));

    final verification = await restored.chainVerifier.verifyChain();
    expect(verification.isFullyVerified, isTrue);

    // Device settings stay; books settings come from the copy.
    expect(
      await restored.settingsRepository.preferredLocaleTag(),
      equals('hi'),
    );
    expect(await restored.settingsRepository.isAppLockEnabled(), isTrue);
    expect(
      await restored.settingsRepository.isReferenceRateLookupEnabled(),
      isTrue,
    );
    expect(
      await restored.settingsRepository.isFirstWeekSetupCompleted(),
      isTrue,
    );

    final category =
        (await restored.categoryRepository.watchCategories().first).first;
    await expectLater(
      restored.repository.recordTransaction(
        amountMinor: 100,
        direction: TransactionDirection.moneyOut,
        categoryId: category.id,
        financialAccountId: account.id,
        transactionDate: DateTime(2026, 1, 2),
      ),
      throwsStateError,
    );
    await restored.repository.close();
  });

  test(
    'tampered copy is refused and the target file is left untouched',
    () async {
      final sourceFile = fileNamed('source.sqlite');
      final source = await seedRepository(sourceFile);
      await source.repository.close();

      final tamperDb = AppDatabase.openFile(sourceFile);
      await tamperDb.customStatement(
        "UPDATE journal_entries SET entry_hash = "
        "X'0000000000000000000000000000000000000000000000000000000000000000'",
      );
      await tamperDb.close();

      final tampered = await openRepository(sourceFile);
      final copy = await tampered.booksCopyRepository.saveBooksCopy(
        passphrase: 'passphrase-a',
        databaseFile: sourceFile,
      );
      await tampered.repository.close();

      final targetFile = fileNamed('target.sqlite');
      final target = await seedRepository(targetFile);
      await target.settingsRepository.setReferenceRateLookupEnabled(false);
      final targetBytesBefore = await targetFile.readAsBytes();

      await expectLater(
        target.booksCopyRepository.restoreBooksCopy(
          fileContents: copy,
          passphrase: 'passphrase-a',
          targetFile: targetFile,
        ),
        throwsA(isA<InvalidLedgerBackupException>()),
      );

      expect(await targetFile.readAsBytes(), equals(targetBytesBefore));
      expect(
        await target.settingsRepository.isReferenceRateLookupEnabled(),
        isFalse,
      );
      await target.repository.close();
    },
  );

  test('wrong passphrase leaves the device untouched', () async {
    final sourceFile = fileNamed('source.sqlite');
    final source = await seedRepository(sourceFile);
    final copy = await source.booksCopyRepository.saveBooksCopy(
      passphrase: 'the-real-passphrase',
      databaseFile: sourceFile,
    );
    await source.repository.close();

    final targetFile = fileNamed('target.sqlite');
    final target = await openRepository(targetFile);
    await target.settingsRepository.setPreferredLocaleTag('ta');

    await expectLater(
      target.booksCopyRepository.restoreBooksCopy(
        fileContents: copy,
        passphrase: 'a-wrong-passphrase',
        targetFile: targetFile,
      ),
      throwsA(anything),
    );

    expect(await target.identityRepository.currentIdentity(), isNull);
    expect(await target.settingsRepository.preferredLocaleTag(), equals('ta'));
    await target.repository.close();
  });

  test(
    'legacy ledger backup restores the database and keeps device settings',
    () async {
      final sourceFile = fileNamed('source.sqlite');
      final source = await seedRepository(sourceFile);
      await source.repository.close();

      final legacy = await encryptLegacyLedgerBackup(
        databaseBytes: await sourceFile.readAsBytes(),
        passphrase: 'legacy-pass',
      );

      final targetFile = fileNamed('target.sqlite');
      final target = await openRepository(targetFile);
      await target.settingsRepository.setPreferredLocaleTag('fr');
      await target.settingsRepository.setReferenceRateLookupEnabled(true);

      await target.booksCopyRepository.restoreBooksCopy(
        fileContents: legacy,
        passphrase: 'legacy-pass',
        targetFile: targetFile,
      );

      final restored = await openRepository(targetFile);
      expect((await restored.repository.watchEntries().first), hasLength(1));
      expect(
        (await restored.chainVerifier.verifyChain()).isFullyVerified,
        isTrue,
      );
      // Legacy files carry no settings — device books settings stay as they were.
      expect(
        await restored.settingsRepository.preferredLocaleTag(),
        equals('fr'),
      );
      expect(
        await restored.settingsRepository.isReferenceRateLookupEnabled(),
        isTrue,
      );
      await restored.repository.close();
    },
  );

  test(
    'legacy device migration bundle restores books and discards the key',
    () async {
      final sourceFile = fileNamed('source.sqlite');
      final source = await seedRepository(sourceFile);
      await source.repository.close();

      final fakeSeed = List<int>.generate(32, (i) => i + 1);
      final legacy = await encryptLegacyDeviceMigrationBundle(
        databaseBytes: await sourceFile.readAsBytes(),
        privateKeySeed: fakeSeed,
        passphrase: 'bundle-pass',
      );
      expect(legacy, contains('smara-device-migration-bundle'));

      final targetFile = fileNamed('target.sqlite');
      final storage = InMemorySecureKeyStorage();
      final target = await openRepository(targetFile, secureStorage: storage);

      await target.booksCopyRepository.restoreBooksCopy(
        fileContents: legacy,
        passphrase: 'bundle-pass',
        targetFile: targetFile,
      );

      // Key material from the bundle must never land in secure storage.
      expect(storage.writeCount, equals(0));

      final restored = await openRepository(targetFile, secureStorage: storage);
      expect((await restored.repository.watchEntries().first), hasLength(1));
      expect(
        (await restored.chainVerifier.verifyChain()).isFullyVerified,
        isTrue,
      );
      final identity = await restored.identityRepository.currentIdentity();
      expect(identity, isNotNull);
      expect(
        await restored.identityRepository.hasMatchingStoredKey(identity!),
        isFalse,
      );
      await restored.repository.close();
    },
  );

  test('books settings apply only after a successful swap', () async {
    final sourceFile = fileNamed('source.sqlite');
    final source = await seedRepository(sourceFile);
    await source.settingsRepository.setFirstWeekSetupCompleted(true);
    await source.settingsRepository.setSelectedProvider(
      ExchangeRateProvider.openErApi,
    );
    final goodCopy = await source.booksCopyRepository.saveBooksCopy(
      passphrase: 'ok',
      databaseFile: sourceFile,
    );
    await source.repository.close();

    // Build a failing copy by tampering the source after a second seed.
    final badSourceFile = fileNamed('bad-source.sqlite');
    final badSource = await seedRepository(badSourceFile);
    await badSource.repository.close();
    final badDb = AppDatabase.openFile(badSourceFile);
    await badDb.customStatement(
      "UPDATE journal_entries SET entry_hash = "
      "X'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff'",
    );
    await badDb.close();
    final badOpened = await openRepository(badSourceFile);
    final badCopy = await badOpened.booksCopyRepository.saveBooksCopy(
      passphrase: 'ok',
      databaseFile: badSourceFile,
    );
    await badOpened.repository.close();

    final targetFile = fileNamed('target.sqlite');
    final target = await openRepository(targetFile);
    await target.settingsRepository.setFirstWeekSetupCompleted(false);
    await target.settingsRepository.setSelectedProvider(
      ExchangeRateProvider.values.first,
    );

    await expectLater(
      target.booksCopyRepository.restoreBooksCopy(
        fileContents: badCopy,
        passphrase: 'ok',
        targetFile: targetFile,
      ),
      throwsA(isA<InvalidLedgerBackupException>()),
    );
    expect(
      await target.settingsRepository.isFirstWeekSetupCompleted(),
      isFalse,
    );

    await target.booksCopyRepository.restoreBooksCopy(
      fileContents: goodCopy,
      passphrase: 'ok',
      targetFile: targetFile,
    );

    final after = SettingsRepository();
    expect(await after.isFirstWeekSetupCompleted(), isTrue);
    expect(
      await after.selectedProvider(),
      equals(ExchangeRateProvider.openErApi),
    );
  });
}
