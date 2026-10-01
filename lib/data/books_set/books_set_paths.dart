import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../domain/crypto/secure_key_storage.dart';
import '../../domain/crypto/signing_key_service.dart';

/// Device-local pointer to the active books set. Does not sync and does not
/// travel in a Books Copy of another set (linked-devices design Decision 4).
class BooksSetStore {
  BooksSetStore({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const activeBooksSetIdKey = 'activeBooksSetId';

  final SharedPreferencesAsync _preferences;

  Future<String?> activeBooksSetId() =>
      _preferences.getString(activeBooksSetIdKey);

  Future<void> setActiveBooksSetId(String id) =>
      _preferences.setString(activeBooksSetIdKey, id);

  Future<void> clearActiveBooksSetId() =>
      _preferences.remove(activeBooksSetIdKey);
}

/// On-disk layout helpers for one-SQLite-file-per-books-set.
///
/// Path pattern under the app support directory:
/// `books/<booksSetId>/ledger.sqlite` (+ WAL/SHM sidecars).
class BooksSetPaths {
  BooksSetPaths._();

  static const booksDirectoryName = 'books';
  static const databaseFileName = 'ledger.sqlite';
  static const legacyDatabaseFileName = 'smara_accounting.sqlite';
  static const receiptsDirectoryName = 'receipts';

  /// Root directory that holds one subdirectory per books set.
  static Directory booksRoot(Directory supportDirectory) =>
      Directory(p.join(supportDirectory.path, booksDirectoryName));

  /// Directory for a single books set.
  static Directory booksSetDirectory(
    Directory supportDirectory,
    String booksSetId,
  ) => Directory(p.join(booksRoot(supportDirectory).path, booksSetId));

  /// SQLite file for a books set.
  static File databaseFile(Directory supportDirectory, String booksSetId) =>
      File(
        p.join(
          booksSetDirectory(supportDirectory, booksSetId).path,
          databaseFileName,
        ),
      );

  /// Directory for Claim receipt blobs: `books/<id>/receipts/`.
  static Directory receiptsDirectory(
    Directory supportDirectory,
    String booksSetId,
  ) => Directory(
    p.join(
      booksSetDirectory(supportDirectory, booksSetId).path,
      receiptsDirectoryName,
    ),
  );

  /// File path for one receipt blob: `books/<id>/receipts/<receiptId>`.
  static File receiptFile(
    Directory supportDirectory,
    String booksSetId,
    String receiptId,
  ) => File(
    p.join(receiptsDirectory(supportDirectory, booksSetId).path, receiptId),
  );

  static Future<Directory> ensureReceiptsDirectory(
    Directory supportDirectory,
    String booksSetId,
  ) async {
    final dir = receiptsDirectory(supportDirectory, booksSetId);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Legacy single-file path used before linked-devices multi-set layout.
  static File legacyDatabaseFile(Directory supportDirectory) =>
      File(p.join(supportDirectory.path, legacyDatabaseFileName));

  static Future<Directory> ensureBooksSetDirectory(
    Directory supportDirectory,
    String booksSetId,
  ) async {
    final dir = booksSetDirectory(supportDirectory, booksSetId);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Lists books-set ids that already have a directory under `books/`.
  static Future<List<String>> listBooksSetIds(
    Directory supportDirectory,
  ) async {
    final root = booksRoot(supportDirectory);
    if (!await root.exists()) return const [];
    final ids = <String>[];
    await for (final entity in root.list()) {
      if (entity is Directory) {
        ids.add(p.basename(entity.path));
      }
    }
    ids.sort();
    return ids;
  }

  /// Deletes a books set's directory (database + WAL/SHM). Does not touch
  /// other sets or SharedPreferences.
  static Future<void> deleteBooksSetDirectory(
    Directory supportDirectory,
    String booksSetId,
  ) async {
    final dir = booksSetDirectory(supportDirectory, booksSetId);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  /// Moves a pre-multi-set install into `books/<id>/` and namespaces the
  /// signing key. Idempotent when [BooksSetStore.activeBooksSetId] is already
  /// set or the legacy file is absent.
  ///
  /// Returns the books-set id that became active, or null when nothing needed
  /// migrating (fresh install with no legacy file and no active id yet).
  static Future<String?> migrateLegacyLayoutIfNeeded({
    required Directory supportDirectory,
    required BooksSetStore store,
    SecureKeyStorage? secureStorage,
    String? Function()? newId,
  }) async {
    final existingActive = await store.activeBooksSetId();
    if (existingActive != null) {
      await ensureBooksSetDirectory(supportDirectory, existingActive);
      return existingActive;
    }

    final legacy = legacyDatabaseFile(supportDirectory);
    final legacyWal = File('${legacy.path}-wal');
    final legacyShm = File('${legacy.path}-shm');

    if (!await legacy.exists()) {
      return null;
    }

    final id = newId?.call() ?? const Uuid().v4();
    await ensureBooksSetDirectory(supportDirectory, id);
    final dest = databaseFile(supportDirectory, id);
    await legacy.rename(dest.path);
    if (await legacyWal.exists()) {
      await legacyWal.rename('${dest.path}-wal');
    }
    if (await legacyShm.exists()) {
      await legacyShm.rename('${dest.path}-shm');
    }
    await store.setActiveBooksSetId(id);

    if (secureStorage != null) {
      await SigningKeyService.migrateLegacyKeyToBooksSet(
        secureStorage: secureStorage,
        booksSetId: id,
      );
    }
    return id;
  }
}
