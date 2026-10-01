import 'dart:io';

import 'package:path/path.dart' as p;

import '../../domain/backup/books_copy_file.dart';
import '../../domain/crypto/signing_key_service.dart';
import '../../domain/exceptions.dart';
import '../database/app_database.dart';
import 'identity_repository.dart';
import 'ledger_chain_verifier.dart';
import 'settings_repository.dart';

/// Counts of what a restore will replace on this device (zero counts are
/// omitted by callers when presenting the warning).
class BooksReplacementCounts {
  const BooksReplacementCounts({
    required this.entries,
    required this.financialAccounts,
    required this.categories,
    required this.userAccountGroups,
    required this.payees,
    required this.categoryRules,
    required this.csvImportProfiles,
    required this.recurringTemplates,
    required this.instruments,
  });

  final int entries;
  final int financialAccounts;
  final int categories;
  final int userAccountGroups;
  final int payees;
  final int categoryRules;
  final int csvImportProfiles;
  final int recurringTemplates;
  final int instruments;

  Map<String, int> get nonZero {
    final all = <String, int>{
      'entries': entries,
      'financialAccounts': financialAccounts,
      'categories': categories,
      'userAccountGroups': userAccountGroups,
      'payees': payees,
      'categoryRules': categoryRules,
      'csvImportProfiles': csvImportProfiles,
      'recurringTemplates': recurringTemplates,
      'instruments': instruments,
    };
    return {
      for (final entry in all.entries)
        if (entry.value > 0) entry.key: entry.value,
    };
  }
}

/// Encrypted save/restore of the whole ledger database file plus books
/// settings (books-copy-and-continuation). Replaces
/// [LedgerBackupRepository] and [DeviceMigrationBundleRepository].
class BooksCopyRepository {
  BooksCopyRepository({
    required AppDatabase database,
    required IdentityRepository identityRepository,
    required SettingsRepository settingsRepository,
    SigningKeyService? signingKeyService,
  }) : _db = database,
       _identityRepository = identityRepository,
       _settingsRepository = settingsRepository,
       _signingKeyService = signingKeyService ?? SigningKeyService();

  final AppDatabase _db;
  final IdentityRepository _identityRepository;
  final SettingsRepository _settingsRepository;
  final SigningKeyService _signingKeyService;

  /// Encrypts the raw local database file and books settings under
  /// [passphrase]. Records last-copy time and entry count for the reminder.
  Future<String> saveBooksCopy({
    required String passphrase,
    File? databaseFile,
    DateTime? now,
  }) async {
    await _db.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
    final file = databaseFile ?? await AppDatabase.resolveDatabaseFile();
    final bytes = await file.readAsBytes();
    final settings = await _settingsRepository.exportBooksSettings();
    final encoded = await BooksCopyFile.encrypt(
      databaseBytes: bytes,
      settings: settings,
      passphrase: passphrase,
    );
    final entryCount = await _countRows(_db.journalEntries.actualTableName);
    await _settingsRepository.recordBooksCopySaved(
      at: now ?? DateTime.now(),
      entryCount: entryCount,
    );
    return encoded;
  }

  /// Counts of current-device data that a restore will replace.
  Future<BooksReplacementCounts> replacementCounts() async {
    return BooksReplacementCounts(
      entries: await _countRows(_db.journalEntries.actualTableName),
      financialAccounts: await _countFinancialAccounts(),
      categories: await _countCategories(),
      userAccountGroups: await _countUserAccountGroups(),
      payees: await _countRows(_db.payees.actualTableName),
      categoryRules: await _countRows(_db.categoryRules.actualTableName),
      csvImportProfiles: await _countRows(
        _db.csvImportProfiles.actualTableName,
      ),
      recurringTemplates: await _countRows(
        _db.recurringTemplates.actualTableName,
      ),
      instruments: await _countRows(_db.instruments.actualTableName),
    );
  }

  /// Decrypts, verifies, replaces the on-disk database, applies books
  /// settings, and deletes any orphaned private key. Never merges; never
  /// rejects a foreign identity. On verification failure the device is
  /// untouched.
  Future<void> restoreBooksCopy({
    required String fileContents,
    required String passphrase,
    File? targetFile,
  }) async {
    final contents = await BooksCopyFile.decrypt(
      fileContents: fileContents,
      passphrase: passphrase,
    );

    final tempFile = File(
      p.join(
        Directory.systemTemp.path,
        'smara-books-copy-validate-'
        '${DateTime.now().microsecondsSinceEpoch}.sqlite',
      ),
    );
    await tempFile.writeAsBytes(contents.databaseBytes);

    try {
      final backupDb = AppDatabase.openFile(tempFile);
      try {
        final backupIdentity = IdentityRepository(
          database: backupDb,
          signingKeyService: _signingKeyService,
        );
        final identity = await backupIdentity.currentIdentity();
        if (identity == null) {
          throw InvalidLedgerBackupException(
            'This copy has no signing identity - it is not a valid '
            'Smara books copy.',
            code: AppErrorCode.invalidLedgerBackupNoIdentity,
          );
        }
        final verification = await LedgerChainVerifier(
          database: backupDb,
          signingKeyService: _signingKeyService,
        ).verifyChain();
        if (!verification.isFullyVerified) {
          throw InvalidLedgerBackupException(
            'This copy did not verify as intact books, so it was not '
            'restored.',
            code: AppErrorCode.invalidLedgerBackupUnverified,
          );
        }
      } finally {
        await backupDb.close();
      }
    } on InvalidLedgerBackupException {
      await tempFile.delete();
      rethrow;
    } catch (e) {
      await tempFile.delete();
      throw InvalidLedgerBackupException(
        'This file could not be opened as a Smara books copy: $e',
        code: AppErrorCode.invalidLedgerBackupUnreadable,
      );
    }

    final resolvedTargetFile =
        targetFile ?? await AppDatabase.resolveDatabaseFile();
    await _db.close();
    await tempFile.copy(resolvedTargetFile.path);
    await tempFile.delete();
    for (final suffix in ['-wal', '-shm', '-journal']) {
      final sidecar = File('${resolvedTargetFile.path}$suffix');
      if (await sidecar.exists()) await sidecar.delete();
    }

    // Settings apply only after a successful swap (design Decision 2).
    if (contents.settings.isNotEmpty) {
      await _settingsRepository.importBooksSettings(contents.settings);
    }
    await _identityRepository.deleteStoredKey();
  }

  Future<int> _countRows(String tableName) async {
    final row = await _db
        .customSelect('SELECT COUNT(*) AS c FROM $tableName')
        .getSingle();
    return row.data['c'] as int;
  }

  Future<int> _countFinancialAccounts() async {
    final row = await _db
        .customSelect(
          "SELECT COUNT(*) AS c FROM accounts WHERE type IN "
          "('asset', 'liability')",
        )
        .getSingle();
    return row.data['c'] as int;
  }

  Future<int> _countCategories() async {
    final row = await _db
        .customSelect(
          "SELECT COUNT(*) AS c FROM accounts WHERE type IN "
          "('income', 'expense')",
        )
        .getSingle();
    return row.data['c'] as int;
  }

  Future<int> _countUserAccountGroups() async {
    final row = await _db
        .customSelect(
          'SELECT COUNT(*) AS c FROM account_groups WHERE is_system = 0',
        )
        .getSingle();
    return row.data['c'] as int;
  }
}
