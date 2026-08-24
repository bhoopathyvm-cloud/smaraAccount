import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:smara_accounting/data/database/app_database.dart';
import 'package:smara_accounting/data/repositories/account_repository.dart';
import 'package:smara_accounting/data/repositories/ledger_repository.dart';
import 'package:smara_accounting/domain/crypto/signing_key_service.dart';
import 'package:smara_accounting/domain/exceptions.dart';
import 'package:smara_accounting/domain/models/transaction_direction.dart';
import 'package:test/test.dart';

import '../../domain/crypto/in_memory_secure_key_storage.dart';

/// Exercises real file-backed databases (not `NativeDatabase.memory()`,
/// which every other repository test uses) - export/restore's whole point
/// is operating on the on-disk database file, so a real temp file is the
/// only way to test it honestly.
void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('smara-backup-test-');
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  File fileNamed(String name) => File(p.join(tempDir.path, name));

  Future<({LedgerRepository repository, AccountRepository accountRepository})>
  openRepository(File file) async {
    final db = AppDatabase.openFile(file);
    final repository = LedgerRepository(
      database: db,
      signingKeyService: SigningKeyService(
        secureStorage: InMemorySecureKeyStorage(),
      ),
    );
    return (
      repository: repository,
      accountRepository: AccountRepository(
        database: db,
        ledgerRepository: repository,
      ),
    );
  }

  Future<({LedgerRepository repository, AccountRepository accountRepository})>
  seedRepository(File file) async {
    final opened = await openRepository(file);
    final repository = opened.repository;
    final generated = await repository.generateFirstIdentity();
    await repository.confirmFirstIdentity(generated, currency: 'USD');
    final account =
        (await opened.accountRepository.watchFinancialAccounts().first).first;
    final category = (await repository.watchCategories().first).first;
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
    'export then restore onto a fresh device reproduces the exact ledger '
    'state, fully verified, but not writable until the key is also restored',
    () async {
      final sourceFile = fileNamed('source.sqlite');
      final source = (await seedRepository(sourceFile)).repository;

      final backupContents = await source.exportLedgerBackup(
        passphrase: 'correct horse battery staple',
        databaseFile: sourceFile,
      );
      await source.close();

      final targetFile = fileNamed('target.sqlite');
      final freshDevice = (await openRepository(targetFile)).repository;
      await freshDevice.restoreLedgerBackup(
        fileContents: backupContents,
        passphrase: 'correct horse battery staple',
        targetFile: targetFile,
      );
      // freshDevice's connection is now closed by restoreLedgerBackup -
      // open a brand new one against the replaced file, exactly as the
      // app would do on the next launch.

      final restoredOpened = await openRepository(targetFile);
      final restored = restoredOpened.repository;
      final entries = await restored
          .watchEntriesForAccount(
            (await restoredOpened.accountRepository
                    .watchFinancialAccounts()
                    .first)
                .first
                .id,
          )
          .first;
      expect(entries, hasLength(1));
      expect(entries.single.postings, hasLength(2));

      final verification = await restored.verifyChain();
      expect(verification.isFullyVerified, isTrue);

      // No matching private key was restored on this "device" - only the
      // ledger backup was. Reading/verifying works; recording does not.
      final account =
          (await restoredOpened.accountRepository
                  .watchFinancialAccounts()
                  .first)
              .first;
      final category = (await restored.watchCategories().first).first;
      await expectLater(
        restored.recordTransaction(
          amountMinor: 100,
          direction: TransactionDirection.moneyOut,
          categoryId: category.id,
          financialAccountId: account.id,
          transactionDate: DateTime(2026, 1, 2),
        ),
        throwsStateError,
      );
    },
  );

  test(
    'restore is rejected when the backup identity differs from the '
    "device's own active identity, and the target file is left untouched",
    () async {
      final sourceFile = fileNamed('source.sqlite');
      final source = (await seedRepository(sourceFile)).repository;
      final backupContents = await source.exportLedgerBackup(
        passphrase: 'passphrase-a',
        databaseFile: sourceFile,
      );
      await source.close();

      final targetFile = fileNamed('target.sqlite');
      final alreadySetUp = (await seedRepository(targetFile)).repository;
      final targetBytesBefore = await targetFile.readAsBytes();

      await expectLater(
        alreadySetUp.restoreLedgerBackup(
          fileContents: backupContents,
          passphrase: 'passphrase-a',
          targetFile: targetFile,
        ),
        throwsA(isA<ForeignBackupIdentityException>()),
      );

      final targetBytesAfter = await targetFile.readAsBytes();
      expect(targetBytesAfter, equals(targetBytesBefore));
    },
  );

  test('restore fails cleanly on the wrong passphrase, with no partial '
      'replacement', () async {
    final sourceFile = fileNamed('source.sqlite');
    final source = (await seedRepository(sourceFile)).repository;
    final backupContents = await source.exportLedgerBackup(
      passphrase: 'the-real-passphrase',
      databaseFile: sourceFile,
    );
    await source.close();

    final targetFile = fileNamed('target.sqlite');
    final freshDevice = (await openRepository(targetFile)).repository;

    await expectLater(
      freshDevice.restoreLedgerBackup(
        fileContents: backupContents,
        passphrase: 'a-wrong-passphrase',
        targetFile: targetFile,
      ),
      throwsA(anything),
    );

    // Nothing was ever written to targetFile - it's still whatever
    // onCreate produced for a never-restored fresh database (no
    // signing identity of its own).
    final stillFresh = (await openRepository(targetFile)).repository;
    expect(await stillFresh.currentIdentity(), isNull);
  });

  test('restore is rejected when the backup chain does not fully verify, '
      'and the target file is left untouched', () async {
    final sourceFile = fileNamed('source.sqlite');
    final source = (await seedRepository(sourceFile)).repository;
    await source.close();

    final tamperDb = AppDatabase.openFile(sourceFile);
    await tamperDb.customStatement(
      "UPDATE journal_entries SET entry_hash = "
      "X'0000000000000000000000000000000000000000000000000000000000000000'",
    );
    await tamperDb.close();

    final tampered = (await openRepository(sourceFile)).repository;
    final backupContents = await tampered.exportLedgerBackup(
      passphrase: 'passphrase-a',
      databaseFile: sourceFile,
    );
    await tampered.close();

    final targetFile = fileNamed('target.sqlite');
    final alreadySetUp = (await seedRepository(targetFile)).repository;
    final targetBytesBefore = await targetFile.readAsBytes();

    await expectLater(
      alreadySetUp.restoreLedgerBackup(
        fileContents: backupContents,
        passphrase: 'passphrase-a',
        targetFile: targetFile,
      ),
      throwsA(isA<InvalidLedgerBackupException>()),
    );

    final targetBytesAfter = await targetFile.readAsBytes();
    expect(targetBytesAfter, equals(targetBytesBefore));
  });

  test('exportLedgerBackup never includes the private key material', () async {
    final sourceFile = fileNamed('source.sqlite');
    final source = (await seedRepository(sourceFile)).repository;
    final backupContents = await source.exportLedgerBackup(
      passphrase: 'p',
      databaseFile: sourceFile,
    );
    await source.close();

    // The backup's ciphertext is opaque without the passphrase, but the
    // JSON envelope around it must never itself carry key material -
    // only the fields the format defines.
    expect(backupContents, isNot(contains('privateKey')));
    expect(backupContents, isNot(contains('seed')));
  });
}
