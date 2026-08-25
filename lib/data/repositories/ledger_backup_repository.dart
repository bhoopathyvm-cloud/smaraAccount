import 'dart:io';

import 'package:path/path.dart' as p;

import '../../domain/backup/ledger_backup_file.dart';
import '../../domain/crypto/signing_key_service.dart';
import '../../domain/exceptions.dart';
import '../../domain/models/signing_identity.dart';
import '../database/app_database.dart';
import 'ledger_repository.dart';

/// Encrypted export/restore of the whole ledger database file. Split out
/// of `LedgerRepository` (architecture-deepening design.md D1); not a
/// true leaf despite the original review sketch - `restoreLedgerBackup`
/// depends on [LedgerRepository] for [LedgerRepository.currentIdentity]
/// (comparing the device's active identity against the backup's) and
/// constructs its own throwaway [LedgerRepository] (via its own
/// [SigningKeyService], defaulted the same way [LedgerRepository] itself
/// defaults one - this class cannot reach that private field) to validate
/// the backup file before replacing the real database (design.md D2).
class LedgerBackupRepository {
  LedgerBackupRepository({
    required AppDatabase database,
    required LedgerRepository ledgerRepository,
    SigningKeyService? signingKeyService,
  }) : _db = database,
       _ledgerRepository = ledgerRepository,
       _signingKeyService = signingKeyService ?? SigningKeyService();

  final AppDatabase _db;
  final LedgerRepository _ledgerRepository;
  final SigningKeyService _signingKeyService;

  /// Encrypts the raw local database file under [passphrase] and returns
  /// the backup file's contents, ready to write wherever the user chooses.
  /// Includes `signing_identities` (public keys/metadata only - the
  /// private key never leaves OS secure storage and is never part of this
  /// file) alongside every ledger table, so a restored backup can be
  /// fully signature-verified with no private key needed.
  ///
  /// [databaseFile] defaults to the real on-disk database
  /// ([AppDatabase.resolveDatabaseFile]) - overridable so this method is
  /// testable without a platform path_provider plugin available.
  Future<String> exportLedgerBackup({
    required String passphrase,
    File? databaseFile,
  }) async {
    // Flush any writes still only in a WAL/rollback-journal sidecar file
    // into the main database file, so reading that one file below is a
    // complete, self-contained snapshot - harmless (and fast) if the
    // database isn't in WAL mode at all.
    await _db.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
    final file = databaseFile ?? await AppDatabase.resolveDatabaseFile();
    final bytes = await file.readAsBytes();
    return LedgerBackupFile.encrypt(
      databaseBytes: bytes,
      passphrase: passphrase,
    );
  }

  /// Decrypts [fileContents] under [passphrase], validates it opens as a
  /// genuine ledger database with an active signing identity, rejects it
  /// if that identity differs from this device's own active identity
  /// (design.md Decision 4), and - only once every check passes - closes
  /// the database connection and replaces the real database file on disk
  /// with the validated backup.
  ///
  /// After this returns successfully, the [AppDatabase] this repository
  /// (and [LedgerRepository]) wraps is closed and must not be used again -
  /// the caller is responsible for restarting the app so a fresh
  /// connection opens against the replaced file. Throws
  /// [InvalidLedgerBackupException] or [ForeignBackupIdentityException]
  /// (or a [SecretBoxAuthenticationError]/[FormatException] from a wrong
  /// passphrase or non-backup file) without touching the real database
  /// file at all - every failure path is a no-op on disk.
  ///
  /// [targetFile] defaults to the real on-disk database
  /// ([AppDatabase.resolveDatabaseFile]), same testability reasoning as
  /// [exportLedgerBackup]'s [databaseFile] parameter.
  Future<void> restoreLedgerBackup({
    required String fileContents,
    required String passphrase,
    File? targetFile,
  }) async {
    final decryptedBytes = await LedgerBackupFile.decrypt(
      fileContents: fileContents,
      passphrase: passphrase,
    );

    // Directory.systemTemp is pure `dart:io` (no path_provider platform
    // channel needed) - appropriate here since this file is an internal
    // scratch copy for validation only, never user-facing.
    final tempFile = File(
      p.join(
        Directory.systemTemp.path,
        'smara-backup-validate-${DateTime.now().microsecondsSinceEpoch}.sqlite',
      ),
    );
    await tempFile.writeAsBytes(decryptedBytes);

    late final SigningIdentity backupIdentity;
    try {
      final backupDb = AppDatabase.openFile(tempFile);
      try {
        final backupRepository = LedgerRepository(
          database: backupDb,
          signingKeyService: _signingKeyService,
        );
        final identity = await backupRepository.currentIdentity();
        if (identity == null) {
          throw InvalidLedgerBackupException(
            'This backup has no signing identity - it is not a valid '
            'Smara backup.',
            code: AppErrorCode.invalidLedgerBackupNoIdentity,
          );
        }
        backupIdentity = identity;
        final verification = await backupRepository.verifyChain();
        if (!verification.isFullyVerified) {
          throw InvalidLedgerBackupException(
            'This backup did not verify as intact books, so it was not '
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
        'This file could not be opened as a Smara backup: $e',
        code: AppErrorCode.invalidLedgerBackupUnreadable,
      );
    }

    final deviceIdentity = await _ledgerRepository.currentIdentity();
    if (deviceIdentity != null &&
        !_bytesEqual(deviceIdentity.publicKey, backupIdentity.publicKey)) {
      await tempFile.delete();
      throw ForeignBackupIdentityException(
        'This backup belongs to a different signing identity than the one '
        'already set up on this device. Restoring it would combine two '
        "different identities' books, not restore your own.",
      );
    }

    final resolvedTargetFile =
        targetFile ?? await AppDatabase.resolveDatabaseFile();
    await _db.close();
    await tempFile.copy(resolvedTargetFile.path);
    await tempFile.delete();
    // A fresh connection on next launch should never try to replay a
    // stale WAL/rollback-journal sidecar left over from the *previous*
    // database file at this same path.
    for (final suffix in ['-wal', '-shm', '-journal']) {
      final sidecar = File('${resolvedTargetFile.path}$suffix');
      if (await sidecar.exists()) await sidecar.delete();
    }
  }
}

bool _bytesEqual(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
