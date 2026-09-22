import 'dart:io';

import 'package:path/path.dart' as p;

import '../../domain/backup/device_migration_bundle_file.dart';
import '../../domain/crypto/ed25519_signing.dart';
import '../../domain/crypto/signing_key_service.dart';
import '../../domain/exceptions.dart';
import '../../domain/models/signing_identity.dart';
import '../database/app_database.dart';
import 'identity_repository.dart';
import 'ledger_chain_verifier.dart';
import 'repository_date_utils.dart';

/// Encrypted export/import of the raw ledger database together with the
/// private key seed, for moving to a new device in one step (spec:
/// `device-migration-bundle`). Mirrors [LedgerBackupRepository]'s
/// validate-before-replace pattern (construct a throwaway
/// [IdentityRepository]/[LedgerChainVerifier] over a temp-file copy,
/// never touching the real database until every check passes), but also
/// restores the private key - never included in a data-only
/// `ledger-backup` export - so the device can record a new entry
/// immediately with no separate key-restore step.
class DeviceMigrationBundleRepository {
  DeviceMigrationBundleRepository({
    required AppDatabase database,
    required IdentityRepository identityRepository,
    SigningKeyService? signingKeyService,
    Ed25519Signing? signer,
  }) : _db = database,
       _identityRepository = identityRepository,
       _signingKeyService = signingKeyService ?? SigningKeyService(),
       _signer = signer ?? const Ed25519Signing();

  final AppDatabase _db;
  final IdentityRepository _identityRepository;
  final SigningKeyService _signingKeyService;
  final Ed25519Signing _signer;

  /// Encrypts the raw local database file together with the currently
  /// stored private key under [passphrase]. See
  /// [LedgerBackupRepository.exportLedgerBackup] for the
  /// WAL-checkpoint/file-read rationale, which this mirrors exactly.
  ///
  /// [databaseFile] defaults to the real on-disk database
  /// ([AppDatabase.resolveDatabaseFile]) - overridable so this method is
  /// testable without a platform path_provider plugin available.
  Future<String> exportBundle({
    required String passphrase,
    File? databaseFile,
  }) async {
    await _db.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
    final file = databaseFile ?? await AppDatabase.resolveDatabaseFile();
    final bytes = await file.readAsBytes();
    return _identityRepository.exportDeviceMigrationBundle(
      databaseBytes: bytes,
      passphrase: passphrase,
    );
  }

  /// Decrypts [fileContents] under [passphrase], validates that its
  /// database and key agree with each other and verify as intact books,
  /// rejects it if its identity differs from this device's own active
  /// identity, and - only once every check passes - replaces the real
  /// database file and stores the private key, so the device is ready to
  /// record a new entry immediately. Throws
  /// [InvalidDeviceMigrationBundleException] or
  /// [ForeignDeviceMigrationBundleIdentityException] (or a
  /// [SecretBoxAuthenticationError]/[FormatException] from a wrong
  /// passphrase or non-bundle file) without touching the real database
  /// file or the stored private key at all - every failure path is a
  /// no-op on disk.
  ///
  /// After this returns successfully, the [AppDatabase] this repository
  /// wraps is closed and must not be used again - the caller is
  /// responsible for restarting the app so a fresh connection opens
  /// against the replaced file, same as
  /// [LedgerBackupRepository.restoreLedgerBackup].
  ///
  /// [targetFile] defaults to the real on-disk database
  /// ([AppDatabase.resolveDatabaseFile]), same testability reasoning as
  /// [exportBundle]'s [databaseFile] parameter.
  Future<void> importBundle({
    required String fileContents,
    required String passphrase,
    File? targetFile,
  }) async {
    final bundle = await DeviceMigrationBundleFile.decrypt(
      fileContents: fileContents,
      passphrase: passphrase,
    );

    // Directory.systemTemp is pure `dart:io` (no path_provider platform
    // channel needed) - appropriate here since this file is an internal
    // scratch copy for validation only, never user-facing.
    final tempFile = File(
      p.join(
        Directory.systemTemp.path,
        'smara-bundle-validate-${DateTime.now().microsecondsSinceEpoch}.sqlite',
      ),
    );
    await tempFile.writeAsBytes(bundle.databaseBytes);

    late final SigningIdentity bundleIdentity;
    try {
      final bundleDb = AppDatabase.openFile(tempFile);
      try {
        final bundleRepository = IdentityRepository(
          database: bundleDb,
          signingKeyService: _signingKeyService,
        );
        final identity = await bundleRepository.currentIdentity();
        if (identity == null) {
          throw InvalidDeviceMigrationBundleException(
            'This bundle has no signing identity - it is not a valid '
            'Smara device migration bundle.',
            code: AppErrorCode.invalidDeviceMigrationBundleNoIdentity,
          );
        }
        final derivedKey = await _signer.keyPairFromSeed(bundle.privateKeySeed);
        if (!bytesEqual(derivedKey.publicKey, identity.publicKey)) {
          throw InvalidDeviceMigrationBundleException(
            "This bundle's key does not match its own database - it is "
            'not a valid Smara device migration bundle.',
            code: AppErrorCode.invalidDeviceMigrationBundleNoIdentity,
          );
        }
        bundleIdentity = identity;
        final verification = await LedgerChainVerifier(
          database: bundleDb,
          signingKeyService: _signingKeyService,
        ).verifyChain();
        if (!verification.isFullyVerified) {
          throw InvalidDeviceMigrationBundleException(
            'This bundle did not verify as intact books, so it was not '
            'imported.',
            code: AppErrorCode.invalidDeviceMigrationBundleUnverified,
          );
        }
      } finally {
        await bundleDb.close();
      }
    } on InvalidDeviceMigrationBundleException {
      await tempFile.delete();
      rethrow;
    } catch (e) {
      await tempFile.delete();
      throw InvalidDeviceMigrationBundleException(
        'This file could not be opened as a Smara device migration '
        'bundle: $e',
        code: AppErrorCode.invalidDeviceMigrationBundleUnreadable,
      );
    }

    final deviceIdentity = await _identityRepository.currentIdentity();
    if (deviceIdentity != null &&
        !bytesEqual(deviceIdentity.publicKey, bundleIdentity.publicKey)) {
      await tempFile.delete();
      throw ForeignDeviceMigrationBundleIdentityException(
        'This bundle belongs to a different signing identity than the '
        'one already set up on this device. Importing it would combine '
        "two different identities' books, not restore your own.",
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

    await _identityRepository.adoptPrivateKeySeed(bundle.privateKeySeed);
  }
}
